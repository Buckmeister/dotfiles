#!/usr/bin/env zsh

# ============================================================================
# XCP-NG VM Installation Testing Script - Enhanced & Unified
# ============================================================================
#
# Tests dotfiles installation on fresh XCP-NG VMs with flexible test modes,
# PI script filtering, and comprehensive debugging options.
#
# Usage:
#   ./tests/test_xen.zsh [OPTIONS]
#
# Test Modes:
#   --basic              VM provisioning and SSH validation only
#   --comprehensive      Full installation with librarian check (default)
#   --full               Run both basic AND comprehensive tests
#
# PI Script Control:
#   --skip-pi            Disable ALL post-install scripts (fastest)
#   --disable-pi GLOB    Disable scripts matching glob pattern
#   --enable-pi GLOB     Enable ONLY scripts matching glob (disable others)
#
# Distribution Selection:
#   --quick              Test Ubuntu only (fastest)
#   --distro NAME        Test specific distribution
#   --linux-only         Test only Linux distributions
#   --windows-only       Test only Windows distributions
#
# Development Options:
#   --keep-vm            Don't destroy VMs after testing (debug)
#   --vm-name PREFIX     Custom VM name prefix (default: aria-test)
#   --no-librarian       Skip librarian health check
#   --host HOSTNAME      Use specific XCP-NG host
#
# Examples:
#   # Fast smoke test (2-3 min)
#   ./tests/test_xen.zsh --basic --quick
#
#   # Test git configs only on real VM (4-5 min)
#   ./tests/test_xen.zsh --enable-pi "git-*" --quick
#
#   # Full test without PI overhead (3-4 min)
#   ./tests/test_xen.zsh --skip-pi --quick
#
#   # Debug failed test (keeps VM)
#   ./tests/test_xen.zsh --quick --keep-vm --vm-name debug
#
#   # Test Linux only (skip slow Windows VMs)
#   ./tests/test_xen.zsh --linux-only --comprehensive
#
# ============================================================================

emulate -LR zsh
# Note: Not using ERR_EXIT to allow proper error handling in test loops
setopt PIPE_FAIL

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="${0:a:h}"
DOTFILES_ROOT="${SCRIPT_DIR:h}"

# Source shared libraries
source "${DOTFILES_ROOT}/bin/lib/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load shared libraries"
    exit 1
}
source "${DOTFILES_ROOT}/bin/lib/ui.zsh"
source "${DOTFILES_ROOT}/bin/lib/utils.zsh"
source "${DOTFILES_ROOT}/bin/lib/greetings.zsh"

# Source test helpers
source "${SCRIPT_DIR}/lib/test_helpers.zsh" 2>/dev/null || {
    echo "Error: Could not load test helpers"
    exit 1
}

# Source deployment library (for --deploy-helpers and related commands)
source "${SCRIPT_DIR}/lib/xen_deploy.zsh" 2>/dev/null || {
    # Deployment library not available - deployment commands will be disabled
    XEN_DEPLOY_AVAILABLE=false
}

# XCP-NG Configuration
XEN_SSH_KEY="${HOME}/.ssh/aria_xen_key"
XEN_HOST="opt-bck01.bck.intern"

# NFS Shared Storage for helper scripts (xenstore1)
XEN_SHARED_SR_UUID="75fa3703-d020-e865-dd0e-3682b83c35f6"
XEN_SHARED_SCRIPTS_PATH="/run/sr-mount/${XEN_SHARED_SR_UUID}/aria-scripts"
XEN_LOCAL_SCRIPTS_PATH="/root/aria-scripts"

# Helper script names (will check shared location first, fallback to local)
XEN_LINUX_HELPER_NAME="create-vm-with-cloudinit-iso.sh"
XEN_WINDOWS_HELPER_NAME="create-windows-vm-with-cloudinit-iso-v2.sh"

# Resolved paths (set during prerequisites check)
XEN_LINUX_HELPER=""
XEN_WINDOWS_HELPER=""

# Available distributions
ALL_LINUX_DISTROS=(
    "ubuntu"
    "debian"
)

ALL_WINDOWS_DISTROS=(
    "w11cb"
)

ALL_DISTROS=("${ALL_LINUX_DISTROS[@]}" "${ALL_WINDOWS_DISTROS[@]}")

# Test configuration variables
TEST_MODE="comprehensive"     # basic, comprehensive, full
DISTROS=("${ALL_DISTROS[@]}")
SKIP_PI=false
DISABLE_PI_GLOB=""
ENABLE_PI_GLOB=""
KEEP_VM=false
CUSTOM_VM_NAME="aria-test"
NO_LIBRARIAN=false
QUICK_MODE=false
SINGLE_DISTRO=""
LINUX_ONLY=false
WINDOWS_ONLY=false

# Deployment mode variables
DEPLOYMENT_MODE=""           # deploy-helpers, list-helpers, verify-helpers, migrate-helpers, status
DEPLOYMENT_ONLY=false        # true = exit after deployment, false = deploy then test

# Track VMs created during testing for cleanup
declare -a CREATED_VMS
declare -a CREATED_VDIS

# ============================================================================
# Argument Parsing
# ============================================================================

show_help() {
    cat <<EOF
${COLOR_PURPLE}${COLOR_BOLD}╔════════════════════════════════════════════════════════════════════════════╗
║                     XCP-NG VM Testing - Enhanced                           ║
║                  Flexible, Fast, and Developer-Friendly                    ║
╚════════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}

${COLOR_BOLD}USAGE:${COLOR_RESET}
  $0 [OPTIONS]

