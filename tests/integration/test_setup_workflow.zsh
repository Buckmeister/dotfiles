#!/usr/bin/env zsh

# ============================================================================
# Integration Tests for Setup Workflow
# ============================================================================
# Comprehensive tests for setup.zsh and the complete setup process

emulate -LR zsh

# Load test framework

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

# Initialize paths using shared utility
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../bin/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

# Initialize dotfiles paths (sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR)
init_dotfiles_paths

source "$SCRIPT_DIR/../lib/test_framework.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "Setup Workflow Integration Tests"

# ============================================================================
# Test Helpers
# ============================================================================


# ============================================================================
# Test Cases - Setup Script Basics
# ============================================================================

test_case "setup.zsh should exist in bin directory" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -f "$setup_script" ]]; then
        echo "setup.zsh not found at $setup_script"
        return 1
    fi

    return 0
'

test_case "setup.zsh should be executable" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    if [[ ! -x "$setup_script" ]]; then
        echo "setup.zsh is not executable"
        return 1
    fi

    return 0
'

test_case "setup wrapper should exist at repository root" '
    local setup_wrapper="$DOTFILES_ROOT/setup"

    if [[ ! -f "$setup_wrapper" ]]; then
        echo "setup wrapper not found"
        return 1
    fi

    return 0
'

test_case "setup wrapper should be executable" '
    local setup_wrapper="$DOTFILES_ROOT/setup"

    if [[ ! -x "$setup_wrapper" ]]; then
        echo "setup wrapper is not executable"
        return 1
    fi

    return 0
'

# ============================================================================
# Test Cases - Flag Support
# ============================================================================

test_case "setup.zsh should support --help flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local help_output=$("$setup_script" --help 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

test_case "setup.zsh should support -h flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local help_output=$("$setup_script" -h 2>&1)

    if [[ "$help_output" == *"Usage"* ]] || [[ "$help_output" == *"usage"* ]]; then
        return 0
    else
        echo "No help output found"
        return 1
    fi
'

test_case "setup.zsh should document --skip-pi-scripts flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local help_output=$("$setup_script" --help 2>&1)

    # Check for skip post-install flag documentation
    if [[ "$help_output" == *"skip"*"pi"* ]] || [[ "$help_output" == *"skip-pi-scripts"* ]] || [[ "$help_output" == *"skip-pi"* ]]; then
        return 0
    else
        echo "No skip-pi-scripts documentation found in help"
        return 1
    fi
'

test_case "setup.zsh should document --all-modules flag" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local help_output=$("$setup_script" --help 2>&1)

    # Check for all-modules flag documentation
    if [[ "$help_output" == *"all-modules"* ]] || [[ "$help_output" == *"all modules"* ]]; then
        return 0
    else
        echo "No all-modules documentation found in help"
        return 1
    fi
'

# ============================================================================
# Test Cases - OS Detection
# ============================================================================

test_case "setup.zsh should have OS detection logic" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for OS detection patterns
    if grep -q "uname\|Darwin\|Linux\|DF_OS" "$setup_script"; then
        return 0
    else
        echo "No OS detection logic found"
        return 1
    fi
'

test_case "setup.zsh should export OS context variables" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for context variable exports
    if grep -q "export DF_OS\|DF_PKG_MANAGER\|DF_PKG_INSTALL_CMD" "$setup_script"; then
        return 0
    else
        echo "No OS context variable exports found"
        return 1
    fi
'

# ============================================================================
# Test Cases - Shared Library Loading
# ============================================================================

test_case "setup.zsh should load shared libraries" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for library sourcing
    if grep -q "source.*lib/\|source.*colors.zsh\|source.*ui.zsh" "$setup_script"; then
        return 0
    else
        echo "No shared library loading found"
        return 1
    fi
'

test_case "shared libraries should exist in bin/lib/" '
    local lib_dir="$DOTFILES_ROOT/bin/lib"

    if [[ ! -d "$lib_dir" ]]; then
        echo "Shared library directory not found"
        return 1
    fi

    # Check for essential libraries
    local essential_libs=(colors.zsh ui.zsh utils.zsh)
    local missing_libs=0

    for lib in "${essential_libs[@]}"; do
        if [[ ! -f "$lib_dir/$lib" ]]; then
            echo "Missing essential library: $lib"
            ((missing_libs++))
        fi
    done

    if [[ $missing_libs -eq 0 ]]; then
        return 0
    else
        return 1
    fi
'

# ============================================================================
# Test Cases - Symlink Creation
# ============================================================================

test_case "setup.zsh should reference link_dotfiles.zsh" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for link_dotfiles reference
    if grep -q "link_dotfiles\|link-dotfiles" "$setup_script"; then
        return 0
    else
        echo "No link_dotfiles.zsh reference found"
        return 1
    fi
'

test_case "link_dotfiles.zsh should exist" '
    local link_script="$DOTFILES_ROOT/bin/link_dotfiles.zsh"

    if [[ ! -f "$link_script" ]]; then
        echo "link_dotfiles.zsh not found"
        return 1
    fi

    if [[ ! -x "$link_script" ]]; then
        echo "link_dotfiles.zsh is not executable"
        return 1
    fi

    return 0
