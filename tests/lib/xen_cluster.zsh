#!/usr/bin/env zsh

# ============================================================================
# XCP-NG Cluster Management Library
# ============================================================================
# This library provides intelligent multi-host XEN cluster management with
# automatic failover, health monitoring, and load balancing across all
# cluster nodes.
#
# Features:
#   - Automatic host health checking
#   - Intelligent host selection (priority, round-robin, least-loaded)
#   - Seamless failover if primary host is unavailable
#   - Cluster-wide resource management
#   - NFS shared storage integration
#
# Usage:
#   source tests/lib/xen_cluster.zsh
#   xen_cluster_init
#   selected_host=$(xen_cluster_select_host)
#   xen_cluster_ssh "$selected_host" "xe host-list"

emulate -LR zsh

# ============================================================================
# Configuration
# ============================================================================

# Cluster hosts configuration (from test_config.yaml)
declare -A XEN_CLUSTER_HOSTS
XEN_CLUSTER_HOSTS=(
    [opt-bck01.bck.intern]="192.168.188.11:1:primary"
    [opt-bck02.bck.intern]="192.168.188.12:2:failover"
    [opt-bck03.bck.intern]="192.168.188.13:3:failover"
    [lat-bck04.bck.intern]="192.168.188.19:4:failover"
)

# Host status tracking
declare -A XEN_HOST_STATUS
declare -A XEN_HOST_LOAD

# Configuration
XEN_SSH_KEY="${XEN_SSH_KEY:-$HOME/.ssh/aria_xen_key}"
XEN_HEALTH_CHECK_TIMEOUT="${XEN_HEALTH_CHECK_TIMEOUT:-10}"
XEN_SELECTION_STRATEGY="${XEN_SELECTION_STRATEGY:-priority}"  # priority, round-robin, random, least-loaded

# NFS storage configuration
XEN_NFS_SR_UUID="${XEN_NFS_SR_UUID:-75fa3703-d020-e865-dd0e-3682b83c35f6}"
XEN_NFS_MOUNT_PATH="${XEN_NFS_MOUNT_PATH:-/var/run/sr-mount/$XEN_NFS_SR_UUID}"
XEN_NFS_SCRIPTS_DIR="${XEN_NFS_SCRIPTS_DIR:-$XEN_NFS_MOUNT_PATH/dotfiles-test-helpers}"

# Cluster state
XEN_CLUSTER_INITIALIZED=false
XEN_LAST_SELECTED_HOST=""
XEN_ROUND_ROBIN_INDEX=0

# ============================================================================
# Color Output
# ============================================================================

# Simple color definitions (fallback if not loaded)
[[ -z "$COLOR_RESET" ]] && COLOR_RESET='\033[0m'
[[ -z "$UI_SUCCESS_COLOR" ]] && UI_SUCCESS_COLOR='\033[32m'
[[ -z "$UI_ERROR_COLOR" ]] && UI_ERROR_COLOR='\033[31m'
[[ -z "$UI_WARNING_COLOR" ]] && UI_WARNING_COLOR='\033[33m'
[[ -z "$UI_INFO_COLOR" ]] && UI_INFO_COLOR='\033[90m'

# ============================================================================
# Host Health Monitoring
# ============================================================================

