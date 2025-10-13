#!/usr/bin/env zsh

# ============================================================================
# Installers Library - Download, Extract, and Install Tools
# ============================================================================
#
# This library provides functions for downloading and installing tools from
# various sources (GitHub releases, direct URLs, etc.), with extraction,
# verification, and installation patterns.
#
# Features:
# - Download files from URLs with progress indication
# - Extract archives (tar.gz, zip, tar.xz, etc.)
# - Install binaries to standard locations
# - GitHub release/tag downloading patterns
# - Temporary file management and cleanup
# - Idempotent installation checks
# ============================================================================

emulate -LR zsh

# ============================================================================
# Dependency: Load other shared libraries
# ============================================================================

if [[ -z "$COLOR_RESET" ]]; then
    local LIB_DIR="${0:a:h}"
    source "$LIB_DIR/colors.zsh" 2>/dev/null || true
    source "$LIB_DIR/ui.zsh" 2>/dev/null || true
    source "$LIB_DIR/utils.zsh" 2>/dev/null || true
fi

# ============================================================================
# Configuration and Constants
# ============================================================================

# Default installation directories
: ${INSTALL_BIN_DIR:="$HOME/.local/bin"}
: ${INSTALL_LIB_DIR:="$HOME/.local/lib"}
: ${INSTALL_SHARE_DIR:="$HOME/.local/share"}
: ${DOWNLOAD_TEMP_DIR:="/tmp/dotfiles-installers"}

# Create directories if they don't exist
mkdir -p "$INSTALL_BIN_DIR" "$INSTALL_LIB_DIR" "$INSTALL_SHARE_DIR" "$DOWNLOAD_TEMP_DIR"

# ============================================================================
# Download Functions
# ============================================================================

# Download a file from a URL to a specified location
# Usage: download_file <url> <destination> [description]
function download_file() {
    local url="$1"
    local destination="$2"
    local description="${3:-file}"

    print_info "Downloading $description..."

    if command_exists curl; then
        if curl -fsSL -o "$destination" "$url" 2>/dev/null; then
            print_success "Downloaded $description"
            return 0
        else
            print_error "Failed to download $description from $url"
            return 1
        fi
    elif command_exists wget; then
        if wget -q -O "$destination" "$url" 2>/dev/null; then
            print_success "Downloaded $description"
            return 0
        else
            print_error "Failed to download $description from $url"
            return 1
        fi
    else
        print_error "Neither curl nor wget found - cannot download $description"
        return 1
    fi
}

# Download a file to temporary directory and return the path
# Usage: download_to_temp <url> <filename> [description]
function download_to_temp() {
    local url="$1"
    local filename="$2"
    local description="${3:-$filename}"
    local temp_file="$DOWNLOAD_TEMP_DIR/$filename"

    if download_file "$url" "$temp_file" "$description"; then
        echo "$temp_file"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Archive Extraction Functions
# ============================================================================

# Extract an archive to a specified directory
# Usage: extract_archive <archive_path> <destination_dir> [description]
function extract_archive() {
    local archive="$1"
    local dest_dir="$2"
    local description="${3:-archive}"

    if [[ ! -f "$archive" ]]; then
        print_error "Archive not found: $archive"
        return 1
    fi

    mkdir -p "$dest_dir"

    print_info "Extracting $description..."

    case "$archive" in
        *.tar.gz|*.tgz)
            if tar -xzf "$archive" -C "$dest_dir" 2>/dev/null; then
                print_success "Extracted $description"
                return 0
            fi
            ;;
        *.tar.xz|*.txz)
            if tar -xJf "$archive" -C "$dest_dir" 2>/dev/null; then
                print_success "Extracted $description"
                return 0
            fi
            ;;
        *.tar.bz2|*.tbz2)
            if tar -xjf "$archive" -C "$dest_dir" 2>/dev/null; then
                print_success "Extracted $description"
                return 0
            fi
            ;;
        *.tar)
            if tar -xf "$archive" -C "$dest_dir" 2>/dev/null; then
                print_success "Extracted $description"
                return 0
            fi
            ;;
        *.zip)
            if command_exists unzip; then
                if unzip -q "$archive" -d "$dest_dir" 2>/dev/null; then
                    print_success "Extracted $description"
                    return 0
                fi
            else
                print_error "unzip not found - cannot extract $description"
                return 1
            fi
            ;;
        *.gz)
            if gunzip -c "$archive" > "$dest_dir/$(basename "$archive" .gz)" 2>/dev/null; then
                print_success "Extracted $description"
                return 0
            fi
            ;;
        *)
            print_error "Unknown archive format: $archive"
            return 1
            ;;
    esac

    print_error "Failed to extract $description"
    return 1
}

