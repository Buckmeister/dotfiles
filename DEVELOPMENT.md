# Developer Documentation

**Comprehensive guide for script authors, contributors, and system architects working with the dotfiles infrastructure.**

---

## Table of Contents

- [Introduction](#introduction)
- [Shared Libraries System](#shared-libraries-system)
- [Complete API Reference](#complete-api-reference)
- [Repository Architecture](#repository-architecture)
- [Writing Scripts Guide](#writing-scripts-guide)
- [Argument Parsing Standard](#argument-parsing-standard)
- [Coding Standards](#coding-standards)
- [Testing & Contributing](#testing--contributing)
- [Advanced Topics](#advanced-topics)
- [Documentation Index](#documentation-index)

---

## Introduction

### Purpose

This document serves as the **central hub for all developer-facing documentation** in the dotfiles repository. It provides comprehensive guidance for:

- **Script Authors** - Writing new post-install scripts and utilities
- **Contributors** - Enhancing existing functionality and fixing bugs
- **System Architects** - Understanding the infrastructure and design patterns
- **Maintainers** - Managing the shared library ecosystem

### Prerequisites

Before diving into development, ensure you're familiar with:

- **zsh scripting** - All scripts use zsh with `emulate -LR zsh`
- **Git workflows** - Branching, committing, and pull requests
- **Cross-platform development** - macOS, Linux, and (planned) Windows support
- **The dotfiles philosophy** - See [CLAUDE.md](CLAUDE.md#design-philosophy) for core principles

### Quick Navigation

- **New to development?** Start with [Writing Scripts Guide](#writing-scripts-guide)
- **Need API reference?** See [Complete API Reference](#complete-api-reference)
- **Understanding the system?** Read [Repository Architecture](#repository-architecture)
- **Ready to contribute?** Check [Testing & Contributing](#testing--contributing)

---

## Shared Libraries System

The dotfiles system includes **14 specialized libraries** providing 200+ functions for UI, validation, package management, menu systems, and more. These libraries form the foundation of every script in the repository.

### Core Libraries (UI & System)

#### `colors.zsh` - OneDark Color Scheme Constants

The **OneDark** color palette provides consistent, beautiful theming across all scripts.

**Color Variables:**
- `$ONEDARK_BLACK`, `$ONEDARK_RED`, `$ONEDARK_GREEN`, `$ONEDARK_YELLOW`
- `$ONEDARK_BLUE`, `$ONEDARK_PURPLE`, `$ONEDARK_CYAN`, `$ONEDARK_WHITE`
- `$ONEDARK_BRIGHT_BLACK`, `$ONEDARK_BRIGHT_RED`, etc.

**Semantic Colors:**
- `$COLOR_ERROR` - Red for error messages
- `$COLOR_SUCCESS` - Green for success messages
- `$COLOR_INFO` - Blue for informational messages
- `$COLOR_WARNING` - Yellow for warnings

**Terminal Control:**
- `$BOLD`, `$ITALIC`, `$UNDERLINE`, `$RESET`

**Usage:**
```zsh
source "$DF_LIB_DIR/colors.zsh"
echo "${COLOR_SUCCESS}Success!${COLOR_RESET}"
echo "${BOLD}Bold text${RESET}"
```

#### `ui.zsh` - Beautiful Terminal Output Functions

Comprehensive UI toolkit for creating elegant, consistent terminal interfaces.

**Headers:**
```zsh
draw_header "Main Title" "Subtitle"           # Large header with box
draw_section_header "Section Name"             # Smaller section divider
```

**Status Messages:**
```zsh
print_success "Operation completed"            # ✅ Green success
print_error "Something went wrong"             # ❌ Red error
print_info "Informational message"             # ℹ️  Blue info
print_warning "Caution advised"                # ⚠️  Yellow warning
```

**Progress Indicators:**
```zsh
show_progress_bar 50 100 "Processing"          # [████████░░░░░] 50%
draw_progress_bar 75 100                       # Standalone progress bar
```

**Step Indicators:**
```zsh
print_step 1 "Initialize system"               # [1] Initialize system
print_step 2 "Install packages"                # [2] Install packages
```

**Interactive Prompts:**
```zsh
ask_confirmation "Continue?" "yes"             # Returns true/false
ask_confirmation "Delete files?" "no"          # Default to "no"
```

#### `utils.zsh` - OS Detection and Common Utilities

Essential helper functions for cross-platform compatibility and system operations.

**OS Detection:**
```zsh
get_os                                         # Returns: macos, linux, windows, unknown
is_macos                                       # Boolean check
is_linux                                       # Boolean check
is_windows                                     # Boolean check
get_distro                                     # Linux distro: ubuntu, debian, fedora, arch
```

**Command Utilities:**
```zsh
command_exists "nvim"                          # Check if command available
get_command_path "git"                         # Get full path to command
```

**Path Detection:**
```zsh
init_dotfiles_paths                            # Sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR
get_script_dir                                 # Get current script directory
expand_path "~/dotfiles"                       # Expand ~ and environment variables
```

**String Utilities:**
```zsh
str_contains "hello world" "world"             # String search
str_starts_with "prefix" "pre"                 # Prefix check
str_ends_with "suffix" "fix"                   # Suffix check
str_trim "  text  "                            # Remove whitespace
```

**Array Utilities:**
```zsh
array_contains array_name "value"              # Check if array contains value
array_join array_name ", "                     # Join array with separator
```

#### `greetings.zsh` - Friendly, Multilingual Messages

Warm, encouraging messages that create a delightful user experience.

**Greeting Functions:**
```zsh
get_random_greeting                            # "Hello!", "Hi there!", "Greetings!"
get_random_friend_greeting                     # "Hello, friend!", "Hey there, friend!"
get_random_success_greeting                    # "Excellent work!", "Great job!"
get_random_encouragement                       # "You've got this!", "Keep it up!"
```

**Multilingual Support:**
- English, Spanish, French, German, Japanese, and more
- Culturally appropriate greetings
- Friendly, encouraging tone throughout

**Usage:**
```zsh
print_success "$(get_random_friend_greeting)"  # Friendly ending for scripts
echo "$(get_random_encouragement)"             # Motivational messages
```

### Script Infrastructure

#### `arguments.zsh` - Standardized CLI Argument Parsing

**Eliminates 200-600 lines of duplicated argument parsing code** across all scripts. Provides consistent CLI behavior with standardized flags and validation.

**Standard Flag Parsing:**
```zsh
source "$DF_LIB_DIR/arguments.zsh"
parse_simple_flags "$@"

# Access parsed flags:
is_help_requested && show_help
is_verbose && print_info "Verbose mode enabled"
is_dry_run && print_info "Dry-run mode (no changes will be made)"

# Standard flags available:
[[ "$ARG_HELP" == "true" ]]       # -h, --help
[[ "$ARG_VERBOSE" == "true" ]]    # -v, --verbose
[[ "$ARG_DRY_RUN" == "true" ]]    # -n, --dry-run
[[ "$ARG_FORCE" == "true" ]]      # -f, --force
[[ "$ARG_SILENT" == "true" ]]     # -s, --silent
[[ "$ARG_UPDATE" == "true" ]]     # --update
```

**Helper Functions:**
```zsh
is_help_requested                              # Check if help requested
is_verbose                                     # Check verbose mode
is_dry_run                                     # Check dry-run mode
validate_no_unknown_args "$@"                  # Validate no invalid options
standard_help_header "Script" "Description"    # Format help text
```

**Custom Flags:**
```zsh
parse_simple_flags "$@"                        # Parse common flags first

for arg in "$@"; do
    case "$arg" in
        --custom-flag) CUSTOM=true ;;
        --dry-run|-n|--help|-h) ;;             # Skip already handled
        *) print_error "Unknown option: $arg"; exit 1 ;;
    esac
done
```

**See also:** [Argument Parsing Standard](#argument-parsing-standard) for complete patterns and examples.

#### `dependencies.zsh` - Declarative Dependency Management

**Automatic dependency resolution with user prompts** - declare what you need, the system handles validation and installation.

**Dependency Declaration:**
```zsh
declare_dependency_command "cargo" "Rust toolchain" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"
declare_dependency_command "git" "Version control" ""  # System package

# Check and resolve all dependencies
check_and_resolve_dependencies || exit 1
```

**Dependency Resolution:**
- Checks if command exists in PATH
- If missing, prompts user: "Install Rust toolchain via toolchains.zsh?"
- User can: (Y)es, (N)o, (S)kip script, (A)bort all
- Automatically runs provider script if user confirms
- Validates that dependency was successfully installed

**Custom Validation:**
```zsh
declare_dependency_custom_validator "check_node_version"

function check_node_version() {
    local version=$(node --version | sed 's/v//')
    if version_ge "$version" "16.0.0"; then
        return 0
    else
        print_error "Node.js >= 16.0.0 required (found: $version)"
        return 1
    fi
}
```

#### `validators.zsh` - Comprehensive Validation Functions

**Rich validation library** for checking commands, versions, paths, permissions, and system requirements.

**Command Validation:**
```zsh
validate_command "nvim" "Neovim"               # Check command exists
validate_commands "git" "curl" "jq"            # Multiple commands
validate_command_any "nvim" "vim" "vi"         # At least one required
```

**Version Validation:**
```zsh
validate_version "node" "16.0.0" "Node.js"     # Check minimum version
version_ge "18.2.0" "16.0.0"                   # Compare versions
get_command_version "python3"                  # Extract version string
```

**Path & Directory Validation:**
```zsh
validate_path "$HOME/.config"                  # Path exists
validate_writable_directory "/tmp"             # Directory writable
validate_readable_file "$HOME/.zshrc"          # File readable
validate_executable "/usr/bin/git"             # File executable
ensure_writable_directory "$HOME/.cache"       # Create if needed
```

**Environment Validation:**
```zsh
validate_env_var "HOME" "Home directory"       # Check env var set
validate_env_vars "PATH" "USER" "SHELL"        # Multiple vars
```

**OS Validation:**
```zsh
validate_os "macos" "macOS required"           # Specific OS
validate_os_any "macos" "linux"                # One of multiple
```

**Network & Permissions:**
```zsh
validate_network "github.com"                  # Check connectivity
validate_sudo "sudo access"                    # Check sudo available
has_sudo_privileges                            # Check cached sudo
```

**Comprehensive Validation:**
```zsh
validate_prerequisites \
    "validate_command git" \
    "validate_version node 16.0.0" \
    "validate_writable_directory ~/.config"

# Runs all checks, reports results
# Returns 0 only if all pass
```

### Package & Installation Management

#### `package_managers.zsh` - Unified Package Manager Interface

**Cross-platform abstraction layer** providing consistent installation patterns across all package managers.

**System Packages:**
```zsh
pkg_install "curl" "HTTP client"               # Uses brew/apt/dnf/pacman automatically
pkg_is_installed "git"                         # Check installation
pkg_install_batch "curl" "git" "jq"            # Install multiple
```

**npm (Node.js):**
```zsh
npm_install_global "typescript"                # Global package
npm_is_installed "typescript"                  # Check if installed
npm_install_from_list "$PACKAGE_LIST"          # Batch install
```

**cargo (Rust):**
```zsh
cargo_install "ripgrep"                        # Rust package
cargo_install_features "bat" "completion"      # With features
cargo_is_installed "ripgrep"                   # Check binary exists
cargo_install_from_list "$PACKAGE_LIST"        # Batch install
```

**gem (Ruby):**
```zsh
gem_install "solargraph"                       # Ruby gem
gem_is_installed "solargraph"                  # Check installation
gem_install_from_list "$PACKAGE_LIST"          # Batch install
```

**pip/pipx (Python):**
```zsh
pip_install "requests"                         # User package
pipx_install "httpie"                          # Isolated app
pip_is_installed "requests"                    # Check pip package
pipx_is_installed "httpie"                     # Check pipx app
pip_install_from_list "$PACKAGE_LIST"          # Batch install
pipx_install_from_list "$PACKAGE_LIST"         # Batch install apps
```

**Package Manager Status:**
```zsh
has_npm                                        # Check npm available
has_cargo                                      # Check cargo available
has_gem                                        # Check gem available
has_pip                                        # Check pip available
has_pipx                                       # Check pipx available
print_package_managers_status                  # Show all managers
```

**Idempotent Patterns:**
- All functions check if already installed
- Safe to run multiple times
- Clear feedback on already-installed vs newly-installed

#### `installers.zsh` - Download and Install Workflows

**Utilities for downloading, extracting, and installing** tools from GitHub releases, tarballs, and custom sources.

**GitHub Release Downloaders:**
```zsh
download_github_release "user/repo" "v1.0.0" "/tmp/tool.tar.gz"
get_latest_github_release "user/repo"          # Get latest version tag
```

**Generic Download:**
```zsh
download_file "$URL" "$DEST" "Tool Name"       # With progress
extract_archive "$FILE" "$DIR" "Tool Name"     # Auto-detect format
```

**Installation Workflows:**
```zsh
install_from_tarball "$URL" "$INSTALL_DIR"     # Download + extract
install_binary "$URL" "$INSTALL_PATH"          # Download + chmod +x
```

#### `os_operations.zsh` - OS-Aware Operations

**Cross-platform file operations, clipboard access, and system utilities.**

**XDG Base Directory Specification:**
```zsh
get_xdg_config_home                            # ~/.config
get_xdg_data_home                              # ~/.local/share
get_xdg_cache_home                             # ~/.cache
get_xdg_state_home                             # ~/.local/state
get_app_config_dir "nvim"                      # ~/.config/nvim
get_app_data_dir "dotfiles"                    # ~/.local/share/dotfiles
ensure_xdg_directories                         # Create all XDG dirs
```

**Clipboard Operations:**
```zsh
copy_to_clipboard "text"                       # Copy to clipboard
paste_from_clipboard                           # Paste from clipboard
has_clipboard_support                          # Check availability

# Works on macOS (pbcopy/pbpaste), Linux (xclip/xsel), Windows (clip.exe)
```

**File Operations:**
```zsh
ensure_directory "$HOME/.config/nvim"          # Create if needed
safe_copy "$SOURCE" "$DEST"                    # Create parent dirs
safe_move "$SOURCE" "$DEST"                    # Create parent dirs
backup_file "$FILE"                            # Create timestamped backup
safe_symlink "$SOURCE" "$TARGET"               # Backup existing target
```

**Path Manipulation:**
```zsh
normalize_path "/path/to/../file"              # Resolve . and ..
get_absolute_path "relative/path"              # Make absolute
join_path "/usr" "local" "bin"                 # Join components
get_dir_path "/usr/local/bin/nvim"             # Get directory
get_file_name "/usr/local/bin/nvim"            # Get filename
get_file_extension "script.zsh"                # Get extension
get_file_basename "script.zsh"                 # Get base name
```

**System Information:**
```zsh
get_desktop_environment                        # gnome, kde, xfce, etc.
is_graphical_session                           # Check DISPLAY/WAYLAND_DISPLAY
get_current_shell                              # bash, zsh, fish
get_architecture                               # x86_64, arm64, etc.
get_cpu_count                                  # Number of cores
```

**File Permissions:**
```zsh
make_executable "$FILE"                        # chmod +x
make_readonly "$FILE"                          # chmod 444
is_owned_by_user "$FILE"                       # Check ownership
```

### Interactive Menu System (Phase 7)

**Hierarchical menu system with breadcrumb navigation, cursor memory, and rich styling.**

#### `menu_engine.zsh` - Hierarchical Menu Rendering Engine

**Core rendering engine** supporting nested menus, multiple item types, and consistent styling.

**Menu Item Types:**
- **Action** - Execute a script or command
- **Submenu** - Navigate to child menu
- **Toggle** - Boolean on/off state
- **Info** - Read-only informational item
- **Separator** - Visual divider

**Menu Rendering:**
```zsh
render_menu \
    --title "Main Menu" \
    --items "item1" "item2" "item3" \
    --types "action" "submenu" "action" \
    --selected 1

# Displays:
# ┌─────────────────────────────────┐
# │         Main Menu                │
# ├─────────────────────────────────┤
# │  ○ Item 1                        │
# │  ● Item 2                        │  ← Selected
# │  ○ Item 3                        │
# └─────────────────────────────────┘
```

**Styling Functions:**
```zsh
get_item_prefix "action" "selected"            # ● for selected action
get_item_prefix "submenu" "normal"             # → for submenu
get_item_prefix "toggle" "selected" "on"       # [✓] for enabled toggle
format_item_label "Install Packages" "action"  # Apply color/style
```

#### `menu_state.zsh` - Navigation Stack and State Management

**State management** for navigation history, breadcrumbs, and cursor position memory.

**Navigation Stack:**
```zsh
push_menu_state "submenu-name" 3               # Enter submenu, cursor at item 3
pop_menu_state                                 # Return to parent
get_current_menu                               # Current menu name
get_menu_depth                                 # How deep in hierarchy
```

**Breadcrumb Trail:**
```zsh
render_breadcrumbs                             # "Main > Settings > Display"
get_breadcrumb_path                            # Array of menu names
```

**Cursor Position Memory:**
```zsh
save_cursor_position "menu-name" 5             # Remember cursor position
restore_cursor_position "menu-name"            # Restore saved position
# When returning to a menu, cursor returns to last position
```

#### `menu_navigation.zsh` - Keyboard Input and Navigation Logic

**Keyboard handling** for menu navigation, item selection, and navigation commands.

**Navigation Keys:**
- `↑` / `k` - Move cursor up
- `↓` / `j` - Move cursor down
- `Space` - Toggle selection (multi-select)
- `Enter` - Execute/navigate to selected item
- `←` / `h` / `Backspace` - Go back to parent menu
- `→` / `l` - Enter submenu (alternative to Enter)
- `q` / `Esc` - Quit menu
- `a` - Select all (multi-select mode)
- `u` - Update all packages (context-sensitive)
- `?` - Show help

**Return Codes:**
```zsh
MENU_NAV_CONTINUE=0      # Continue menu loop
MENU_NAV_EXECUTE=1       # Execute selected action
MENU_NAV_BACK=2          # Return to parent menu
MENU_NAV_QUIT=3          # Exit entire menu system
```

**See also:** [bin/lib/MENU_ENGINE_API.md](bin/lib/MENU_ENGINE_API.md) for complete API documentation with examples.

### Testing Infrastructure

#### `test_libraries.zsh` - Testing Framework Utilities

**Lightweight testing framework** with beautiful OneDark output and comprehensive assertion library.

**Test Functions:**
```zsh
assert_equals "expected" "actual" "Test name"  # Equality check
assert_not_equals "val1" "val2" "Test name"    # Inequality check
assert_true condition "Test name"              # Boolean true
assert_false condition "Test name"             # Boolean false
assert_contains "string" "substring"           # String contains
assert_command_exists "git"                    # Command available
assert_file_exists "/path/to/file"             # File exists
```

**Test Organization:**
```zsh
test_suite_name="My Test Suite"

function test_feature_one() {
    assert_equals "expected" "actual" "Feature one works"
}

function test_feature_two() {
    assert_true "[[ -d /tmp ]]" "/tmp directory exists"
}

# Run all tests
run_test_suite
```

**See also:** [tests/README.md](tests/README.md) and [TESTING.md](TESTING.md) for comprehensive testing documentation.

---

### Library Statistics

- **14 specialized libraries**
- **200+ exported functions**
- **Used by 80+ scripts** across the dotfiles
- **~96% code coverage** via 251 tests across 15 test suites
- **Consistent OneDark theming** throughout
- **Cross-platform support** (macOS, Linux, Windows)

### Usage Example

**Complete script using multiple libraries:**

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../bin/lib/colors.zsh"
source "$SCRIPT_DIR/../bin/lib/ui.zsh"
source "$SCRIPT_DIR/../bin/lib/utils.zsh"
source "$SCRIPT_DIR/../bin/lib/arguments.zsh"
source "$SCRIPT_DIR/../bin/lib/validators.zsh"
source "$SCRIPT_DIR/../bin/lib/dependencies.zsh"
source "$SCRIPT_DIR/../bin/lib/package_managers.zsh"
source "$SCRIPT_DIR/../bin/lib/greetings.zsh"

# Parse arguments
parse_simple_flags "$@"
is_help_requested && show_help

# Declare dependencies
declare_dependency_command "cargo" "Rust toolchain" "toolchains.zsh"

# Main execution
draw_header "My Awesome Script" "Installing Rust tools"
echo

draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1

if is_verbose; then
    print_info "Verbose mode: Showing detailed output"
fi

draw_section_header "Installing Packages"
cargo_install "ripgrep"
cargo_install "fd-find"
cargo_install "bat"

draw_section_header "Verification"
validate_command "rg" "ripgrep"
validate_command "fd" "fd-find"
validate_command "bat" "bat"

echo
print_success "$(get_random_friend_greeting)"
```

---

## Complete API Reference

The shared libraries provide **200+ functions** across 14 specialized modules. Complete API documentation is available in:

### [bin/lib/README.md](bin/lib/README.md) (1750+ lines)

**Comprehensive API reference including:**

- **Architecture Overview** - Dependency graphs, loading order, integration patterns
- **Complete Function Reference** - Signatures, parameters, return values, examples
- **Usage Patterns** - Common workflows, templates, best practices
- **Library Categories** - Organized by functionality (UI, validation, package management, etc.)
- **Contributing Guidelines** - How to add new functions, maintain consistency

**Quick links to sections:**
- [Colors Library API](bin/lib/README.md#colors-library)
- [UI Library API](bin/lib/README.md#ui-library)
- [Utils Library API](bin/lib/README.md#utils-library)
- [Validators Library API](bin/lib/README.md#validators-library)
- [Package Managers Library API](bin/lib/README.md#package-managers-library)

### [bin/lib/MENU_ENGINE_API.md](bin/lib/MENU_ENGINE_API.md) (624 lines)

**Complete menu system documentation:**

- **Three-Module Architecture** - Engine, State, Navigation
- **API Reference** - All functions with signatures and examples
- **Navigation Return Codes** - State machine behavior
- **Keyboard Handling** - Input processing and key mappings
- **Complete Working Example** - Full hierarchical menu implementation

---

## Repository Architecture

### Symlink Patterns

The dotfiles use a **symlink-based architecture** for managing configuration files:

| Pattern | Target Location | Example |
|---------|----------------|---------|
| `*.symlink` | `~/.{basename}` | `zsh/zshrc.symlink` → `~/.zshrc` |
| `*.symlink_config` | `~/.config/{basename}` | `nvim/nvim.symlink_config/` → `~/.config/nvim/` |
| `*.symlink_local_bin.*` | `~/.local/bin/{basename}` | `github/get_github_url.symlink_local_bin.zsh` → `~/.local/bin/get_github_url` |

**Benefits:**
- Version control your configurations
- Easy rollback and experimentation
- Consistent across machines
- Automatic backup before linking

### Core Infrastructure

**Main Scripts:**

| Script | Purpose |
|--------|---------|
| `bin/setup.zsh` | Cross-platform setup orchestrator with automatic OS detection |
| `bin/menu_tui.zsh` | Interactive TUI menu with hierarchical navigation (Phase 7) |
| `bin/librarian.zsh` | System health checker and comprehensive status reporter |
| `bin/link_dotfiles.zsh` | Symlink creation engine |
| `bin/backup_dotfiles_repo.zsh` | Comprehensive backup system |
| `bin/update_all.zsh` | Central update script with category filtering |
| `bin/profile_manager.zsh` | Profile management and application (Phase 4) |
| `bin/wizard.zsh` | Interactive setup wizard for custom configurations |

**Convenience Wrappers:**

POSIX shell wrappers that ensure zsh is available:
- `./setup` → `bin/setup.zsh`
- `./backup` → `bin/backup_dotfiles_repo.zsh`
- `./update` → `bin/update_all.zsh`

### OS Detection and Context

**Automatic environment variables** set by `setup.zsh`:

| Variable | Description | Examples |
|----------|-------------|----------|
| `DF_OS` | Detected operating system | `macos`, `linux`, `windows`, `unknown` |
| `DF_PKG_MANAGER` | System package manager | `brew`, `apt`, `dnf`, `pacman`, `choco` |
| `DF_PKG_INSTALL_CMD` | Full installation command | `brew install`, `sudo apt install -y` |

**Path Context Variables:**

| Variable | Description |
|----------|-------------|
| `DF_DIR` | Dotfiles repository root |
| `DF_SCRIPT_DIR` | Directory of currently executing script |
| `DF_LIB_DIR` | Shared libraries directory (`bin/lib/`) |
| `DF_CONFIG_DIR` | Configuration directory (`config/`) |

**Usage:**
```zsh
# Initialize paths
init_dotfiles_paths  # Sets all DF_* variables

# Access context
case "$DF_OS" in
    macos)   brew install "$package" ;;
    linux)   sudo apt install "$package" ;;
    windows) choco install "$package" ;;
esac
```

### Directory Structure

```
dotfiles/
├── bin/                          # Core infrastructure scripts
│   ├── setup.zsh                 # Main setup orchestrator
│   ├── menu_tui.zsh              # Interactive TUI menu (Phase 7)
│   ├── librarian.zsh             # System health checker
│   ├── update_all.zsh            # Central update script
│   ├── profile_manager.zsh       # Profile management
│   ├── wizard.zsh                # Interactive wizard
│   └── lib/                      # Shared libraries (14 files)
│       ├── colors.zsh
│       ├── ui.zsh
│       ├── utils.zsh
│       ├── arguments.zsh
│       ├── validators.zsh
│       ├── dependencies.zsh
│       ├── package_managers.zsh
│       ├── installers.zsh
│       ├── os_operations.zsh
│       ├── greetings.zsh
│       ├── menu_engine.zsh
│       ├── menu_state.zsh
│       ├── menu_navigation.zsh
│       └── test_libraries.zsh
│
├── post-install/                 # Post-installation scripts
│   ├── scripts/                  # Individual setup scripts
│   │   ├── cargo-packages.zsh
│   │   ├── npm-global-packages.zsh
│   │   ├── ruby-gems.zsh
│   │   ├── language-servers.zsh
│   │   ├── toolchains.zsh
│   │   └── ...
│   ├── README.md                 # Post-install system guide
│   └── ARGUMENT_PARSING.md       # Standardized argument patterns
│
├── packages/                     # Universal package management
│   ├── base.yaml                 # Curated base manifest (~50 packages)
│   ├── SCHEMA.md                 # Complete YAML specification
│   └── README.md                 # Package system documentation
│
├── profiles/                     # Configuration profiles
│   ├── minimal.yaml
│   ├── standard.yaml
│   ├── full.yaml
│   ├── manifests/                # Package manifests per profile
│   └── README.md                 # Profile system documentation
│
├── config/                       # Configuration files
│   ├── paths.env                 # Path configuration
│   ├── versions.env              # Version pinning
│   └── packages/                 # Package lists (.list files)
│
├── tests/                        # Test infrastructure
│   ├── run_tests.zsh             # Test runner
│   ├── unit/                     # Unit tests (105 tests)
│   ├── integration/              # Integration tests (146 tests)
│   ├── lib/                      # Test framework
│   └── README.md                 # Testing documentation
│
├── zsh/                          # Shell configurations
├── nvim/                         # Neovim configuration (submodule)
├── git/                          # Git configurations
├── tmux/                         # tmux configuration
├── kitty/                        # Kitty terminal
├── alacritty/                    # Alacritty terminal
└── ...                           # Additional tool configurations
```

---

## Writing Scripts Guide

### Script Template

**Complete template for new post-install scripts:**

```zsh
#!/usr/bin/env zsh

# ============================================================================
# Script Name - Brief Description
# ============================================================================
#
# Longer description of what this script does, why it exists, and any
# important details about its operation.
#
# Dependencies:
#   - command1 (description) → provider_script.zsh
#   - command2 (description) → "system package"
#
# Package list: config/packages/your-packages.list
#
# Options:
#   --help, -h      Show help message
#   --update        Update packages instead of installing
#   --dry-run, -n   Show what would be done without making changes
#
# Examples:
#   ./script.zsh              # Install packages
#   ./script.zsh --update     # Update installed packages
#   ./script.zsh --dry-run    # Preview actions
#
# ============================================================================

emulate -LR zsh

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/arguments.zsh"
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

PACKAGE_LIST="$CONFIG_DIR/packages/your-packages.list"
UPDATE_MODE=false

# ============================================================================
# Help Text
# ============================================================================

function show_help() {
    cat <<EOF
$(standard_help_header "Script Name" "Brief description")

USAGE:
    $(basename "$0") [OPTIONS]

DESCRIPTION:
    Detailed description of what this script does and when to use it.

OPTIONS:
    --help, -h      Show this help message
    --update        Update installed packages
    --dry-run, -n   Show what would be done without making changes

EXAMPLES:
    $(basename "$0")              # Install packages
    $(basename "$0") --update     # Update packages
    $(basename "$0") --dry-run    # Preview changes

PACKAGE LIST:
    $PACKAGE_LIST

DEPENDENCIES:
    - dependency1 (via provider_script.zsh)
    - dependency2 (system package)

EOF
    exit 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_simple_flags "$@"
is_help_requested && show_help

# Handle custom flags (if any)
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n|--help|-h|--verbose|-v)
            # Skip already handled by parse_simple_flags
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Dependency Declaration
# ============================================================================

declare_dependency_command "required_cmd" "Human-readable name" "provider.zsh"
# Add more dependencies as needed

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Script Title" "Brief subtitle"
echo

# Dependency Validation
draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1

is_verbose && print_info "All dependencies satisfied"
echo

# Main Installation Logic
draw_section_header "Installing Packages"

if is_dry_run; then
    print_info "DRY RUN MODE - No changes will be made"
    echo
fi

# Your installation logic here
# Use package_managers.zsh functions:
pkg_install "package-name" "Human-readable description"
# or
cargo_install_from_list "$PACKAGE_LIST"

echo

# Summary
draw_section_header "Installation Summary"
print_info "📦 What was installed:"
echo "   • Package 1"
echo "   • Package 2"
echo "   • Package 3"
echo
print_info "📍 Location: /path/to/installed/things"
echo
print_success "$(get_random_friend_greeting)"
```

### Common Patterns

#### Pattern 1: Package List Installation

```zsh
# Configuration
PACKAGE_LIST="$CONFIG_DIR/packages/cargo-packages.list"

# Dependencies
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"

# Installation
draw_section_header "Installing Cargo Packages"
cargo_install_from_list "$PACKAGE_LIST"
```

**Package list format** (`config/packages/cargo-packages.list`):
```
# Comments start with #
# Blank lines ignored

# Category: Search tools
ripgrep
fd-find

# Category: File viewers
bat
exa
```

#### Pattern 2: OS-Specific Behavior

```zsh
case "${DF_OS:-$(get_os)}" in
    macos)
        print_info "macOS detected - using Homebrew"
        brew install font-fira-code-nerd-font
        ;;
    linux)
        print_info "Linux detected - manual installation"
        download_file "$FONT_URL" "$FONT_FILE" "Font"
        extract_archive "$FONT_FILE" "$FONTS_DIR"
        fc-cache -f -v
        ;;
    windows)
        print_info "Windows detected - using Chocolatey"
        choco install firacodenf
        ;;
    *)
        print_warning "Unsupported OS - skipping"
        exit 0
        ;;
esac
```

#### Pattern 3: Update vs Install Mode

```zsh
# Argument parsing sets UPDATE_MODE
[[ "$ARG_UPDATE" == "true" ]] && UPDATE_MODE=true

# Main logic
if $UPDATE_MODE; then
    draw_header "Package Manager" "Updating packages"
    gem update
    gem cleanup
else
    draw_header "Package Manager" "Installing packages"
    gem_install_from_list "$PACKAGE_LIST"
fi
```

#### Pattern 4: GitHub Release Installation

```zsh
source "$LIB_DIR/installers.zsh"

RELEASE_URL="https://github.com/user/repo/releases/download/v1.0.0/tool.tar.gz"
DOWNLOAD_FILE="/tmp/tool.tar.gz"

if download_file "$RELEASE_URL" "$DOWNLOAD_FILE" "Tool Name"; then
    extract_archive "$DOWNLOAD_FILE" "$INSTALL_DIR" "Tool Name"
    print_success "Tool installed to $INSTALL_DIR"
fi
```

### Best Practices

**DO:**
- ✅ Use shared libraries for all UI output
- ✅ Declare all dependencies explicitly
- ✅ Handle errors gracefully with helpful messages
- ✅ Make scripts idempotent (safe to run multiple times)
- ✅ Support standard flags (--help, --update, --dry-run)
- ✅ Use configuration files for package lists
- ✅ Provide clear summary at the end
- ✅ Include friendly greeting

**DON'T:**
- ❌ Hardcode ANSI color codes
- ❌ Assume dependencies are available
- ❌ Fail silently without error messages
- ❌ Create non-idempotent scripts
- ❌ Skip argument validation
- ❌ Hardcode package lists in scripts
- ❌ Leave user wondering what happened

### Testing Your Script

**Checklist:**
- [ ] Script is executable (`chmod +x`)
- [ ] `--help` works and shows complete usage
- [ ] All dependencies declared and validated
- [ ] Error messages are helpful
- [ ] Idempotent (safe to run multiple times)
- [ ] OS-specific behavior tested
- [ ] Works via TUI menu
- [ ] Works when run directly
- [ ] Summary shows what was installed

**See also:** [post-install/README.md](post-install/README.md) for comprehensive script writing guide.

---

## Argument Parsing Standard

The **arguments.zsh library** provides standardized CLI parsing, eliminating 200-600 lines of duplicated code across scripts.

### Standard Pattern

```zsh
# Load arguments library
source "$DF_LIB_DIR/arguments.zsh"

# Parse standard flags
parse_simple_flags "$@"
is_help_requested && show_help

# Use parsed flags
[[ "$ARG_UPDATE" == "true" ]] && UPDATE_MODE=true
[[ "$ARG_DRY_RUN" == "true" ]] && DRY_RUN=true
[[ "$ARG_VERBOSE" == "true" ]] && VERBOSE=true

# Validate no unknown arguments
validate_no_unknown_args "$@" || exit 1
```

### Standard Flags

| Flag | Variable | Description |
|------|----------|-------------|
| `-h`, `--help` | `$ARG_HELP` | Show help message |
| `-v`, `--verbose` | `$ARG_VERBOSE` | Verbose output |
| `-n`, `--dry-run` | `$ARG_DRY_RUN` | Preview mode (no changes) |
| `-f`, `--force` | `$ARG_FORCE` | Force operation |
| `-s`, `--silent` | `$ARG_SILENT` | Suppress output |
| `--update` | `$ARG_UPDATE` | Update mode |
| `--resume` | `$ARG_RESUME` | Resume operation |
| `--reset` | `$ARG_RESET` | Reset state |

### Helper Functions

```zsh
is_help_requested                      # Returns 0 if help requested
is_verbose                             # Returns 0 if verbose enabled
is_dry_run                             # Returns 0 if dry-run enabled
validate_no_unknown_args "$@"          # Validates all args recognized
standard_help_header "Name" "Desc"     # Formats help header
```

### Custom Flags

```zsh
# Parse common flags first
parse_simple_flags "$@"
is_help_requested && show_help

# Then handle script-specific flags
for arg in "$@"; do
    case "$arg" in
        --custom-flag)
            CUSTOM=true
            ;;
        --dry-run|-n|--help|-h|--verbose|-v)
            # Skip - already handled by parse_simple_flags
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done
```

### Benefits

- **Consistency** - Same flags work the same way across all scripts
- **DRY Principle** - No code duplication
- **Validation** - Automatic unknown flag detection
- **Documentation** - Standard help formatting
- **Maintainability** - Change once, update everywhere

**See also:** [post-install/ARGUMENT_PARSING.md](post-install/ARGUMENT_PARSING.md) for complete documentation.

---

## Coding Standards

### Line Length and Formatting

**Target:** ~80 column width whenever readability allows

**Flexibility:** Exceed when it improves readability (long strings, URLs)

**Examples:**
```zsh
# Good: Fits in 80 cols, readable
draw_section_header "Setup Complete" "Your environment is ready"

# Also Good: Exceeds 80 cols but more readable than wrapped
local long_url="https://github.com/buckmeister/dotfiles/releases/download/v1.0.0/package.tar.gz"

# Avoid: Unnecessary wrapping that reduces readability
draw_section_header \
    "Setup" \
    "Complete"
```

### Code Consistency

**Look for inspiration in existing code:**

- Study `bin/` directory for established patterns
- Check shared libraries (`bin/lib/`) before writing utilities
- Follow existing patterns in similar scripts
- Reference these examples:
  - `bin/setup.zsh` - Argument parsing, OS detection
  - `bin/menu_tui.zsh` - UI patterns, user interaction
  - `bin/librarian.zsh` - Status reporting
  - `bin/lib/ui.zsh` - Progress bars, headers
  - `bin/lib/utils.zsh` - Helper functions

### DRY Principle (Don't Repeat Yourself)

**Reduce code duplication aggressively:**

```zsh
# Bad: Reimplementing path detection
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Good: Use standardized function
init_dotfiles_paths  # Sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR

# Bad: Custom error message formatting
echo "ERROR: Something went wrong" >&2

# Good: Use shared function
print_error "Something went wrong"
```

### Default Values and Parameter Handling

```zsh
# Good: Default values reduce complexity
local output_file="${1:-~/.local/share/dotfiles/packages.yaml}"
local verbosity="${VERBOSE:-0}"
local dry_run="${DRY_RUN:-false}"

# Good: Function with defaults
function show_status() {
    local message="$1"
    local color="${2:-$UI_INFO_COLOR}"
    local prefix="${3:-ℹ}"

    echo "${color}${prefix} ${message}${COLOR_RESET}"
}
```

### Library Sourcing with Defaults

```zsh
# Required library with clear error
source "$DF_LIB_DIR/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load colors.zsh" >&2
    exit 1
}

# Optional library with fallback
source "$DF_LIB_DIR/greetings.zsh" 2>/dev/null || {
    # Define minimal fallback
    function get_random_greeting() { echo "Hello"; }
}
```

### Pre-Commit Quality Checklist

**Review before committing changes:**

**1. Test Suites**
- [ ] Run `./tests/run_tests.zsh` - All tests pass?
- [ ] New functionality has tests?
- [ ] Edge cases covered?

**2. Documentation**
- [ ] CLAUDE.md updated if architecture changed?
- [ ] README.md updated if user-facing changes?
- [ ] DEVELOPMENT.md updated if API changed?
- [ ] Inline comments for complex logic?

**3. Code Quality**
- [ ] Follows ~80 column guideline where readable?
- [ ] Uses shared libraries (no duplication)?
- [ ] Default values where appropriate?
- [ ] Consistent with existing code style?
- [ ] Cross-platform compatible?

**4. Error Handling**
- [ ] Graceful failures with helpful messages?
- [ ] Required dependencies checked?
- [ ] User-actionable error guidance?

**5. Integration**
- [ ] Compatible with package management system?
- [ ] Uses OS context variables (`$DF_OS`, etc.)?
- [ ] Integrates with shared libraries?
- [ ] Works with existing workflows?

---

## Testing & Contributing

### Testing Patterns

**Unit Tests** - Test individual functions in isolation:
```zsh
# tests/unit/test_utils.zsh
function test_command_exists() {
    assert_true "command_exists ls" "ls command exists"
    assert_false "command_exists nonexistent_cmd" "nonexistent command not found"
}
```

**Integration Tests** - Test complete workflows:
```zsh
# tests/integration/test_setup.zsh
function test_full_setup() {
    ./bin/setup.zsh --skip-pi
    assert_true "[[ -d ~/.config/nvim ]]" "Neovim config linked"
    assert_true "[[ -f ~/.zshrc ]]" "zshrc linked"
}
```

**Test Execution:**
```bash
# Run all tests (251 tests across 15 suites)
./tests/run_tests.zsh

# Run specific test category
./tests/run_tests.zsh unit
./tests/run_tests.zsh integration

# Run specific test file
./tests/unit/test_utils.zsh
```

### Contributing Guidelines

**Adding New Scripts:**
1. Create script in appropriate directory (`post-install/scripts/`, `bin/`, etc.)
2. Follow the [script template](#script-template)
3. Use shared libraries for consistency
4. Add tests for new functionality
5. Update relevant documentation
6. Run test suite before committing

**Improving Existing Scripts:**
1. Read and understand existing code
2. Follow established patterns
3. Test on multiple platforms (macOS, Linux)
4. Maintain backward compatibility
5. Update help text if changing options
6. Run full test suite

**Adding Library Functions:**
1. Choose appropriate library file (or create new one)
2. Follow existing naming conventions
3. Add comprehensive documentation
4. Include usage examples
5. Write unit tests
6. Update bin/lib/README.md

### Code Review Checklist

- [ ] Follows script template and standards
- [ ] Uses shared libraries for UI
- [ ] Declares all dependencies
- [ ] Handles errors gracefully
- [ ] Idempotent (safe to run multiple times)
- [ ] Supports standard flags (--help, --update)
- [ ] Cross-platform compatible
- [ ] Includes tests for new functionality
- [ ] Documentation updated
- [ ] All tests pass

---

## Advanced Topics

### ACTION_PLAN.md Methodology

For **complex improvements** involving multiple related tasks, use the ACTION_PLAN.md approach:

**When to Create an Action Plan:**
- Complex refactoring involving multiple files/systems
- Major feature additions with interdependent tasks
- Documentation overhauls spanning multiple areas
- Quality improvements requiring systematic changes
- Any work with 5+ distinct tasks

**Action Plan Structure:**
```markdown
# Action Plan: [Project Name]

## Context
Brief problem description

## Goals
Clear objectives

## Phase 1: [Phase Name]
- [x] Task 1.1 (✅ Complete)
- [x] Task 1.2 (✅ Complete)
- [ ] Task 1.3 (In Progress)

## Phase 2: [Phase Name]
- [ ] Task 2.1 (Pending)

## Success Criteria
How we know it's complete

## Timeline
Estimated completion
```

**Workflow:**
1. Plan first - create comprehensive action plan
2. Review together - discuss priorities
3. Tackle in phases - 1-2 phases at a time
4. Assess progress - review after each phase
5. Update ACTION_PLAN.md - mark completed tasks
6. Document in MEETINGS.md - add milestone journal entry

**See also:** [CLAUDE.md](CLAUDE.md#action_planmd-approach) for complete methodology.

### Post-Install Script Control

**Marker files** for fine-grained control over which scripts run:

| Marker | Scope | Git Tracked | Use Case |
|--------|-------|-------------|----------|
| `.ignored` | Local only | ❌ No | Machine-specific, temporary testing |
| `.disabled` | Team-wide | ✅ Yes | Deprecated scripts, incomplete features |

**Creating markers:**
```bash
# Local-only skip (not committed)
touch post-install/scripts/npm-global-packages.zsh.ignored

# Team-wide disable (committable)
touch post-install/scripts/old-script.zsh.disabled
```

**Effects:**
- Skipped by `./setup` and `bin/setup.zsh`
- Don't appear in TUI menu
- Excluded from `bin/librarian.zsh --all-pi`
- No effect when run directly

**See also:** [post-install/README.md](post-install/README.md#post-install-script-control) for complete documentation.

### Universal Package Management

**Cross-platform package manifest system** for reproducible environments:

```bash
# Generate manifest from current system
generate_package_manifest

# Install from manifest on new machine
install_from_manifest

# Keep synchronized
sync_packages --push
```

**Features:**
- One YAML manifest works on all platforms
- Supports brew, apt, cargo, npm, pipx, gem, and more
- Priority levels (required/recommended/optional)
- Category filtering
- Git integration

**See also:** [packages/README.md](packages/README.md) for complete package system documentation.

---

## Documentation Index

### Core Documentation

- **[README.md](README.md)** - User-facing quick start and overview
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - This file (developer documentation hub)
- **[CLAUDE.md](CLAUDE.md)** - AI assistant guidance and system architecture
- **[INSTALL.md](INSTALL.md)** - Detailed installation and troubleshooting
- **[MANUAL.md](MANUAL.md)** - Configuration reference and keybindings
- **[TESTING.md](TESTING.md)** - Comprehensive testing documentation
- **[CHANGELOG.md](CHANGELOG.md)** - Project history and milestones

### Shared Libraries

- **[bin/lib/README.md](bin/lib/README.md)** - Complete API reference (1750+ lines)
- **[bin/lib/MENU_ENGINE_API.md](bin/lib/MENU_ENGINE_API.md)** - Menu system documentation (624 lines)

### Subsystem Documentation

- **[post-install/README.md](post-install/README.md)** - Post-install script system (1615 lines)
- **[post-install/ARGUMENT_PARSING.md](post-install/ARGUMENT_PARSING.md)** - Standardized argument patterns
- **[packages/README.md](packages/README.md)** - Universal package management
- **[packages/SCHEMA.md](packages/SCHEMA.md)** - Package manifest specification
- **[profiles/README.md](profiles/README.md)** - Configuration profiles
- **[tests/README.md](tests/README.md)** - Testing infrastructure

### Maintenance Notes

- **MEETINGS.md** - Private meeting notes and planning (local-only, gitignored)
- **ACTION_PLAN.md** - Living document tracking current and future tasks

---

**Created:** 2025-10-16
**Status:** Production Ready ✨
**Maintainers:** Thomas + Aria (Claude Code)

This documentation serves as the **single source of truth** for all development activities in the dotfiles repository. Keep it updated as the system evolves!
