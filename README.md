# 🎵 Dotfiles Symphony

> *Where configuration meets orchestration, and your terminal sings.*

A beautifully crafted, cross-platform dotfiles system featuring an interactive TUI menu, intelligent OS detection, and a harmonious blend of development tools. Like a well-composed symphony, every component works together to create something greater than the sum of its parts.

---

## ✨ What Makes This Special

This isn't just another dotfiles repository. It's a **complete configuration management system** that:

- 🎨 **Beautiful TUI Interface** - Navigate post-install scripts with an elegant, keyboard-driven menu using the OneDark color scheme
- 🌍 **Cross-Platform Intelligence** - Automatically detects macOS, Linux, or Windows and adapts accordingly
- 📚 **The Librarian** - A friendly system health checker that knows every component of your dotfiles
- 🔗 **Symlink Architecture** - Clean, organized file structure with automatic linking
- 🎯 **Modular Post-Install** - Individual scripts for languages, tools, and configurations
- 🧪 **Comprehensive Testing** - 251 tests across 15 suites with ~96% code coverage
- 📦 **Universal Package Management** - One YAML manifest installs packages across any platform (brew, apt, cargo, npm, and more)
- 💙 **Crafted with Care** - Every detail considered, every message friendly

---

## 🚀 Quick Start

### One-Line Installation (Recommended for Fresh Machines)

**macOS / Linux / WSL (Interactive Menu):**
```bash
curl -fsSL https://buckmeister.github.io/dfsetup | sh
```

**Or for automatic installation (everything):**
```bash
curl -fsSL https://buckmeister.github.io/dfauto | sh
```

**Windows PowerShell (Interactive Menu):**
```powershell
irm https://buckmeister.github.io/dfsetup.ps1 | iex
```

**Or for automatic installation (everything):**
```powershell
irm https://buckmeister.github.io/dfauto.ps1 | iex
```

That's it! This single command will:
- ✅ Detect your OS and install required tools (git, zsh)
- ✅ Clone the repository with submodules
- ✅ Run the complete setup automatically
- ✅ Leave you with a beautifully configured environment