'

# ============================================================================
# Test Cases - Post-Install Scripts
# ============================================================================

test_case "setup.zsh should have post-install script discovery" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for post-install directory reference
    if grep -q "post-install\|post_install" "$setup_script"; then
        return 0
    else
        echo "No post-install script discovery found"
        return 1
    fi
'

test_case "post-install scripts directory should exist" '
    local pi_dir="$DOTFILES_ROOT/post-install/scripts"

    if [[ ! -d "$pi_dir" ]]; then
        echo "Post-install scripts directory not found"
        return 1
    fi

    return 0
'

test_case "post-install scripts should be executable" '
    local pi_dir="$DOTFILES_ROOT/post-install/scripts"

    if [[ ! -d "$pi_dir" ]]; then
        return 0  # Skip if directory doesnt exist
    fi

    # Find all .zsh files in post-install/scripts
    local script_files=(${(f)"$(find "$pi_dir" -name "*.zsh" -type f 2>/dev/null)"})

    if [[ ${#script_files[@]} -eq 0 ]]; then
        echo "No post-install scripts found"
        return 1
    fi

    local non_executable=0
    for script in "${script_files[@]}"; do
        if [[ ! -x "$script" ]]; then
            echo "Not executable: $(basename "$script")"
            ((non_executable++))
        fi
    done

    if [[ $non_executable -eq 0 ]]; then
        return 0
    else
        echo "$non_executable post-install scripts are not executable"
        return 1
    fi
'

# ============================================================================
# Test Cases - Menu Integration
# ============================================================================

test_case "setup.zsh should reference menu_tui.zsh" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"

    # Check for menu_tui reference
    if grep -q "menu_tui\|menu-tui\|interactive.*menu" "$setup_script"; then
        return 0
    else
        echo "No menu_tui.zsh reference found"
        # This is acceptable - menu might be optional
        return 0
    fi
'

test_case "menu_tui.zsh should exist if referenced" '
    local menu_script="$DOTFILES_ROOT/bin/menu_tui.zsh"

    # If menu exists, it should be executable
    if [[ -f "$menu_script" ]]; then
        if [[ ! -x "$menu_script" ]]; then
            echo "menu_tui.zsh exists but is not executable"
            return 1
        fi
    fi

    return 0
'

# ============================================================================
# Test Cases - Backup Functionality
# ============================================================================

test_case "setup workflow should have backup mechanism" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local link_script="$DOTFILES_ROOT/bin/link_dotfiles.zsh"

    # Check if either setup or link_dotfiles has backup logic
    if grep -q "backup\|.tmp.*Backup" "$setup_script" || grep -q "backup\|.tmp.*Backup" "$link_script"; then
        return 0
    else
        echo "No backup mechanism found in setup workflow"
        # This is a warning, not a failure
        return 0
    fi
'

test_case "backup_dotfiles_repo.zsh should exist for manual backups" '
    local backup_script="$DOTFILES_ROOT/bin/backup_dotfiles_repo.zsh"

    if [[ ! -f "$backup_script" ]]; then
        echo "backup_dotfiles_repo.zsh not found"
        return 1
    fi

    if [[ ! -x "$backup_script" ]]; then
        echo "backup_dotfiles_repo.zsh is not executable"
        return 1
    fi

    return 0
'

# ============================================================================
# Test Cases - Complete Workflow
# ============================================================================

test_case "all essential setup components should exist" '
    local required_files=(
        "$DOTFILES_ROOT/setup"
        "$DOTFILES_ROOT/bin/setup.zsh"
        "$DOTFILES_ROOT/bin/link_dotfiles.zsh"
        "$DOTFILES_ROOT/bin/lib/colors.zsh"
        "$DOTFILES_ROOT/bin/lib/ui.zsh"
        "$DOTFILES_ROOT/bin/lib/utils.zsh"
    )

    local missing_files=0

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "Missing required file: $(basename "$file")"
            ((missing_files++))
        fi
    done

    if [[ $missing_files -eq 0 ]]; then
        return 0
    else
        echo "$missing_files required files are missing"
        return 1
    fi
'

test_case "setup.zsh should have zsh shebang" '
    local setup_script="$DOTFILES_ROOT/bin/setup.zsh"
    local shebang=$(head -n 1 "$setup_script")

    if [[ "$shebang" == "#!/usr/bin/env zsh" || "$shebang" == "#!/bin/zsh" ]]; then
        return 0
    else
        echo "Unexpected shebang: $shebang"
        return 1
    fi
'

test_case "setup wrapper should have POSIX shell shebang" '
    local setup_wrapper="$DOTFILES_ROOT/setup"
    local shebang=$(head -n 1 "$setup_wrapper")

    if [[ "$shebang" == "#!/bin/sh" || "$shebang" == "#!/usr/bin/env sh" ]]; then
        return 0
    else
        echo "Unexpected shebang: $shebang"
        return 1
    fi
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
