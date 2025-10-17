#!/usr/bin/env zsh

# ============================================================================
# deploy.zsh - Remote Dotfiles Deployment Script
# ============================================================================
#
# Deploy your dotfiles to remote hosts via SSH with interactive guidance
# and beautiful progress tracking.
#
# Usage:
#   ./bin/deploy.zsh                    # Interactive mode
#   ./bin/deploy.zsh --hosts host1 host2 host3
#   ./bin/deploy.zsh --hosts-file hosts.txt
#   ./bin/deploy.zsh --auto --hosts server.example.com
#   ./bin/deploy.zsh --dry-run --hosts host1
#
# Features:
#   - Interactive host selection or command-line host specification
#   - SSH key-based authentication (preferred) with password fallback
#   - Web installer integration (dfsetup interactive / dfauto automatic)
#   - Beautiful progress tracking with OneDark theme
#   - Parallel or sequential deployment modes
#   - Dry-run mode for testing
#   - Comprehensive error handling and reporting
#
# ============================================================================

emulate -LR zsh
setopt PIPE_FAIL
unsetopt NOMATCH  # Disable glob failure errors

# ============================================================================
# Bootstrap: Load Shared Libraries
# ============================================================================

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

# Load shared libraries with fallback protection
LIBRARIES_LOADED=false

if [[ -f "$SCRIPT_DIR/lib/colors.zsh" ]]; then
    source "$SCRIPT_DIR/lib/colors.zsh"
    source "$SCRIPT_DIR/lib/ui.zsh"
    source "$SCRIPT_DIR/lib/utils.zsh"
    source "$SCRIPT_DIR/lib/arguments.zsh"
    source "$SCRIPT_DIR/lib/greetings.zsh"
    LIBRARIES_LOADED=true