function xen_cluster_check_host_health() {
    local hostname="$1"
    local ip=$(echo "${XEN_CLUSTER_HOSTS[$hostname]}" | cut -d: -f1)

    # Quick ping check first (fast fail)
    if ! ping -c 1 -W 2 "$ip" >/dev/null 2>&1; then
        return 1
    fi

    # SSH connectivity check with timeout
    if timeout "$XEN_HEALTH_CHECK_TIMEOUT" ssh -i "$XEN_SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        root@"$hostname" "xe host-list params=name-label" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function xen_cluster_get_host_load() {
    local hostname="$1"

    # Get number of running VMs as a simple load metric
    local vm_count=$(ssh -i "$XEN_SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        root@"$hostname" "xe vm-list power-state=running params=name-label --minimal 2>/dev/null | tr ',' '\n' | wc -l" 2>/dev/null || echo "999")

    echo "$vm_count"
}

function xen_cluster_update_host_status() {
    local hostname="$1"

    if xen_cluster_check_host_health "$hostname"; then
        XEN_HOST_STATUS[$hostname]="available"
        XEN_HOST_LOAD[$hostname]=$(xen_cluster_get_host_load "$hostname")
        return 0
    else
        XEN_HOST_STATUS[$hostname]="unavailable"
        XEN_HOST_LOAD[$hostname]=999
        return 1
    fi
}

# ============================================================================
# Cluster Initialization
# ============================================================================

function xen_cluster_init() {
    if [[ "$XEN_CLUSTER_INITIALIZED" == true ]]; then
        return 0
    fi

    echo
    echo "${UI_INFO_COLOR}🖥️  Initializing XCP-NG Cluster Connection...${COLOR_RESET}"
    echo

    # Verify SSH key exists
    if [[ ! -f "$XEN_SSH_KEY" ]]; then
        echo "${UI_ERROR_COLOR}✗ SSH key not found: $XEN_SSH_KEY${COLOR_RESET}"
        return 1
    fi

    # Check all hosts and update their status
    local available_hosts=0
    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        echo -n "  Checking host: $hostname ... "

        if xen_cluster_update_host_status "$hostname"; then
            local load="${XEN_HOST_LOAD[$hostname]}"
            echo "${UI_SUCCESS_COLOR}✓ Available${COLOR_RESET} (load: $load VMs)"
            available_hosts=$((available_hosts + 1))
        else
            echo "${UI_ERROR_COLOR}✗ Unavailable${COLOR_RESET}"
        fi
    done

    echo

    if [[ $available_hosts -eq 0 ]]; then
        echo "${UI_ERROR_COLOR}✗ No cluster hosts are available!${COLOR_RESET}"
        return 1
    fi

    echo "${UI_SUCCESS_COLOR}✓ Cluster initialized with $available_hosts available host(s)${COLOR_RESET}"
    echo

    XEN_CLUSTER_INITIALIZED=true
    return 0
}

# ============================================================================
# Host Selection Strategies
# ============================================================================

function xen_cluster_select_by_priority() {
    # Select host with lowest priority number (1 is highest priority)
    local best_host=""
    local best_priority=999

    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        if [[ "${XEN_HOST_STATUS[$hostname]}" == "available" ]]; then
            local priority=$(echo "${XEN_CLUSTER_HOSTS[$hostname]}" | cut -d: -f2)

            if [[ $priority -lt $best_priority ]]; then
                best_priority=$priority
                best_host="$hostname"
            fi
        fi
    done

    echo "$best_host"
}

function xen_cluster_select_by_round_robin() {
    # Get list of available hosts sorted by priority
    local available_hosts=()
    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        if [[ "${XEN_HOST_STATUS[$hostname]}" == "available" ]]; then
            local priority=$(echo "${XEN_CLUSTER_HOSTS[$hostname]}" | cut -d: -f2)
            available_hosts+=("$priority:$hostname")
        fi
    done

    if [[ ${#available_hosts[@]} -eq 0 ]]; then
        return 1
    fi

    # Sort by priority
    available_hosts=(${(on)available_hosts})

    # Extract hostnames
    local host_list=()
    for entry in "${available_hosts[@]}"; do
        host_list+=("${entry#*:}")
    done

    # Select using round-robin index
    local selected="${host_list[$((XEN_ROUND_ROBIN_INDEX % ${#host_list[@]} + 1))]}"
    XEN_ROUND_ROBIN_INDEX=$((XEN_ROUND_ROBIN_INDEX + 1))

    echo "$selected"
}

function xen_cluster_select_by_least_loaded() {
    # Select host with lowest load (fewest running VMs)
    local best_host=""
    local best_load=999

    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        if [[ "${XEN_HOST_STATUS[$hostname]}" == "available" ]]; then
            local load="${XEN_HOST_LOAD[$hostname]}"

            if [[ $load -lt $best_load ]]; then
                best_load=$load
                best_host="$hostname"
            fi
        fi
    done

    echo "$best_host"
}

function xen_cluster_select_by_random() {
    # Select random available host
    local available_hosts=()
    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        if [[ "${XEN_HOST_STATUS[$hostname]}" == "available" ]]; then
            available_hosts+=("$hostname")
        fi
    done

    if [[ ${#available_hosts[@]} -eq 0 ]]; then
        return 1
    fi

    # Select random host
    local random_index=$(( (RANDOM % ${#available_hosts[@]}) + 1 ))
    echo "${available_hosts[$random_index]}"
}

# ============================================================================
# Main Host Selection
# ============================================================================

function xen_cluster_select_host() {
    local strategy="${1:-$XEN_SELECTION_STRATEGY}"

    # Initialize cluster if not done yet
    if [[ "$XEN_CLUSTER_INITIALIZED" != true ]]; then
        xen_cluster_init || return 1
    fi

    # Select host based on strategy
    local selected_host=""
    case "$strategy" in
        priority)
            selected_host=$(xen_cluster_select_by_priority)
            ;;
        round-robin)
            selected_host=$(xen_cluster_select_by_round_robin)
            ;;
        least-loaded)
            selected_host=$(xen_cluster_select_by_least_loaded)
            ;;
        random)
            selected_host=$(xen_cluster_select_by_random)
            ;;
        *)
            echo "${UI_ERROR_COLOR}✗ Unknown selection strategy: $strategy${COLOR_RESET}" >&2
            return 1
            ;;
    esac

    if [[ -z "$selected_host" ]]; then
        echo "${UI_ERROR_COLOR}✗ No available hosts found!${COLOR_RESET}" >&2
        return 1
    fi

    # Verify selected host is still available (health check might be stale)
    if ! xen_cluster_check_host_health "$selected_host"; then
        echo "${UI_WARNING_COLOR}⚠️  Selected host became unavailable, retrying...${COLOR_RESET}" >&2

        # Mark as unavailable and try again
        XEN_HOST_STATUS[$selected_host]="unavailable"

        # Recursive call with failover
        selected_host=$(xen_cluster_select_host "$strategy")
    fi

    XEN_LAST_SELECTED_HOST="$selected_host"
    echo "$selected_host"
}

# ============================================================================
# Cluster Operations
# ============================================================================

function xen_cluster_ssh() {
    local hostname="$1"
    shift

    ssh -i "$XEN_SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no \
        root@"$hostname" "$@"
}

function xen_cluster_scp() {
    local hostname="$1"
    local source="$2"
    local destination="$3"

    scp -i "$XEN_SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no \
        "$source" root@"$hostname":"$destination"
}

function xen_cluster_get_current_host() {
    echo "$XEN_LAST_SELECTED_HOST"
}

function xen_cluster_get_host_ip() {
    local hostname="$1"
    echo "${XEN_CLUSTER_HOSTS[$hostname]}" | cut -d: -f1
}

function xen_cluster_list_available_hosts() {
    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        if [[ "${XEN_HOST_STATUS[$hostname]}" == "available" ]]; then
            echo "$hostname"
        fi
    done
}

# ============================================================================
# NFS Shared Storage Operations
# ============================================================================

function xen_cluster_verify_nfs_access() {
    local hostname="$1"

    # Check if NFS mount exists
    if xen_cluster_ssh "$hostname" "test -d '$XEN_NFS_MOUNT_PATH'"; then
        return 0
    else
        return 1
    fi
}

function xen_cluster_get_nfs_scripts_dir() {
    echo "$XEN_NFS_SCRIPTS_DIR"
}

function xen_cluster_deploy_helper_to_nfs() {
    local hostname="$1"
    local local_script="$2"
    local script_name="$(basename "$local_script")"

    # Create scripts directory on NFS if it doesn't exist
    xen_cluster_ssh "$hostname" "mkdir -p '$XEN_NFS_SCRIPTS_DIR'" || return 1

    # Copy script to NFS
    echo "  Deploying $script_name to NFS share on $hostname..."
    xen_cluster_scp "$hostname" "$local_script" "$XEN_NFS_SCRIPTS_DIR/$script_name" || return 1

    # Make it executable
    xen_cluster_ssh "$hostname" "chmod +x '$XEN_NFS_SCRIPTS_DIR/$script_name'" || return 1

    echo "${UI_SUCCESS_COLOR}✓ Deployed $script_name to NFS (accessible from all hosts)${COLOR_RESET}"
    return 0
}

function xen_cluster_list_nfs_helpers() {
    local hostname="$1"

    xen_cluster_ssh "$hostname" "ls -lh '$XEN_NFS_SCRIPTS_DIR/' 2>/dev/null || echo 'No helpers found'"
}

# ============================================================================
# Cluster Status Reporting
# ============================================================================

function xen_cluster_status() {
    echo
    echo "════════════════════════════════════════════════════════════════"
    echo "  🖥️  XCP-NG Cluster Status"
    echo "════════════════════════════════════════════════════════════════"
    echo

    # Reinitialize to get fresh status
    XEN_CLUSTER_INITIALIZED=false
    xen_cluster_init

    echo "Cluster Configuration:"
    echo "  Selection Strategy: $XEN_SELECTION_STRATEGY"
    echo "  SSH Key: $XEN_SSH_KEY"
    echo "  NFS Scripts: $XEN_NFS_SCRIPTS_DIR"
    echo

    echo "Host Status:"
    for hostname in ${(k)XEN_CLUSTER_HOSTS}; do
        local info="${XEN_CLUSTER_HOSTS[$hostname]}"
        local ip=$(echo "$info" | cut -d: -f1)
        local priority=$(echo "$info" | cut -d: -f2)
        local role=$(echo "$info" | cut -d: -f3)
        local status="${XEN_HOST_STATUS[$hostname]}"
        local load="${XEN_HOST_LOAD[$hostname]}"

        if [[ "$status" == "available" ]]; then
            echo "  ${UI_SUCCESS_COLOR}✓${COLOR_RESET} $hostname ($ip)"
            echo "    Role: $role | Priority: $priority | Load: $load VMs"
        else
            echo "  ${UI_ERROR_COLOR}✗${COLOR_RESET} $hostname ($ip)"
            echo "    Role: $role | Priority: $priority | Status: Unavailable"
        fi
    done

    echo
    echo "════════════════════════════════════════════════════════════════"
    echo
}

# ============================================================================
# Helper Script Migration (from local to NFS)
# ============================================================================

function xen_cluster_migrate_helpers_to_nfs() {
    local hostname="$1"

    echo
    echo "${UI_INFO_COLOR}🔄 Migrating helper scripts to NFS share...${COLOR_RESET}"
    echo

    # Check if old helper scripts exist locally
    local old_helper_dir="/root/aria-scripts"
    local has_old_scripts=$(xen_cluster_ssh "$hostname" "test -d '$old_helper_dir' && echo 'yes' || echo 'no'")

    if [[ "$has_old_scripts" == "yes" ]]; then
        echo "  Found helper scripts in $old_helper_dir"

        # Create NFS scripts directory
        xen_cluster_ssh "$hostname" "mkdir -p '$XEN_NFS_SCRIPTS_DIR'" || {
            echo "${UI_ERROR_COLOR}✗ Failed to create NFS scripts directory${COLOR_RESET}"
            return 1
        }

        # Copy scripts to NFS
        echo "  Copying scripts to NFS share..."
        xen_cluster_ssh "$hostname" "cp -a $old_helper_dir/* '$XEN_NFS_SCRIPTS_DIR'/" || {
            echo "${UI_ERROR_COLOR}✗ Failed to copy scripts${COLOR_RESET}"
            return 1
        }

        # Backup and remove old directory
        echo "  Backing up and removing old directory..."
        xen_cluster_ssh "$hostname" "mv '$old_helper_dir' '${old_helper_dir}.bak.$(date +%Y%m%d)'" || {
            echo "${UI_WARNING_COLOR}⚠️  Could not remove old directory${COLOR_RESET}"
        }

        echo "${UI_SUCCESS_COLOR}✓ Helper scripts migrated to NFS successfully${COLOR_RESET}"
    else
        echo "  No old helper scripts found (already migrated or not present)"
    fi

    # List current scripts on NFS
    echo
    echo "Scripts available on NFS share:"
    xen_cluster_list_nfs_helpers "$hostname"
    echo
}

# ============================================================================
# Exports
# ============================================================================

# Export functions for use in test scripts
export -f xen_cluster_init
export -f xen_cluster_select_host
export -f xen_cluster_ssh
export -f xen_cluster_scp
export -f xen_cluster_get_current_host
export -f xen_cluster_get_host_ip
export -f xen_cluster_list_available_hosts
export -f xen_cluster_verify_nfs_access
export -f xen_cluster_get_nfs_scripts_dir
export -f xen_cluster_deploy_helper_to_nfs
export -f xen_cluster_list_nfs_helpers
export -f xen_cluster_status
export -f xen_cluster_migrate_helpers_to_nfs
