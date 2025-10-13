#!/usr/bin/env zsh

# ============================================================================
# Language Servers Installation
# ============================================================================
#
# Downloads and installs various language servers (JDT.LS, OmniSharp, etc.)
# Uses shared libraries for consistent downloading, extraction, and installation.
#
# Installed language servers:
# - JDT.LS (Java Language Server)
# - OmniSharp (C# Language Server)
# - rust-analyzer (Rust Language Server, Linux only)
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/os_operations.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

# Installation directories (following standard paths)
JDTLS_DIR="/usr/local/share/jdt.ls"
OMNISHARP_DIR="/usr/local/share/omnisharp"

# ============================================================================
# Helper Functions
# ============================================================================

# Install with sudo on Linux, without on macOS
function os_aware_command() {
    local cmd="$@"
    case "${DF_OS:-$(get_os)}" in
        linux)
            sudo $cmd
            ;;
        macos)
            $cmd
            ;;
        *)
            $cmd
            ;;
    esac
}

# ============================================================================
# JDT.LS (Java Language Server) Installation
# ============================================================================

function install_jdtls() {
    draw_section_header "JDT.LS (Java Language Server)"

    # Try to use specialized JDT.LS downloader if available
    local download_url=""

    if command_exists get_jdtls_url; then
        print_info "Using specialized JDT.LS downloader..."
        download_url=$(get_jdtls_url -s 2>/dev/null)

        if [[ $? -eq 0 && -n "$download_url" ]]; then
            print_success "Found JDT.LS download URL"
        else
            print_warning "Specialized downloader failed, using fallback URL"
            download_url=""
        fi
    else
        print_info "JDT.LS downloader not available, using fallback URL"
    fi

    # Fallback to version-independent URL if needed
    if [[ -z "$download_url" ]]; then
        download_url="https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"
        print_info "Using fallback URL: $download_url"
    fi

    # Clean up existing installation
    if [[ -d "$JDTLS_DIR" ]]; then
        print_info "Removing existing JDT.LS installation..."
        os_aware_command rm -rf "$JDTLS_DIR"
    fi

    # Create directory
    print_info "Creating installation directory..."
    os_aware_command mkdir -p "$JDTLS_DIR"

    # Download archive
    local temp_archive="$DOWNLOAD_TEMP_DIR/jdt-language-server.tar.gz"
    if ! download_file "$download_url" "$temp_archive" "JDT.LS"; then
        print_error "Failed to download JDT.LS"
        return 1
    fi

    # Extract archive
    print_info "Extracting JDT.LS..."
    case "${DF_OS:-$(get_os)}" in
        linux)
            if sudo tar xzf "$temp_archive" --directory="$JDTLS_DIR" --strip-components=1 2>/dev/null; then
                print_success "JDT.LS extracted successfully"
            else
                print_error "Failed to extract JDT.LS"
                return 1
            fi
            ;;
        *)
            if tar xzf "$temp_archive" --directory="$JDTLS_DIR" --strip-components=1 2>/dev/null; then
                print_success "JDT.LS extracted successfully"
            else
                print_error "Failed to extract JDT.LS"
                return 1
            fi
            ;;
    esac

    # Cleanup
    rm -f "$temp_archive"

    print_success "JDT.LS installation complete!"
    echo
}

# ============================================================================
# OmniSharp (C# Language Server) Installation
# ============================================================================

function install_omnisharp() {
    draw_section_header "OmniSharp (C# Language Server)"

    # Determine download URL based on OS
    local download_url=""
    local archive_name=""

    case "${DF_OS:-$(get_os)}" in
        macos)
            download_url="https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.37.6/omnisharp-osx.tar.gz"
            archive_name="omnisharp-osx.tar.gz"
            ;;
        linux)
            download_url="https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-linux-x64.tar.gz"
            archive_name="omnisharp-linux.tar.gz"
            ;;
        *)
            print_error "Unsupported OS for OmniSharp: ${DF_OS:-unknown}"
            return 1
            ;;
    esac

    # Clean up existing installation
    if [[ -d "$OMNISHARP_DIR" ]]; then
        print_info "Removing existing OmniSharp installation..."
        os_aware_command rm -rf "$OMNISHARP_DIR"
    fi

    # Create directory
    print_info "Creating installation directory..."
    os_aware_command mkdir -p "$OMNISHARP_DIR"

    # Download archive
    local temp_archive="$DOWNLOAD_TEMP_DIR/$archive_name"
    if ! download_file "$download_url" "$temp_archive" "OmniSharp"; then
        print_error "Failed to download OmniSharp"
        return 1
    fi

    # Extract archive
    print_info "Extracting OmniSharp..."
    case "${DF_OS:-$(get_os)}" in
        linux)
            if sudo tar xzf "$temp_archive" --directory="$OMNISHARP_DIR" 2>/dev/null; then
                print_success "OmniSharp extracted successfully"
            else
                print_error "Failed to extract OmniSharp"
                return 1
            fi
            ;;
        *)
            if tar xzf "$temp_archive" --directory="$OMNISHARP_DIR" 2>/dev/null; then
                print_success "OmniSharp extracted successfully"
            else
                print_error "Failed to extract OmniSharp"
                return 1
            fi
            ;;
    esac

    # Cleanup
    rm -f "$temp_archive"

    print_success "OmniSharp installation complete!"
    echo
}

# ============================================================================
# rust-analyzer (Rust Language Server) Installation
# ============================================================================

function install_rust_analyzer() {
    # Only install on Linux (macOS uses brew)
    if [[ "${DF_OS:-$(get_os)}" != "linux" ]]; then
        print_info "Skipping rust-analyzer (macOS uses brew installation)"
        return 0
    fi

    draw_section_header "rust-analyzer (Rust Language Server)"

    local download_url="https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux"
    local binary_name="rust-analyzer"
    local target_path="$INSTALL_BIN_DIR/$binary_name"

    # Check if already installed
    if command_exists "$binary_name"; then
        print_success "rust-analyzer already installed"
        echo
        return 0
    fi

    # Download binary
    if ! download_file "$download_url" "$target_path" "rust-analyzer"; then
        print_error "Failed to download rust-analyzer"
        return 1
    fi

    # Make executable
    if chmod +x "$target_path"; then
        print_success "rust-analyzer installed successfully"
    else
        print_error "Failed to make rust-analyzer executable"
        return 1
    fi

    echo
}

# ============================================================================
# Main Installation
# ============================================================================

draw_header "Language Servers" "Installing development language servers"
echo

# Ensure download directory exists
mkdir -p "$DOWNLOAD_TEMP_DIR"

# Install each language server
install_jdtls
install_omnisharp
install_rust_analyzer

# Cleanup temporary downloads
cleanup_temp_downloads

echo
print_success "All language servers installed successfully!"
echo
print_info "📍 Installation locations:"
echo "   JDT.LS:        $JDTLS_DIR"
echo "   OmniSharp:     $OMNISHARP_DIR"
[[ "${DF_OS:-$(get_os)}" == "linux" ]] && echo "   rust-analyzer: $INSTALL_BIN_DIR/rust-analyzer"

echo
print_success "$(get_random_friend_greeting)"
