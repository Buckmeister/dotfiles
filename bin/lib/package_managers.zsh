#!/usr/bin/env zsh

# ============================================================================
# Package Managers Library - Cross-Platform Package Management
# ============================================================================
#
# This library provides a unified interface for managing packages across
# different package managers and platforms, with idempotent installation
# patterns and consistent error handling.
#
# Features:
# - System package managers (brew, apt, dnf, pacman)
# - Language-specific package managers (npm, cargo, gem, pipx, pip)
# - Idempotent installations (only install if not present)
# - Consistent error handling and user feedback
# - Version checking and validation
# ============================================================================

emulate -LR zsh

# ============================================================================
# Dependency: Load other shared libraries
# ============================================================================

# Try to load colors and ui libraries if not already loaded
if [[ -z "$COLOR_RESET" ]]; then
    local LIB_DIR="${0:a:h}"
    source "$LIB_DIR/colors.zsh" 2>/dev/null || true
    source "$LIB_DIR/ui.zsh" 2>/dev/null || true
    source "$LIB_DIR/utils.zsh" 2>/dev/null || true
fi

# ============================================================================
# System Package Managers
# ============================================================================

# Install a system package using the detected package manager
# Usage: pkg_install <package_name> [description]
function pkg_install() {
    local package="$1"
    local description="${2:-$package}"

    if ! command_exists "$package"; then
        print_info "Installing $description..."

        case "${DF_PKG_MANAGER:-unknown}" in
            brew)
                if brew install "$package" >/dev/null 2>&1; then
                    print_success "Installed $description"
                    return 0
                else
                    print_error "Failed to install $description"
                    return 1
                fi
                ;;
            apt)
                if sudo apt install -y "$package" >/dev/null 2>&1; then
                    print_success "Installed $description"
                    return 0
                else
                    print_error "Failed to install $description"
                    return 1
                fi
                ;;
            dnf)
                if sudo dnf install -y "$package" >/dev/null 2>&1; then
                    print_success "Installed $description"
                    return 0
                else
                    print_error "Failed to install $description"
                    return 1
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm "$package" >/dev/null 2>&1; then
                    print_success "Installed $description"
                    return 0
                else
                    print_error "Failed to install $description"
                    return 1
                fi
                ;;
            *)
                print_error "Unknown package manager: ${DF_PKG_MANAGER:-not set}"
                return 1
                ;;
        esac
    else
        print_success "$description already installed"
        return 0
    fi
}

# Check if a system package is installed
# Usage: pkg_is_installed <package_name>
function pkg_is_installed() {
    local package="$1"

    case "${DF_PKG_MANAGER:-unknown}" in
        brew)
            brew list "$package" >/dev/null 2>&1
            ;;
        apt)
            dpkg -l "$package" >/dev/null 2>&1
            ;;
        dnf)
            dnf list installed "$package" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================================
# npm - Node Package Manager
# ============================================================================

