#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# XCP-NG Helper Script Deployment Tool
# ============================================================================
# This script deploys and manages helper scripts on the NFS shared storage,
# making them accessible from all cluster hosts.
#
# Features:
#   - Deploy helper scripts to NFS share
#   - Migrate existing scripts from local directories
#   - List scripts available on NFS
#   - Clean up old scripts
#   - Verify NFS access across all hosts
#
# Usage:
#   ./deploy_xen_helpers.zsh --deploy <script>    # Deploy specific script
#   ./deploy_xen_helpers.zsh --deploy-all         # Deploy all helper scripts
#   ./deploy_xen_helpers.zsh --migrate            # Migrate from /root/aria-scripts
#   ./deploy_xen_helpers.zsh --list               # List NFS scripts
#   ./deploy_xen_helpers.zsh --verify             # Verify NFS access
#   ./deploy_xen_helpers.zsh --status             # Show cluster status

# ============================================================================
# Load Dependencies
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load cluster management library
source "$SCRIPT_DIR/lib/xen_cluster.zsh" || {
    echo "Error: Could not load xen_cluster.zsh library"
    exit 1
}

# Load UI libraries
source "$DF_DIR/bin/lib/colors.zsh" 2>/dev/null
source "$DF_DIR/bin/lib/ui.zsh" 2>/dev/null

# ============================================================================
# Helper Script Locations
# ============================================================================

# Helper scripts that should be deployed to NFS
HELPER_SCRIPTS=(
    "$SCRIPT_DIR/helpers/create-vm-with-cloudinit-iso.sh"
    "$SCRIPT_DIR/helpers/create-windows-vm-with-cloudinit-iso.sh"
    "$SCRIPT_DIR/helpers/cleanup-test-vms.sh"
    "$SCRIPT_DIR/helpers/list-test-vms.sh"
)

# ============================================================================
# Deployment Functions
# ============================================================================

function deploy_single_script() {
    local script_path="$1"
    local hostname="${2:-$(xen_cluster_select_host)}"

    if [[ ! -f "$script_path" ]]; then
        print_error "Script not found: $script_path"
        return 1
    fi

    print_info "Deploying $(basename "$script_path") to $hostname..."

    if xen_cluster_deploy_helper_to_nfs "$hostname" "$script_path"; then
        print_success "Deployed successfully!"
        return 0
    else
        print_error "Deployment failed!"
        return 1
    fi
}

function deploy_all_scripts() {
    echo
    draw_section_header "📦 Deploying All Helper Scripts to NFS"
    echo

    # Select a host
    local hostname=$(xen_cluster_select_host)
    if [[ -z "$hostname" ]]; then
        print_error "No available hosts found!"
        return 1
    fi

    print_info "Using host: $hostname"
    echo

    # Deploy each helper script
    local success_count=0
    local fail_count=0

    for script in "${HELPER_SCRIPTS[@]}"; do
        if [[ -f "$script" ]]; then
            if deploy_single_script "$script" "$hostname"; then
                success_count=$((success_count + 1))
            else
                fail_count=$((fail_count + 1))
            fi
        else
            print_warning "Script not found (skipping): $script"
        fi
        echo
    done

    echo
    echo "Deployment Summary:"
    printf "  ${UI_SUCCESS_COLOR}✓ Successful:${COLOR_RESET} %d\n" $success_count
    printf "  ${UI_ERROR_COLOR}✗ Failed:${COLOR_RESET}     %d\n" $fail_count
    echo

    if [[ $success_count -gt 0 ]]; then
        print_success "Helper scripts are now accessible from all cluster hosts!"
        echo
        print_info "Scripts location on all hosts:"
        echo "  $(xen_cluster_get_nfs_scripts_dir)"
    fi

    return $fail_count
}

function migrate_existing_scripts() {
    echo
    draw_section_header "🔄 Migrating Existing Helper Scripts to NFS"
    echo

    # Select a host
    local hostname=$(xen_cluster_select_host)
    if [[ -z "$hostname" ]]; then
        print_error "No available hosts found!"
        return 1
    fi

    print_info "Using host: $hostname"
    echo

    # Call cluster migration function
    xen_cluster_migrate_helpers_to_nfs "$hostname"
}