# Extract and return the first directory created (useful for extracting releases)
# Usage: extract_archive_get_dir <archive_path> <destination_dir> [description]
function extract_archive_get_dir() {
    local archive="$1"
    local dest_dir="$2"
    local description="${3:-archive}"

    if ! extract_archive "$archive" "$dest_dir" "$description"; then
        return 1
    fi

    # Find the first directory created in dest_dir
    local extracted_dir=$(find "$dest_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)

    if [[ -n "$extracted_dir" ]]; then
        echo "$extracted_dir"
        return 0
    else
        # If no directory found, return the dest_dir itself
        echo "$dest_dir"
        return 0
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

# Install a binary file to the bin directory
# Usage: install_binary <source_path> <binary_name> [description]
function install_binary() {
    local source="$1"
    local binary_name="$2"
    local description="${3:-$binary_name}"
    local target="$INSTALL_BIN_DIR/$binary_name"

    if [[ ! -f "$source" ]]; then
        print_error "Source binary not found: $source"
        return 1
    fi

    print_info "Installing $description to $INSTALL_BIN_DIR..."

    if cp "$source" "$target" && chmod +x "$target"; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Install multiple binaries from a directory
# Usage: install_binaries_from_dir <source_dir> <pattern> [description]
function install_binaries_from_dir() {
    local source_dir="$1"
    local pattern="${2:-*}"
    local description="${3:-binaries}"

    if [[ ! -d "$source_dir" ]]; then
        print_error "Source directory not found: $source_dir"
        return 1
    fi

    local binaries=($(find "$source_dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null))

    if [[ ${#binaries[@]} -eq 0 ]]; then
        print_warning "No binaries found matching pattern: $pattern"
        return 1
    fi

    print_info "Installing ${#binaries[@]} $description..."

    local failed=0
    for binary in "${binaries[@]}"; do
        local binary_name=$(basename "$binary")
        if ! install_binary "$binary" "$binary_name" "$binary_name"; then
            ((failed++))
        fi
    done

    if [[ $failed -eq 0 ]]; then
        print_success "Installed all $description"
        return 0
    else
        print_warning "$failed binaries failed to install"
        return 1
    fi
}

# Install a directory to lib or share
# Usage: install_directory <source_dir> <target_name> <type> [description]
#   type: "lib" or "share"
function install_directory() {
    local source_dir="$1"
    local target_name="$2"
    local install_type="$3"
    local description="${4:-$target_name}"

    if [[ ! -d "$source_dir" ]]; then
        print_error "Source directory not found: $source_dir"
        return 1
    fi

    local target_dir
    case "$install_type" in
        lib)
            target_dir="$INSTALL_LIB_DIR/$target_name"
            ;;
        share)
            target_dir="$INSTALL_SHARE_DIR/$target_name"
            ;;
        *)
            print_error "Unknown installation type: $install_type (use 'lib' or 'share')"
            return 1
            ;;
    esac

    print_info "Installing $description to $target_dir..."

    # Remove existing directory if present
    if [[ -d "$target_dir" ]]; then
        rm -rf "$target_dir"
    fi

    if cp -r "$source_dir" "$target_dir"; then
        print_success "Installed $description"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

# Create a wrapper script in bin directory
# Usage: create_wrapper_script <binary_path> <wrapper_name> [description]
function create_wrapper_script() {
    local binary_path="$1"
    local wrapper_name="$2"
    local description="${3:-$wrapper_name}"
    local wrapper_file="$INSTALL_BIN_DIR/$wrapper_name"

    print_info "Creating wrapper script for $description..."

    cat > "$wrapper_file" <<EOF
#!/usr/bin/env bash
# Wrapper script for $description
exec "$binary_path" "\$@"
EOF

    if chmod +x "$wrapper_file"; then
        print_success "Created wrapper script for $description"
        return 0
    else
        print_error "Failed to create wrapper script"
        return 1
    fi
}

# ============================================================================
# GitHub Release/Tag Functions
# ============================================================================

# Download and install a GitHub release binary
# Usage: github_install_release <user> <repo> <tag> <asset_pattern> <binary_name> [description]
function github_install_release() {
    local user="$1"
    local repo="$2"
    local tag="$3"
    local asset_pattern="$4"
    local binary_name="$5"
    local description="${6:-$binary_name}"

    # Check if already installed
    if command_exists "$binary_name"; then
        print_success "$description already installed"
        return 0
    fi

    # Use get_github_url if available, otherwise construct URL directly
    local download_url
    if command_exists get_github_url; then
        download_url=$(get_github_url -u "$user" -r "$repo" -t "$tag" -p "$asset_pattern" 2>/dev/null)
    else
        # Fallback: construct basic release URL
        download_url="https://github.com/$user/$repo/releases/download/$tag/$asset_pattern"
    fi

    if [[ -z "$download_url" ]]; then
        print_error "Could not determine download URL for $description"
        return 1
    fi

    print_info "Installing $description from GitHub..."

    local temp_file=$(download_to_temp "$download_url" "$binary_name" "$description")
    if [[ -z "$temp_file" ]]; then
        return 1
    fi

    if install_binary "$temp_file" "$binary_name" "$description"; then
        rm -f "$temp_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Download and extract a GitHub release archive, then install
# Usage: github_install_release_archive <user> <repo> <tag> <asset_pattern> <binary_path_in_archive> <binary_name> [description]
function github_install_release_archive() {
    local user="$1"
    local repo="$2"
    local tag="$3"
    local asset_pattern="$4"
    local binary_path_in_archive="$5"
    local binary_name="$6"
    local description="${7:-$binary_name}"

    # Check if already installed
    if command_exists "$binary_name"; then
        print_success "$description already installed"
        return 0
    fi

    # Use get_github_url if available
    local download_url
    if command_exists get_github_url; then
        download_url=$(get_github_url -u "$user" -r "$repo" -t "$tag" -p "$asset_pattern" 2>/dev/null)
    else
        download_url="https://github.com/$user/$repo/releases/download/$tag/$asset_pattern"
    fi

    if [[ -z "$download_url" ]]; then
        print_error "Could not determine download URL for $description"
        return 1
    fi

    print_info "Installing $description from GitHub..."

    local archive_name=$(basename "$asset_pattern")
    local temp_archive=$(download_to_temp "$download_url" "$archive_name" "$description")
    if [[ -z "$temp_archive" ]]; then
        return 1
    fi

    local temp_extract_dir="$DOWNLOAD_TEMP_DIR/${binary_name}-extract"
    rm -rf "$temp_extract_dir"
    mkdir -p "$temp_extract_dir"

    if ! extract_archive "$temp_archive" "$temp_extract_dir" "$description"; then
        rm -f "$temp_archive"
        rm -rf "$temp_extract_dir"
        return 1
    fi

    # Find the binary in the extracted archive
    local binary_source="$temp_extract_dir/$binary_path_in_archive"

    if [[ ! -f "$binary_source" ]]; then
        # Try to find it anywhere in the extracted directory
        binary_source=$(find "$temp_extract_dir" -type f -name "$(basename "$binary_path_in_archive")" 2>/dev/null | head -1)
    fi

    if [[ ! -f "$binary_source" ]]; then
        print_error "Could not find binary in archive: $binary_path_in_archive"
        rm -f "$temp_archive"
        rm -rf "$temp_extract_dir"
        return 1
    fi

    if install_binary "$binary_source" "$binary_name" "$description"; then
        rm -f "$temp_archive"
        rm -rf "$temp_extract_dir"
        return 0
    else
        rm -f "$temp_archive"
        rm -rf "$temp_extract_dir"
        return 1
    fi
}

# ============================================================================
# Cleanup Functions
# ============================================================================

# Clean up temporary download directory
# Usage: cleanup_temp_downloads
function cleanup_temp_downloads() {
    if [[ -d "$DOWNLOAD_TEMP_DIR" ]]; then
        print_info "Cleaning up temporary downloads..."
        rm -rf "$DOWNLOAD_TEMP_DIR"/*
        print_success "Cleaned up temporary files"
    fi
}

# Clean up a specific temporary file or directory
# Usage: cleanup_temp <path>
function cleanup_temp() {
    local path="$1"
    if [[ -e "$path" ]]; then
        rm -rf "$path"
    fi
}

# ============================================================================
# Utility Functions
# ============================================================================

# Check if a binary is installed in our bin directory
# Usage: is_installed_in_bin <binary_name>
function is_installed_in_bin() {
    local binary_name="$1"
    [[ -x "$INSTALL_BIN_DIR/$binary_name" ]]
}

# Get the version of an installed binary (if it supports --version)
# Usage: get_installed_version <binary_name>
function get_installed_version() {
    local binary_name="$1"
    if command_exists "$binary_name"; then
        "$binary_name" --version 2>/dev/null | head -1
    else
        echo "not installed"
    fi
}

# Print installation paths summary
function print_installation_paths() {
    print_info "📁 Installation Paths:"
    echo "   Binaries:  $INSTALL_BIN_DIR"
    echo "   Libraries: $INSTALL_LIB_DIR"
    echo "   Shared:    $INSTALL_SHARE_DIR"
    echo "   Temp:      $DOWNLOAD_TEMP_DIR"
    echo
}