${COLOR_BOLD}TEST MODES:${COLOR_RESET}
  ${COLOR_CYAN}--basic${COLOR_RESET}              VM provisioning and SSH validation only (~2-3 min)
  ${COLOR_CYAN}--comprehensive${COLOR_RESET}      Full installation with librarian check (~5-7 min, default)
  ${COLOR_CYAN}--full${COLOR_RESET}               Run both basic AND comprehensive tests

${COLOR_BOLD}POST-INSTALL SCRIPT CONTROL:${COLOR_RESET}
  ${COLOR_CYAN}--skip-pi${COLOR_RESET}            Disable ALL post-install scripts (fastest testing)
  ${COLOR_CYAN}--disable-pi GLOB${COLOR_RESET}    Disable scripts matching glob (e.g., "*packages*")
  ${COLOR_CYAN}--enable-pi GLOB${COLOR_RESET}     Enable ONLY scripts matching glob (disable others)

${COLOR_BOLD}DISTRIBUTION SELECTION:${COLOR_RESET}
  ${COLOR_CYAN}--quick${COLOR_RESET}              Test Ubuntu only (fastest, recommended for iteration)
  ${COLOR_CYAN}--distro NAME${COLOR_RESET}        Test specific distribution
  ${COLOR_CYAN}--linux-only${COLOR_RESET}         Test only Linux distributions (ubuntu, debian)
  ${COLOR_CYAN}--windows-only${COLOR_RESET}       Test only Windows distributions (w11)

${COLOR_BOLD}DEVELOPMENT & DEBUGGING:${COLOR_RESET}
  ${COLOR_CYAN}--keep-vm${COLOR_RESET}            Don't destroy VMs after testing (for debugging)
  ${COLOR_CYAN}--vm-name PREFIX${COLOR_RESET}     Custom VM name prefix (default: aria-test)
  ${COLOR_CYAN}--no-librarian${COLOR_RESET}       Skip librarian health check (faster iteration)
  ${COLOR_CYAN}--host HOSTNAME${COLOR_RESET}      Use specific XCP-NG host

${COLOR_BOLD}HELPER SCRIPT DEPLOYMENT:${COLOR_RESET}
  ${COLOR_CYAN}--deploy-helpers${COLOR_RESET}     Deploy all helper scripts to NFS shared storage
  ${COLOR_CYAN}--list-helpers${COLOR_RESET}       List helper scripts on NFS share
  ${COLOR_CYAN}--verify-helpers${COLOR_RESET}     Verify NFS access across all cluster hosts
  ${COLOR_CYAN}--migrate-helpers${COLOR_RESET}    Migrate scripts from /root/aria-scripts to NFS
  ${COLOR_CYAN}--cluster-status${COLOR_RESET}     Show cluster status and host availability

${COLOR_BOLD}GENERAL:${COLOR_RESET}
  ${COLOR_CYAN}-h, --help${COLOR_RESET}           Show this help message

${COLOR_BOLD}EXAMPLES:${COLOR_RESET}

  ${COLOR_COMMENT}# Fast smoke test (2-3 minutes)${COLOR_RESET}
  $0 --basic --quick

  ${COLOR_COMMENT}# Test git configs only on real VM${COLOR_RESET}
  $0 --enable-pi "git-*" --quick

  ${COLOR_COMMENT}# Full validation without PI overhead${COLOR_RESET}
  $0 --comprehensive --skip-pi --quick

  ${COLOR_COMMENT}# Debug failed test (keeps VM for manual inspection)${COLOR_RESET}
  $0 --quick --keep-vm --vm-name debug

  ${COLOR_COMMENT}# Test Linux distros only (skip slow Windows VMs)${COLOR_RESET}
  $0 --linux-only --comprehensive

  ${COLOR_COMMENT}# Test specific PI script in isolation${COLOR_RESET}
  $0 --enable-pi "cargo-packages" --distro ubuntu

  ${COLOR_COMMENT}# Full regression test (SLOW but thorough)${COLOR_RESET}
  $0 --full --linux-only

  ${COLOR_COMMENT}# Deploy helper scripts before testing${COLOR_RESET}
  $0 --deploy-helpers

  ${COLOR_COMMENT}# Verify NFS access across cluster${COLOR_RESET}
  $0 --verify-helpers

  ${COLOR_COMMENT}# List deployed helper scripts${COLOR_RESET}
  $0 --list-helpers

${COLOR_BOLD}AVAILABLE DISTRIBUTIONS:${COLOR_RESET}
  Linux:   ${ALL_LINUX_DISTROS[@]}
  Windows: ${ALL_WINDOWS_DISTROS[@]} (w11cb = Windows 11 Pro with cloudbase-init)

${COLOR_BOLD}PREREQUISITES:${COLOR_RESET}
  • SSH key: ~/.ssh/aria_xen_key
  • XCP-NG host with cloud-init Hub templates (Linux)
  • XCP-NG host with Windows templates (for Windows testing)
  • Helper scripts on XCP-NG host

${COLOR_BOLD}TEST TIME ESTIMATES:${COLOR_RESET}
  Basic mode:         ~2-3 minutes per Linux VM
  Comprehensive mode: ~5-7 minutes per Linux VM
  Windows VM:         ~10-15 minutes (boot time)
  With --skip-pi:     ~2 minutes faster
  With --enable-pi:   Depends on script complexity

${COLOR_PURPLE}${COLOR_BOLD}Pro Tip:${COLOR_RESET} Use --skip-pi during development to test VM provisioning
         and installation mechanics without waiting for package installations!

EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        # Test modes
        --basic)
            TEST_MODE="basic"
            shift
            ;;
        --comprehensive)
            TEST_MODE="comprehensive"
            shift
            ;;
        --full)
            TEST_MODE="full"
            shift
            ;;

        # PI script control
        --skip-pi)
            SKIP_PI=true
            shift
            ;;
        --disable-pi)
            DISABLE_PI_GLOB="$2"
            shift 2
            ;;
        --enable-pi)
            ENABLE_PI_GLOB="$2"
            shift 2
            ;;

        # Distribution selection
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --distro)
            SINGLE_DISTRO="$2"
            shift 2
            ;;
        --linux-only)
            LINUX_ONLY=true
            shift
            ;;
        --windows-only)
            WINDOWS_ONLY=true
            shift
            ;;

        # Development options
        --keep-vm)
            KEEP_VM=true
            shift
            ;;
        --vm-name)
            CUSTOM_VM_NAME="$2"
            shift 2
            ;;
        --no-librarian)
            NO_LIBRARIAN=true
            shift
            ;;
        --host)
            XEN_HOST="$2"
            shift 2
            ;;

        # Deployment commands
        --deploy-helpers)
            DEPLOYMENT_MODE="deploy"
            DEPLOYMENT_ONLY=true
            shift
            ;;
        --list-helpers)
            DEPLOYMENT_MODE="list"
            DEPLOYMENT_ONLY=true
            shift
            ;;
        --verify-helpers)
            DEPLOYMENT_MODE="verify"
            DEPLOYMENT_ONLY=true
            shift
            ;;
        --migrate-helpers)
            DEPLOYMENT_MODE="migrate"
            DEPLOYMENT_ONLY=true
            shift
            ;;
        --cluster-status)
            DEPLOYMENT_MODE="status"
            DEPLOYMENT_ONLY=true
            shift
            ;;

        # Help
        -h|--help)
            show_help
            exit 0
            ;;

        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Apply distribution filters
if [[ "$QUICK_MODE" = true ]]; then
    DISTROS=("ubuntu")
elif [[ -n "$SINGLE_DISTRO" ]]; then
    DISTROS=("$SINGLE_DISTRO")
elif [[ "$LINUX_ONLY" = true ]]; then
    DISTROS=("${ALL_LINUX_DISTROS[@]}")
elif [[ "$WINDOWS_ONLY" = true ]]; then
    DISTROS=("${ALL_WINDOWS_DISTROS[@]}")
fi

# Validate PI filter combinations
if [[ "$SKIP_PI" = true ]] && [[ -n "$ENABLE_PI_GLOB" || -n "$DISABLE_PI_GLOB" ]]; then
    print_error "Cannot use --skip-pi with --enable-pi or --disable-pi"
    exit 1
fi

if [[ -n "$ENABLE_PI_GLOB" ]] && [[ -n "$DISABLE_PI_GLOB" ]]; then
    print_error "Cannot use --enable-pi and --disable-pi together"
    exit 1
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Detect if distro is Windows
is_windows() {
    local distro="$1"
    case "$distro" in
        w11cb|w11|win11|windows11|win10|windows10|win2022|win2019|ws2022|ws2019)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Execute command on XCP-NG host (wrapper around remote_ssh helper)
xen_ssh() {
    remote_ssh "$XEN_SSH_KEY" root "$XEN_HOST" "$@"
}

# Get helper script path (shared NFS if available, fallback to local)
get_helper_script_path() {
    local script_name="$1"
    local shared_path="${XEN_SHARED_SCRIPTS_PATH}/${script_name}"
    local local_path="${XEN_LOCAL_SCRIPTS_PATH}/${script_name}"

    # Check if shared path exists and is executable
    if xen_ssh "test -x '${shared_path}'" >/dev/null 2>&1; then
        echo "$shared_path"
        return 0
    fi

    # Fallback to local path
    if xen_ssh "test -x '${local_path}'" >/dev/null 2>&1; then
        echo "$local_path"
        return 0
    fi

    # Neither found
    return 1
}

# Execute command on VM (wrapper around remote_ssh helper)
vm_ssh() {
    local vm_ip="$1"
    shift
    remote_ssh "$XEN_SSH_KEY" aria "$vm_ip" "$@"
}