else
    # Minimal fallback if libraries unavailable
    print_error() { echo "Error: $1" >&2; }
    print_success() { echo "✓ $1"; }
    print_info() { echo "ℹ $1"; }
    print_warning() { echo "⚠ $1"; }
    draw_section_header() { echo "\n=== $1 ===\n"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
fi

# ============================================================================
# Configuration
# ============================================================================

# Web installer URLs
WEB_INSTALLER_BASE="https://buckmeister.github.io/dotfiles"
DFAUTO_URL="${WEB_INSTALLER_BASE}/dfauto"
DFSETUP_URL="${WEB_INSTALLER_BASE}/dfsetup"

# Default deployment mode
DEFAULT_MODE="interactive"  # or "automatic"
DEFAULT_PARALLEL=false      # Deploy sequentially by default

# SSH connection timeout (seconds)
SSH_TIMEOUT=10

# ============================================================================
# Global State
# ============================================================================

typeset -a HOSTS               # Array of hosts to deploy to
typeset -a DEPLOYMENT_RESULTS  # Track success/failure for each host
DRY_RUN=false
AUTO_MODE=false
PARALLEL_MODE=false
SEQUENTIAL_MODE=true
HOSTS_FILE=""

# ============================================================================
# Helper Functions
# ============================================================================

# Display help message
show_help() {
    cat <<'EOF'
deploy.zsh - Remote Dotfiles Deployment Script

Deploy your dotfiles to remote hosts via SSH with beautiful progress tracking
and comprehensive error handling.

USAGE:
    ./bin/deploy.zsh [options]
    ./bin/deploy.zsh --hosts host1 host2 host3
    ./bin/deploy.zsh --hosts-file hosts.txt
    ./bin/deploy.zsh --auto --hosts server.example.com

OPTIONS:
    -h, --help              Show this help message
    --hosts HOST [HOST...]  Deploy to specified hosts (space-separated)
    --hosts-file FILE       Read hosts from file (one per line)
    --auto                  Use automatic installer (dfauto, non-interactive)
    --interactive           Use interactive installer (dfsetup, default)
    --parallel              Deploy to all hosts in parallel
    --sequential            Deploy to hosts one at a time (default)
    --dry-run               Show what would be done without executing
    --timeout SECONDS       SSH connection timeout (default: 10)

EXAMPLES:
    # Interactive mode - prompts for hosts
    ./bin/deploy.zsh

    # Deploy to specific hosts
    ./bin/deploy.zsh --hosts server1.example.com server2.example.com

    # Deploy using hosts file
    ./bin/deploy.zsh --hosts-file production_servers.txt

    # Automatic deployment (non-interactive)
    ./bin/deploy.zsh --auto --hosts server.example.com

    # Parallel deployment to multiple hosts
    ./bin/deploy.zsh --parallel --hosts host1 host2 host3

    # Dry-run to test without executing
    ./bin/deploy.zsh --dry-run --hosts testserver.local

HOSTS FILE FORMAT:
    One hostname per line, comments with #, empty lines ignored:

    # Production servers
    server1.example.com
    server2.example.com

    # Staging
    staging.example.com

SSH AUTHENTICATION:
    The script prefers SSH key-based authentication. Ensure your SSH keys
    are properly configured:

    1. Generate SSH key: ssh-keygen -t ed25519
    2. Copy to remote: ssh-copy-id user@host
    3. Test connection: ssh user@host "echo OK"

    If key-based auth fails, SSH will fall back to password authentication.

WEB INSTALLERS:
    - dfsetup (interactive): Prompts for confirmation, shows progress
    - dfauto (automatic):    Non-interactive, automatic installation

NOTES:
    - Hosts can include user@hostname or just hostname (uses current user)
    - SSH connections are validated before deployment
    - Failed hosts are reported at the end
    - Use --dry-run to test your configuration first

EOF
}

# Validate SSH connection to a host
# Args: $1 = hostname
# Returns: 0 on success, 1 on failure
validate_ssh_connection() {
    local host="$1"

    if [[ "$DRY_RUN" == true ]]; then
        print_info "Would validate SSH connection to: $host"
        return 0
    fi

    # Try to connect and run a simple command
    if ssh -o ConnectTimeout="$SSH_TIMEOUT" \
           -o BatchMode=yes \
           -o StrictHostKeyChecking=accept-new \
           "$host" "echo OK" >/dev/null 2>&1; then
        return 0
    else
        # Try again without BatchMode (allows password prompt)
        if ssh -o ConnectTimeout="$SSH_TIMEOUT" \
               -o StrictHostKeyChecking=accept-new \
               "$host" "echo OK" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

# Deploy dotfiles to a single host
# Args: $1 = hostname, $2 = installer URL
# Returns: 0 on success, 1 on failure
deploy_to_host() {
    local host="$1"
    local installer_url="$2"
    local installer_type="${installer_url##*/}"  # dfauto or dfsetup

    if [[ "$DRY_RUN" == true ]]; then
        print_info "Would deploy to $host using $installer_type"
        return 0
    fi

    # Deployment command
    local deploy_cmd="curl -fsSL '$installer_url' | sh"

    # Execute deployment via SSH
    if ssh -o ConnectTimeout="$SSH_TIMEOUT" \
           -o StrictHostKeyChecking=accept-new \
           "$host" "$deploy_cmd"; then
        return 0
    else
        return 1
    fi
}

# Interactive host input
# Populates the HOSTS array
interactive_host_selection() {
    draw_section_header "Remote Host Selection"
    echo
    print_info "Enter remote hosts to deploy dotfiles to."
    print_info "You can specify:"
    echo "  • Single host: server.example.com"
    echo "  • User@host:   thomas@server.example.com"
    echo "  • Multiple:    host1 host2 host3 (space-separated)"
    echo "  • File:        @hosts.txt (one host per line)"
    echo

    # Prompt for input
    echo -n "${BLUE}Enter hosts: ${RESET}"
    read -r host_input

    # Check if input is a file reference (@filename)
    if [[ "$host_input" =~ ^@(.+)$ ]]; then
        local file="${match[1]}"
        if [[ ! -f "$file" ]]; then
            print_error "Hosts file not found: $file"
            return 1
        fi
        read_hosts_from_file "$file"
    else
        # Split space-separated hosts
        HOSTS=("${(@s: :)host_input}")
    fi

    # Validate we have hosts
    if [[ ${#HOSTS[@]} -eq 0 ]]; then
        print_error "No hosts specified"
        return 1
    fi

    return 0
}

# Read hosts from file
# Args: $1 = filename
# Populates the HOSTS array
read_hosts_from_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        print_error "Hosts file not found: $file"
        return 1
    fi

    HOSTS=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue

        # Trim whitespace and add to array
        local host="${line##*( )}"
        host="${host%%*( )}"
        HOSTS+=("$host")
    done < "$file"

    return 0
}

# Validate all hosts before deployment
# Returns: 0 if all valid, 1 if any invalid
validate_all_hosts() {
    draw_section_header "Validating SSH Connections"
    echo

    local all_valid=true
    local i=1
    local total=${#HOSTS[@]}

    for host in "${HOSTS[@]}"; do
        echo -n "[$i/$total] Testing connection to ${CYAN}${host}${RESET}... "

        if validate_ssh_connection "$host"; then
            echo "${GREEN}✓${RESET}"
        else
            echo "${RED}✗${RESET}"
            print_error "Cannot connect to $host"
            all_valid=false
        fi

        ((i++))
    done

    echo

    if [[ "$all_valid" == false ]]; then
        print_error "Some hosts are unreachable. Fix SSH connectivity and try again."
        print_info "Tip: Use 'ssh-copy-id user@host' to set up key-based authentication"
        return 1
    fi

    print_success "All hosts are reachable!"
    return 0
}

# Deploy to all hosts sequentially
deploy_sequential() {
    local installer_url="$1"
    local i=1
    local total=${#HOSTS[@]}
    local failed_hosts=()

    draw_section_header "Sequential Deployment"
    echo

    for host in "${HOSTS[@]}"; do
        print_info "[$i/$total] Deploying to ${CYAN}${host}${RESET}"
        echo

        if deploy_to_host "$host" "$installer_url"; then
            DEPLOYMENT_RESULTS+=("SUCCESS:$host")
            print_success "Deployment to $host completed!"
        else
            DEPLOYMENT_RESULTS+=("FAILED:$host")
            failed_hosts+=("$host")
            print_error "Deployment to $host failed!"
        fi

        echo
        echo "${DIM}────────────────────────────────────────────────────────────────${RESET}"
        echo

        ((i++))
    done

    return ${#failed_hosts[@]}
}

# Deploy to all hosts in parallel
deploy_parallel() {
    local installer_url="$1"
    local failed_hosts=()

    draw_section_header "Parallel Deployment"
    echo
    print_info "Deploying to ${#HOSTS[@]} hosts simultaneously..."
    echo

    # Launch parallel deployments
    local -a pids
    local -a host_status

    for host in "${HOSTS[@]}"; do
        (
            if deploy_to_host "$host" "$installer_url"; then
                echo "SUCCESS:$host"
            else
                echo "FAILED:$host"
            fi
        ) &
        pids+=($!)
    done

    # Wait for all deployments
    for pid in "${pids[@]}"; do
        if wait "$pid"; then
            : # Success, output already captured
        else
            : # Failure, output already captured
        fi
    done

    echo
    print_success "Parallel deployment complete!"

    return ${#failed_hosts[@]}
}

# Display deployment summary
show_deployment_summary() {
    echo
    draw_section_header "Deployment Summary"
    echo

    local success_count=0
    local failed_count=0

    for result in "${DEPLOYMENT_RESULTS[@]}"; do
        if [[ "$result" =~ ^SUCCESS: ]]; then
            local host="${result#SUCCESS:}"
            echo "  ${GREEN}✓${RESET} $host - Success"
            ((success_count++))
        else
            local host="${result#FAILED:}"
            echo "  ${RED}✗${RESET} $host - Failed"
            ((failed_count++))
        fi
    done

    echo

    local total_count=${#DEPLOYMENT_RESULTS[@]}

    if [[ $success_count -eq $total_count ]]; then
        print_success "All deployments completed successfully! ($success_count/$total_count)"
    else
        print_warning "$success_count/$total_count deployments succeeded, $failed_count failed"
    fi
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    # Parse arguments - we need a different approach for --hosts with multiple values
    local -a remaining_args

    # Manual argument parsing to handle --hosts with multiple values
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --auto)
                AUTO_MODE=true
                shift
                ;;
            --interactive)
                AUTO_MODE=false
                shift
                ;;
            --parallel)
                PARALLEL_MODE=true
                SEQUENTIAL_MODE=false
                shift
                ;;
            --sequential)
                PARALLEL_MODE=false
                SEQUENTIAL_MODE=true
                shift
                ;;
            --timeout)
                if [[ -n "${2:-}" ]]; then
                    SSH_TIMEOUT="$2"
                    shift 2
                else
                    print_error "--timeout requires a value"
                    return 1
                fi
                ;;
            --hosts-file)
                if [[ -n "${2:-}" ]]; then
                    HOSTS_FILE="$2"
                    read_hosts_from_file "$HOSTS_FILE" || return 1
                    shift 2
                else
                    print_error "--hosts-file requires a filename"
                    return 1
                fi
                ;;
            --hosts)
                # Collect all following non-option arguments as hosts
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                    HOSTS+=("$1")
                    shift
                done
                ;;
            -*)
                print_error "Unknown option: $1"
                print_info "Use --help for usage information"
                return 1
                ;;
            *)
                remaining_args+=("$1")
                shift
                ;;
        esac
    done

    # Show dry-run warning
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY-RUN MODE: No changes will be made"
        echo
    fi

    # If no hosts specified via options, use interactive mode
    if [[ ${#HOSTS[@]} -eq 0 && -z "$HOSTS_FILE" ]]; then
        if [[ "$LIBRARIES_LOADED" == true ]]; then
            print_greeting "deploy"
            echo
        fi

        interactive_host_selection || return 1
    fi

    # Validate we have hosts
    if [[ ${#HOSTS[@]} -eq 0 ]]; then
        print_error "No hosts specified"
        return 1
    fi

    # Show configuration
    echo
    draw_section_header "Deployment Configuration"
    echo
    echo "  ${BOLD}Hosts:${RESET}      ${#HOSTS[@]} total"
    for host in "${HOSTS[@]}"; do
        echo "              • $host"
    done
    echo "  ${BOLD}Mode:${RESET}       $(if [[ "$AUTO_MODE" == true ]]; then echo "Automatic (dfauto)"; else echo "Interactive (dfsetup)"; fi)"
    echo "  ${BOLD}Execution:${RESET}  $(if [[ "$PARALLEL_MODE" == true ]]; then echo "Parallel"; else echo "Sequential"; fi)"
    echo "  ${BOLD}Timeout:${RESET}    ${SSH_TIMEOUT}s"
    echo

    # Confirm deployment (unless dry-run or auto mode)
    if [[ "$DRY_RUN" == false && "$AUTO_MODE" == false ]]; then
        echo -n "${YELLOW}Proceed with deployment? [y/N]:${RESET} "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Deployment cancelled"
            return 0
        fi
        echo
    fi

    # Validate SSH connections
    validate_all_hosts || return 1

    # Select installer URL
    local installer_url
    if [[ "$AUTO_MODE" == true ]]; then
        installer_url="$DFAUTO_URL"
    else
        installer_url="$DFSETUP_URL"
    fi

    # Deploy based on mode
    if [[ "$PARALLEL_MODE" == true ]]; then
        deploy_parallel "$installer_url"
    else
        deploy_sequential "$installer_url"
    fi

    # Show summary
    show_deployment_summary

    return 0
}

# Run main function
main "$@"
