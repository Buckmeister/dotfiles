# Post-Install Scripts System

**Beautiful, modular post-installation automation for the dotfiles repository.**

The post-install system is a collection of independent, OS-aware scripts that automate the installation of development tools, language runtimes, packages, and configurations. Each script follows consistent patterns, uses shared libraries for beautiful UI, and automatically adapts to your operating system.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Script Index](#script-index)
- [Architecture](#architecture)
- [Writing New Scripts](#writing-new-scripts)
- [Common Patterns](#common-patterns)
- [OS Context Variables](#os-context-variables)
- [Testing Your Script](#testing-your-script)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Argument Parsing Standard](ARGUMENT_PARSING.md) ⭐

---

## Overview

### What Are Post-Install Scripts?

Post-install scripts are **modular installation automation** that run after the initial dotfiles setup. Each script:

- **Installs specific tools or packages** (language runtimes, CLI tools, LSP servers, fonts, etc.)
- **Uses shared libraries** for consistent, beautiful UI output
- **Automatically adapts** to your operating system (macOS, Linux, Windows)
- **Declares dependencies** that are automatically resolved
- **Can be run independently** or through the interactive TUI menu
- **Provides helpful output** with progress bars, status messages, and friendly greetings

### Design Philosophy

The post-install system follows these principles:

1. **Modularity** - Each script is independent and focused on one task
2. **Reusability** - Shared libraries provide common functionality
3. **Consistency** - All scripts follow the same patterns and structure
4. **Beauty** - OneDark color scheme and beautiful UI components throughout
5. **Cross-Platform** - OS detection and adaptation built into every script
6. **Friendly** - Encouraging messages and helpful error reporting
7. **Idempotent** - Running scripts multiple times is safe

---

## Quick Start

### Running Post-Install Scripts

**Via Interactive TUI Menu (Recommended):**
```bash
# Run setup, which launches the TUI menu
./setup

# Navigate with arrow keys or j/k
# Select scripts with Space
# Press Enter to execute
```

**Run All Scripts Automatically:**
```bash
# Run all post-install scripts in sequence
./bin/librarian.zsh --all-pi
```

**Run Individual Scripts:**
```bash
# Execute a specific script directly
./post-install/scripts/cargo-packages.zsh

# With options (example)
./post-install/scripts/ruby-gems.zsh --update
```

**Get Help for Any Script:**
```bash
# All scripts support --help
./post-install/scripts/npm-global-packages.zsh --help
```

---

## Script Index

### Current Scripts

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| **bash-preexec.zsh** | Install bash-preexec hook | bash |
| **cargo-packages.zsh** | Install Rust packages via Cargo | cargo, rust |
| **fonts.zsh** | Install Nerd Fonts (Linux only) | fc-cache |
| **ghcup-packages.zsh** | Install Haskell tools via ghcup | ghcup |
| **git-delta.zsh** | Install git-delta (syntax highlighter) | git |
| **git-delta-config.zsh** | Configure git-delta | git, delta |
| **git-settings-general.zsh** | Configure git settings | git |
| **haskell-toolchain.zsh** | Install Haskell toolchain (Stack, GHCup) | none |
| **language-servers.zsh** | Install LSP servers (JDT.LS, OmniSharp, rust-analyzer) | varies |
| **lombok.zsh** | Install Java Lombok | java |
| **luarocks-packages.zsh** | Install Lua packages via LuaRocks | luarocks |
| **npm-global-packages.zsh** | Install Node.js global packages | npm |
| **python-packages.zsh** | Install Python tools (pipx, HTTPie, Neovim support) | python3, pipx |
| **ruby-gems.zsh** | Install Ruby gems | ruby, gem |
| **rust-toolchain.zsh** | Install Rust toolchain (rustup, cargo, rustc) | none |
| **starship-prompt.zsh** | Install Starship cross-shell prompt | none |
| **vim-setup.zsh** | Setup vim-plug and plugins | vim or nvim |

### Categories

**Language Package Managers:**
- `cargo-packages.zsh` - Rust packages
- `npm-global-packages.zsh` - Node.js packages
- `ruby-gems.zsh` - Ruby gems
- `luarocks-packages.zsh` - Lua packages
- `ghcup-packages.zsh` - Haskell tools

**Development Toolchains:**
- `haskell-toolchain.zsh` - Haskell Stack and GHCup
- `rust-toolchain.zsh` - Rust (rustup, cargo, rustc)
- `language-servers.zsh` - LSP servers for editors

**Configuration & Setup:**
- `vim-setup.zsh` - Vim plugin manager
- `git-delta.zsh` - Git diff tool
- `git-delta-config.zsh` - Git delta configuration
- `git-settings-general.zsh` - Git global configuration
- `bash-preexec.zsh` - Bash hook system
- `starship-prompt.zsh` - Starship cross-shell prompt
- `lombok.zsh` - Java Lombok

**System Utilities:**
- `fonts.zsh` - Terminal fonts
- `python-packages.zsh` - Python environment

---

## Architecture

### Directory Structure

```
post-install/
├── README.md                           # This file
└── scripts/                            # Post-install scripts
    ├── bash-preexec.zsh
    ├── cargo-packages.zsh
    ├── fonts.zsh
    ├── git-delta.zsh
    ├── language-servers.zsh
    ├── npm-global-packages.zsh
    ├── python-packages.zsh
    ├── ruby-gems.zsh
    ├── toolchains.zsh
    ├── vim-setup.zsh
    └── ...
```

### How Scripts Are Discovered

The TUI menu (`bin/menu_tui.zsh`) automatically discovers all `.zsh` files in `post-install/scripts/` and presents them for selection. No registration or configuration needed!

### Execution Flow

1. **User selects script** in TUI menu or runs directly
2. **Script loads shared libraries** (colors, ui, utils, validators, dependencies, etc.)
3. **Script declares dependencies** using `declare_dependency_command`
4. **Dependencies are validated** and automatically resolved if possible
5. **Main installation logic** executes with beautiful progress output
6. **Summary shown** with installation results
7. **Friendly greeting** displayed

### Shared Library Integration

All post-install scripts use shared libraries from `bin/lib/`:

- **colors.zsh** - OneDark color constants
- **ui.zsh** - Headers, progress bars, status messages
- **utils.zsh** - OS detection, common utilities
- **validators.zsh** - Command/package existence checking
- **dependencies.zsh** - Dependency declaration and resolution
- **package_managers.zsh** - Cross-platform package installation
- **os_operations.zsh** - OS-specific operations (directories, symlinks, etc.)
- **installers.zsh** - Download/extract helpers for GitHub releases
- **greetings.zsh** - Friendly, multilingual messages

See [`bin/lib/README.md`](../bin/lib/README.md) for complete API reference.

### Post-Install Script Control (.ignored and .disabled)

The post-install system supports **fine-grained control** over which scripts run using marker files. This allows you to skip specific scripts without deleting them, either temporarily (local machine) or permanently (team-wide).

#### Marker File Semantics

| Marker File | Scope | Git Tracked | Use Case |
|-------------|-------|-------------|----------|
| **`.ignored`** | Local only | ❌ No (gitignored) | Machine-specific preferences, temporary testing |
| **`.disabled`** | Team-wide | ✅ Yes (committable) | Deprecated scripts, incomplete features |

#### How Marker Files Work

**Creating Marker Files:**

```bash
# Temporarily skip a script on this machine only
touch post-install/scripts/npm-global-packages.zsh.ignored

# Permanently disable a script for everyone (committable)
touch post-install/scripts/old-script.zsh.disabled
```

**Effects on System Components:**

1. **`./setup` and `bin/setup.zsh`** - Skips marked scripts during initial setup
2. **`bin/menu_tui.zsh`** - Marked scripts don't appear in the interactive TUI menu
3. **`bin/librarian.zsh --all-pi`** - Skips marked scripts when running all post-install scripts
4. **Direct execution** - Marker files have NO effect (script still runs if invoked directly)

**Detection Logic:**

```zsh
# Scripts are skipped if EITHER marker file exists
if [[ -f "$script.ignored" ]] || [[ -f "$script.disabled" ]]; then
    # Skip this script
    continue
fi
```

#### Use Cases

**Use Case 1: Minimal Docker Profile (`.ignored` for local testing)**

You're testing the dotfiles in a minimal Docker container and want to skip heavy installations:

```bash
# Skip large installations in Docker
cd ~/.config/dotfiles/post-install/scripts
touch cargo-packages.zsh.ignored
touch npm-global-packages.zsh.ignored
touch ruby-gems.zsh.ignored
touch language-servers.zsh.ignored

# Run setup - these scripts are automatically skipped
./setup
```

**Why `.ignored`?** The exclusions are specific to this Docker container and shouldn't affect other machines or be committed to git.

**Use Case 2: Team Standardization (`.disabled` for permanent removal)**

Your team decides certain tools are no longer needed:

```bash
# Permanently disable obsolete scripts (committable to git)
cd ~/.config/dotfiles/post-install/scripts
touch old-package-manager.zsh.disabled
touch deprecated-tool.zsh.disabled

# Commit these changes
git add post-install/scripts/*.disabled
git commit -m "Disable obsolete post-install scripts"
git push

# Everyone on the team now skips these scripts automatically
```

**Why `.disabled`?** The decision applies to the entire team and should be tracked in version control.

**Use Case 3: Work vs. Personal Machines (`.ignored` for profiles)**

You maintain separate profiles for work and personal machines:

```bash
# On work machine - skip personal development tools
touch post-install/scripts/game-dev-tools.zsh.ignored
touch post-install/scripts/personal-scripts.zsh.ignored

# On personal machine - skip work-specific tools
touch post-install/scripts/work-vpn-setup.zsh.ignored
touch post-install/scripts/corporate-tools.zsh.ignored
```

**Why `.ignored`?** Each machine has different requirements, and these preferences shouldn't be committed.

**Use Case 4: Incomplete Features (`.disabled` during development)**

You're developing a new post-install script that's not ready for production:

```bash
# Disable incomplete script (committable)
touch post-install/scripts/experimental-feature.zsh.disabled

# Develop and test by running directly (marker files don't affect direct execution)
./post-install/scripts/experimental-feature.zsh

# When ready, remove the marker and commit
rm post-install/scripts/experimental-feature.zsh.disabled
git add post-install/scripts/experimental-feature.zsh
git commit -m "Enable experimental feature script"
```

**Why `.disabled`?** Prevents incomplete features from running in TUI menu or during `./setup` while still allowing direct testing.

**Use Case 5: Debugging and Isolation**

You're troubleshooting a post-install script issue:

```bash
# Temporarily disable all scripts except the one you're debugging
cd ~/.config/dotfiles/post-install/scripts
for script in *.zsh; do
    [[ "$script" != "debug-this-script.zsh" ]] && touch "$script.ignored"
done

# Run setup - only debug-this-script.zsh will run
./setup

# Clean up when done
rm *.ignored
```

**Why `.ignored`?** Temporary debugging configuration that shouldn't be committed.

#### Practical Examples

**Example 1: Skip Rust Toolchain on CI Servers**

```bash
# In CI environment, skip Rust installation (use pre-installed version)
echo "Skipping Rust toolchain (using system version)" > post-install/scripts/toolchains.zsh.ignored
```

**Example 2: Disable Deprecated Script Team-Wide**

```bash
# Old script no longer maintained, disable for everyone
touch post-install/scripts/old-bash-config.zsh.disabled
git add post-install/scripts/old-bash-config.zsh.disabled
git commit -m "Disable old-bash-config (superseded by new-bash-config)"
```

**Example 3: Profile-Based Filtering**

```bash
# Function to apply minimal profile (add to your setup script)
function apply_minimal_profile() {
    local scripts=(
        "cargo-packages.zsh"
        "npm-global-packages.zsh"
        "ruby-gems.zsh"
        "language-servers.zsh"
        "fonts.zsh"
    )

    for script in "${scripts[@]}"; do
        touch "post-install/scripts/$script.ignored"
    done

    echo "✅ Minimal profile applied (heavy scripts disabled)"
}

# Apply the profile
apply_minimal_profile
```

**Example 4: Conditional Disabling Based on Environment**

```bash
# In your setup script or .zshrc
if [[ "$CI" == "true" ]]; then
    # CI environment - skip interactive scripts
    touch ~/.config/dotfiles/post-install/scripts/vim-setup.zsh.ignored
    touch ~/.config/dotfiles/post-install/scripts/fonts.zsh.ignored
elif [[ "$(uname)" == "Linux" ]] && grep -q "docker" /proc/1/cgroup 2>/dev/null; then
    # Docker container - minimal installation
    touch ~/.config/dotfiles/post-install/scripts/*.ignored
    rm ~/.config/dotfiles/post-install/scripts/git-settings-general.zsh.ignored
fi
```

#### Checking Marker File Status

**List all marked scripts:**

```bash
# List all ignored scripts (local only)
ls -1 post-install/scripts/*.ignored 2>/dev/null | sed 's/\.ignored$//'

# List all disabled scripts (team-wide)
ls -1 post-install/scripts/*.disabled 2>/dev/null | sed 's/\.disabled$//'

# List all marked scripts (both types)
ls -1 post-install/scripts/*.{ignored,disabled} 2>/dev/null
```

**Check if a specific script is marked:**

```bash
# Check if script is marked
script="post-install/scripts/npm-global-packages.zsh"
if [[ -f "$script.ignored" ]]; then
    echo "⚠️  Script is locally ignored"
elif [[ -f "$script.disabled" ]]; then
    echo "🚫 Script is disabled team-wide"
else
    echo "✅ Script is active"
fi
```

**Clean up all `.ignored` files:**

```bash
# Remove all local ignore markers
rm post-install/scripts/*.ignored

# This is safe - .ignored files are never committed to git
```

#### Integration with System Tools

**`bin/librarian.zsh` Status Reporting:**

The librarian tool automatically reports marked scripts:

```bash
./bin/librarian.zsh

# Output includes:
# 📋 Post-Install Scripts:
#    - Active: 12
#    - Ignored (local): 3
#    - Disabled (team): 2
```

**`bin/menu_tui.zsh` Filtering:**

The TUI menu automatically filters out marked scripts:

```bash
./setup

# Only active scripts appear in the menu
# Marked scripts are silently filtered
```

**Git Status Check:**

```bash
# Check for uncommitted .disabled files (reminder to commit team decisions)
git status post-install/scripts/*.disabled

# .ignored files never appear in git status (they're gitignored)
git status post-install/scripts/*.ignored
# (no output - gitignored)
```

#### Advanced: Programmatic Script Selection

**Dynamic profile application using YAML manifests:**

See [`packages/`](../packages/) for comprehensive profile management using YAML manifests. These manifests allow you to specify:

- Package lists (brew, apt, cargo, npm, pip, etc.)
- Post-install script inclusion/exclusion rules
- Profile inheritance (minimal → standard → full)

**Example from `packages/minimal.yaml`:**

```yaml
post_install:
  include:
    - git-settings-general.zsh
    - git-delta-config.zsh
  exclude:
    - cargo-packages.zsh
    - npm-global-packages.zsh
    - ruby-gems.zsh
    - language-servers.zsh
```

The profile system automatically creates `.ignored` marker files for excluded scripts.

#### Cross-References

- **Package Profiles:** [`packages/README.md`](../packages/README.md) - YAML-based profile management
- **Main README:** [`README.md`](../README.md#profile-system) (lines 114-135) - Profile system overview
- **Project Philosophy:** [`CLAUDE.md`](../CLAUDE.md#post-install-script-filtering) (lines 187-244) - Design rationale
- **Testing Documentation:** [`tests/README.md`](../tests/README.md) - Test coverage for filtering
- **Git Configuration:** [`.gitignore`](../.gitignore) - Why `.ignored` files are excluded

#### Best Practices

**When to use `.ignored`:**
- ✅ Machine-specific preferences (work vs. personal)
- ✅ Temporary testing and debugging
- ✅ CI/CD environment customization
- ✅ Docker container profiles
- ❌ Don't commit `.ignored` files (they're gitignored by design)

**When to use `.disabled`:**
- ✅ Deprecating scripts team-wide
- ✅ Incomplete features during development
- ✅ Scripts that are broken or unmaintained
- ✅ Platform-specific exclusions (e.g., "macos-only.zsh.disabled" on Linux)
- ❌ Don't use for temporary testing (use `.ignored` instead)

**Workflow Tips:**

1. **Start with `.ignored`** for experimentation
2. **Promote to `.disabled`** when decisions are team-wide
3. **Document** why scripts are disabled (commit messages, code comments)
4. **Review periodically** - clean up obsolete markers
5. **Use profiles** for complex multi-script configurations

---

## Writing New Scripts

### Script Template

Use this template as a starting point for new post-install scripts:

```zsh
#!/usr/bin/env zsh

# ============================================================================
# Script Name and Purpose
# ============================================================================
#
# Brief description of what this script does.
# Explain the purpose and any important details.
#
# Dependencies:
#   - command1 (description) → provider script or "system package"
#   - command2 (description) → provider script or "system package"
#
# Package list: env/packages/your-package-list.list (if applicable)
#
# Notes:
#   - Any special considerations
#   - Platform-specific behaviors
# ============================================================================

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Load shared libraries (adjust based on your needs)
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

PACKAGE_LIST="$CONFIG_DIR/packages/your-packages.list"
UPDATE_MODE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

DESCRIPTION:
    Brief description of what this script does.

OPTIONS:
    --update    Update installed packages instead of installing new ones
    --help, -h  Show this help message

EXAMPLES:
    $(basename "$0")              # Install packages
    $(basename "$0") --update     # Update installed packages

EOF
            exit 0
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

declare_dependency_command "required_command" "Human-readable name" "provider_script.zsh"
# Add more dependencies as needed

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Your Script Title" "Brief subtitle"
echo

# ============================================================================
# Dependency Validation
# ============================================================================

draw_section_header "Checking Dependencies"

check_and_resolve_dependencies || exit 1

# Show version information if helpful
if command_exists your_command; then
    local version=$(your_command --version 2>&1 | head -1)
    print_success "Your command available (version: $version)"
fi

echo

# ============================================================================
# Installation Logic
# ============================================================================

draw_section_header "Installing Your Things"

# Your installation logic here
# Use functions from package_managers.zsh:
#   - pkg_install "package" "description"
#   - npm_install_from_list "$PACKAGE_LIST"
#   - cargo_install_from_list "$PACKAGE_LIST"
#   - gem_install_from_list "$PACKAGE_LIST"
#   - etc.

print_info "Doing something..."
# ... your code ...
print_success "Task completed successfully"

echo

# ============================================================================
# Summary
# ============================================================================

draw_section_header "Installation Summary"

print_info "📦 What was installed:"
echo
echo "   • Item 1"
echo "   • Item 2"
echo "   • Item 3"

echo
print_info "📍 Location: /path/to/installed/things"

echo
print_success "$(get_random_friend_greeting)"
```

### Step-by-Step Guide

**1. Create Your Script File**

```bash
cd ~/.config/dotfiles/post-install/scripts
touch your-script-name.zsh
chmod +x your-script-name.zsh
```

**2. Add the Script Header**

Include:
- Script name and purpose
- Brief description
- Dependencies list
- Package list location (if applicable)
- Special notes

**3. Load Shared Libraries**

Always load these core libraries:
```zsh
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
```

Load additional libraries as needed:
```zsh
source "$LIB_DIR/validators.zsh"        # For validation functions
source "$LIB_DIR/dependencies.zsh"       # For dependency management
source "$LIB_DIR/package_managers.zsh"   # For package installation
source "$LIB_DIR/os_operations.zsh"      # For OS-specific operations
source "$LIB_DIR/installers.zsh"         # For downloading/extracting
source "$LIB_DIR/greetings.zsh"          # For friendly messages
```

**4. Define Configuration Variables**

```zsh
PACKAGE_LIST="$CONFIG_DIR/packages/your-packages.list"
UPDATE_MODE=false
CUSTOM_DIR="${CUSTOM_DIR:-$HOME/.local/lib/your-tool}"
```

**5. Implement Argument Parsing**

Always support `--help`:
```zsh
for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

DESCRIPTION:
    Your script description here.

OPTIONS:
    --update    Update mode description
    --help, -h  Show this help message

EXAMPLES:
    $(basename "$0")          # Basic usage
    $(basename "$0") --update # Update usage
EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done
```

**6. Declare Dependencies**

```zsh
# Command dependencies (will be checked/resolved)
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"

# The third argument can be:
# - "" (empty) for system packages
# - "script.zsh" for dependencies provided by other post-install scripts
```

**7. Write Main Execution Logic**

Follow this structure:
```zsh
# Header
draw_header "Your Script Title" "Subtitle"
echo

# Dependency Check
draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1
echo

# Installation
draw_section_header "Installing Things"
# Your installation logic
echo

# Summary
draw_section_header "Installation Summary"
print_info "📦 What was installed:"
echo "   • Item 1"
echo
print_success "$(get_random_friend_greeting)"
```

**8. Use Package Manager Functions**

For language-specific packages:
```zsh
# Cargo (Rust)
cargo_install_from_list "$PACKAGE_LIST"

# npm (Node.js)
npm_install_from_list "$PACKAGE_LIST"

# gem (Ruby)
gem_install_from_list "$PACKAGE_LIST"

# pipx (Python apps)
pipx_install_from_list "$PACKAGE_LIST"

# luarocks (Lua)
luarocks_install_from_list "$PACKAGE_LIST"
```

For system packages:
```zsh
pkg_install "curl" "HTTP client"
pkg_install "git" "Version control"
```

**9. Handle OS-Specific Behavior**

Use OS context variables or OS detection:
```zsh
case "${DF_OS:-$(get_os)}" in
    macos)
        print_info "macOS detected - using Homebrew"
        brew install your-package
        ;;
    linux)
        print_info "Linux detected - using apt/dnf"
        pkg_install "your-package"
        ;;
    windows)
        print_info "Windows detected - using chocolatey"
        choco install your-package
        ;;
    *)
        print_error "Unsupported OS: ${DF_OS:-unknown}"
        exit 1
        ;;
esac
```

**10. Test Your Script**

```bash
# Test help output
./post-install/scripts/your-script.zsh --help

# Test actual execution
./post-install/scripts/your-script.zsh

# Test with options
./post-install/scripts/your-script.zsh --update
```

---

## Common Patterns

### Pattern 1: Package List Installation

**Use Case:** Installing multiple packages from a list file

**Pattern:**
```zsh
# Configuration
PACKAGE_LIST="$CONFIG_DIR/packages/cargo-packages.list"

# Dependency Declaration
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
declare_dependency_command "rustc" "Rust compiler" "toolchains.zsh"

# Installation
draw_section_header "Installing Cargo Packages"
cargo_install_from_list "$PACKAGE_LIST"
```

**Package List Format** (`env/packages/cargo-packages.list`):
```
# Rust CLI tools
ripgrep
fd-find
bat
exa

# Development tools
cargo-watch
cargo-edit
```

### Pattern 2: OS-Specific Installation

**Use Case:** Different installation methods for different operating systems

**Pattern:**
```zsh
case "${DF_OS:-$(get_os)}" in
    macos)
        print_info "macOS detected - fonts via Homebrew"
        brew install font-fira-code-nerd-font
        ;;
    linux)
        print_info "Linux detected - manual font installation"
        download_file "$FONT_URL" "$FONT_FILE" "Font"
        extract_archive "$FONT_FILE" "$FONTS_DIR"
        fc-cache -f -v
        ;;
    *)
        print_warning "Unsupported OS - skipping"
        exit 0
        ;;
esac
```

### Pattern 3: Update vs. Install Mode

**Use Case:** Support both installing and updating packages

**Pattern:**
```zsh
# Argument parsing
UPDATE_MODE=false
for arg in "$@"; do
    case "$arg" in
        --update) UPDATE_MODE=true ;;
    esac
done

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

### Pattern 4: Function Decomposition

**Use Case:** Complex installation with multiple steps

**Pattern:**
```zsh
# Define helper functions
function install_powerline() {
    draw_section_header "Powerline Status"
    print_info "Installing powerline-status..."
    pipx install powerline-status
    print_success "Powerline installed"
}

function install_httpie() {
    draw_section_header "HTTPie"
    print_info "Installing HTTPie..."
    pipx install httpie
    pipx inject httpie httpie-jwt-auth
    print_success "HTTPie installed with JWT plugin"
}

# Main execution
install_powerline
echo
install_httpie
```

### Pattern 5: Downloading GitHub Releases

**Use Case:** Installing tools from GitHub releases

**Pattern:**
```zsh
# Use installers.zsh functions
source "$LIB_DIR/installers.zsh"

# Download a GitHub release
RELEASE_URL="https://github.com/user/repo/releases/download/v1.0.0/tool.tar.gz"
DOWNLOAD_FILE="/tmp/tool.tar.gz"

if download_file "$RELEASE_URL" "$DOWNLOAD_FILE" "Tool Name"; then
    extract_archive "$DOWNLOAD_FILE" "$INSTALL_DIR" "Tool Name"
    print_success "Tool installed to $INSTALL_DIR"
fi
```

### Pattern 6: Virtual Environment Creation

**Use Case:** Creating isolated Python/Node environments

**Pattern:**
```zsh
VENV_DIR="$HOME/.local/lib/venvs/my-venv"

# Create virtual environment
if [[ ! -d "$VENV_DIR" ]]; then
    print_info "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi

# Install packages in venv
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install pynvim
```

### Pattern 7: Conditional Dependency Resolution

**Use Case:** Dependencies that might already be satisfied

**Pattern:**
```zsh
# Declare dependencies
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"

# Check and resolve
draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1

# If we reach here, all dependencies are satisfied
print_success "All dependencies satisfied"
```

### Pattern 8: Cleanup and Old Package Detection

**Use Case:** Detecting old installations and offering cleanup

**Pattern:**
```zsh
function check_old_packages() {
    draw_section_header "Checking for Old Packages"

    local old_packages=($(pip list --user | grep httpie))

    if [[ ${#old_packages[@]} -gt 0 ]]; then
        print_warning "Found old user packages:"
        for pkg in "${old_packages[@]}"; do
            echo "  - $pkg"
        done
        echo
        print_info "Consider removing with: pip uninstall --user ${old_packages[*]}"
    else
        print_success "No old packages found"
    fi
}
```

---

## OS Context Variables

### Automatic OS Detection

When scripts are run via `setup.zsh` or the TUI menu, these environment variables are automatically set:

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `DF_OS` | Detected operating system | `macos`, `linux`, `windows`, `unknown` |
| `DF_PKG_MANAGER` | System package manager | `brew`, `apt`, `dnf`, `pacman`, `choco` |
| `DF_PKG_INSTALL_CMD` | Full install command | `brew install`, `sudo apt install -y` |

### Using OS Context Variables

```zsh
# Check the operating system
case "$DF_OS" in
    macos)
        # macOS-specific logic
        ;;
    linux)
        # Linux-specific logic
        ;;
    windows)
        # Windows-specific logic
        ;;
esac

# Use the detected package manager
print_info "Package manager: $DF_PKG_MANAGER"
print_info "Install command: $DF_PKG_INSTALL_CMD"

# Install a system package (automatically uses correct package manager)
pkg_install "curl" "HTTP client"
```

### Fallback for Direct Execution

If your script is run directly (not via TUI menu), you should provide fallbacks:

```zsh
# Get OS if not already set
: ${DF_OS:=$(get_os)}

# Use OS detection function from utils.zsh
case "${DF_OS:-$(get_os)}" in
    macos)
        # macOS logic
        ;;
    linux)
        # Linux logic
        ;;
esac
```

---

## Testing Your Script

### Manual Testing

**1. Test Help Output:**
```bash
./post-install/scripts/your-script.zsh --help
```

**2. Test Dry Run (if supported):**
```bash
./post-install/scripts/your-script.zsh --dry-run
```

**3. Test Actual Execution:**
```bash
./post-install/scripts/your-script.zsh
```

**4. Test with Options:**
```bash
./post-install/scripts/your-script.zsh --update
./post-install/scripts/your-script.zsh --verbose
```

**5. Test from TUI Menu:**
```bash
./setup
# Select your script and run it
```

### Validation Checklist

- [ ] Script is executable (`chmod +x`)
- [ ] `--help` flag works and shows usage
- [ ] All dependencies are declared
- [ ] Script uses shared libraries for UI
- [ ] Error messages are helpful and actionable
- [ ] Script is idempotent (can run multiple times safely)
- [ ] OS-specific behavior is handled correctly
- [ ] Summary section shows what was installed
- [ ] Script includes friendly greeting at the end

### Common Issues

**Issue:** Script can't find shared libraries
```
Error: Could not load shared libraries
```
**Solution:** Check that `SCRIPT_DIR` and paths are correct:
```zsh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
```

**Issue:** Dependencies not found
```
Error: cargo not found
```
**Solution:** Ensure dependencies are declared and `check_and_resolve_dependencies` is called:
```zsh
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
check_and_resolve_dependencies || exit 1
```

**Issue:** Package list not found
```
Error: Package list not found: env/packages/your-list.list
```
**Solution:** Create the package list file or adjust the path:
```bash
touch ~/.config/dotfiles/env/packages/your-packages.list
```

---

## Best Practices

### 1. Use Shared Libraries

**DO:**
```zsh
source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
print_success "Installation complete"
```

**DON'T:**
```zsh
echo "\033[32m✅ Installation complete\033[0m"
```

### 2. Declare All Dependencies

**DO:**
```zsh
declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"
check_and_resolve_dependencies || exit 1
```

**DON'T:**
```zsh
# Assume cargo is available
cargo install ripgrep
```

### 3. Handle Errors Gracefully

**DO:**
```zsh
if cargo install ripgrep >/dev/null 2>&1; then
    print_success "ripgrep installed"
else
    print_error "Failed to install ripgrep"
    print_info "Try running: cargo install ripgrep"
    exit 1
fi
```

**DON'T:**
```zsh
cargo install ripgrep  # No error checking
```

### 4. Be Idempotent

**DO:**
```zsh
if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi
```

**DON'T:**
```zsh
# Always create, will fail if exists
python3 -m venv "$VENV_DIR"
```

### 5. Provide Helpful Output

**DO:**
```zsh
draw_header "Cargo Packages" "Installing Rust CLI tools"
draw_section_header "Installing Packages"
print_info "Installing ripgrep..."
print_success "ripgrep installed successfully"
print_success "$(get_random_friend_greeting)"
```

**DON'T:**
```zsh
echo "Installing..."
cargo install ripgrep > /dev/null
echo "Done"
```

### 6. Use Configuration Files

**DO:**
```zsh
# Use centralized package lists
PACKAGE_LIST="$CONFIG_DIR/packages/cargo-packages.list"
cargo_install_from_list "$PACKAGE_LIST"
```

**DON'T:**
```zsh
# Hardcode packages in script
cargo install ripgrep
cargo install fd-find
cargo install bat
# ... 20 more lines
```

### 7. Support Common Options

Always support:
- `--help` or `-h` for usage information
- `--update` for update mode (if applicable)

Consider supporting:
- `--verbose` or `-v` for detailed output
- `--dry-run` for simulation
- `--force` for forcing reinstallation

### 8. Structure Your Script

Follow this order:
1. Header comment with description
2. Load shared libraries
3. Configuration variables
4. Argument parsing
5. Dependency declaration
6. Main execution with clear sections
7. Summary and friendly greeting

### 9. Document Everything

- Add comments explaining complex logic
- Include usage examples in `--help`
- Document dependencies in header
- Explain OS-specific behavior

### 10. Test Thoroughly

- Test on multiple operating systems
- Test with and without dependencies installed
- Test all command-line options
- Test error conditions

---

## Contributing

### Adding a New Post-Install Script

1. **Create the script file** in `post-install/scripts/`
2. **Follow the template** provided in this document
3. **Use shared libraries** for consistency
4. **Test thoroughly** on your target platforms
5. **Add package list** to `env/packages/` if needed
6. **Update this README** if you're adding a new category

### Improving Existing Scripts

1. **Read the script** and understand its purpose
2. **Follow existing patterns** for consistency
3. **Test your changes** on multiple platforms
4. **Keep backward compatibility** when possible
5. **Update help text** if changing options

### Code Review Checklist

- [ ] Script follows the standard template
- [ ] Uses shared libraries for UI
- [ ] Declares all dependencies
- [ ] Handles errors gracefully
- [ ] Is idempotent (safe to run multiple times)
- [ ] Supports `--help` flag
- [ ] Includes helpful output and messages
- [ ] Works on target platforms (macOS, Linux, Windows)
- [ ] Package lists are in `env/packages/`
- [ ] Documentation is updated

---

## Examples

### Example 1: Simple Package Installation

**Script:** `post-install/scripts/simple-example.zsh`

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/package_managers.zsh"
source "$LIB_DIR/greetings.zsh"

source "$CONFIG_DIR/paths.env"
source "$CONFIG_DIR/versions.env"

PACKAGE_LIST="$CONFIG_DIR/packages/simple-packages.list"

declare_dependency_command "cargo" "Rust package manager" "toolchains.zsh"

draw_header "Simple Package Installer" "Installing Rust tools"
echo

draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1
echo

draw_section_header "Installing Packages"
cargo_install_from_list "$PACKAGE_LIST"
echo

draw_section_header "Installation Summary"
print_info "📦 Installed packages from: $PACKAGE_LIST"
echo
print_success "$(get_random_friend_greeting)"
```

### Example 2: OS-Specific Installation

**Script:** `post-install/scripts/os-specific-example.zsh`

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"

source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"

draw_header "OS-Specific Installation" "Platform-aware setup"
echo

case "${DF_OS:-$(get_os)}" in
    macos)
        print_success "macOS detected"
        print_info "Installing via Homebrew..."
        brew install your-tool
        ;;
    linux)
        print_success "Linux detected"
        print_info "Installing via package manager..."
        pkg_install "your-tool"
        ;;
    windows)
        print_success "Windows detected"
        print_info "Installing via Chocolatey..."
        choco install your-tool
        ;;
    *)
        print_error "Unsupported OS: ${DF_OS:-unknown}"
        exit 1
        ;;
esac

echo
print_success "Installation complete!"
```

### Example 3: Complex Multi-Step Installation

**Script:** `post-install/scripts/complex-example.zsh`

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
CONFIG_DIR="$DOTFILES_ROOT/config"

source "$LIB_DIR/colors.zsh"
source "$LIB_DIR/ui.zsh"
source "$LIB_DIR/utils.zsh"
source "$LIB_DIR/validators.zsh"
source "$LIB_DIR/dependencies.zsh"
source "$LIB_DIR/os_operations.zsh"
source "$LIB_DIR/installers.zsh"
source "$LIB_DIR/greetings.zsh"

source "$CONFIG_DIR/paths.env"

function download_and_install_tool() {
    local tool_name="$1"
    local download_url="$2"
    local install_dir="$3"

    draw_section_header "Installing $tool_name"

    local temp_file=$(mktemp)

    if download_file "$download_url" "$temp_file" "$tool_name"; then
        if extract_archive "$temp_file" "$install_dir" "$tool_name"; then
            print_success "$tool_name installed successfully"
            return 0
        fi
    fi

    print_error "Failed to install $tool_name"
    return 1
}

function setup_configuration() {
    draw_section_header "Setting up Configuration"

    local config_dir="$HOME/.config/my-tool"
    ensure_directory "$config_dir"

    cat > "$config_dir/config.yaml" <<EOF
# Configuration for my-tool
theme: onedark
enable_features:
  - feature1
  - feature2
EOF

    print_success "Configuration created"
}

declare_dependency_command "curl" "HTTP client" ""
declare_dependency_command "tar" "Archive utility" ""

draw_header "Complex Installation Example" "Multi-step setup"
echo

draw_section_header "Checking Dependencies"
check_and_resolve_dependencies || exit 1
echo

download_and_install_tool "MyTool" \
    "https://github.com/user/mytool/releases/download/v1.0.0/mytool.tar.gz" \
    "$INSTALL_BIN_DIR"
echo

setup_configuration
echo

draw_section_header "Installation Summary"
print_info "📦 Components installed:"
echo "   • MyTool (CLI application)"
echo "   • Configuration files"
echo
print_info "📍 Installation location: $INSTALL_BIN_DIR"
echo
print_success "$(get_random_friend_greeting)"
```

---

## Troubleshooting

### Script Won't Execute

**Issue:** `Permission denied`

**Solution:**
```bash
chmod +x post-install/scripts/your-script.zsh
```

### Can't Find Shared Libraries

**Issue:** `Error: Could not load shared libraries`

**Solution:** Ensure you're using the correct paths:
```zsh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$DOTFILES_ROOT/bin/lib"
```

### Dependencies Not Resolved

**Issue:** Dependencies aren't being installed automatically

**Solution:**
1. Check that dependencies are declared before validation:
   ```zsh
   declare_dependency_command "cargo" "Rust" "toolchains.zsh"
   check_and_resolve_dependencies || exit 1
   ```
2. Ensure provider scripts exist and are executable
3. Check that dependency resolution is working:
   ```bash
   ./bin/librarian.zsh  # Check system status
   ```

### Package Manager Not Found

**Issue:** `pkg_install: command not found`

**Solution:** Load `package_managers.zsh`:
```zsh
source "$LIB_DIR/package_managers.zsh"
```

---

## References

### Developer Documentation
- **[DEVELOPMENT.md](../DEVELOPMENT.md)** - **Developer hub:** Complete API reference, library documentation, and contribution guide ⭐ **NEW**
- **[Argument Parsing Standard](ARGUMENT_PARSING.md)** - Standardized CLI patterns for all scripts
- **[Shared Libraries API](../bin/lib/README.md)** - Complete 1750-line API reference for all 14 libraries
- **[bin/lib/MENU_ENGINE_API.md](../bin/lib/MENU_ENGINE_API.md)** - Menu system documentation (624 lines)

### Core Scripts
- **[bin/setup.zsh](../bin/setup.zsh)** - Main setup orchestrator
- **[bin/menu_tui.zsh](../bin/menu_tui.zsh)** - Interactive TUI menu
- **[bin/librarian.zsh](../bin/librarian.zsh)** - System health checker

### Testing
- **[tests/README.md](../tests/README.md)** - Test infrastructure and execution guide
- **[TESTING.md](../TESTING.md)** - Comprehensive testing documentation

---

**Created:** 2025-10-15
**Status:** Production Ready ✨
**Maintainer:** Thomas + Aria (Claude Code)
