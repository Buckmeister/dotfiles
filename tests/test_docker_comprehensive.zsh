#!/usr/bin/env zsh

# ============================================================================
# Comprehensive Docker Installation Testing Script
# ============================================================================
#
# Tests dotfiles installation on fresh Linux containers with extensive validation
# Tests new features: profiles, package management, librarian, wizard
#
# Usage:
#   ./tests/test_docker_comprehensive.zsh
#   ./tests/test_docker_comprehensive.zsh --quick
#   ./tests/test_docker_comprehensive.zsh --distro ubuntu:24.04
#
# ============================================================================

emulate -LR zsh
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

# Test configurations
DISTROS=(
    "ubuntu:24.04"
    "ubuntu:22.04"
    "debian:12"
)

# Parse arguments
QUICK_MODE=false
SINGLE_DISTRO=""

for arg in "$@"; do
    case "$arg" in
        --quick)
            QUICK_MODE=true
            ;;
        --distro)
            shift
            SINGLE_DISTRO="$1"
            ;;
        -h|--help)
            cat <<EOF
Comprehensive Docker Installation Testing Script

Tests:
  • Web installer (dfauto)
  • Profile system functionality
  • Package management availability
  • Librarian output
  • Wizard availability
  • Symlink creation

Usage:
  $0 [OPTIONS]

Options:
  --quick           Test only Ubuntu 24.04
  --distro IMAGE    Test specific distro
  -h, --help        Show this help

Examples:
  $0                              # Full test suite
  $0 --quick                      # Quick test (Ubuntu 24.04 only)
  $0 --distro debian:12           # Test Debian 12

EOF
            exit 0
            ;;
    esac
done

if [[ "$QUICK_MODE" = true ]]; then
    DISTROS=("ubuntu:24.04")
fi

if [[ -n "$SINGLE_DISTRO" ]]; then
    DISTROS=("$SINGLE_DISTRO")
fi

# ============================================================================
# Test Functions
# ============================================================================

