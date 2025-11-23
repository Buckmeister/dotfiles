# Shared Libraries Reference

> **Powerful, reusable components for the dotfiles system**
>
> A comprehensive guide to all shared libraries in `bin/lib/`

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Library Index](#library-index)
- [API Reference](#api-reference)
  - [colors.zsh](#colorszsh---onedark-color-scheme)
  - [ui.zsh](#uizsh---ui-components)
  - [utils.zsh](#utilszsh---utility-functions)
  - [greetings.zsh](#greetingszsh---friendly-messages)
  - [validators.zsh](#validatorszsh---validation-functions)
  - [package_managers.zsh](#package_managerszsh---package-management)
  - [dependencies.zsh](#dependencieszsh---dependency-management)
  - [os_operations.zsh](#os_operationszsh---os-operations)
  - [installers.zsh](#installerszsh---installer-helpers)
  - [test_libraries.zsh](#test_librarieszsh---test-utilities)
- [Common Patterns](#common-patterns)
- [Contributing](#contributing)

---

## Overview

The shared libraries in `bin/lib/` form the **foundation** of the entire dotfiles system. They provide:

- **Consistent UI** - OneDark-themed output across all scripts
- **Cross-Platform Support** - Detect and adapt to different operating systems
- **Package Management** - Unified interface for brew, apt, cargo, npm, etc.
- **Validation & Error Handling** - Robust checks with helpful messages
- **Dependency Resolution** - Automatic dependency management
- **Reusable Utilities** - Common operations in one place

**Design Principles:**
- DRY (Don't Repeat Yourself) - Write once, use everywhere
- Beautiful Output - OneDark color scheme, consistent formatting
- Helpful Errors - Clear, actionable error messages
- Fallback Protection - Graceful degradation if library unavailable
- Modularity - Each library has a single, clear purpose

---

## Architecture

### Dependency Graph

```
┌──────────────────────────────────────────────────────────┐
│                     colors.zsh                           │
│            (OneDark color definitions)                   │
│                  NO DEPENDENCIES                         │
└─────────────────────┬────────────────────────────────────┘
                      │
         ┌────────────┴────────────┬──────────────────────┐
         │                         │                      │
┌────────▼─────────┐  ┌───────────▼──────────┐  ┌───────▼──────────┐
│    ui.zsh        │  │    utils.zsh         │  │  greetings.zsh   │
│  (UI components) │  │  (Utility functions) │  │  (Messages)      │
│  Depends on:     │  │  Depends on:         │  │  Depends on:     │
│  - colors.zsh    │  │  - colors.zsh        │  │  - colors.zsh    │
└────────┬─────────┘  └───────────┬──────────┘  └──────────────────┘
         │                        │
         └────────────┬───────────┘
                      │
         ┌────────────┴────────────┬───────────────┐
         │                         │               │
┌────────▼─────────┐  ┌───────────▼──────────┐  ┌▼──────────────────┐
│  validators.zsh  │  │ package_managers.zsh │  │ os_operations.zsh │
│  (Validation)    │  │ (Package mgmt)       │  │ (OS operations)   │
│  Depends on:     │  │  Depends on:         │  │  Depends on:      │
│  - colors.zsh    │  │  - colors.zsh        │  │  - colors.zsh     │
│  - ui.zsh        │  │  - ui.zsh            │  │  - ui.zsh         │
│  - utils.zsh     │  │  - utils.zsh         │  │  - utils.zsh      │
└────────┬─────────┘  └───────────┬──────────┘  └───────────────────┘
         │                        │
         └────────────┬───────────┘
                      │
         ┌────────────┴────────────┬───────────────────────┐
         │                         │                       │
┌────────▼─────────┐  ┌───────────▼──────────┐  ┌────────▼──────────┐
│ dependencies.zsh │  │  installers.zsh      │  │test_libraries.zsh │
│  (Dep resolution)│  │  (Install helpers)   │  │ (Test utilities)  │
│  Depends on:     │  │  Depends on:         │  │  Depends on:      │
│  - colors.zsh    │  │  - colors.zsh        │  │  - colors.zsh     │
│  - ui.zsh        │  │  - ui.zsh            │  │  - ui.zsh         │
│  - validators.zsh│  │  - utils.zsh         │  │  - utils.zsh      │
└──────────────────┘  └──────────────────────┘  └───────────────────┘
```

### Loading Order

For maximum functionality, load in this order:

```zsh
source "$LIB_DIR/colors.zsh"     # 1. Colors (no dependencies)
source "$LIB_DIR/ui.zsh"          # 2. UI (depends on colors)
source "$LIB_DIR/utils.zsh"       # 3. Utils (depends on colors)
source "$LIB_DIR/greetings.zsh"   # 4. Greetings (depends on colors)
source "$LIB_DIR/validators.zsh"  # 5. Validators (depends on colors, ui, utils)
source "$LIB_DIR/package_managers.zsh"  # 6. Package managers (depends on colors, ui, utils)
source "$LIB_DIR/dependencies.zsh"      # 7. Dependencies (depends on colors, ui, validators)
source "$LIB_DIR/os_operations.zsh"     # 8. OS operations (depends on colors, ui, utils)
source "$LIB_DIR/installers.zsh"        # 9. Installers (depends on colors, ui, utils)
```

**Note:** Most scripts include automatic fallback protection if libraries aren't available.

---

## Quick Start

### Basic Usage

```zsh
#!/usr/bin/env zsh

# Determine library directory
LIB_DIR="$(cd "$(dirname "$0")" && pwd)/lib"

# Load libraries (with fallback protection)
source "$LIB_DIR/colors.zsh" 2>/dev/null || {
    # Fallback colors if library unavailable
    COLOR_RESET='\033[0m'
    UI_SUCCESS_COLOR='\033[32m'
}

source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"

# Use library functions
draw_header "My Script" "Does amazing things"
echo

if command_exists git; then
    print_success "Git is available"
else
    print_error "Git not found"
    exit 1
fi

echo
print_info "$(get_random_friend_greeting)"
```

### Post-Install Script Template

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Script Name - Description
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
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "My Script" "Installing awesome things"
echo

draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1

draw_section_header "Installing Packages"
cargo_install_from_list "$CONFIG_DIR/packages/my-packages.list"

echo
print_success "$(get_random_friend_greeting)"
```

---

## Library Index

| Library | Purpose | Key Features |
|---------|---------|--------------|
| **colors.zsh** | OneDark color scheme | Color constants for consistent theming |
| **ui.zsh** | UI components | Headers, progress bars, status messages |
| **utils.zsh** | Utility functions | OS detection, file operations, helpers |
| **greetings.zsh** | Friendly messages | Multilingual greetings, encouraging messages |
| **validators.zsh** | Validation | Command/package checking, version validation |
| **package_managers.zsh** | Package management | brew, apt, cargo, npm, gem, pip, pipx |
| **dependencies.zsh** | Dependency resolution | Declarative dependencies, auto-resolution |
| **os_operations.zsh** | OS operations | Platform-specific operations |
| **installers.zsh** | Installer helpers | Download, extract, install workflows |
| **test_libraries.zsh** | Test utilities | Shared test functions |

---

## API Reference

### colors.zsh - OneDark Color Scheme

**Purpose:** Provides consistent OneDark color definitions for all UI output.

**Dependencies:** None

**Load Protection:**
```zsh
[[ -n "$DOTFILES_COLORS_LOADED" ]] && return 0  # Prevents multiple loading
```

#### Color Variables

**Base Colors:**
```zsh
COLOR_RESET        # Reset all attributes
COLOR_BOLD         # Bold text
COLOR_DIM          # Dimmed text
COLOR_UNDERLINE    # Underlined text
COLOR_BLINK        # Blinking text (use sparingly!)
COLOR_REVERSE      # Reverse video
COLOR_HIDDEN       # Hidden text
```

**OneDark Primary Colors:**
```zsh
COLOR_BLACK        # #1f2329
COLOR_RED          # #e06c75
COLOR_GREEN        # #98c379
COLOR_YELLOW       # #d19a66
COLOR_BLUE         # #61afef
COLOR_MAGENTA      # #c678dd
COLOR_CYAN         # #56b6c2
COLOR_WHITE        # #abb2bf
```

**Bright Variants:**
```zsh
COLOR_BRIGHT_BLACK    # #5c6370
COLOR_BRIGHT_RED      # #e06c75 (brighter)
COLOR_BRIGHT_GREEN    # #98c379 (brighter)
COLOR_BRIGHT_YELLOW   # #e5c07b
COLOR_BRIGHT_BLUE     # #61afef (brighter)
COLOR_BRIGHT_MAGENTA  # #c678dd (brighter)
COLOR_BRIGHT_CYAN     # #56b6c2 (brighter)
COLOR_BRIGHT_WHITE    # #ffffff
```

**Semantic UI Colors:**
```zsh
UI_SUCCESS_COLOR   # Green - for success messages
UI_ERROR_COLOR     # Red - for error messages
UI_WARNING_COLOR   # Yellow - for warnings
UI_INFO_COLOR      # Bright black (gray) - for info messages
UI_ACCENT_COLOR    # Cyan - for accents
UI_HEADER_COLOR    # Blue - for headers
```

**Shortened Aliases:**
```zsh
COLOR_SUCCESS      # = UI_SUCCESS_COLOR
COLOR_ERROR        # = UI_ERROR_COLOR
COLOR_WARNING      # = UI_WARNING_COLOR
COLOR_INFO         # = UI_INFO_COLOR
COLOR_COMMENT      # = UI_INFO_COLOR (gray for comments)
```

**Terminal Control:**
```zsh
TERM_CLEAR_LINE    # Clear current line
TERM_CLEAR_SCREEN  # Clear entire screen
TERM_CURSOR_UP     # Move cursor up one line
TERM_CURSOR_DOWN   # Move cursor down one line
TERM_SAVE_CURSOR   # Save cursor position
TERM_RESTORE_CURSOR # Restore saved cursor position
```

#### Usage Examples

**Basic coloring:**
```zsh
echo "${COLOR_GREEN}Success!${COLOR_RESET}"
echo "${COLOR_RED}Error occurred${COLOR_RESET}"
echo "${COLOR_YELLOW}${COLOR_BOLD}Warning:${COLOR_RESET} Be careful"
```

**Semantic colors:**
```zsh
echo "${UI_SUCCESS_COLOR}✓ Installation complete${COLOR_RESET}"
echo "${UI_ERROR_COLOR}✗ Failed to connect${COLOR_RESET}"
echo "${UI_INFO_COLOR}ℹ Additional information${COLOR_RESET}"
```

---

### ui.zsh - UI Components

**Purpose:** Beautiful terminal output components with OneDark theming.

**Dependencies:** colors.zsh

**Load Protection:**
```zsh
[[ -n "$DOTFILES_UI_LOADED" ]] && return 0
```

#### Status Messages

**print_success(message)**

Display a success message with green checkmark.

```zsh
print_success "Installation completed successfully"
# Output: ✅ Installation completed successfully
```

**print_error(message)**

Display an error message with red X.

```zsh
print_error "Failed to download package"
# Output: ❌ Failed to download package
```

**print_warning(message)**

Display a warning message with yellow warning symbol.

```zsh
print_warning "This operation may take a while"
# Output: ⚠️ This operation may take a while
```

**print_info(message)**

Display an informational message with info symbol.

```zsh
print_info "Checking dependencies..."
# Output: ℹ️ Checking dependencies...
```

#### Headers and Sections

**draw_header(title, [subtitle])**

Draw a beautiful box header (80 characters wide).

```zsh
draw_header "Dotfiles Setup" "Installing configurations"
# Output:
# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                           Dotfiles Setup                                   ║
# ║                      Installing configurations                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝
```

**draw_section_header(title)**

Draw a section separator with title.

```zsh
draw_section_header "Installing Packages"
# Output:
# ═══ Installing Packages ═══
```

#### Progress Bars

**progress_bar(current, total, [label])**

Draw an animated progress bar.

```zsh
for i in {1..10}; do
    progress_bar $i 10 "Installing"
    sleep 0.1
done
# Output: Installing [████████░░] 80% (8/10)
```

**progress_percent(current, total)**

Calculate percentage for custom progress displays.

```zsh
percent=$(progress_percent 7 10)
echo "Progress: ${percent}%"
# Output: Progress: 70%
```

#### Interactive Prompts

**ask_confirmation(prompt, [default])**

Ask for yes/no confirmation.

```zsh
if ask_confirmation "Continue with installation?" "y"; then
    echo "Installing..."
else
    echo "Cancelled"
fi
# Prompt: Continue with installation? [Y/n]:
```

**ask_input(prompt, [default])**

Ask for text input.

```zsh
username=$(ask_input "Enter your username" "user")
echo "Hello, $username!"
# Prompt: Enter your username [user]:
```

#### Visual Elements

**draw_line([character], [width])**

Draw a horizontal line.

```zsh
draw_line "─" 40
# Output: ────────────────────────────────────────

draw_line "=" 20
# Output: ====================
```

**print_centered(text, [width])**

Print text centered within width.

```zsh
print_centered "Dotfiles" 20
# Output: "       Dotfiles       "
```

#### Special Messages

**print_step(step_num, total_steps, description)**

Display a numbered step in a process.

```zsh
print_step 1 3 "Downloading packages"
print_step 2 3 "Installing packages"
print_step 3 3 "Configuring system"
# Output:
# [1/3] Downloading packages
# [2/3] Installing packages
# [3/3] Configuring system
```

---

### utils.zsh - Utility Functions

**Purpose:** Common utility functions for file operations, OS detection, and more.

**Dependencies:** colors.zsh

**Load Protection:**
```zsh
[[ -n "$DOTFILES_UTILS_LOADED" ]] && return 0
```

#### OS Detection

**get_os()**

Detect the current operating system.

```zsh
os=$(get_os)
case "$os" in
    macos)   echo "Running on macOS" ;;
    linux)   echo "Running on Linux" ;;
    windows) echo "Running on Windows" ;;
    *)       echo "Unknown OS" ;;
esac
```

**detect_package_manager()**

Detect OS and set environment variables.

```zsh
detect_package_manager
echo "OS: $DF_OS"                    # macos, linux, windows, unknown
echo "Package Manager: $DF_PKG_MANAGER"  # brew, apt, dnf, pacman, choco
echo "Install Command: $DF_PKG_INSTALL_CMD"
```

**is_macos()**, **is_linux()**, **is_windows()**

Check if running on specific OS.

```zsh
if is_macos; then
    echo "macOS-specific code"
fi

if is_linux; then
    echo "Linux-specific code"
fi
```

#### Command and File Checks

**command_exists(command_name)**

Check if a command exists in PATH.

```zsh
if command_exists git; then
    echo "Git is installed"
else
    echo "Git not found"
fi
```

**file_exists(file_path)**, **dir_exists(dir_path)**

Check if file/directory exists.

```zsh
if file_exists "/etc/hosts"; then
    echo "Hosts file found"
fi

if dir_exists "/usr/local/bin"; then
    echo "Directory exists"
fi
```

#### Directory Operations

**create_directory_safe(dir_path, [description])**

Create directory with error handling.

```zsh
if create_directory_safe "$HOME/.config/myapp" "config directory"; then
    echo "Directory ready"
else
    echo "Failed to create directory"
fi
```

**ensure_directory(dir_path)**

Ensure directory exists (creates if missing).

```zsh
ensure_directory "$HOME/.local/share/myapp"
```

#### Timestamp and Path Operations

**get_timestamp()**

Get current timestamp in YYYYMMDD-HHMMSS format.

```zsh
timestamp=$(get_timestamp)
echo "Backup created: $timestamp"
# Output: Backup created: 20251015-143022
```

**expand_path(path)**

Expand ~, environment variables, and relative paths.

```zsh
full_path=$(expand_path "~/Documents")
echo "$full_path"
# Output: /Users/thomas/Documents
```

#### String Operations

**trim(string)**

Remove leading/trailing whitespace.

```zsh
cleaned=$(trim "  hello world  ")
echo "$cleaned"
# Output: "hello world"
```

**to_lower(string)**, **to_upper(string)**

Convert string to lowercase/uppercase.

```zsh
echo $(to_lower "HELLO")  # Output: hello
echo $(to_upper "world")  # Output: WORLD
```

#### System Information

**get_shell()**

Get current shell name.

```zsh
shell=$(get_shell)
echo "Running: $shell"
# Output: Running: zsh
```

**get_cpu_count()**

Get number of CPU cores.

```zsh
cores=$(get_cpu_count)
echo "CPU cores: $cores"
```

---

### greetings.zsh - Friendly Messages

**Purpose:** Provide friendly, encouraging messages in multiple languages.

**Dependencies:** colors.zsh

**Load Protection:**
```zsh
[[ -n "$DOTFILES_GREETINGS_LOADED" ]] && return 0
```

#### Random Greetings

**get_random_greeting()**

Get a random greeting from 50+ greetings in 20+ languages.

```zsh
echo "$(get_random_greeting)"
# Random output: "Happy coding! 💙" or "Bon courage !" or "頑張って！"
```

**get_random_friend_greeting()**

Get a random friendly greeting (subset of all greetings).

```zsh
echo "$(get_random_friend_greeting)"
# Random output: "Happy coding, friend! 💙"
```

#### Specific Greeting Types

**get_completion_message()**

Get a completion/success message.

```zsh
echo "$(get_completion_message)"
# Output: "Great work! 🎉" or similar
```

**get_encouragement()**

Get an encouraging message.

```zsh
echo "$(get_encouragement)"
# Output: "You're doing great! Keep going!"
```

#### Usage in Scripts

```zsh
# At the end of a successful script
echo
print_success "Installation complete!"
echo
print_info "$(get_random_friend_greeting)"
```

---

### validators.zsh - Validation Functions

**Purpose:** Comprehensive validation for commands, versions, paths, and prerequisites.

**Dependencies:** colors.zsh, ui.zsh, utils.zsh

**Load Protection:**
```zsh
[[ -n "$DOTFILES_VALIDATORS_LOADED" ]] && return 0
```

#### Command Validation

**validate_command(command_name, [description])**

Check if a command exists.

```zsh
validate_command "git" "Git version control"
# Output: ✅ Git version control is available
```

**validate_commands(command1, command2, ...)**

Check multiple commands.

```zsh
validate_commands git curl jq
# Output: ✅ All required commands available
# Or: ❌ Missing commands: jq
```

**validate_command_any(command1, command2, ..., [description])**

Check if any one command exists (OR logic).

```zsh
validate_command_any vim nvim "Text editor"
# Output: ✅ nvim is available
```

#### Version Validation

**version_ge(version1, version2)**

Compare version strings (>= check).

```zsh
if version_ge "2.5.3" "2.4.0"; then
    echo "Version is sufficient"
fi
```

**get_command_version(command, [version_flag])**

Extract version from command output.

```zsh
version=$(get_command_version "node" "--version")
echo "Node version: $version"
# Output: Node version: 18.16.0
```

**validate_version(command, min_version, [description])**

Validate command meets minimum version.

```zsh
validate_version "node" "16.0.0" "Node.js"
# Output: ✅ Node.js 18.16.0 (>= 16.0.0 required)
```

#### Path Validation

**validate_path(path, [description])**

Validate that a path exists.

```zsh
validate_path "/usr/local/bin" "Binary directory"
# Output: ✅ Binary directory exists
```

**validate_writable_directory(path, [description])**

Validate directory exists and is writable.

```zsh
validate_writable_directory "$HOME/.config" "Config directory"
# Output: ✅ Config directory is writable
```

**validate_readable_file(path, [description])**

Validate file exists and is readable.

```zsh
validate_readable_file "/etc/hosts" "Hosts file"
# Output: ✅ Hosts file is readable
```

**validate_executable(path, [description])**

Validate file is executable.

```zsh
validate_executable "./setup.sh" "Setup script"
# Output: ✅ Setup script is executable
```

**ensure_writable_directory(path, [description])**

Create directory if missing, validate writable.

```zsh
ensure_writable_directory "$HOME/.cache/myapp" "Cache directory"
# Output: ✅ Created Cache directory directory
```

#### Environment Validation

**validate_env_var(var_name, [description])**

Validate environment variable is set.

```zsh
validate_env_var "HOME" "Home directory"
# Output: ✅ Home directory is set
```

**validate_env_vars(var1, var2, ...)**

Validate multiple environment variables.

```zsh
validate_env_vars HOME USER PATH
# Output: ✅ All required environment variables set
```

#### OS Validation

**validate_os(expected_os, [description])**

Validate running on specific OS.

```zsh
validate_os "macos" "macOS check"
# Output: ✅ macOS check: macos
```

**validate_os_any(os1, os2, ..., [description])**

Validate running on one of multiple OSes.

```zsh
validate_os_any macos linux "Unix-like system"
# Output: ✅ Unix-like system: macos
```

#### Permission Validation

**has_sudo_privileges()**

Check if user has sudo privileges (no password prompt).

```zsh
if has_sudo_privileges; then
    echo "Sudo available"
fi
```

**validate_sudo([description])**

Validate sudo is available.

```zsh
validate_sudo "Administrator access"
# Output: ✅ Administrator access available
```

#### Network Validation

**validate_network([test_host])**

Check network connectivity.

```zsh
validate_network "github.com"
# Output: ✅ Network connectivity available
```

#### Comprehensive Validation

**validate_prerequisites(check_function1, check_function2, ...)**

Run multiple validation checks and report overall result.

```zsh
validate_prerequisites \
    "validate_command git" \
    "validate_command curl" \
    "validate_network"
# Output:
# ℹ️ Checking prerequisites...
# ✅ git is available
# ✅ curl is available
# ✅ Network connectivity available
# ✅ All prerequisites met!
```

**validate_language_setup(language, pkg_manager, [compiler])**

Validate language environment.

```zsh
validate_language_setup "Rust" "cargo" "rustc"
# Output:
# ℹ️ Validating Rust setup...
# ✅ cargo available
# ✅ rustc available
# ✅ Rust environment ready
```

---

### package_managers.zsh - Package Management

**Purpose:** Unified interface for managing packages across different package managers.

**Dependencies:** colors.zsh, ui.zsh, utils.zsh

**Features:**
- System package managers (brew, apt, dnf, pacman)
- Language-specific (npm, cargo, gem, pip, pipx)
- Idempotent installations
- Batch operations
- List-based installations

#### System Package Management

**pkg_install(package_name, [description])**

Install system package (idempotent).

```zsh
pkg_install "git" "Git version control"
# On macOS: Uses brew install git
# On Ubuntu: Uses sudo apt install -y git
# Output: ✅ Git version control already installed
```

**pkg_is_installed(package_name)**

Check if system package is installed.

```zsh
if pkg_is_installed "git"; then
    echo "Git is installed"
fi
```

**pkg_install_batch(package1, package2, ...)**

Install multiple system packages.

```zsh
pkg_install_batch git curl wget jq
# Output:
# ℹ️ Installing 4 system packages...
# ✅ git already installed
# ✅ Installed curl
# ✅ Installed wget
# ✅ Installed jq
```

#### npm - Node Package Manager

**npm_install_global(package_name, [description])**

Install global npm package (idempotent).

```zsh
npm_install_global "typescript" "TypeScript compiler"
# Output: ✅ TypeScript compiler already installed
```

**npm_is_installed(package_name)**

Check if npm package is installed globally.

```zsh
if npm_is_installed "typescript"; then
    echo "TypeScript is installed"
fi
```

**npm_install_from_list(file_path)**

Install packages from a list file.

```zsh
npm_install_from_list "$CONFIG_DIR/packages/npm-packages.list"
# Reads file (one package per line, # for comments)
# Output:
# ℹ️ Installing 10 npm packages...
# ✅ Installed typescript-language-server (1/10)
# ✅ Installed prettier (2/10)
# ...
```

#### cargo - Rust Package Manager

**cargo_install(package_name, [description])**

Install Rust package via cargo (idempotent).

```zsh
cargo_install "ripgrep" "Ultra-fast grep"
# Output: ✅ Ultra-fast grep already installed
```

**cargo_install_features(package_name, features, [description])**

Install cargo package with specific features.

```zsh
cargo_install_features "bat" "all" "Cat with syntax highlighting"
```

**cargo_is_installed(binary_name)**

Check if cargo package is installed.

```zsh
if cargo_is_installed "ripgrep"; then
    echo "ripgrep is installed"
fi
```

**cargo_install_from_list(file_path)**

Install packages from a list file.

```zsh
cargo_install_from_list "$CONFIG_DIR/packages/cargo-packages.list"
# Output:
# ℹ️ Installing 15 cargo packages...
# ✅ Installed ripgrep (1/15)
# ✅ Installed fd-find (2/15)
# ...
```

#### gem - Ruby Package Manager

**gem_install(gem_name, [description])**

Install Ruby gem (idempotent).

```zsh
gem_install "solargraph" "Ruby language server"
# Output: ✅ Ruby language server already installed
```

**gem_is_installed(gem_name)**

Check if gem is installed.

```zsh
if gem_is_installed "solargraph"; then
    echo "Solargraph is installed"
fi
```

**gem_install_from_list(file_path)**

Install gems from a list file.

```zsh
gem_install_from_list "$CONFIG_DIR/packages/ruby-gems.list"
```

#### pip/pipx - Python Package Managers

**pip_install(package_name, [description])**

Install Python package via pip (user install, idempotent).

```zsh
pip_install "black" "Python formatter"
# Output: ✅ Python formatter already installed
```

**pipx_install(package_name, [description])**

Install Python package via pipx (isolated, idempotent).

```zsh
pipx_install "black" "Python formatter"
# Output: ✅ Python formatter already installed
```

**pip_is_installed(package_name)**, **pipx_is_installed(package_name)**

Check if pip/pipx package is installed.

```zsh
if pipx_is_installed "black"; then
    echo "Black is installed"
fi
```

**pip_install_from_list(file_path)**, **pipx_install_from_list(file_path)**

Install packages from a list file.

```zsh
pip_install_from_list "$CONFIG_DIR/packages/pip-packages.list"
pipx_install_from_list "$CONFIG_DIR/packages/pipx-packages.list"
```

#### Package Manager Status

**has_npm()**, **has_cargo()**, **has_gem()**, **has_pip()**, **has_pipx()**

Check if package manager is available.

```zsh
if has_cargo; then
    echo "Cargo is available"
fi
```

**print_package_managers_status()**

Print status of all package managers.

```zsh
print_package_managers_status
# Output:
# 📦 Package Managers Status:
# ✅ System: brew
# ✅ npm: 9.5.1
# ✅ cargo: 1.70.0
# ✅ gem: 3.4.10
# ✅ pip: 23.1.2
# ⚠️  pipx: not available
```

---

### dependencies.zsh - Dependency Management

**Purpose:** Declarative dependency system with automatic resolution.

**Dependencies:** colors.zsh, ui.zsh, validators.zsh

**Load Protection:**
```zsh
[[ -n "$DOTFILES_DEPENDENCIES_LOADED" ]] && return 0
```

**Features:**
- Declare dependencies upfront
- Automatic resolution via provider scripts
- Interactive and non-interactive modes
- Clear error messages

#### Dependency Declaration

**declare_dependency_command(command, name, [provider])**

Declare a command dependency.

```zsh
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"
declare_dependency_command "npm" "Node package manager" ""
```

**Parameters:**
- `command` - Command to check for (e.g., "cargo")
- `name` - Human-readable name (e.g., "Rust package manager")
- `provider` - Optional provider script that installs this command

**declare_dependency_script(script, description)**

Declare a script dependency (another post-install script).

```zsh
declare_dependency_script "toolchains.zsh" "Core development toolchains"
```

**clear_declared_dependencies()**

Clear all declared dependencies (useful for testing).

```zsh
clear_declared_dependencies
```

#### Dependency Resolution

**check_and_resolve_dependencies()**

Check all declared dependencies and attempt to resolve missing ones.

```zsh
declare_dependency_command "cargo" "Rust toolchain" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"

if check_and_resolve_dependencies; then
    echo "All dependencies satisfied"
else
    echo "Missing dependencies"
    exit 1
fi
```

**Interactive Mode:**
- If dependency missing, offers to run provider script
- User can accept or decline
- Verifies command available after running provider

**Non-Interactive Mode:**
- Simply reports missing dependencies
- Provides install instructions

#### Configuration

**DEPENDENCY_AUTO_RESOLVE**

Enable/disable automatic resolution (default: true).

```zsh
DEPENDENCY_AUTO_RESOLVE=false check_and_resolve_dependencies
```

**DEPENDENCY_INTERACTIVE**

Enable/disable interactive prompts (default: true).

```zsh
DEPENDENCY_INTERACTIVE=false check_and_resolve_dependencies
```

#### Utility Functions

**is_command_dependency_satisfied(command)**

Check if a specific command dependency is satisfied.

```zsh
if is_command_dependency_satisfied "cargo"; then
    echo "Cargo is available"
fi
```

**get_command_provider(command)**

Get provider script for a command.

```zsh
provider=$(get_command_provider "cargo")
echo "Provider: $provider"  # Output: toolchains.zsh
```

**get_command_name(command)**

Get human-readable name for a command.

```zsh
name=$(get_command_name "cargo")
echo "Name: $name"  # Output: Rust package manager
```

**show_declared_dependencies()**

Show all declared dependencies (debugging).

```zsh
show_declared_dependencies
# Output:
# 📦 Declared Dependencies:
#
# Commands:
#   ✅ cargo        Rust package manager
#   ❌ node         Node.js runtime (provider: nvm-install.zsh)
#
# Scripts:
#   📄 toolchains.zsh    Core development toolchains
```

#### Usage Example

```zsh
# In a post-install script

# Declare dependencies
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"

# Check and resolve
draw_section_header "Checking Dependencies"

if ! check_and_resolve_dependencies; then
    print_error "Missing required dependencies"
    exit 1
fi

# If we get here, all dependencies are satisfied
print_success "All dependencies available"
```

---

### os_operations.zsh - OS Operations

**Purpose:** Platform-specific operations with cross-platform abstractions.

**Dependencies:** colors.zsh, ui.zsh, utils.zsh

**Features:**
- Platform-specific file operations
- Service management
- System information
- Cross-platform abstractions

#### Platform Detection

Functions automatically adapt based on `$DF_OS` or `get_os()`.

#### File Operations

**os_copy_file(source, dest)**

Copy file (platform-specific).

```zsh
os_copy_file "/path/to/source" "/path/to/dest"
```

**os_move_file(source, dest)**

Move file (platform-specific).

```zsh
os_move_file "/path/to/source" "/path/to/dest"
```

**os_delete_file(file_path)**

Delete file safely.

```zsh
os_delete_file "/path/to/file"
```

#### System Information

**os_get_username()**

Get current username.

```zsh
username=$(os_get_username)
echo "User: $username"
```

**os_get_home_directory()**

Get user's home directory.

```zsh
home=$(os_get_home_directory)
echo "Home: $home"
```

#### Service Management

**os_start_service(service_name)**

Start a system service.

```zsh
os_start_service "docker"
```

**os_stop_service(service_name)**

Stop a system service.

```zsh
os_stop_service "docker"
```

**os_restart_service(service_name)**

Restart a system service.

```zsh
os_restart_service "docker"
```

---

### installers.zsh - Installer Helpers

**Purpose:** Download, extract, and install workflows for various file types.

**Dependencies:** colors.zsh, ui.zsh, utils.zsh

**Features:**
- HTTP/HTTPS downloads with progress
- Archive extraction (tar.gz, zip)
- Checksum verification
- Retry logic

#### Download Functions

**download_file(url, dest_path, [description])**

Download file with progress indicator.

```zsh
download_file "https://example.com/file.tar.gz" "/tmp/file.tar.gz" "My Package"
# Output:
# ℹ️ Downloading My Package...
# ✅ Downloaded successfully
```

**download_with_retry(url, dest_path, [max_retries])**

Download with automatic retry on failure.

```zsh
download_with_retry "https://example.com/file.tar.gz" "/tmp/file.tar.gz" 3
```

#### Archive Extraction

**extract_archive(archive_path, dest_dir, [strip_components])**

Extract archive (auto-detects format).

```zsh
extract_archive "/tmp/file.tar.gz" "/usr/local/share/myapp" 1
# Extracts and strips first directory level
```

**extract_tar_gz(archive_path, dest_dir, [strip_components])**

Extract tar.gz archive.

```zsh
extract_tar_gz "/tmp/file.tar.gz" "/usr/local/share/myapp"
```

**extract_zip(archive_path, dest_dir)**

Extract zip archive.

```zsh
extract_zip "/tmp/file.zip" "/usr/local/share/myapp"
```

#### Checksum Verification

**verify_checksum(file_path, expected_checksum, [algorithm])**

Verify file checksum (SHA256 by default).

```zsh
if verify_checksum "/tmp/file.tar.gz" "abc123..."; then
    echo "Checksum verified"
else
    echo "Checksum mismatch!"
fi
```

#### Installation Helpers

**install_binary(source_path, dest_path, [make_executable])**

Install a binary to destination.

```zsh
install_binary "/tmp/mybinary" "$HOME/.local/bin/mybinary" true
# Copies and makes executable
```

**cleanup_temp_downloads([temp_dir])**

Clean up temporary download files.

```zsh
cleanup_temp_downloads
# Removes files from $DOWNLOAD_TEMP_DIR
```

---

### test_libraries.zsh - Test Utilities

**Purpose:** Shared test utilities for the test suite.

**Dependencies:** colors.zsh, ui.zsh, utils.zsh

**Features:**
- Test result tracking
- Common test assertions
- Mock functions

#### Test Tracking

**init_test_results()**

Initialize test result tracking.

```zsh
init_test_results
```

**track_test_result(test_name, passed)**

Track individual test result.

```zsh
track_test_result "Git installation" true
track_test_result "Network check" false
```

**print_test_results()**

Print test results summary.

```zsh
print_test_results
# Output:
# 📊 Test Results:
#   Total: 2
#   Passed: 1
#   Failed: 1
```

#### Mock Functions

**mock_command(command_name, output)**

Mock a command for testing.

```zsh
mock_command "git" "git version 2.39.0"
```

---

## Common Patterns

### Post-Install Script Pattern

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Script Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# ============================================================================
# Load Shared Libraries
# ============================================================================

source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"

# Load configuration
source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"
[[ -f "$CONFIG_DIR/personal.env" ]] && source "$CONFIG_DIR/personal.env"

# ============================================================================
# Configuration
# ============================================================================

PACKAGE_LIST="$CONFIG_DIR/packages/my-packages.list"

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"

# ============================================================================
# Main Execution
# ============================================================================

draw_header "My Script" "Installing awesome things"
echo

# Check dependencies
draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1

# Do work
draw_section_header "Installing Packages"
cargo_install_from_list "$PACKAGE_LIST"

# Success
echo
print_success "$(get_random_friend_greeting)"
```

### Error Handling Pattern

```zsh
# Robust error handling
if ! command_exists git; then
    print_error "Git not found"
    print_info "Install with: brew install git (macOS) or sudo apt install git (Linux)"
    exit 1
fi

# With validation
if ! validate_command "git" "Git version control"; then
    exit 1
fi

# With dependency resolution
declare_dependency_command "git" "Git version control" ""
check_and_resolve_dependencies || exit 1
```

### OS-Specific Code Pattern

```zsh
case "${DF_OS:-$(get_os)}" in
    macos)
        echo "Running macOS-specific code"
        brew install package
        ;;
    linux)
        echo "Running Linux-specific code"
        sudo apt install -y package
        ;;
    windows)
        echo "Running Windows-specific code"
        choco install package
        ;;
    *)
        print_error "Unsupported OS: ${DF_OS}"
        exit 1
        ;;
esac
```

### Progress Reporting Pattern

```zsh
total=10
for i in {1..10}; do
    progress_bar $i $total "Installing"
    # Do work
    sleep 0.5
done
echo
print_success "Installation complete"
```

---

## Contributing

### Adding a New Library

1. **Create the library file** in `bin/lib/`
2. **Add load protection** at the top:
   ```zsh
   [[ -n "$DOTFILES_MYLIB_LOADED" ]] && return 0
   readonly DOTFILES_MYLIB_LOADED=1
   ```
3. **Document dependencies** in comments
4. **Load required libraries** with error handling
5. **Export functions** if needed:
   ```zsh
   typeset -fx my_function
   ```
6. **Update this README** with API documentation
7. **Add tests** in `tests/unit/test_mylib.zsh`

### Style Guidelines

**Function Naming:**
- Use `snake_case` for function names
- Use descriptive names (e.g., `install_package` not `install_pkg`)
- Prefix library-specific functions with library name for clarity

**Error Handling:**
- Always check return codes
- Provide helpful error messages with `print_error`
- Suggest solutions in error messages

**Comments:**
- Add header comments explaining purpose
- Document function parameters and return values
- Use `# ===` section dividers

**Colors:**
- Use semantic colors from colors.zsh
- Always reset colors after use (`${COLOR_RESET}`)

---

## See Also

- **[CLAUDE.md](../../docs/CLAUDE.md)** - Architecture guide and development workflow
- **[tests/README.md](../../tests/README.md)** - Test suite documentation
- **[post-install/README.md](../../post-install/README.md)** - Post-install script system

---

**Created:** 2025-10-15
**Status:** Production Ready
**Maintainer:** Thomas + Aria (Claude Code)
