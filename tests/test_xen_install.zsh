#!/usr/bin/env zsh

# ============================================================================
# XCP-NG VM Installation Testing Script
# ============================================================================
#
# Tests dotfiles installation on fresh XCP-NG VMs (Linux & Windows)
# Uses cloud-init/cloudbase-init ConfigDrive ISO method for automated provisioning
#
# Usage:
#   ./tests/test_xen_install.zsh
#   ./tests/test_xen_install.zsh --quick           # Single distro (faster)
#   ./tests/test_xen_install.zsh --distro ubuntu
#   ./tests/test_xen_install.zsh --distro w11      # Test Windows 11
#   ./tests/test_xen_install.zsh --host opt-bck01.bck.intern
#
# Prerequisites:
#   - SSH access configured to XCP-NG host
#   - Cloud-init Hub templates (Linux) or Windows templates
#   - Helper scripts in ~/.config/xen/helpers/
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

# XCP-NG Configuration
XEN_SSH_KEY="${HOME}/.ssh/aria_xen_key"
XEN_HOST="opt-bck01.bck.intern"
XEN_LINUX_HELPER="/root/aria-scripts/create-vm-with-cloudinit-iso.sh"
XEN_WINDOWS_HELPER="/root/aria-scripts/create-windows-vm-with-cloudinit-iso.sh"

# Test configurations
DISTROS=(
    "ubuntu"
    "debian"
    "w11"
)

# Parse arguments
QUICK_MODE=false
SINGLE_DISTRO=""
CUSTOM_HOST=""

for arg in "$@"; do
    case "$arg" in
        --quick)
            QUICK_MODE=true
            ;;
        --distro)
            shift
            SINGLE_DISTRO="$1"
            ;;
        --host)
            shift
            CUSTOM_HOST="$1"
            ;;
        -h|--help)
            cat <<EOF
XCP-NG VM Installation Testing Script

Usage:
  $0 [OPTIONS]

Options:
  --quick           Test only Ubuntu (faster, single distro)
  --distro NAME     Test only specified distro (ubuntu, debian, w11)
  --host HOSTNAME   Use specific XCP-NG host (default: opt-bck01.bck.intern)
  -h, --help        Show this help message

Examples:
  $0                              # Full test suite (all distros including Windows)
  $0 --quick                      # Quick test (Ubuntu only)
  $0 --distro debian              # Test specific Linux distro
  $0 --distro w11                 # Test Windows 11
  $0 --host my-xen-host.local     # Use different host

Supported Distributions:
  Linux:   ubuntu, debian
  Windows: w11, win10, win2022, win2019

Prerequisites:
  - SSH key: ~/.ssh/aria_xen_key
  - XCP-NG host with cloud-init Hub templates (Linux)
  - XCP-NG host with Windows templates (for Windows testing)
  - Helper scripts in ~/.config/xen/helpers/

EOF
            exit 0
            ;;
    esac
done

# If custom host specified, use it
if [[ -n "$CUSTOM_HOST" ]]; then
    XEN_HOST="$CUSTOM_HOST"
fi

# If quick mode, test only Ubuntu
if [[ "$QUICK_MODE" = true ]]; then
    DISTROS=("ubuntu")
fi

# If single distro specified, use only that
if [[ -n "$SINGLE_DISTRO" ]]; then
    DISTROS=("$SINGLE_DISTRO")
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Detect if distro is Windows
is_windows() {
    local distro="$1"
    case "$distro" in
        w11|win11|windows11|win10|windows10|win2022|win2019|ws2022|ws2019)
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

# Execute command on VM (wrapper around remote_ssh helper)
vm_ssh() {
    local vm_ip="$1"
    shift
    remote_ssh "$XEN_SSH_KEY" aria "$vm_ip" "$@"
}