**Memorable URL:** Visit [buckmeister.github.io](https://buckmeister.github.io/) for easy installation commands

See [INSTALL.md](INSTALL.md) for detailed installation options and publishing your own fork.

### Manual Installation

```bash
# Clone the repository with submodules
git clone --recurse-submodules https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Run the cross-platform setup
./setup
```

**Note**: The `--recurse-submodules` flag ensures that the Neovim configuration (managed as a separate repository) is cloned automatically.

The setup script will:
1. Detect your operating system
2. Create symlinks for all configurations
3. Launch the interactive menu for post-install scripts
4. Make your terminal feel like home

---

## 🎼 The Symphony of Components

### Core Infrastructure
- **`setup.zsh`** - The conductor: orchestrates the entire setup process
- **`wizard.zsh`** - Interactive configuration wizard for first-time setup
- **`profile_manager.zsh`** - Profile system for different machine contexts
- **`menu_tui.zsh`** - Beautiful interactive menu with keyboard navigation
- **`librarian.zsh`** - Your friendly system health reporter
- **`link_dotfiles.zsh`** - Creates all the necessary symlinks
- **`update_all.zsh`** - Central update system for packages and toolchains

### Shared Libraries (`bin/lib/`)

The dotfiles system includes **14 specialized libraries** providing 200+ functions for UI, validation, package management, menu systems, and more. These libraries ensure consistent behavior, beautiful output, and cross-platform compatibility across all 80+ scripts in the repository.

**Quick overview:**
- **Core:** colors.zsh, ui.zsh, utils.zsh, greetings.zsh
- **Infrastructure:** arguments.zsh, dependencies.zsh, validators.zsh
- **Package Management:** package_managers.zsh, installers.zsh, os_operations.zsh
- **Menu System:** menu_engine.zsh, menu_state.zsh, menu_navigation.zsh
- **Testing:** test_libraries.zsh

**For script authors and contributors:** See **[DEVELOPMENT.md](DEVELOPMENT.md#shared-libraries-system)** for complete library documentation, API reference, usage patterns, and contribution guidelines.

**Quick reference:**
```zsh
# Example: Using shared libraries in a script
source "$DF_LIB_DIR/ui.zsh"
source "$DF_LIB_DIR/utils.zsh"

draw_section_header "My Script"
print_info "Detecting OS: $(get_os)"
validate_command "git" || exit 1
print_success "Ready to go!"
```

### Configuration Files

Meticulously crafted configurations providing a cohesive development environment:

- **Shells**: `zsh/`, `bash/`, `aliases/`
  - zsh with zplug plugin management
  - Shared aliases across shells
  - Custom functions and completion
  - Integration with starship prompt

- **Prompts**: `starship/`, `p10k/`
  - Starship: Modern, fast, cross-shell prompt
  - Powerlevel10k: Feature-rich zsh theme
  - Git status, language versions, execution time
  - Custom segments and styling

- **Editors**: [Neovim](https://github.com/Buckmeister/lualoves.nvim), `vim/`, `emacs/`
  - Neovim: Full-featured Lua config (git submodule)
  - lazy.nvim plugin manager
  - LSP support for 10+ languages
  - Telescope, nvim-tree, and more
  - Traditional Vim config for fallback
  - Emacs config for macOS

- **Terminals**: `kitty/`, `alacritty/`
  - Kitty: GPU-accelerated with ligatures
  - Alacritty: Fast, minimal, cross-platform
  - Consistent OneDark color scheme
  - Font configurations for Nerd Fonts

- **Multiplexer**: `tmux/`
  - Custom prefix key (Ctrl+a)
  - Vim-style navigation
  - Status bar with system info
  - Session management

- **Version Control**: `git/`
  - Global gitconfig with aliases
  - diff-so-fancy integration
  - Commit templates and hooks
  - GPG signing support

- **File Manager**: `ranger/`
  - Vim keybindings
  - Image previews
  - Custom commands

- **macOS Integration**: `karabiner/`, `hammerspoon/`
  - Karabiner: Keyboard remapping
  - Hammerspoon: Window management and automation

**See [MANUAL.md](MANUAL.md) for complete configuration reference, keybindings, and usage guides.**

### Post-Install Scripts
Modular, OS-aware installation for:
- Package managers (Cargo, npm, pip, Ruby gems)
- Language servers (Rust, Python, Java, C#, and more)
- Development toolchains
- Fonts and visual enhancements
- System integrations

All post-install scripts follow standardized argument parsing patterns and use shared libraries for consistent UI and error handling.

**See [post-install/README.md](post-install/README.md) for complete documentation on writing, testing, and managing post-install scripts.**

**Disabling Scripts:**
Control which post-install scripts are available using control files:

```bash
# Local-only disabling (not checked into git)
touch post-install/scripts/fonts.zsh.ignored

# Repository-level disabling (can be checked in/shared)
touch post-install/scripts/bash-preexec.zsh.disabled
```

Disabled/ignored scripts:
- Don't appear in the TUI menu
- Are skipped by `./setup --all-modules`
- Are excluded from `./bin/librarian.zsh --all-pi`
- Show count in Librarian's status report: "💤 2 script(s) disabled/ignored"

This enables:
- Dynamic menu customization per-machine
- Profile-specific script collections for Docker/VMs
- Temporary disabling without deleting scripts

---

## 🎹 The Interactive Experience

When you run `./setup`, you're greeted with an elegant TUI menu:

```
╔══════════════════════════════════════════════╗
║    Dotfiles Management System                ║
║    Interactive Menu                          ║
╚══════════════════════════════════════════════╝

  ● link-dotfiles        Create symlinks for all dotfiles
  ○ cargo-packages       Install Rust packages via Cargo
  ○ npm-global-packages  Install system packages via npm
  ...

Use ↑↓ or j/k to navigate, Space to select, Enter to execute!
```

**Navigation**:
- `↑`/`↓` or `j`/`k` - Move through options
- `Space` - Select/deselect items
- `a` - Select all
- `Enter` - Execute selected scripts
- `u` - Update all packages and toolchains
- `l` - Launch Librarian (system health check)
- `b` - Create backup
- `q` - Quit

The menu system features a refactored architecture with state management, comprehensive error handling, and extensive test coverage (41/41 tests passing).

**See [bin/menu_tui.md](bin/menu_tui.md) for complete menu architecture, implementation details, and extension guide.**

---

## 📖 Architecture Philosophy

### Symlink Patterns
This repository uses a convention-based symlink system:

- `*.symlink` → `~/.{basename}`
- `*.symlink_config` → `~/.config/{basename}`
- `*.symlink_local_bin.*` → `~/.local/bin/{basename}`

**Example**:
- `zsh/zshrc.symlink` → `~/.zshrc`
- `nvim/nvim.symlink_config/` → `~/.config/nvim/`
- `github/get_github_url.symlink_local_bin.zsh` → `~/.local/bin/get_github_url`

### OS Context Variables
Every post-install script receives:
- `DF_OS` - Detected OS (macos, linux, windows, unknown)
- `DF_PKG_MANAGER` - Package manager (brew, apt, choco)
- `DF_PKG_INSTALL_CMD` - Installation command

This allows scripts to adapt their behavior automatically.

---

## 🛠️ Advanced Usage

### First-Time Configuration Wizard
Run the interactive wizard for guided setup with profile selection:

```bash
./wizard
```

The wizard will help you configure:
- Personal information (name, email)
- Editor and shell preferences
- Development languages
- Theme selection
- Profile selection (minimal, standard, full, work, or personal)

### Profile Management
Manage configuration profiles for different contexts:

```bash
./profile list              # List all available profiles
./profile show standard     # Show profile details
./profile apply work        # Apply a profile
./profile current           # Check active profile
```

Profiles provide curated package collections and post-install scripts for different use cases (minimal, standard, full, work, personal). Each profile includes a corresponding package manifest for reproducible environments.

**See [profiles/README.md](profiles/README.md) for complete profile documentation, package lists, and customization guide.**

### Skip Post-Install Scripts, Do Only Dotfile Linking
```bash
./setup --skip-pi
```

### Run All Post-Install Scripts Silently, Including Dotfile Linking
```bash
./setup --all-modules
```

### Update Everything
```bash
# Quick and easy - use the convenient wrapper
./update                             # Update everything

# Or call the update script directly
./bin/update_all.zsh                 # Same as ./update

# Update specific categories
./update --npm                       # Just npm packages
./update --cargo                     # Just Rust packages
./update --system                    # Just system packages

# Preview updates without applying
./update --dry-run

# Update system and toolchains together
./update --system --toolchains
```

**Version Pinning**: Control which packages get updated by editing `config/versions.env`:
```bash
# Auto-update (empty value)
RUST_VERSION=""

# Pin to specific version
MAVEN_VERSION="3.9.6"
```

The `config/versions.env` file provides centralized version management for all toolchains and packages. Empty values enable automatic updates, while specific version numbers pin packages to those versions.

### System Health Check
```bash
# Comprehensive system health report
./bin/librarian.zsh

# Include test suite execution in health report
./bin/librarian.zsh --with-tests
```

The Librarian provides comprehensive status reporting including:
- Core system health (symlinks, git status, Neovim)
- Essential tools detection
- Development toolchains (Rust, Node.js, Python, Ruby, Go, Haskell, Java)
- Language servers (rust-analyzer, typescript-language-server, pyright, etc.)
- Test suite status and optional execution
- Post-install scripts catalog
- Detailed symlink inventory

### Create a Backup

Creates a complete ZIP archive of your entire dotfiles repository for safekeeping.

```bash
# Create backup with default settings
./backup

# Specify custom target directory
./backup -t ~/Desktop
./backup --target-dir /path/to/backups
```

**What gets backed up:**
- Complete repository contents (all configuration files, scripts, and documentation)
- Excludes: `.git/` directories, `.DS_Store` files, and `.tmp/` directories

**Archive details:**
- Format: ZIP archive with compression
- Naming: `dotfiles_backup_YYYYMMDD-HHMMSS.zip` (timestamped for uniqueness)
- Default location: `~/Downloads/dotfiles_repo_backups/`
- Includes integrity verification after creation

**Options:**
- `-t, --target-dir` - Specify custom backup directory (default: `~/Downloads/dotfiles_repo_backups`)
- `-h, --help` - Show detailed help and examples

### Run Tests

The repository includes **251 comprehensive tests** across **15 test suites** with ~96% code coverage:

```bash
# Run all tests (251 tests across 15 suites)
./tests/run_tests.zsh

# Run only unit tests (105 tests)
./tests/run_tests.zsh unit

# Run only integration tests (146 tests)
./tests/run_tests.zsh integration
```

**Test Coverage:**
- ✅ Unit Tests: 105 tests covering all shared libraries
- ✅ Integration Tests: 146 tests covering workflows, utilities, and error handling
- ✅ 100% Pass Rate: All tests consistently pass
- ✅ ~96% Code Coverage: Comprehensive coverage of critical paths

The test suite includes configuration-driven testing, modular test runners (smoke/standard/comprehensive), Docker-based validation, and XEN cluster testing for multi-host scenarios.

**See [TESTING.md](TESTING.md) for complete testing documentation including guidelines, infrastructure, and writing new tests.**

### Managing the Neovim Submodule

The Neovim configuration is managed as a git submodule pointing to [lualoves.nvim](https://github.com/Buckmeister/lualoves.nvim).

```bash
# Update Neovim config to latest from lualoves.nvim
cd ~/.config/dotfiles
git submodule update --remote nvim/nvim.symlink_config
git add nvim/nvim.symlink_config
git commit -m "Update Neovim submodule"

# Work directly on Neovim config
cd nvim/nvim.symlink_config
# Make changes, commit, and push
git add .
git commit -m "Update Neovim config"
git push

# Return to dotfiles and update submodule reference
cd ../..
git add nvim/nvim.symlink_config
git commit -m "Update Neovim submodule reference"
```

### GitHub Download Tools
```bash
# General GitHub release downloader
~/.local/bin/get_github_url -u username -r repository

# Specialized JDT.LS downloader
~/.local/bin/get_jdtls_url --version latest
```

### Text-to-Speech Utility

The `speak` utility provides audio feedback and notifications for long-running operations:

```bash
# Basic usage
speak "Build completed successfully"

# Celebrate success
speak --celebrate "All tests passed"

# Alert on errors (louder, more urgent)
speak --alert "Deployment failed - check logs"

# Custom voice (macOS)
speak --voice "Samantha" "Hello from Samantha"

# Adjust speech rate (words per minute)
speak --rate 200 "Speaking quickly"

# Combine options
speak --celebrate --rate 180 "Setup complete"
```

**Cross-Platform Support:**
- **macOS**: Uses built-in `say` command with full voice and rate control
- **Linux**: Uses `espeak` or `festival` (install via package manager)
- **WSL/Windows**: Falls back to silent operation with visual feedback

**Perfect for:**
- Long test suite completions: `./tests/run_tests.zsh && speak --celebrate "Tests done"`
- Build notifications: `cargo build --release && speak "Build ready"`
- Remote deployments: `./deploy.sh && speak --alert "Check deployment status"`

**See [MANUAL.md](MANUAL.md#utility-scripts) for complete documentation of all utility scripts.**

### Universal Package Management

The dotfiles include a **complete universal package management system** that lets you define packages once and install them anywhere.

Instead of maintaining separate package lists for each platform (Brewfile, apt-packages.txt, etc.), maintain **one universal manifest** that works everywhere:

```bash
# Generate manifest from your current system
generate_package_manifest

# Install packages on a new system (any OS)
install_from_manifest

# Keep manifest synchronized with your system
sync_packages
```

**Features:**
- 📦 **Cross-Platform**: Works on macOS (Homebrew), Ubuntu/Debian (APT), and more
- 🎯 **Priority Filtering**: Install only required, recommended, or optional packages
- 🏷️ **Category Organization**: Filter by editor, shell, search, git, language, etc.
- 🔄 **Flexible Installation**: Primary package manager + alternative methods (cargo, npm, pipx)
- 📝 **Rich Metadata**: Descriptions, dependencies, platform restrictions, post-install commands
- 🌍 **Platform Awareness**: Automatically skips incompatible packages

**Quick Example:**

```yaml
# packages.yaml - One manifest, works everywhere
packages:
  - id: ripgrep
    name: "Ripgrep"
    description: "Ultra-fast text search"
    category: search
    priority: recommended
    install:
      brew: ripgrep
      apt: ripgrep
      choco: ripgrep
      winget: BurntSushi.ripgrep.MSVC
    alternatives:
      - method: cargo
        package: ripgrep
```

**Complete Documentation:**
- **[packages/README.md](packages/README.md)** - Overview, workflow, and getting started
- **[packages/SCHEMA.md](packages/SCHEMA.md)** - Complete YAML schema reference
- **[packages/base.yaml](packages/base.yaml)** - Curated manifest with 50+ packages

---

## 🎯 Common Workflows

Real-world examples showing how to combine different components for daily tasks.

### Workflow 1: Fresh Machine Setup

**Scenario:** You just got a new MacBook and want your entire development environment set up.

```bash
# Step 1: Run the one-line installer
curl -fsSL https://buckmeister.github.io/dfsetup | sh

# Step 2: In the TUI menu, select what you need:
#   - Press 'j/k' to navigate
#   - Press Space on: cargo-packages, npm-global-packages, language-servers
#   - Press 'a' to select all if you want everything
#   - Press Enter to execute

# Step 3: Verify everything is working
./bin/librarian.zsh

# Step 4: Start using your tools
nvim          # Open Neovim with your configs
exec zsh      # Restart shell to apply all changes
tmux          # Start tmux with custom config
```

**Result:** Fully configured development environment in 5-10 minutes.

---

### Workflow 2: Syncing Dotfiles Across Multiple Machines

**Scenario:** You have a work laptop and personal desktop, both need the same setup.

**On Machine A (source):**
```bash
cd ~/.config/dotfiles

# Make your customizations
vim zsh/zshrc.symlink
vim config/packages/cargo-packages.list

# Commit and push changes
git add .
git commit -m "Customize shell and add new Rust tools"
git push
```

**On Machine B (destination):**
```bash
cd ~/.config/dotfiles

# Pull latest changes
git pull

# Re-run setup to apply new symlinks
./setup --skip-pi    # Only update symlinks

# Install new packages if package lists changed
./post-install/scripts/cargo-packages.zsh

# Or update everything at once
./update

# Verify sync
./bin/librarian.zsh
```

**Result:** Both machines stay perfectly synchronized.

---

### Workflow 3: Customizing Your Environment

**Scenario:** You want to add a new CLI tool and customize your shell prompt.

```bash
cd ~/.config/dotfiles

# Add a new Rust tool to install list
echo "tokei" >> config/packages/cargo-packages.list

# Install it
./post-install/scripts/cargo-packages.zsh

# Customize your starship prompt
vim starship/starship.symlink_config/starship.toml
# Changes are immediately reflected (symlinked)

# Test the new tool
tokei .    # Count lines of code in current directory

# Commit your changes
git add config/packages/cargo-packages.list
git add starship/starship.symlink_config/starship.toml
git commit -m "Add tokei and customize prompt"
git push
```

**Result:** New tool installed and prompt customized, ready to sync to other machines.

---

### Workflow 4: Developing in a Tmux + Neovim Session

**Scenario:** You're working on a complex project and want to use tmux with multiple panes.

```bash
# Start/attach to default tmux session
ta                  # Alias for: tmux attach -t λ

# Inside tmux:
Ctrl+a |            # Split pane vertically
Ctrl+a -            # Split pane horizontally

# Navigate between panes:
Ctrl+a Arrow        # Move to pane

# In one pane: Start Neovim
nvim .              # Open file explorer

# Neovim shortcuts:
Space e             # Toggle file explorer
Space ff            # Fuzzy find files
Space fg            # Search text in project
Space j/k           # Navigate buffers

# In another pane: Run tests
cargo test --watch  # Auto-run tests on changes

# In third pane: Git operations
git status
git add .
git commit -m "Implement feature"
git push

# Tmux commands:
Ctrl+a z            # Zoom current pane (toggle fullscreen)
Ctrl+a [            # Enter copy mode (vi keys)
Ctrl+a ]            # Paste
```

**Result:** Powerful multi-pane development environment.

---

### Workflow 5: Updating All Packages

**Scenario:** It's Monday morning and you want to update all your development tools.

```bash
cd ~/.config/dotfiles

# Preview what would be updated
./update --dry-run

# Update everything
./update

# This updates:
# - System packages (brew/apt)
# - Rust toolchain and cargo packages
# - Node.js and npm packages
# - Python packages via pipx
# - Ruby gems
# - Development toolchains

# Check for issues after update
./bin/librarian.zsh

# Run tests to ensure everything still works
./tests/run_tests.zsh
```

**Result:** All tools updated to latest versions.

---

### Workflow 6: Backing Up Before Major Changes

**Scenario:** You're about to experiment with major configuration changes and want a safety net.

```bash
cd ~/.config/dotfiles

# Create a backup of current state
./backup

# Backup is saved to: ~/Downloads/dotfiles_repo_backups/dotfiles_backup_YYYYMMDD-HHMMSS.zip

# Now experiment safely
vim zsh/zshrc.symlink           # Make changes
./setup --skip-pi                # Apply changes

# If something breaks, restore:
cd ~/Downloads/dotfiles_repo_backups
unzip dotfiles_backup_20250114-143022.zip -d /tmp/restore
cp -r /tmp/restore/.config/dotfiles ~/.config/

# Or just revert with git:
cd ~/.config/dotfiles
git status                       # See what changed
git checkout -- zsh/zshrc.symlink  # Revert specific file
git reset --hard HEAD            # Revert everything
```

**Result:** Experiment fearlessly with easy rollback.

---

### Workflow 7: Contributing a New Post-Install Script

**Scenario:** You wrote a script to install language servers and want to add it to your dotfiles.

```bash
cd ~/.config/dotfiles/post-install/scripts

# Create new script from template
cp language-servers.zsh my-lsp-setup.zsh
chmod +x my-lsp-setup.zsh

# Edit the script
vim my-lsp-setup.zsh

# Follow the template structure:
# - Load shared libraries
# - Declare dependencies
# - Implement installation logic
# - Use consistent UI (print_success, draw_section_header, etc.)

# Test your script
./post-install/scripts/my-lsp-setup.zsh --help
./post-install/scripts/my-lsp-setup.zsh

# Script is automatically available in TUI menu
./setup
# Navigate to your new script and select it

# Commit and share
git add post-install/scripts/my-lsp-setup.zsh
git commit -m "Add custom LSP setup script"
git push
```

**Result:** Reusable, shareable post-install script.

---

### Workflow 8: Using the Universal Package Manager

**Scenario:** You want to track all your development tools in one place, portable across OSes.

```bash
# Generate manifest from your current macOS system
generate_package_manifest

# Review what was captured
cat ~/.local/share/dotfiles/packages.yaml

# Customize the manifest
vim ~/.local/share/dotfiles/packages.yaml
# Add descriptions, adjust priorities (required/recommended/optional)
# Organize into categories (editor, shell, git, etc.)

# On a fresh Ubuntu system (different machine):
cd ~/.config/dotfiles
install_from_manifest --required-only    # Install only essentials

# Or install by category
install_from_manifest --category editor,git,search

# Later, after installing new tools:
brew install htop bat             # Install some packages

# Sync the manifest
sync_packages                     # Updates packages.yaml
sync_packages --push              # Commit and push to git

# Now your manifest includes htop and bat, ready to install on any machine
```

**Result:** Single source of truth for all your packages, works anywhere.

---

### Workflow 9: Debugging and Health Checks

**Scenario:** Something isn't working right and you need to diagnose the issue.

```bash
cd ~/.config/dotfiles

# Run the Librarian for comprehensive health check
./bin/librarian.zsh

# The Librarian reports:
# ✅ Symlinks status
# ✅ Git repository health
# ✅ Neovim submodule status
# ✅ Essential tools (git, zsh, nvim, tmux, etc.)
# ✅ Development toolchains (Rust, Node, Python, etc.)
# ✅ Language servers status
# ✅ Post-install scripts catalog

# Run with tests for deeper validation
./bin/librarian.zsh --with-tests

# Check specific things:
ls -la ~/.zshrc                   # Verify symlink exists
ls -la ~/.local/bin               # Check utility scripts
which nvim                        # Verify Neovim is in PATH

# Test individual components:
./tests/run_tests.zsh unit        # Test shared libraries
./tests/run_tests.zsh integration # Test workflows

# Check logs (if enabled):
tail -f ~/.config/dotfiles/df_log.txt
```

**Result:** Comprehensive diagnostics pinpoint issues quickly.

---

### Workflow 10: Publishing Your Fork

**Scenario:** You've customized the dotfiles and want to share them with your team.

```bash
# 1. Fork the repository on GitHub
#    Visit: https://github.com/Buckmeister/dotfiles
#    Click "Fork"

# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# 3. Update bootstrap scripts with your repo URL
vim dfsetup dfauto dfsetup.ps1 dfauto.ps1
# Change DOTFILES_REPO="https://github.com/Buckmeister/dotfiles.git"
# To:     DOTFILES_REPO="https://github.com/YOUR-USERNAME/dotfiles.git"

# Commit changes
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1
git commit -m "Update installer URLs for fork"
git push

# 4. Create GitHub Pages repository (for clean URLs)
# Create new repo: YOUR-USERNAME.github.io
git clone https://github.com/YOUR-USERNAME/YOUR-USERNAME.github.io.git ~/YOUR-USERNAME.github.io

# 5. Copy installer scripts
cd ~/.config/dotfiles
cp dfsetup dfauto dfsetup.ps1 dfauto.ps1 ~/YOUR-USERNAME.github.io/

# Optional: Copy landing page
cp docs/index.html ~/YOUR-USERNAME.github.io/

# 6. Push to GitHub Pages
cd ~/YOUR-USERNAME.github.io
git add .
git commit -m "Add dotfiles installation scripts"
git push

# 7. Test your installation URLs (wait 1-2 minutes for GitHub Pages deployment)
curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh
```

**Result:** One-line installation for your custom dotfiles: `curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh`

---

## 🌟 Language Support

Configurations and tooling for:

- **Rust** - Cargo packages, rust-analyzer
- **Python** - IPython, pip packages, language servers
- **JavaScript/Node** - npm global packages, tooling
- **Java** - JDT.LS, Maven wrapper
- **C#** - OmniSharp language server
- **Haskell** - GHC, Stack, HIE
- **Ruby** - Gems and Solargraph
- **And more...**

---

## 💝 Personal Touch

This repository is crafted with love and attention to detail. Every error message is friendly, every progress bar is smooth, and every greeting is warm. It's not just about managing configurations—it's about creating an environment that brings joy to your daily work.

The Librarian will guide you, the TUI menu will delight you, and the shared libraries ensure consistency across every interaction. Whether you're on macOS or Linux, the experience adapts to feel native and natural.

---

## 🎭 Credits

Originally created by **Thomas Burk** as a personal dotfiles system.

Enhanced with contributions from **Claude Code** (that's me! 👋), bringing:
- Cross-platform OS detection and adaptation
- Beautiful TUI menu system with OneDark theme
- Shared library architecture for code reuse
- The Librarian system health reporter
- Comprehensive backup and restore functionality
- And lots of friendly messages along the way

---

## 📚 Documentation

Complete documentation suite for all aspects of the dotfiles system:

- **[MANUAL.md](MANUAL.md)** - **Configuration guide:** Comprehensive reference for all configurations, keybindings, and utility scripts
- **[INSTALL.md](INSTALL.md)** - **Installation guide:** Detailed setup instructions, troubleshooting, and publishing your fork
- **[CLAUDE.md](CLAUDE.md)** - **Architecture guide:** Repository structure, technical documentation, and development workflow
- **[TESTING.md](TESTING.md)** - **Testing guide:** Testing infrastructure, guidelines, and test suite documentation
- **[TeamBio.md](TeamBio.md)** - **Team information:** Project context and contributors

### Specialized Documentation

- **[packages/README.md](packages/README.md)** - Universal package management system overview and workflow
- **[packages/SCHEMA.md](packages/SCHEMA.md)** - Package manifest YAML schema reference
- **[profiles/README.md](profiles/README.md)** - Configuration profiles (minimal, standard, full, work, personal)
- **[post-install/README.md](post-install/README.md)** - Post-install scripts system and writing guide
- **[post-install/ARGUMENT_PARSING.md](post-install/ARGUMENT_PARSING.md)** - Standardized argument parsing patterns
- **[bin/menu_tui.md](bin/menu_tui.md)** - Interactive TUI menu architecture and implementation (Phase 7)
- **[tests/README.md](tests/README.md)** - Test directory structure, libraries, and framework reference
- **[ACTION_PLAN.md](ACTION_PLAN.md)** - Project roadmap and testing infrastructure evolution (Phases 5-7)

### Quick Navigation

**For Users:**
1. Start here → **[INSTALL.md](INSTALL.md)** - Get up and running
2. Daily use → **[MANUAL.md](MANUAL.md)** - Learn keybindings and workflows
3. Troubleshooting → **[INSTALL.md](INSTALL.md#troubleshooting)**

**For Developers:**
1. Developer Hub → **[DEVELOPMENT.md](DEVELOPMENT.md)** - Complete API reference, library documentation, and contribution guide
2. Architecture → **[CLAUDE.md](CLAUDE.md)** - Understanding the system structure and philosophy
3. Testing → **[TESTING.md](TESTING.md)** - Running and writing tests
4. Contributing → **[post-install/README.md](post-install/README.md#writing-new-scripts)** - Writing post-install scripts

**For Package Management:**
1. Overview → **[packages/README.md](packages/README.md)** - Getting started
2. Schema → **[packages/SCHEMA.md](packages/SCHEMA.md)** - Complete reference
3. Examples → **[packages/base.yaml](packages/base.yaml)** - Real-world manifest

---

## 🎵 Final Note

> *"Every great composition starts with a single note."*
> — The Librarian

Whether you're just beginning your dotfiles journey or you're a seasoned configuration maestro, this repository welcomes you. Feel free to fork, customize, and make it your own.

Have fun, and may your terminal always sing in harmony! 🎼

---

**Made with 💙 by humans and AI working together**