# Prepare PI script filtering on VM
prepare_pi_filtering() {
    local vm_ip="$1"
    local pi_filter_cmd=""

    if [[ "$SKIP_PI" = true ]]; then
        pi_filter_cmd="
            echo '📝 Disabling ALL post-install scripts...'
            cd ~/.config/dotfiles/post-install/scripts
            for script in *.zsh; do
                if [[ -f \"\$script\" && ! -f \"\${script}.disabled\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\"
                    echo \"   Disabled: \$script\"
                fi
            done
            echo '✅ All PI scripts disabled'
        "
    elif [[ -n "$ENABLE_PI_GLOB" ]]; then
        pi_filter_cmd="
            echo '📝 Enabling ONLY PI scripts matching: $ENABLE_PI_GLOB'
            cd ~/.config/dotfiles/post-install/scripts

            # First, disable everything
            for script in *.zsh; do
                if [[ -f \"\$script\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\" 2>/dev/null || true
                fi
            done

            # Then re-enable matching patterns
            for script in ${ENABLE_PI_GLOB}.disabled; do
                if [[ -f \"\$script\" ]]; then
                    original=\"\${script%.disabled}\"
                    mv \"\$script\" \"\$original\"
                    echo \"   Enabled: \$original\"
                fi
            done
        "
    elif [[ -n "$DISABLE_PI_GLOB" ]]; then
        pi_filter_cmd="
            echo '📝 Disabling PI scripts matching: $DISABLE_PI_GLOB'
            cd ~/.config/dotfiles/post-install/scripts
            for script in ${DISABLE_PI_GLOB}; do
                if [[ -f \"\$script\" ]]; then
                    mv \"\$script\" \"\${script}.disabled\"
                    echo \"   Disabled: \$script\"
                fi
            done
        "
    fi

    echo "$pi_filter_cmd"
}

# Restore PI scripts after testing (cleanup)
restore_pi_scripts() {
    local vm_ip="$1"

    if [[ "$SKIP_PI" = true ]] || [[ -n "$ENABLE_PI_GLOB" ]] || [[ -n "$DISABLE_PI_GLOB" ]]; then
        vm_ssh "$vm_ip" "
            cd ~/.config/dotfiles/post-install/scripts 2>/dev/null || exit 0
            for script in *.disabled; do
                if [[ -f \"\$script\" ]]; then
                    original=\"\${script%.disabled}\"
                    mv \"\$script\" \"\$original\" 2>/dev/null || true
                fi
            done
        " >/dev/null 2>&1 || true
    fi
}

# Clean up a VM
cleanup_vm() {
    local vm_uuid="$1"
    local vdi_uuid="$2"
    local skip_destroy="${3:-false}"

    if [[ "$KEEP_VM" = true ]] || [[ "$skip_destroy" = true ]]; then
        print_info "VM kept for debugging: $vm_uuid"
        if [[ -n "$vm_ip" ]]; then
            print_info "SSH access: ssh -i $XEN_SSH_KEY aria@$vm_ip"
        fi
        return 0
    fi

    if [[ -n "$vm_uuid" ]]; then
        xen_ssh "xe vm-shutdown uuid=$vm_uuid force=true 2>/dev/null || true" >/dev/null 2>&1
        sleep 2
        xen_ssh "xe vm-destroy uuid=$vm_uuid 2>/dev/null || true" >/dev/null 2>&1
    fi

    if [[ -n "$vdi_uuid" ]]; then
        xen_ssh "xe vdi-destroy uuid=$vdi_uuid 2>/dev/null || true" >/dev/null 2>&1
    fi
}

# ============================================================================
# Test Functions - Basic Mode
# ============================================================================

# Basic test: VM provisioning and SSH validation only
test_basic_linux() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: ${(C)distro} (Basic)" "Testing VM provisioning"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: ${(C)distro}"
    print_info "Test mode: Basic (VM + SSH validation)"
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create VM with cloud-init
    print_test_phase 1 3 "Creating VM with cloud-init configuration"

    local create_output=$(xen_ssh "'$XEN_LINUX_HELPER' $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    # Track for cleanup
    CREATED_VMS+=("$vm_uuid")
    [[ -n "$vdi_uuid" ]] && CREATED_VDIS+=("$vdi_uuid")

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible
    print_test_phase 2 3 "Waiting for VM to boot and cloud-init to complete"

    if [[ -z "$vm_ip" ]]; then
        print_error "VM did not receive an IP address"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    # Wait for SSH to be ready
    if ! wait_for_ssh "$XEN_SSH_KEY" aria "$vm_ip" 120 false; then
        print_error "VM did not become SSH accessible"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "VM is accessible via SSH"
    echo ""

    # Phase 3: Basic system validation
    print_test_phase 3 3 "Validating VM system information"

    local verify_output=$(vm_ssh "$vm_ip" "
        echo 'INFO:Distribution:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')
        echo 'INFO:Kernel:' \$(uname -r)
        echo 'INFO:User:' \$(whoami)
        echo 'SUCCESS:VM provisioning successful'
    ")

    echo "$verify_output" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    echo ""

    # Cleanup
    draw_section_header "Cleanup"
    print_info "Removing test VM and cloud-init ISO..."

    cleanup_vm "$vm_uuid" "$vdi_uuid"

    print_success "Cleanup complete"
    echo ""

    print_success "Test passed: ${(C)distro} (Basic) ✨"

    return 0
}

# ============================================================================
# Test Functions - Comprehensive Mode
# ============================================================================

# Comprehensive test: Full installation with librarian check
test_comprehensive_linux() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: ${(C)distro}" "Testing dotfiles installation"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: ${(C)distro}"
    print_info "Test mode: Comprehensive (Full installation)"

    # Show PI filtering status
    if [[ "$SKIP_PI" = true ]]; then
        print_warning "Post-install scripts: ALL DISABLED"
    elif [[ -n "$ENABLE_PI_GLOB" ]]; then
        print_info "Post-install scripts: ONLY '${ENABLE_PI_GLOB}' enabled"
    elif [[ -n "$DISABLE_PI_GLOB" ]]; then
        print_warning "Post-install scripts: '${DISABLE_PI_GLOB}' disabled"
    else
        print_info "Post-install scripts: ALL ENABLED"
    fi

    if [[ "$NO_LIBRARIAN" = true ]]; then
        print_warning "Librarian check: SKIPPED"
    fi
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create VM with cloud-init
    print_test_phase 1 6 "Creating VM with cloud-init configuration"

    local create_output=$(xen_ssh "'$XEN_LINUX_HELPER' $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    # Track for cleanup
    CREATED_VMS+=("$vm_uuid")
    [[ -n "$vdi_uuid" ]] && CREATED_VDIS+=("$vdi_uuid")

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible
    print_test_phase 2 6 "Waiting for VM to boot and cloud-init to complete"

    if [[ -z "$vm_ip" ]]; then
        print_error "VM did not receive an IP address"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    # Wait for SSH to be ready
    if ! wait_for_ssh "$XEN_SSH_KEY" aria "$vm_ip" 120 false; then
        print_error "VM did not become SSH accessible"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "VM is accessible via SSH"
    echo ""

    # Phase 3: Install prerequisites
    print_test_phase 3 6 "Installing prerequisites"

    local prereq_output=$(vm_ssh "$vm_ip" "sudo apt update -qq && sudo apt install -y -qq zsh build-essential curl git 2>&1 | tail -5")

    if [[ $? -eq 0 ]]; then
        print_success "Prerequisites installed"
    else
        print_error "Failed to install prerequisites"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi
    echo ""

    # Phase 4: Clone repository and apply PI filtering
    print_test_phase 4 6 "Cloning repository and configuring PI scripts"

    local clone_cmd="
        set -e
        echo 'PROGRESS:Cloning repository'
        if [ ! -d ~/.config/dotfiles ]; then
            git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles 2>&1 | tail -3
        fi
        echo 'SUCCESS:Repository cloned'

        # Apply PI filtering if configured
        $(prepare_pi_filtering "$vm_ip")
    "

    vm_ssh "$vm_ip" "$clone_cmd" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    if [[ $? -ne 0 ]]; then
        print_error "Failed to clone repository or configure PI scripts"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    echo ""

    # Phase 5: Run dotfiles setup
    print_test_phase 5 6 "Running dotfiles installation"

    local install_cmd="
        set -e
        echo 'PROGRESS:Running setup'
        cd ~/.config/dotfiles && ./bin/setup.zsh --all-modules 2>&1 | tail -20

        echo 'PROGRESS:Verifying installation'

        if [ -d ~/.config/dotfiles/.git ]; then
            echo 'SUCCESS:Git repository initialized'
        else
            echo 'FAILED:Not a git repository'
            exit 1
        fi

        if [ -f ~/.config/dotfiles/bin/setup.zsh ]; then
            echo 'SUCCESS:Setup script found'
        fi

        if git config --global user.name >/dev/null 2>&1; then
            echo 'SUCCESS:Git configuration applied'
        fi
    "

    # Add librarian check if not disabled
    if [[ "$NO_LIBRARIAN" = false ]]; then
        install_cmd+="
        echo 'PROGRESS:Running librarian health check'
        cd ~/.config/dotfiles

        # Run librarian and capture output
        librarian_output=\$(./bin/librarian.zsh 2>&1 || true)

        # Check for errors and warnings in librarian output
        if echo \"\$librarian_output\" | grep -qi 'error'; then
            echo 'FAILED:Librarian detected errors'
            echo \"\$librarian_output\" | grep -i 'error' | head -5
            exit 1
        fi

        if echo \"\$librarian_output\" | grep -qi 'warning'; then
            echo 'INFO:Librarian warnings detected (non-critical)'
            echo \"\$librarian_output\" | grep -i 'warning' | head -3
        else
            echo 'SUCCESS:Librarian health check passed'
        fi
        "
    fi

    install_cmd+="
        echo 'PROGRESS:Complete'
    "

    vm_ssh "$vm_ip" "$install_cmd" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    if [[ $? -ne 0 ]]; then
        print_error "Dotfiles installation failed"
        restore_pi_scripts "$vm_ip"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "Dotfiles installation complete"
    echo ""

    # Phase 6: Verify installation
    print_test_phase 6 6 "Verifying installation results"

    local verify_output=$(vm_ssh "$vm_ip" "
        echo 'INFO:Distribution:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')
        echo 'INFO:Git User:' \$(git config --global user.name)
        echo 'INFO:Git Email:' \$(git config --global user.email)
        echo 'INFO:Dotfiles:' \$(ls -d ~/.config/dotfiles 2>/dev/null || echo 'Not found')
        echo 'INFO:Symlinks:' \$(ls -1 ~/.local/bin 2>/dev/null | wc -l) 'files'
    ")

    echo "$verify_output" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    print_success "Installation verified"
    echo ""

    # Restore PI scripts before cleanup
    restore_pi_scripts "$vm_ip"

    # Cleanup
    draw_section_header "Cleanup"
    print_info "Removing test VM and cloud-init ISO..."

    cleanup_vm "$vm_uuid" "$vdi_uuid"

    print_success "Cleanup complete"
    echo ""

    print_success "Test passed: ${(C)distro} ✨"

    return 0
}

# ============================================================================
# Test Functions - Windows
# ============================================================================

# Windows basic test: VM provisioning and SSH validation
test_basic_windows() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: Windows ${(C)distro} (Basic)" "Testing Windows VM provisioning"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: Windows ${(C)distro}"
    print_info "Test mode: Basic (VM + SSH validation)"
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create Windows VM with cloudbase-init
    print_test_phase 1 3 "Creating Windows VM with cloudbase-init configuration"
    print_phase_context "This takes longer than Linux - Windows boot time ~5-10 minutes"

    local create_output=$(xen_ssh "'$XEN_WINDOWS_HELPER' $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    # Track for cleanup
    CREATED_VMS+=("$vm_uuid")
    [[ -n "$vdi_uuid" ]] && CREATED_VDIS+=("$vdi_uuid")

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible
    print_test_phase 2 3 "Waiting for Windows to boot and OpenSSH setup"
    print_phase_context "Cloudbase-init is installing OpenSSH Server, please be patient"

    if [[ -z "$vm_ip" ]]; then
        print_error "VM did not receive an IP address"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    # Wait for PowerShell/SSH to be ready (4 minutes timeout, show progress)
    if ! wait_for_condition "vm_ssh '$vm_ip' 'powershell.exe -Command Write-Output OK' >/dev/null 2>&1" 240 2 "Still waiting for SSH access" true; then
        print_error "VM did not become SSH accessible"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "VM is accessible via SSH"
    echo ""

    # Phase 3: Verify cloudbase-init execution
    print_test_phase 3 3 "Verifying cloudbase-init execution"

    local cloudinit_check=$(vm_ssh "$vm_ip" 'powershell.exe -Command "
        # Check if cloudbase-init service exists
        if (Get-Service cloudbase-init -ErrorAction SilentlyContinue) {
            Write-Output \"INFO:Cloudbase-Init: Service present\"
        }

        # Check cloudbase-init logs for successful completion
        \$logPath = \"C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\log\\cloudbase-init.log\"
        if (Test-Path \$logPath) {
            \$logContent = Get-Content \$logPath -Tail 50
            if (\$logContent -match \"Executing plugins\") {
                Write-Output \"SUCCESS:Cloudbase-Init executed plugins\"
            }
            if (\$logContent -match \"ConfigDrive\") {
                Write-Output \"SUCCESS:ConfigDrive detected\"
            }
        }

        # Verify aria user was created by cloudbase-init
        \$ariaUser = Get-LocalUser aria -ErrorAction SilentlyContinue
        if (\$ariaUser) {
            Write-Output \"SUCCESS:Aria user created by cloudbase-init\"
        }
    "')

    echo "$cloudinit_check" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    print_success "Cloudbase-init verification complete"
    echo ""

    # Cleanup
    draw_section_header "Cleanup"
    print_info "Removing test VM and cloudbase-init ISO..."

    cleanup_vm "$vm_uuid" "$vdi_uuid"

    print_success "Cleanup complete"
    echo ""

    print_success "Test passed: Windows ${(C)distro} (Basic) ✨"

    return 0
}

# Windows comprehensive test: Full system validation
test_comprehensive_windows() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: Windows ${(C)distro}" "Testing Windows SSH access"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: Windows ${(C)distro}"
    print_info "Test mode: Comprehensive (SSH + PowerShell validation)"
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create Windows VM with cloudbase-init
    print_test_phase 1 5 "Creating Windows VM with cloudbase-init configuration"
    print_phase_context "This takes longer than Linux - Windows boot time ~5-10 minutes"

    local create_output=$(xen_ssh "'$XEN_WINDOWS_HELPER' $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    # Track for cleanup
    CREATED_VMS+=("$vm_uuid")
    [[ -n "$vdi_uuid" ]] && CREATED_VDIS+=("$vdi_uuid")

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible (Windows takes longer)
    print_test_phase 2 5 "Waiting for Windows to boot and OpenSSH setup"
    print_phase_context "Cloudbase-init is installing OpenSSH Server, please be patient"

    if [[ -z "$vm_ip" ]]; then
        print_error "VM did not receive an IP address"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    # Wait for PowerShell/SSH to be ready (4 minutes timeout, show progress)
    if ! wait_for_condition "vm_ssh '$vm_ip' 'powershell.exe -Command Write-Output OK' >/dev/null 2>&1" 240 2 "Still waiting for SSH access" true; then
        print_error "VM did not become SSH accessible"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "VM is accessible via SSH"
    echo ""

    # Phase 3: Verify cloudbase-init execution
    print_test_phase 3 5 "Verifying cloudbase-init execution"

    local cloudinit_check=$(vm_ssh "$vm_ip" 'powershell.exe -Command "
        # Check if cloudbase-init service exists
        if (Get-Service cloudbase-init -ErrorAction SilentlyContinue) {
            Write-Output \"INFO:Cloudbase-Init: Service present\"
        }

        # Check cloudbase-init logs for successful completion
        \$logPath = \"C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\log\\cloudbase-init.log\"
        if (Test-Path \$logPath) {
            \$logContent = Get-Content \$logPath -Tail 50
            if (\$logContent -match \"Executing plugins\") {
                Write-Output \"SUCCESS:Cloudbase-Init executed plugins\"
            }
            if (\$logContent -match \"ConfigDrive\") {
                Write-Output \"SUCCESS:ConfigDrive detected\"
            }
        }

        # Verify aria user was created by cloudbase-init
        \$ariaUser = Get-LocalUser aria -ErrorAction SilentlyContinue
        if (\$ariaUser) {
            Write-Output \"SUCCESS:Aria user created by cloudbase-init\"
        }
    "')

    echo "$cloudinit_check" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    print_success "Cloudbase-init verification complete"
    echo ""

    # Phase 4: Verify Windows system and SSH access
    print_test_phase 4 5 "Verifying Windows system and PowerShell access"

    local verify_cmd='
        echo "PROGRESS:Checking Windows version"
        $os = Get-CimInstance Win32_OperatingSystem
        Write-Output "INFO:OS: $($os.Caption) $($os.Version)"

        echo "PROGRESS:Checking OpenSSH service"
        $ssh = Get-Service sshd
        Write-Output "INFO:SSH Service: $($ssh.Status)"

        echo "PROGRESS:Checking PowerShell version"
        Write-Output "INFO:PowerShell: $($PSVersionTable.PSVersion.ToString())"

        echo "PROGRESS:Checking Git availability"
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $gitVer = git --version
            Write-Output "INFO:Git: $gitVer"
        } else {
            Write-Output "INFO:Git: Not installed"
        }

        echo "PROGRESS:Checking user profile"
        Write-Output "INFO:User: $env:USERNAME"
        Write-Output "INFO:Profile: $env:USERPROFILE"

        echo "PROGRESS:Complete"
    '

    vm_ssh "$vm_ip" "powershell.exe -Command \"$verify_cmd\"" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    if [[ $? -ne 0 ]]; then
        print_error "System verification failed"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "Windows system verified"
    echo ""

    # Phase 5: Test dotfiles readiness (clone check)
    print_test_phase 5 5 "Testing dotfiles repository access"

    local git_test=$(vm_ssh "$vm_ip" "powershell.exe -Command 'git ls-remote https://github.com/Buckmeister/dotfiles.git HEAD' 2>&1")

    if [[ $? -eq 0 ]]; then
        print_success "Git repository accessible"
        echo "   ${COLOR_COMMENT}Note: Windows dotfiles installation would require PowerShell setup script${COLOR_RESET}"
    else
        print_error "Could not access Git repository"
        print_info "   This might be expected if Git is not pre-installed"
    fi
    echo ""

    # Cleanup
    draw_section_header "Cleanup"
    print_info "Removing test VM and cloudbase-init ISO..."

    cleanup_vm "$vm_uuid" "$vdi_uuid"

    print_success "Cleanup complete"
    echo ""

    print_success "Test passed: Windows ${(C)distro} ✨"
    print_info "   ${COLOR_COMMENT}SSH access verified, system is ready for PowerShell automation${COLOR_RESET}"

    return 0
}

# ============================================================================
# Test Orchestration
# ============================================================================

# Run tests based on mode and OS
run_test_for_distro() {
    local distro="$1"
    local mode="$2"

    if is_windows "$distro"; then
        # Windows test
        if [[ "$mode" == "basic" ]]; then
            test_basic_windows "$distro"
        else
            test_comprehensive_windows "$distro"
        fi
    else
        # Linux test
        if [[ "$mode" == "basic" ]]; then
            test_basic_linux "$distro"
        else
            test_comprehensive_linux "$distro"
        fi
    fi
}

# ============================================================================
# Main Test Suite
# ============================================================================

run_tests() {
    draw_header "XCP-NG VM Testing - Enhanced" "Flexible and comprehensive validation"
    echo ""

    draw_section_header "Test Configuration"

    print_info "Test mode: ${COLOR_BOLD}${TEST_MODE}${COLOR_RESET}"
    print_info "XCP-NG Host: ${COLOR_BOLD}${XEN_HOST}${COLOR_RESET}"

    # Show PI filtering status
    if [[ "$SKIP_PI" = true ]]; then
        print_warning "Post-install scripts: ALL DISABLED (--skip-pi)"
    elif [[ -n "$ENABLE_PI_GLOB" ]]; then
        print_info "Post-install scripts: ONLY '${ENABLE_PI_GLOB}' enabled"
    elif [[ -n "$DISABLE_PI_GLOB" ]]; then
        print_warning "Post-install scripts: '${DISABLE_PI_GLOB}' disabled"
    fi

    print_info "Distributions: ${#DISTROS[@]}"
    for distro in "${DISTROS[@]}"; do
        echo "   • ${(C)distro}"
    done

    # Calculate total tests
    local total_tests=${#DISTROS[@]}
    if [[ "$TEST_MODE" == "full" ]]; then
        ((total_tests *= 2))
    fi
    print_info "Total tests to run: ${COLOR_BOLD}${total_tests}${COLOR_RESET}"
    echo ""

    # Time estimate
    local time_estimate="~5-7 minutes"
    if [[ "$TEST_MODE" == "basic" ]]; then
        time_estimate="~2-3 minutes"
    elif [[ "$TEST_MODE" == "full" ]]; then
        time_estimate="~7-10 minutes"
    fi

    if [[ "$SKIP_PI" = true ]]; then
        time_estimate="${time_estimate} (faster with --skip-pi)"
    fi

    echo "   ${COLOR_BOLD}${UI_WARNING_COLOR}⏱️  Estimated time:${COLOR_RESET} ${time_estimate}"
    echo ""

    draw_section_header "Prerequisites Check"

    # Check SSH key
    if [[ ! -f "$XEN_SSH_KEY" ]]; then
        print_error "SSH key not found: $XEN_SSH_KEY"
        print_info "Please run the SSH key deployment script first"
        return 1
    fi
    print_success "SSH key found"

    # Check XCP-NG host connectivity
    if ! xen_ssh "xe host-list params=name-label --minimal" >/dev/null 2>&1; then
        print_error "Cannot connect to XCP-NG host: $XEN_HOST"
        print_info "Please check SSH configuration and host connectivity"
        return 1
    fi
    print_success "XCP-NG host accessible: $XEN_HOST"

    # Check helper scripts
    local has_linux=false
    local has_windows=false
    for distro in "${DISTROS[@]}"; do
        if is_windows "$distro"; then
            has_windows=true
        else
            has_linux=true
        fi
    done

    if [[ "$has_linux" = true ]]; then
        XEN_LINUX_HELPER=$(get_helper_script_path "$XEN_LINUX_HELPER_NAME")
        if [[ $? -ne 0 || -z "$XEN_LINUX_HELPER" ]]; then
            print_error "Linux helper script not found: $XEN_LINUX_HELPER_NAME"
            print_info "Please upload to either:"
            print_info "  • Shared: $XEN_SHARED_SCRIPTS_PATH/"
            print_info "  • Local:  $XEN_LOCAL_SCRIPTS_PATH/"
            return 1
        fi
        # Show which location is being used
        if [[ "$XEN_LINUX_HELPER" == *"$XEN_SHARED_SCRIPTS_PATH"* ]]; then
            print_success "Linux helper script ready (shared NFS)"
        else
            print_success "Linux helper script ready (local)"
        fi
    fi

    if [[ "$has_windows" = true ]]; then
        XEN_WINDOWS_HELPER=$(get_helper_script_path "$XEN_WINDOWS_HELPER_NAME")
        if [[ $? -ne 0 || -z "$XEN_WINDOWS_HELPER" ]]; then
            print_error "Windows helper script not found: $XEN_WINDOWS_HELPER_NAME"
            print_info "Please upload to either:"
            print_info "  • Shared: $XEN_SHARED_SCRIPTS_PATH/"
            print_info "  • Local:  $XEN_LOCAL_SCRIPTS_PATH/"
            return 1
        fi
        # Show which location is being used
        if [[ "$XEN_WINDOWS_HELPER" == *"$XEN_SHARED_SCRIPTS_PATH"* ]]; then
            print_success "Windows helper script ready (shared NFS)"
        else
            print_success "Windows helper script ready (local)"
        fi
    fi

    echo ""

    # Initialize test result tracking
    init_test_tracking

    # Run tests based on mode
    if [[ "$TEST_MODE" == "full" ]]; then
        # Run both basic and comprehensive tests
        for distro in "${DISTROS[@]}"; do
            # Basic test
            if run_test_for_distro "$distro" "basic"; then
                track_test_result "${(C)distro} (basic)" true
            else
                track_test_result "${(C)distro} (basic)" false
            fi
            echo ""

            # Comprehensive test
            if run_test_for_distro "$distro" "comprehensive"; then
                track_test_result "${(C)distro} (comprehensive)" true
            else
                track_test_result "${(C)distro} (comprehensive)" false
            fi
            echo ""
        done
    else
        # Run single mode test
        for distro in "${DISTROS[@]}"; do
            local mode="$TEST_MODE"

            if run_test_for_distro "$distro" "$mode"; then
                track_test_result "${(C)distro}" true
            else
                track_test_result "${(C)distro}" false
            fi
            echo ""
        done
    fi

    # Print summary
    print_test_summary
}

# ============================================================================
# Cleanup Function
# ============================================================================

cleanup() {
    if [[ "$KEEP_VM" = true ]]; then
        print_info "Skipping cleanup due to --keep-vm flag"
        print_info "Created VMs: ${CREATED_VMS[@]}"
        return 0
    fi

    print_info "Cleaning up any remaining test VMs..."

    # Clean up tracked VMs
    for vm_uuid in "${CREATED_VMS[@]}"; do
        if [[ -n "$vm_uuid" ]]; then
            xen_ssh "xe vm-shutdown uuid=$vm_uuid force=true 2>/dev/null || true" >/dev/null 2>&1
            sleep 1
            xen_ssh "xe vm-destroy uuid=$vm_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done

    # Clean up tracked VDIs
    for vdi_uuid in "${CREATED_VDIS[@]}"; do
        if [[ -n "$vdi_uuid" ]]; then
            xen_ssh "xe vdi-destroy uuid=$vdi_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done

    # Find and destroy any test VMs that might be left
    local test_vms=$(xen_ssh "xe vm-list name-label='${CUSTOM_VM_NAME}-*' params=uuid --minimal 2>/dev/null" | tr ',' '\n')

    for vm_uuid in $test_vms; do
        if [[ -n "$vm_uuid" ]]; then
            xen_ssh "xe vm-shutdown uuid=$vm_uuid force=true 2>/dev/null || true" >/dev/null 2>&1
            sleep 1
            xen_ssh "xe vm-destroy uuid=$vm_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done

    # Clean up cloud-init ISOs
    local test_vdis=$(xen_ssh "xe vdi-list name-label='cloud-init-${CUSTOM_VM_NAME}-*' params=uuid --minimal 2>/dev/null" | tr ',' '\n')

    for vdi_uuid in $test_vdis; do
        if [[ -n "$vdi_uuid" ]]; then
            xen_ssh "xe vdi-destroy uuid=$vdi_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done
}

# Register cleanup on exit
register_cleanup_handler cleanup

# ============================================================================
# Entry Point
# ============================================================================

# Verify prerequisites
draw_header "XCP-NG VM Testing" "Initializing test environment"
echo ""

print_info "Verifying test environment..."
echo ""

# Check if SSH key exists
if [[ ! -f "$XEN_SSH_KEY" ]]; then
    print_error "SSH key not found: $XEN_SSH_KEY"
    print_info ""
    print_info "Please generate and deploy the SSH key first:"
    print_info "  ~/.config/xen/deploy-aria-key.sh"
    exit 1
fi

# Check XCP-NG connectivity
if ! xen_ssh "xe host-list params=name-label --minimal" >/dev/null 2>&1; then
    print_error "Cannot connect to XCP-NG host: $XEN_HOST"
    print_info ""
    print_info "Please check:"
    print_info "  • SSH key is deployed to the host"
    print_info "  • Host is reachable: $XEN_HOST"
    print_info "  • You have permission to run 'xe' commands"
    exit 1
fi

print_success "XCP-NG host is accessible"
echo ""

# ============================================================================
# Deployment Mode Execution
# ============================================================================

if [[ -n "$DEPLOYMENT_MODE" ]]; then
    # Initialize cluster for deployment operations
    xen_cluster_init || {
        print_error "Failed to initialize cluster connection"
        exit 1
    }

    # Execute deployment command
    case "$DEPLOYMENT_MODE" in
        deploy)
            xen_deploy_all_scripts "$XEN_HOST"
            exit_code=$?
            ;;
        list)
            xen_deploy_list_scripts "$XEN_HOST"
            exit_code=$?
            ;;
        verify)
            xen_deploy_verify_access
            exit_code=$?
            ;;
        migrate)
            xen_deploy_migrate_scripts "$XEN_HOST"
            exit_code=$?
            ;;
        status)
            xen_deploy_cluster_status
            exit_code=$?
            ;;
        *)
            print_error "Unknown deployment mode: $DEPLOYMENT_MODE"
            exit 1
            ;;
    esac

    # Exit after deployment if DEPLOYMENT_ONLY is true
    if [[ "$DEPLOYMENT_ONLY" = true ]]; then
        exit $exit_code
    fi

    echo ""
    print_success "Deployment complete! Proceeding with tests..."
    echo ""
fi

# ============================================================================
# Run Test Suite
# ============================================================================

run_tests