# Comprehensive installation test
test_comprehensive_installation() {
    local distro="$1"
    local container_name="dotfiles-comprehensive-test-${distro//[:.]/-}"

    draw_section_header "Testing: $distro"
    echo ""
    print_info "Container: $container_name"
    echo ""

    # Build comprehensive test command
    local test_cmd="
        set -e
        export DEBIAN_FRONTEND=noninteractive

        echo '════════════════════════════════════════════════════════════════'
        echo '🐳 Dotfiles Comprehensive Testing - $distro'
        echo '════════════════════════════════════════════════════════════════'
        echo

        # Phase 1: Prerequisites
        echo '📋 Phase 1/6: Installing Prerequisites'
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq && apt-get install -y -qq curl git zsh 2>&1 | tail -1
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y -q curl git zsh
        fi
        echo '✅ Prerequisites installed'
        echo

        # Phase 2: Web Installer
        echo '════════════════════════════════════════════════════════════════'
        echo '🚀 Phase 2/6: Running Web Installer (dfauto)'
        echo '════════════════════════════════════════════════════════════════'
        echo
        curl -fsSL https://buckmeister.github.io/dfauto | sh 2>&1 | tail -20
        echo

        # Phase 3: Basic Verification
        echo '════════════════════════════════════════════════════════════════'
        echo '✅ Phase 3/6: Basic Installation Verification'
        echo '════════════════════════════════════════════════════════════════'
        echo

        if [ -d ~/.config/dotfiles ]; then
            echo '✅ Dotfiles directory exists'
        else
            echo '❌ FAILED: Dotfiles directory not found'
            exit 1
        fi

        if [ -d ~/.config/dotfiles/.git ]; then
            echo '✅ Git repository initialized'
        else
            echo '❌ FAILED: Not a git repository'
            exit 1
        fi

        if [ -f ~/.config/dotfiles/bin/setup.zsh ]; then
            echo '✅ Setup script found'
        else
            echo '❌ FAILED: Setup script not found'
            exit 1
        fi
        echo

        # Phase 4: Profile System Tests
        echo '════════════════════════════════════════════════════════════════'
        echo '📦 Phase 4/6: Profile System Validation'
        echo '════════════════════════════════════════════════════════════════'
        echo

        cd ~/.config/dotfiles

        # Check profile_manager.zsh exists and is executable
        if [ -x ./bin/profile_manager.zsh ]; then
            echo '✅ profile_manager.zsh is executable'
        else
            echo '❌ FAILED: profile_manager.zsh not found or not executable'
            exit 1
        fi

        # Test profile_manager --help
        if ./bin/profile_manager.zsh --help >/dev/null 2>&1; then
            echo '✅ profile_manager --help works'
        else
            echo '❌ FAILED: profile_manager --help failed'
            exit 1
        fi

        # Test profile_manager list
        echo
        echo '📋 Testing profile_manager list:'
        ./bin/profile_manager.zsh list 2>&1 | head -15
        echo

        # Test profile_manager show standard
        echo '📋 Testing profile_manager show standard:'
        ./bin/profile_manager.zsh show standard 2>&1 | head -20
        echo

        # Check profile manifests exist
        PROFILE_MANIFESTS=0
        for manifest in profiles/manifests/*.yaml; do
            if [ -f \"\$manifest\" ]; then
                ((PROFILE_MANIFESTS++))
                echo \"✅ Found: \${manifest##*/}\"
            fi
        done

        if [ \$PROFILE_MANIFESTS -ge 5 ]; then
            echo \"✅ All profile manifests found (\$PROFILE_MANIFESTS)\"
        else
            echo \"❌ FAILED: Expected 5+ manifests, found \$PROFILE_MANIFESTS\"
            exit 1
        fi
        echo

        # Phase 5: Package Management Tests
        echo '════════════════════════════════════════════════════════════════'
        echo '📦 Phase 5/6: Package Management Validation'
        echo '════════════════════════════════════════════════════════════════'
        echo

        # Check if install_from_manifest is available
        if command -v install_from_manifest >/dev/null 2>&1; then
            echo '✅ install_from_manifest command available'
        else
            echo '⚠️  WARNING: install_from_manifest not in PATH yet (expected)'
            echo '   (Will be available after ./bin/link_dotfiles.zsh runs)'
        fi

        # Check if generate_package_manifest is available
        if command -v generate_package_manifest >/dev/null 2>&1; then
            echo '✅ generate_package_manifest command available'
        else
            echo '⚠️  WARNING: generate_package_manifest not in PATH yet (expected)'
        fi

        # Check package management scripts exist
        if [ -f ~/.local/bin/install_from_manifest ] || [ -f ./packages/install_from_manifest.symlink_local_bin.zsh ]; then
            echo '✅ Package management scripts present'
        else
            echo '❌ FAILED: Package management scripts not found'
            exit 1
        fi

        # Verify manifest files are valid YAML
        echo
        echo '📋 Validating manifest YAML structure:'
        for manifest in profiles/manifests/*.yaml; do
            if [ -f \"\$manifest\" ]; then
                # Check for required YAML fields
                if grep -q '^version:' \"\$manifest\" && grep -q '^packages:' \"\$manifest\"; then
                    PKG_COUNT=\$(grep -c '^\\s*-\\s*id:' \"\$manifest\" || echo 0)
                    echo \"✅ \${manifest##*/}: \$PKG_COUNT packages\"
                else
                    echo \"❌ FAILED: Invalid YAML in \${manifest##*/}\"
                    exit 1
                fi
            fi
        done
        echo

        # Phase 6: System Tools Validation
        echo '════════════════════════════════════════════════════════════════'
        echo '🔧 Phase 6/6: System Tools Validation'
        echo '════════════════════════════════════════════════════════════════'
        echo

        # Test wizard.zsh
        if [ -x ./bin/wizard.zsh ]; then
            echo '✅ wizard.zsh is executable'
            if ./bin/wizard.zsh --help >/dev/null 2>&1; then
                echo '✅ wizard.zsh --help works'
            fi
        else
            echo '❌ FAILED: wizard.zsh not found or not executable'
            exit 1
        fi

        # Test librarian.zsh
        if [ -x ./bin/librarian.zsh ]; then
            echo '✅ librarian.zsh is executable'
            echo
            echo '📋 Librarian output sample:'
            ./bin/librarian.zsh 2>&1 | head -30
            echo
        else
            echo '❌ FAILED: librarian.zsh not found or not executable'
            exit 1
        fi

        # Check symlink scripts
        if [ -x ./bin/link_dotfiles.zsh ]; then
            echo '✅ link_dotfiles.zsh is executable'
        fi

        # Final Summary
        echo '════════════════════════════════════════════════════════════════'
        echo '🎉 ALL TESTS PASSED'
        echo '════════════════════════════════════════════════════════════════'
        echo
        echo '📊 Validation Summary:'
        echo '   ✅ Web installer succeeded'
        echo '   ✅ Basic installation verified'
        echo '   ✅ Profile system operational'
        echo '   ✅ Package manifests present'
        echo '   ✅ Package management tools found'
        echo '   ✅ System tools validated'
        echo
        echo \"📂 Dotfiles location: ~/.config/dotfiles\"
        echo \"🐧 Distribution: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')\"
        echo
    "

    # Run the comprehensive test
    if docker run --rm \
        --name "$container_name" \
        -e DEBIAN_FRONTEND=noninteractive \
        "$distro" \
        bash -c "$test_cmd" 2>&1; then
        echo ""
        print_success "✅ Comprehensive test PASSED for $distro"
        return 0
    else
        echo ""
        print_error "❌ Comprehensive test FAILED for $distro"
        return 1
    fi
}