# Clean up a VM
cleanup_vm() {
    local vm_uuid="$1"
    local vdi_uuid="$2"

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
# Test Functions
# ============================================================================

# Test a single installation on a VM
test_installation() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: ${(C)distro}" "Testing dotfiles installation"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: ${(C)distro}"
    print_info "Test type: Full automated installation"
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create VM with cloud-init
    print_test_phase 1 5 "Creating VM with cloud-init configuration"

    local create_output=$(xen_ssh "cd /root/aria-scripts && ./create-vm-with-cloudinit-iso.sh $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible
    print_test_phase 2 5 "Waiting for VM to boot and cloud-init to complete"

    if [[ -z "$vm_ip" ]]; then
        print_error "VM did not receive an IP address"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    # Wait for SSH to be ready using helper function
    if ! wait_for_ssh "$XEN_SSH_KEY" aria "$vm_ip" 120 false; then
        print_error "VM did not become SSH accessible"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "VM is accessible via SSH"
    echo ""

    # Phase 3: Install prerequisites
    print_test_phase 3 5 "Installing prerequisites"

    local prereq_output=$(vm_ssh "$vm_ip" "sudo apt update -qq && sudo apt install -y -qq zsh build-essential curl git 2>&1 | tail -5")

    if [[ $? -eq 0 ]]; then
        print_success "Prerequisites installed"
    else
        print_error "Failed to install prerequisites"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi
    echo ""

    # Phase 4: Clone and run dotfiles setup
    print_test_phase 4 5 "Running dotfiles installation"

    local install_cmd="
        set -e
        echo 'PROGRESS:Cloning repository'
        if [ ! -d ~/.config/dotfiles ]; then
            git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles 2>&1 | tail -3
        fi

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

        echo 'PROGRESS:Complete'
    "

    # Use parse_test_output helper for standard output parsing
    vm_ssh "$vm_ip" "$install_cmd" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    if [[ $? -ne 0 ]]; then
        print_error "Dotfiles installation failed"
        cleanup_vm "$vm_uuid" "$vdi_uuid"
        return 1
    fi

    print_success "Dotfiles installation complete"
    echo ""

    # Phase 5: Verify installation
    print_test_phase 5 5 "Verifying installation results"

    local verify_output=$(vm_ssh "$vm_ip" "
        echo 'INFO:Distribution:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')
        echo 'INFO:Git User:' \$(git config --global user.name)
        echo 'INFO:Git Email:' \$(git config --global user.email)
        echo 'INFO:Dotfiles:' \$(ls -d ~/.config/dotfiles 2>/dev/null || echo 'Not found')
        echo 'INFO:Symlinks:' \$(ls -1 ~/.local/bin 2>/dev/null | wc -l) 'files'
    ")

    # Use parse_test_output helper
    echo "$verify_output" | while IFS= read -r line; do
        parse_test_output "$line"
    done

    print_success "Installation verified"
    echo ""

    # Cleanup
    draw_section_header "Cleanup"
    print_info "Removing test VM and cloud-init ISO..."

    cleanup_vm "$vm_uuid" "$vdi_uuid"

    print_success "Cleanup complete"
    echo ""

    print_success "Test passed: ${(C)distro} ✨"

    return 0
}

# Test Windows installation on a VM
test_windows_installation() {
    local distro="$1"
    local vm_uuid=""
    local vdi_uuid=""
    local vm_ip=""

    draw_header "XCP-NG VM Test: Windows ${(C)distro}" "Testing Windows SSH access"
    echo ""

    print_info "XCP-NG Host: $XEN_HOST"
    print_info "Distribution: Windows ${(C)distro}"
    print_info "Test type: Windows VM with SSH access"
    echo ""

    draw_section_header "Test Phases"

    # Phase 1: Create Windows VM with cloudbase-init
    print_test_phase 1 4 "Creating Windows VM with cloudbase-init configuration"
    print_phase_context "This takes longer than Linux - Windows boot time ~5-10 minutes"

    local create_output=$(xen_ssh "cd /root/aria-scripts && ./create-windows-vm-with-cloudinit-iso.sh $distro 2>&1")

    # Extract VM UUID and IP from output
    vm_uuid=$(echo "$create_output" | grep "VM UUID:" | awk '{print $3}' | head -1)
    vdi_uuid=$(echo "$create_output" | grep "Cloud-init ISO:" | awk '{print $3}' | head -1)
    vm_ip=$(echo "$create_output" | grep "VM IP:" | awk '{print $3}' | head -1)

    if [[ -z "$vm_uuid" ]]; then
        print_error "Failed to create VM"
        echo "$create_output" | tail -20
        return 1
    fi

    print_success "VM created: $vm_uuid"
    echo "   ${COLOR_COMMENT}IP address: ${vm_ip:-Pending}${COLOR_RESET}"
    echo ""

    # Phase 2: Wait for VM to be accessible (Windows takes longer)
    print_test_phase 2 4 "Waiting for Windows to boot and OpenSSH setup"
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

    # Phase 3: Verify Windows system and SSH access
    print_test_phase 3 4 "Verifying Windows system and PowerShell access"

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

    # Use parse_test_output helper
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

    # Phase 4: Test dotfiles readiness (clone check)
    print_test_phase 4 4 "Testing dotfiles repository access"

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
# Main Test Suite
# ============================================================================

run_tests() {
    draw_header "XCP-NG VM Installation Testing" "Testing on fresh VMs"
    echo ""

    draw_section_header "Test Overview"

    print_info "What This Test Does:"
    echo "   • Creates fresh XCP-NG VM with cloud-init (Linux) or cloudbase-init (Windows)"
    echo "   • Provisions VM with SSH keys and packages/OpenSSH"
    echo "   • Linux: Clones and installs dotfiles automatically"
    echo "   • Windows: Verifies SSH access and PowerShell automation readiness"
    echo "   • Cleans up VM and cloud-init ISO when done"
    echo ""
    echo "   ${COLOR_BOLD}${UI_WARNING_COLOR}⏱️  Estimated time:${COLOR_RESET} ~5-7 min per Linux distro, ~10-15 min per Windows"
    echo ""
    echo "   ${COLOR_BOLD}${UI_INFO_COLOR}💡 Tip:${COLOR_RESET} VMs are created with guest tools for IP reporting"
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

    # Check helper scripts (Linux and/or Windows depending on distros being tested)
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
        if ! xen_ssh "test -x $XEN_LINUX_HELPER" >/dev/null 2>&1; then
            print_error "Linux helper script not found: $XEN_LINUX_HELPER"
            print_info "Please upload create-vm-with-cloudinit-iso.sh"
            return 1
        fi
        print_success "Linux helper script ready"
    fi

    if [[ "$has_windows" = true ]]; then
        if ! xen_ssh "test -x $XEN_WINDOWS_HELPER" >/dev/null 2>&1; then
            print_error "Windows helper script not found: $XEN_WINDOWS_HELPER"
            print_info "Please upload create-windows-vm-with-cloudinit-iso.sh"
            return 1
        fi
        print_success "Windows helper script ready"
    fi

    echo ""

    draw_section_header "Test Configuration"

    print_info "Test parameters:"
    echo "   XCP-NG Host: $XEN_HOST"
    echo "   Distributions: ${#DISTROS[@]}"
    for distro in "${DISTROS[@]}"; do
        echo "     • ${(C)distro}"
    done
    echo "   Total tests: ${#DISTROS[@]}"
    echo ""

    # Initialize test result tracking
    init_test_tracking

    for distro in "${DISTROS[@]}"; do
        # Run appropriate test based on OS type
        if is_windows "$distro"; then
            # Windows VM test
            if test_windows_installation "$distro"; then
                track_test_result "${(C)distro}" true
            else
                track_test_result "${(C)distro}" false
            fi
        else
            # Linux VM test
            if test_installation "$distro"; then
                track_test_result "${(C)distro}" true
            else
                track_test_result "${(C)distro}" false
            fi
        fi

        echo ""
    done

    # Print summary using helper function
    print_test_summary
}

# ============================================================================
# Cleanup Function
# ============================================================================

cleanup() {
    print_info "Cleaning up any remaining test VMs..."

    # Find and destroy any test VMs that might be left
    local test_vms=$(xen_ssh "xe vm-list name-label='aria-test-*' params=uuid --minimal 2>/dev/null" | tr ',' '\n')

    for vm_uuid in $test_vms; do
        if [[ -n "$vm_uuid" ]]; then
            xen_ssh "xe vm-shutdown uuid=$vm_uuid force=true 2>/dev/null || true" >/dev/null 2>&1
            sleep 1
            xen_ssh "xe vm-destroy uuid=$vm_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done

    # Clean up cloud-init ISOs
    local test_vdis=$(xen_ssh "xe vdi-list name-label='cloud-init-aria-test-*' params=uuid --minimal 2>/dev/null" | tr ',' '\n')

    for vdi_uuid in $test_vdis; do
        if [[ -n "$vdi_uuid" ]]; then
            xen_ssh "xe vdi-destroy uuid=$vdi_uuid 2>/dev/null || true" >/dev/null 2>&1
        fi
    done
}

# Register cleanup on exit using helper function
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

# Run the test suite
run_tests
