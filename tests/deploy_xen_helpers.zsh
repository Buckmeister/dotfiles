#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# XCP-NG Helper Script Deployment Tool
# ============================================================================
# This script deploys and manages helper scripts on the NFS shared storage,
# making them accessible from all cluster hosts.
#
# This is a CLI wrapper around the xen_deploy library.
# For programmatic access, source tests/lib/xen_deploy.zsh directly.
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
#
# ============================================================================
# Load Dependencies
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load UI libraries
source "$DF_DIR/bin/lib/colors.zsh" 2>/dev/null
source "$DF_DIR/bin/lib/ui.zsh" 2>/dev/null

# Load deployment library (which loads cluster library)
source "$SCRIPT_DIR/lib/xen_deploy.zsh" || {
    echo "Error: Could not load xen_deploy.zsh library"
    exit 1
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

# Execute command using library functions
case "$COMMAND" in
    deploy)
        if [[ -n "$TARGET_HOST" ]]; then
            xen_deploy_single_script "$SCRIPT_PATH" "$TARGET_HOST"
        else
            xen_deploy_single_script "$SCRIPT_PATH"
        fi
        ;;
    deploy-all)
        if [[ -n "$TARGET_HOST" ]]; then
            xen_deploy_all_scripts "$TARGET_HOST"
        else
            xen_deploy_all_scripts
        fi
        ;;
    migrate)
        if [[ -n "$TARGET_HOST" ]]; then
            xen_deploy_migrate_scripts "$TARGET_HOST"
        else
            xen_deploy_migrate_scripts
        fi
        ;;
    list)
        if [[ -n "$TARGET_HOST" ]]; then
            xen_deploy_list_scripts "$TARGET_HOST"
        else
            xen_deploy_list_scripts
        fi
        ;;
    verify)
        xen_deploy_verify_access
        ;;
    status)
        xen_deploy_cluster_status
        ;;
    *)
        print_error "No command specified"
        show_help
        exit 1
        ;;
esac

exit $?