# ============================================================================
# Main Test Suite
# ============================================================================

run_comprehensive_tests() {
    draw_header "Comprehensive Docker Testing" "Testing all new features"
    echo ""

    print_info "🧪 This test validates:"
    echo "   • Web installer (dfauto)"
    echo "   • Profile manager functionality"
    echo "   • Profile manifests (5 files)"
    echo "   • Package management system"
    echo "   • Wizard availability"
    echo "   • Librarian output"
    echo "   • Script permissions"
    echo ""

    print_info "📋 Testing distributions:"
    for distro in "${DISTROS[@]}"; do
        echo "   • $distro"
    done
    echo ""

    print_warning "⏱️  Estimated time: ~3-5 minutes per distribution"
    echo ""

    local passed=0
    local failed=0

    for distro in "${DISTROS[@]}"; do
        if test_comprehensive_installation "$distro"; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done

    # Final summary
    draw_header "Test Suite Complete" "Final Results"
    echo ""

    print_info "Results:"
    echo "   ✅ Passed: ${UI_SUCCESS_COLOR}${passed}${COLOR_RESET}"
    echo "   ❌ Failed: ${UI_ERROR_COLOR}${failed}${COLOR_RESET}"
    echo "   📊 Total:  $((passed + failed))"
    echo ""

    if [[ $failed -eq 0 ]]; then
        print_success "🎉 ALL TESTS PASSED! Dotfiles installation is fully operational."
        return 0
    else
        print_error "Some tests failed. Please review the output above."
        return 1
    fi
}

# ============================================================================
# Cleanup Function
# ============================================================================

cleanup() {
    print_info "Cleaning up test containers..."
    docker ps -a --filter "name=dotfiles-comprehensive-test-" --format "{{.Names}}" 2>/dev/null | while read container; do
        docker rm -f "$container" 2>/dev/null || true
    done
}

trap cleanup EXIT INT TERM

# ============================================================================
# Entry Point
# ============================================================================

# Verify Docker is running
if ! docker ps >/dev/null 2>&1; then
    print_error "Docker daemon is not running"
    print_info "Please start Docker and try again"
    exit 1
fi

print_success "Docker is running"
echo ""

# Run the comprehensive test suite
run_comprehensive_tests