function list_nfs_scripts() {
    echo
    draw_section_header "📋 Helper Scripts on NFS Share"
    echo

    # Select a host
    local hostname=$(xen_cluster_select_host)
    if [[ -z "$hostname" ]]; then
        print_error "No available hosts found!"
        return 1
    fi

    print_info "Listing scripts from: $hostname"
    print_info "NFS path: $(xen_cluster_get_nfs_scripts_dir)"
    echo

    xen_cluster_list_nfs_helpers "$hostname"
    echo
}

function verify_nfs_access() {
    echo
    draw_section_header "✓ Verifying NFS Access Across Cluster"
    echo

    local all_accessible=true

    for hostname in $(xen_cluster_list_available_hosts); do
        echo -n "  Checking NFS access on $hostname ... "

        if xen_cluster_verify_nfs_access "$hostname"; then
            echo "${UI_SUCCESS_COLOR}✓ Accessible${COLOR_RESET}"
        else
            echo "${UI_ERROR_COLOR}✗ Not accessible${COLOR_RESET}"
            all_accessible=false
        fi
    done

    echo

    if $all_accessible; then
        print_success "NFS share is accessible from all available hosts!"
        return 0
    else
        print_error "Some hosts cannot access the NFS share"
        return 1
    fi
}

function show_cluster_status() {
    xen_cluster_status
}

# ============================================================================
# Command Line Interface
# ============================================================================

function show_help() {
    cat <<EOF

XCP-NG Helper Script Deployment Tool

This tool deploys and manages helper scripts on the NFS shared storage,
making them accessible from all cluster hosts automatically.

Usage:
  $0 [COMMAND] [OPTIONS]

Commands:
  --deploy <script>         Deploy a specific helper script to NFS
  --deploy-all              Deploy all helper scripts to NFS
  --migrate                 Migrate existing scripts from /root/aria-scripts
  --list                    List all scripts on the NFS share
  --verify                  Verify NFS access across all cluster hosts
  --status                  Show cluster status and host availability

Options:
  --host <hostname>         Use a specific host (default: auto-select)
  -h, --help                Show this help message

Examples:
  # Deploy all helper scripts to NFS
  $0 --deploy-all

  # Migrate existing scripts from local directories
  $0 --migrate

  # List what's currently on NFS
  $0 --list

  # Verify all hosts can access NFS
  $0 --verify

  # Check cluster status
  $0 --status

NFS Configuration:
  SR UUID: $(echo "$XEN_NFS_SR_UUID")
  Scripts Path: $(xen_cluster_get_nfs_scripts_dir)

Cluster Hosts:
  - opt-bck01.bck.intern (192.168.188.11) - Primary
  - opt-bck02.bck.intern (192.168.188.12) - Failover
  - opt-bck03.bck.intern (192.168.188.13) - Failover
  - lat-bck04.bck.intern (192.168.188.19) - Failover

EOF
}

# ============================================================================
# Main Execution
# ============================================================================

# Parse command line arguments
COMMAND=""
SCRIPT_PATH=""
TARGET_HOST=""

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --deploy)
            COMMAND="deploy"
            if [[ -n "$2" && "$2" != --* ]]; then
                SCRIPT_PATH="$2"
                shift
            else
                print_error "--deploy requires a script path"
                exit 1
            fi
            shift
            ;;
        --deploy-all)
            COMMAND="deploy-all"
            shift
            ;;
        --migrate)
            COMMAND="migrate"
            shift
            ;;
        --list)
            COMMAND="list"
            shift
            ;;
        --verify)
            COMMAND="verify"
            shift
            ;;
        --status)
            COMMAND="status"
            shift
            ;;
        --host)
            TARGET_HOST="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Initialize cluster
xen_cluster_init || {
    print_error "Failed to initialize cluster connection"
    exit 1
}

# Execute command
case "$COMMAND" in
    deploy)
        if [[ -n "$TARGET_HOST" ]]; then
            deploy_single_script "$SCRIPT_PATH" "$TARGET_HOST"
        else
            deploy_single_script "$SCRIPT_PATH"
        fi
        ;;
    deploy-all)
        deploy_all_scripts
        ;;
    migrate)
        migrate_existing_scripts
        ;;
    list)
        list_nfs_scripts
        ;;
    verify)
        verify_nfs_access
        ;;
    status)
        show_cluster_status
        ;;
    *)
        print_error "No command specified"
        show_help
        exit 1
        ;;
esac

exit $?
