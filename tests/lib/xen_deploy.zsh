#!/usr/bin/env zsh

# ============================================================================
# XEN Helper Script Deployment Library
# ============================================================================
# Provides deployment and management functions for XCP-NG helper scripts
# on NFS shared storage, making them accessible from all cluster hosts.
#
# This library is sourced by:
#   - tests/deploy_xen_helpers.zsh (standalone deployment tool)
#   - tests/test_xen.zsh (integrated test workflow)
#
# Functions:
#   - xen_deploy_single_script()      Deploy specific script to NFS
#   - xen_deploy_all_scripts()        Deploy all helper scripts
#   - xen_deploy_migrate_scripts()    Migrate from /root/aria-scripts
#   - xen_deploy_list_scripts()       List scripts on NFS share
#   - xen_deploy_verify_access()      Verify NFS access across cluster
#   - xen_deploy_cluster_status()     Show cluster status
#   - xen_deploy_get_helper_scripts() Get array of helper scripts to deploy
#
# Dependencies:
#   - tests/lib/xen_cluster.zsh (cluster management)
#   - bin/lib/colors.zsh (color constants)
#   - bin/lib/ui.zsh (UI functions)
#
# ============================================================================

# Prevent double-sourcing
[[ -n "${_XEN_DEPLOY_LOADED:-}" ]] && return 0
_XEN_DEPLOY_LOADED=1

# ============================================================================
# Configuration
# ============================================================================

# Get script directory for finding helper scripts
_XEN_DEPLOY_LIB_DIR="${0:a:h}"
_XEN_DEPLOY_TESTS_DIR="${_XEN_DEPLOY_LIB_DIR:h}"
_XEN_DEPLOY_HELPERS_DIR="${_XEN_DEPLOY_TESTS_DIR}/helpers"

# Helper scripts that should be deployed to NFS
# Can be overridden by setting XEN_DEPLOY_HELPER_SCRIPTS before sourcing
typeset -ga XEN_DEPLOY_HELPER_SCRIPTS
if [[ ${#XEN_DEPLOY_HELPER_SCRIPTS[@]} -eq 0 ]]; then
    XEN_DEPLOY_HELPER_SCRIPTS=(
        "${_XEN_DEPLOY_HELPERS_DIR}/create-vm-with-cloudinit-iso.sh"
        "${_XEN_DEPLOY_HELPERS_DIR}/create-windows-vm-with-cloudinit-iso-v2.sh"
        "${_XEN_DEPLOY_HELPERS_DIR}/cleanup-test-vms.sh"
        "${_XEN_DEPLOY_HELPERS_DIR}/list-test-vms.sh"
    )
fi

# ============================================================================
# Public API Functions
# ============================================================================

# Deploy a single helper script to NFS
# Args:
#   $1 - Script path to deploy
#   $2 - (Optional) Hostname to use (default: auto-select)
# Returns:
#   0 on success, 1 on failure
function xen_deploy_single_script() {
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

# Deploy all helper scripts to NFS
# Args:
#   $1 - (Optional) Hostname to use (default: auto-select)
#   $2 - (Optional) "silent" to suppress headers
# Returns:
#   Number of failed deployments (0 = all succeeded)
function xen_deploy_all_scripts() {
    local hostname="${1:-$(xen_cluster_select_host)}"
    local silent="${2:-false}"

    if [[ "$silent" != "true" ]]; then
        echo
        draw_section_header "📦 Deploying All Helper Scripts to NFS"
        echo
    fi

    # Validate hostname
    if [[ -z "$hostname" ]]; then
        print_error "No available hosts found!"
        return 1
    fi

    if [[ "$silent" != "true" ]]; then
        print_info "Using host: $hostname"
        echo
    fi

    # Deploy each helper script
    local success_count=0
    local fail_count=0

    for script in "${XEN_DEPLOY_HELPER_SCRIPTS[@]}"; do
        if [[ -f "$script" ]]; then
            if xen_deploy_single_script "$script" "$hostname"; then
                success_count=$((success_count + 1))
            else
                fail_count=$((fail_count + 1))
            fi
        else
            print_warning "Script not found (skipping): $script"
        fi
        [[ "$silent" != "true" ]] && echo
    done

    if [[ "$silent" != "true" ]]; then
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
    fi

    return $fail_count
}

# Migrate existing helper scripts from /root/aria-scripts to NFS
# Args:
#   $1 - (Optional) Hostname to use (default: auto-select)
# Returns:
#   0 on success, 1 on failure
function xen_deploy_migrate_scripts() {
    local hostname="${1:-$(xen_cluster_select_host)}"

    echo
    draw_section_header "🔄 Migrating Existing Helper Scripts to NFS"
    echo

    # Validate hostname
    if [[ -z "$hostname" ]]; then
        print_error "No available hosts found!"
        return 1
    fi

    print_info "Using host: $hostname"
    echo

    # Call cluster migration function
    xen_cluster_migrate_helpers_to_nfs "$hostname"
}

# List helper scripts available on NFS share
# Args:
#   $1 - (Optional) Hostname to use (default: auto-select)
# Returns:
#   0 on success, 1 on failure
function xen_deploy_list_scripts() {
    local hostname="${1:-$(xen_cluster_select_host)}"

    echo
    draw_section_header "📋 Helper Scripts on NFS Share"
    echo

    # Validate hostname
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

# Verify NFS access across all cluster hosts
# Args: None
# Returns:
#   0 if all hosts can access NFS, 1 otherwise
function xen_deploy_verify_access() {
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

# Show cluster status
# Args: None
# Returns:
#   Exit code from xen_cluster_status
function xen_deploy_cluster_status() {
    xen_cluster_status
}

# Get array of helper scripts configured for deployment
# Prints each script path on a separate line
# Args: None
# Returns: 0
function xen_deploy_get_helper_scripts() {
    for script in "${XEN_DEPLOY_HELPER_SCRIPTS[@]}"; do
        echo "$script"
    done
}

# ============================================================================
# Library Initialization
# ============================================================================

# This function is called automatically when the library is sourced
# It ensures all dependencies are loaded
function _xen_deploy_init() {
    # Check if cluster library is loaded
    if ! typeset -f xen_cluster_init >/dev/null 2>&1; then
        # Try to load it
        local lib_dir="${0:a:h}"
        if [[ -f "${lib_dir}/xen_cluster.zsh" ]]; then
            source "${lib_dir}/xen_cluster.zsh" || {
                echo "Error: Failed to load xen_cluster.zsh" >&2
                return 1
            }
        else
            echo "Error: xen_cluster.zsh not found" >&2
            return 1
        fi
    fi

    return 0
}

# Initialize on source
_xen_deploy_init || {
    echo "Error: Failed to initialize xen_deploy library" >&2
    return 1
}