# Install a global npm package if not already installed
# Usage: npm_install_global <package_name> [description]
function npm_install_global() {
    local package="$1"
    local description="${2:-$package}"

    if ! command_exists npm; then
        print_error "npm not found - cannot install $description"
        return 1
    fi

    # Check if package is already installed globally
    if npm list -g "$package" >/dev/null 2>&1; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via npm..."
    if npm install -g "$package" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Check if an npm package is installed globally
# Usage: npm_is_installed <package_name>
function npm_is_installed() {
    local package="$1"
    command_exists npm && npm list -g "$package" >/dev/null 2>&1
}

# Install multiple npm packages from a list
# Usage: npm_install_from_list <file_path>
function npm_install_from_list() {
    local list_file="$1"

    if [[ ! -f "$list_file" ]]; then
        print_error "Package list not found: $list_file"
        return 1
    fi

    if ! command_exists npm; then
        print_error "npm not found - skipping npm packages"
        return 1
    fi

    local packages=(${(f)"$(grep -v '^#' "$list_file" | grep -v '^[[:space:]]*$')"})
    local total=${#packages[@]}
    local current=0

    print_info "Installing $total npm packages..."

    for package in "${packages[@]}"; do
        ((current++))
        npm_install_global "$package" "$package ($current/$total)"
    done

    print_success "Completed npm package installation"
}

# ============================================================================
# cargo - Rust Package Manager
# ============================================================================

# Install a cargo package if not already installed
# Usage: cargo_install <package_name> [description]
function cargo_install() {
    local package="$1"
    local description="${2:-$package}"

    if ! command_exists cargo; then
        print_error "cargo not found - cannot install $description"
        return 1
    fi

    # Check if binary is already in PATH (cargo installs create binaries)
    # Extract binary name (usually the package name, but can differ)
    local binary_name="$package"

    if command_exists "$binary_name"; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via cargo..."
    if cargo install "$package" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Install cargo package with specific features
# Usage: cargo_install_features <package_name> <features> [description]
function cargo_install_features() {
    local package="$1"
    local features="$2"
    local description="${3:-$package}"

    if ! command_exists cargo; then
        print_error "cargo not found - cannot install $description"
        return 1
    fi

    local binary_name="$package"

    if command_exists "$binary_name"; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via cargo (features: $features)..."
    if cargo install "$package" --features "$features" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Check if a cargo package is installed (by checking for binary)
# Usage: cargo_is_installed <binary_name>
function cargo_is_installed() {
    local binary_name="$1"
    command_exists "$binary_name"
}

# Install multiple cargo packages from a list
# Usage: cargo_install_from_list <file_path>
function cargo_install_from_list() {
    local list_file="$1"

    if [[ ! -f "$list_file" ]]; then
        print_error "Package list not found: $list_file"
        return 1
    fi

    if ! command_exists cargo; then
        print_error "cargo not found - skipping cargo packages"
        return 1
    fi

    local packages=(${(f)"$(grep -v '^#' "$list_file" | grep -v '^[[:space:]]*$')"})
    local total=${#packages[@]}
    local current=0

    print_info "Installing $total cargo packages..."

    for package in "${packages[@]}"; do
        ((current++))
        cargo_install "$package" "$package ($current/$total)"
    done

    print_success "Completed cargo package installation"
}

# ============================================================================
# gem - Ruby Package Manager
# ============================================================================

# Install a Ruby gem if not already installed
# Usage: gem_install <gem_name> [description]
function gem_install() {
    local gem="$1"
    local description="${2:-$gem}"

    if ! command_exists gem; then
        print_error "gem not found - cannot install $description"
        return 1
    fi

    if gem list -i "^${gem}$" >/dev/null 2>&1; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via gem..."
    if gem install "$gem" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Check if a Ruby gem is installed
# Usage: gem_is_installed <gem_name>
function gem_is_installed() {
    local gem="$1"
    command_exists gem && gem list -i "^${gem}$" >/dev/null 2>&1
}

# Install multiple gems from a list
# Usage: gem_install_from_list <file_path>
function gem_install_from_list() {
    local list_file="$1"

    if [[ ! -f "$list_file" ]]; then
        print_error "Package list not found: $list_file"
        return 1
    fi

    if ! command_exists gem; then
        print_error "gem not found - skipping Ruby gems"
        return 1
    fi

    local gems=(${(f)"$(grep -v '^#' "$list_file" | grep -v '^[[:space:]]*$')"})
    local total=${#gems[@]}
    local current=0

    print_info "Installing $total Ruby gems..."

    for gem in "${gems[@]}"; do
        ((current++))
        gem_install "$gem" "$gem ($current/$total)"
    done

    print_success "Completed gem installation"
}

# ============================================================================
# pip/pipx - Python Package Managers
# ============================================================================

# Install a Python package via pip if not already installed
# Usage: pip_install <package_name> [description]
function pip_install() {
    local package="$1"
    local description="${2:-$package}"

    if ! command_exists pip3; then
        print_error "pip3 not found - cannot install $description"
        return 1
    fi

    if pip3 list 2>/dev/null | grep -q "^${package} "; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via pip..."
    if pip3 install --user "$package" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Install a Python package via pipx (isolated environment) if not already installed
# Usage: pipx_install <package_name> [description]
function pipx_install() {
    local package="$1"
    local description="${2:-$package}"

    if ! command_exists pipx; then
        print_error "pipx not found - cannot install $description"
        return 1
    fi

    if pipx list 2>/dev/null | grep -q "package ${package} "; then
        print_success "$description already installed"
        return 0
    fi

    print_info "Installing $description via pipx..."
    if pipx install "$package" >/dev/null 2>&1; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Check if a pip package is installed
# Usage: pip_is_installed <package_name>
function pip_is_installed() {
    local package="$1"
    command_exists pip3 && pip3 list 2>/dev/null | grep -q "^${package} "
}

# Check if a pipx package is installed
# Usage: pipx_is_installed <package_name>
function pipx_is_installed() {
    local package="$1"
    command_exists pipx && pipx list 2>/dev/null | grep -q "package ${package} "
}

# Install multiple pip packages from a list
# Usage: pip_install_from_list <file_path>
function pip_install_from_list() {
    local list_file="$1"

    if [[ ! -f "$list_file" ]]; then
        print_error "Package list not found: $list_file"
        return 1
    fi

    if ! command_exists pip3; then
        print_error "pip3 not found - skipping pip packages"
        return 1
    fi

    local packages=(${(f)"$(grep -v '^#' "$list_file" | grep -v '^[[:space:]]*$')"})
    local total=${#packages[@]}
    local current=0

    print_info "Installing $total pip packages..."

    for package in "${packages[@]}"; do
        ((current++))
        pip_install "$package" "$package ($current/$total)"
    done

    print_success "Completed pip package installation"
}

# Install multiple pipx packages from a list
# Usage: pipx_install_from_list <file_path>
function pipx_install_from_list() {
    local list_file="$1"

    if [[ ! -f "$list_file" ]]; then
        print_error "Package list not found: $list_file"
        return 1
    fi

    if ! command_exists pipx; then
        print_error "pipx not found - skipping pipx packages"
        return 1
    fi

    local packages=(${(f)"$(grep -v '^#' "$list_file" | grep -v '^[[:space:]]*$')"})
    local total=${#packages[@]}
    local current=0

    print_info "Installing $total pipx packages..."

    for package in "${packages[@]}"; do
        ((current++))
        pipx_install "$package" "$package ($current/$total)"
    done

    print_success "Completed pipx package installation"
}

# ============================================================================
# Batch Installation Helpers
# ============================================================================

# Install multiple system packages at once
# Usage: pkg_install_batch <package1> <package2> ...
function pkg_install_batch() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    local failed=()

    print_info "Installing $total system packages..."

    for package in "${packages[@]}"; do
        ((current++))
        if ! pkg_install "$package" "$package ($current/$total)"; then
            failed+=("$package")
        fi
    done

    if [[ ${#failed[@]} -eq 0 ]]; then
        print_success "All packages installed successfully"
        return 0
    else
        print_warning "${#failed[@]} packages failed to install: ${failed[*]}"
        return 1
    fi
}

# ============================================================================
# Package Manager Availability Checks
# ============================================================================

# Check if npm is available
function has_npm() {
    command_exists npm
}

# Check if cargo is available
function has_cargo() {
    command_exists cargo
}

# Check if gem is available
function has_gem() {
    command_exists gem
}

# Check if pip is available
function has_pip() {
    command_exists pip3
}

# Check if pipx is available
function has_pipx() {
    command_exists pipx
}

# Print a summary of available package managers
function print_package_managers_status() {
    print_info "📦 Package Managers Status:"

    if command_exists "${DF_PKG_MANAGER:-}"; then
        print_success "   System: $DF_PKG_MANAGER"
    else
        print_warning "   System: none detected"
    fi

    has_npm && print_success "   npm: $(npm --version 2>/dev/null)" || print_warning "   npm: not available"
    has_cargo && print_success "   cargo: $(cargo --version 2>/dev/null | cut -d' ' -f2)" || print_warning "   cargo: not available"
    has_gem && print_success "   gem: $(gem --version 2>/dev/null)" || print_warning "   gem: not available"
    has_pip && print_success "   pip: $(pip3 --version 2>/dev/null | cut -d' ' -f2)" || print_warning "   pip: not available"
    has_pipx && print_success "   pipx: $(pipx --version 2>/dev/null)" || print_warning "   pipx: not available"

    echo
}
