# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal dotfiles repository featuring a beautifully crafted, cross-platform configuration management system. It uses a symlink-based architecture to manage configuration files across different applications and tools, with intelligent OS detection, an interactive TUI menu, and comprehensive automation.

The repository showcases a harmonious blend of technical sophistication and user-friendly design, with every component working together like a well-orchestrated symphony.

## Repository Architecture

The repository structure follows these conventions:

### Symlink Patterns
- `*.symlink` files → linked to `~/.{basename}`
- `*.symlink_config` directories → linked to `~/.config/{basename}`
- `*.symlink_local_bin.*` files → linked to `~/.local/bin/{basename}`

**Examples:**
- `zsh/zshrc.symlink` → `~/.zshrc`
- `nvim/nvim.symlink_config/` → `~/.config/nvim/`
- `github/get_github_url.symlink_local_bin.zsh` → `~/.local/bin/get_github_url`

### Core Infrastructure

The system is built on a shared library architecture:

- **`bin/setup.zsh`** - Cross-platform setup orchestrator with automatic OS detection
- **`bin/menu_tui.zsh`** - Interactive TUI menu with OneDark color scheme
- **`bin/librarian.zsh`** - System health checker and status reporter
- **`bin/link_dotfiles.zsh`** - Symlink creation engine
- **`bin/backup_dotfiles_repo.zsh`** - Comprehensive backup system

### Shared Libraries (`bin/lib/`)

- **`colors.zsh`** - OneDark color scheme constants and theming
- **`ui.zsh`** - Progress bars, headers, and beautiful terminal output
- **`utils.zsh`** - OS detection, common utilities, and helper functions
- **`greetings.zsh`** - Friendly, encouraging messages for user interaction

### Convenience Wrappers

- **`./setup`** - POSIX shell wrapper that ensures zsh is available before running `bin/setup.zsh`
- **`./backup`** - POSIX shell wrapper for `bin/backup_dotfiles_repo.zsh`
- **`./update`** - POSIX shell wrapper for `bin/update_all.zsh`

These wrappers provide helpful error messages and OS-specific installation instructions if zsh is missing.

### Update System (Phase 2 Enhancement)

The update system provides a centralized way to update all packages and toolchains:

- **`bin/update_all.zsh`** - Central update script with category filtering and dry-run mode
- **Version Pinning** - Control updates via `config/versions.env` (empty = auto-update, specific = pin)
- **Individual --update Flags** - Post-install scripts support `--update` for granular control
- **Menu Integration** - Press `u` in menu for one-click updates

### Test Infrastructure (Phase 3 Complete)

Comprehensive testing system with **251 tests across 15 suites** providing ~96% code coverage:

- **`tests/lib/test_framework.zsh`** - Lightweight zsh testing framework with beautiful OneDark output
- **`tests/unit/`** - 105 unit tests for shared libraries (colors, ui, utils, validators, package_managers, greetings)
- **`tests/integration/`** - 64 integration tests for workflows (symlinks, updates, librarian, post-install scripts)
- **`tests/test_docker_install.zsh`** - Docker-based installation testing on fresh Linux containers (Ubuntu, Debian)
- **`tests/run_tests.zsh`** - Test runner with detailed reporting and suite summaries
- **100% Pass Rate** - All tests consistently pass with fast execution (~90 seconds for full suite)
- **Test Coverage** - Comprehensive assertions, setup/teardown, mocking, and smoke tests

### One-Line Installation Scripts

The repository provides two installation modes accessible via GitHub Pages:

- **`dfsetup`** - Interactive installation with menu-driven post-install script selection
- **`dfauto`** - Automatic installation with all modules (non-interactive, installs everything)

Both scripts are available in Unix (sh) and Windows (PowerShell) versions, accessible at:
- `https://buckmeister.github.io/dfsetup` (Unix interactive)
- `https://buckmeister.github.io/dfauto` (Unix automatic)
- `https://buckmeister.github.io/dfsetup.ps1` (Windows interactive)
- `https://buckmeister.github.io/dfauto.ps1` (Windows automatic)

### OS Detection and Context

The setup.zsh script automatically detects the operating system and exports context variables that all post-install scripts receive:

- `DF_OS`: Detected OS (macos, linux, windows, unknown)
- `DF_PKG_MANAGER`: Package manager (brew, apt, choco)
- `DF_PKG_INSTALL_CMD`: Installation command for the detected package manager

This allows all scripts to adapt their behavior cross-platform automatically.

## Common Commands

### Primary Setup (Recommended)

```bash
# Full cross-platform setup (creates symlinks, launches interactive menu)
./setup

# Skip post-install scripts (symlinks only)
./bin/setup.zsh --skip-pi

# Show help and detected OS information
./bin/setup.zsh --help
```

### Update System (New!)

```bash
# Quick and easy - use the convenient wrapper
./update                            # Update everything

# Or call the update script directly
./bin/update_all.zsh                # Same as ./update

# Update specific categories
./update --system                   # System packages only
./update --npm                      # npm packages only
./update --cargo                    # Rust packages only
./update --packages                 # All language packages

# Preview updates without applying
./update --dry-run

# Individual script updates
./post-install/scripts/npm-global-packages.zsh --update
./post-install/scripts/cargo-packages.zsh --update
./post-install/scripts/ruby-gems.zsh --update
```

### Testing

```bash
# Run all tests (251 tests across 15 suites)
./tests/run_tests.zsh

# Run unit tests only (105 tests)
./tests/run_tests.zsh unit

# Run integration tests only (146 tests)
./tests/run_tests.zsh integration

# Docker-based installation testing (requires Docker)
./tests/test_docker_install.zsh                      # Full test suite
./tests/test_docker_install.zsh --quick              # Quick test (dfauto only)
./tests/test_docker_install.zsh --distro ubuntu:24.04 # Test specific distro
```

### Interactive Menu

The TUI menu (`bin/menu_tui.zsh`) provides an elegant interface for managing post-install scripts:

**Navigation:**
- `↑`/`↓` or `j`/`k` - Move through options
- `Space` - Select/deselect items
- `a` - Select all
- `Enter` - Execute selected scripts
- `q` - Quit

### Post-Install Scripts

All scripts in `post-install/scripts/` are modular and OS-aware:

```bash
# Individual post-install scripts
./post-install/scripts/cargo-packages.zsh       # Rust packages
./post-install/scripts/npm-global-packages.zsh  # Node.js global packages
./post-install/scripts/pip-packages.zsh         # Python packages
./post-install/scripts/ruby-gems.zsh            # Ruby gems
./post-install/scripts/language-servers.zsh     # LSP servers
./post-install/scripts/toolchains.zsh           # Development toolchains
./post-install/scripts/fonts.zsh                # Font installation
./post-install/scripts/vim-setup.zsh            # Vim/Neovim setup
./post-install/scripts/bash-preexec.zsh         # Bash preexec hook
./post-install/scripts/lombok.zsh               # Java Lombok

# Run all post-install scripts silently
./bin/librarian.zsh --all-pi
```

### System Management

```bash
# Comprehensive system health check and status report
./bin/librarian.zsh

# System health check with test suite execution
./bin/librarian.zsh --with-tests

# Create a backup of the dotfiles repository
./backup

# Generate new brew install script from current system (deprecated)
~/.local/bin/generate_brew_install_script
```

### Universal Package Management System (NEW!)

The dotfiles now include a **complete universal package management system** for cross-platform package installation and synchronization:

```bash
# Generate manifest from your current system
generate_package_manifest
# → Creates ~/.local/share/dotfiles/packages.yaml

# Install packages on a new machine
install_from_manifest
# → Installs all packages from manifest

# Keep manifest synchronized
sync_packages --push
# → Regenerates manifest and commits to git

# Additional options
generate_package_manifest -o ~/my-packages.yaml  # Custom location
install_from_manifest --dry-run                   # Preview only
install_from_manifest --required-only             # Essential packages only
install_from_manifest --category editor           # Specific category
sync_packages --push --message "Add new tools"    # Custom commit
```

**Features:**
- **Cross-Platform**: Works on macOS (Homebrew), Ubuntu/Debian (APT), and more
- **Universal Manifest**: One YAML file works everywhere
- **Package Manager Support**: brew, apt, cargo, npm, pipx, gem (with more planned)
- **Intelligent Installation**: Skips already installed, detects available package managers
- **Git Integration**: Version control your entire package environment
- **Beautiful UI**: OneDark-themed with progress indicators
- **Flexible Filtering**: By category, priority, or platform

**Documentation:**
- `packages/README.md` - Overview and usage guide
- `packages/SCHEMA.md` - Complete YAML specification
- `packages/base.yaml` - Curated base manifest with 50+ packages

**Use Cases:**
- System migration (export from old machine, install on new)
- Team standardization (share identical development environment)
- Disaster recovery (one-command reinstall everything)
- Multi-platform development (same packages on macOS and Linux)

**The Librarian** provides comprehensive system health reporting including:
- **Core System Status** - Dotfiles location, setup scripts, symlink counts, git status
- **Essential Tools** - Detection of git, curl, jq, zsh
- **Development Toolchains** - Version checking for Rust, Node.js, Python, Ruby, Go, Haskell, Java
- **Language Servers** - Detection of rust-analyzer, typescript-language-server, pyright, lua-language-server, gopls, haskell-language-server-wrapper, solargraph
- **Test Suite Status** - Test runner availability, unit/integration test counts, optional execution with `--with-tests`
- **Post-Install Scripts Catalog** - Lists all available scripts with executable status
- **GitHub Downloaders** - Status of get_github_url and get_jdtls_url tools
- **Configuration Health** - Checks for .zshrc, .vimrc, .tmux.conf, .gitconfig
- **Detailed Symlink Inventory** - Complete listing of symlinks in ~/.local/bin, ~/.config, and ~/ with broken link detection

### GitHub Downloaders

```bash
# General GitHub release/tag downloader
~/.local/bin/get_github_url -u username -r repository [options]

# Specialized JDT.LS downloader (handles quirky release patterns)
~/.local/bin/get_jdtls_url [--version VERSION] [--silent]
```

### Testing and Validation

```bash
# System health check and comprehensive status
./bin/librarian.zsh

# Manual verification steps:
# 1. Run ./setup in clean environment
# 2. Check symlink creation with `ls -la ~` and `ls -la ~/.config`
# 3. Verify application configs load correctly
# 4. Use librarian.zsh to get comprehensive system status
```

## Configuration Structure

### Shell Configuration
- **zsh**: Main shell with zplug plugin management
- **bash**: Backup configuration for compatibility
- **aliases**: Shared command aliases across shells
- **starship**: Cross-shell prompt with custom configuration
- **p10k**: Powerlevel10k theme configuration

### Development Tools
- **vim/nvim**: Neovim configuration with lazy.nvim package manager
- **emacs**: Emacs configuration for macOS
- **git**: Git settings and diff-so-fancy integration
- **tmux**: Terminal multiplexer configuration

### Terminal Applications
- **kitty**: Primary terminal emulator
- **alacritty**: Alternative terminal emulator
- **starship**: Cross-shell prompt configuration

### System Integration
- **karabiner**: Keyboard remapping for macOS
- **hammerspoon**: macOS automation (installed via brew)
- **local/bin/**: Custom utility scripts

## Language Support

The dotfiles include comprehensive configurations for:

- **Rust**: Cargo packages, rust-analyzer LSP
- **Python**: IPython, pip packages, Python LSP servers
- **JavaScript/Node**: npm global packages, TypeScript support
- **Java**: JDT.LS language server, Maven wrapper
- **C#**: OmniSharp language server
- **Haskell**: GHC, Stack, HIE setup
- **Ruby**: Gems, Solargraph LSP
- **Go**: Go toolchain and gopls
- **And more...**

## Design Philosophy

### User Experience

This repository prioritizes a delightful user experience:

- **Friendly Messages**: Every output is warm and encouraging
- **Visual Consistency**: OneDark color scheme throughout
- **Progress Feedback**: Clear progress bars and status updates
- **Error Handling**: Helpful, actionable error messages with OS-specific guidance
- **Cross-Platform**: Seamless experience on macOS and Linux

### Code Organization

- **Shared Libraries**: DRY principle with reusable UI and utility functions
- **Modularity**: Each post-install script is independent and focused
- **Fallback Protection**: Graceful degradation when libraries are unavailable
- **Context Awareness**: All scripts receive OS and package manager context

### Backup Strategy

Installation scripts automatically backup existing configurations to `~/.tmp/dotfilesBackup-{timestamp}/` before creating symlinks. The `./backup` command creates comprehensive ZIP archives stored in `~/Downloads/dotfiles_repo_backups/`.

## Platform Support

- **Primary**: macOS (Homebrew ecosystem)
- **Secondary**: Ubuntu/Debian Linux (apt ecosystem)
- **Portable**: Cross-platform configs where possible
- **Planned**: Windows support via WSL

## Development Workflow

### Making Changes

1. Edit configuration files in their respective directories
2. Test changes locally
3. Use `./bin/librarian.zsh` to verify system health
4. Create meaningful git commits with clear messages
5. Push to GitHub

### Adding New Post-Install Scripts

1. Create script in `post-install/scripts/` with `.zsh` extension
2. Make it executable: `chmod +x post-install/scripts/your-script.zsh`
3. Use shared libraries for consistent UI:
   ```zsh
   source "$SCRIPT_DIR/../bin/lib/colors.zsh"
   source "$SCRIPT_DIR/../bin/lib/ui.zsh"
   source "$SCRIPT_DIR/../bin/lib/utils.zsh"
   ```
4. Access OS context via `$DF_OS`, `$DF_PKG_MANAGER`, `$DF_PKG_INSTALL_CMD`
5. Add to interactive menu automatically (detected by menu_tui.zsh)

### Adding New Configurations

1. Create directory for application (e.g., `myapp/`)
2. Add configuration files with appropriate symlink suffix
3. Run `./bin/link_dotfiles.zsh` to create symlinks
4. Verify with `./bin/librarian.zsh`

## Notes for AI Assistants

When working with this codebase:

- **Maintain Consistency**: Use the shared libraries for all UI output
- **Follow Conventions**: Respect the symlink naming patterns
- **Be Friendly**: Keep the warm, encouraging tone in all messages
- **Test Cross-Platform**: Consider both macOS and Linux when making changes
- **Use Context Variables**: Leverage `DF_OS`, `DF_PKG_MANAGER`, etc. for adaptability
- **Document Changes**: Update this file, README.md, and TESTING.md as appropriate
- **Write Tests**: Add tests for new functionality (see TESTING.md)
- **Update System Integration**: New package scripts should support `--update` flag
- **Version Pinning**: Document version control in `config/versions.env`
- **Preserve the Vision**: This is a "symphony" - every component should harmonize

### Update System Patterns

When adding new package management scripts:

1. **Add `--update` flag** - Follow pattern from npm-global-packages.zsh
2. **Document in versions.env** - Add version variables with comments
3. **Integrate with update_all.zsh** - Add update function if needed
4. **Support dry-run** - Show what would be updated
5. **Maintain UI consistency** - Use shared libraries

### Testing Patterns

When adding new functionality:

1. **Write unit tests** for shared libraries in `tests/unit/`
2. **Write integration tests** for workflows in `tests/integration/`
3. **Run tests locally** before committing: `./tests/run_tests.zsh`
4. **Keep tests fast** - Unit tests should run in milliseconds
5. **Document test patterns** in TESTING.md if adding new approaches

The goal is to create not just a functional dotfiles system, but a delightful experience that brings joy to daily development work.

### Manual Maintenance (MANUAL.md)

The repository includes **MANUAL.md** - a comprehensive user guide documenting all configurations, keybindings, and utility scripts. This is separate from the management system documentation (README.md, INSTALL.md, CLAUDE.md) and focuses on **what the configurations provide** rather than **how to install them**.

#### When to Update MANUAL.md

Update the manual when:
1. **Adding new configuration files** (new .symlink or .symlink_config directories)
2. **Adding new utility scripts** (.symlink_local_bin.* files)
3. **Changing keybindings** in tmux, zsh, vim, or terminal emulators
4. **Modifying behavior** of existing configurations
5. **Adding new features** to utility scripts
6. **Changing color schemes** or themes
7. **Updating the Neovim submodule** significantly

#### MANUAL.md Structure

The manual is organized by **user-facing functionality**:

**Main Sections:**
- **Shell Configurations** - zsh, bash, aliases, starship prompt
  - Keybindings and shortcuts
  - Plugin configurations
  - Custom functions
- **Terminal Multiplexer** - tmux configuration
  - All keybindings documented
  - Status bar format
  - Special features
- **Editor Configurations** - Neovim, Vim, Emacs
  - Links to Neovim submodule README
  - Configuration highlights
  - Keybinding reference
- **Terminal Emulators** - Kitty, Alacritty
  - Theme settings
  - Keybindings
  - Integration details
- **Development Tools** - Git, IPython, language configs
- **Utility Scripts** - All ~/.local/bin scripts
  - Usage examples
  - Options and flags
  - Integration notes
- **System Integration** - Karabiner, etc.
- **Appendix** - Color schemes, fonts, file locations

#### How to Update the Manual

When making changes to configurations:

1. **Read the affected config file** to understand the changes
2. **Update the relevant section** in MANUAL.md:
   - For keybindings: Update the key mapping tables
   - For features: Update the features list
   - For scripts: Update usage examples and options
3. **Keep examples current** - Show real, working examples
4. **Update the TOC** if adding new sections
5. **Test the examples** - Ensure documented commands actually work
6. **Cross-reference** - Link between related sections
7. **Preserve the tone** - Keep it user-friendly and helpful

#### Neovim Documentation

The Neovim configuration (git submodule at `nvim/nvim.symlink_config/`) maintains its own comprehensive README.md. The main MANUAL.md links to this rather than duplicating it. This keeps documentation close to the code and allows the Neovim config to evolve independently.

**When updating Neovim:**
- Update the submodule's README.md directly
- Update the main MANUAL.md only if:
  - The integration with dotfiles changes
  - The symlink location changes
  - The installation method changes

#### Manual vs. README vs. INSTALL

**README.md** - Quick start, project overview, installation commands
**INSTALL.md** - Detailed installation, troubleshooting, publishing forks
**MANUAL.md** - Configuration reference, keybindings, usage guide
**CLAUDE.md** - Development guidance, architecture, AI assistant notes

Think of it as:
- README = "How do I get started?"
- INSTALL = "How does the installation work?"
- MANUAL = "How do I use what I installed?"
- CLAUDE = "How does the system work internally?"

#### Quick Reference for Manual Updates

```bash
# After adding a new configuration file:
# 1. Read the config to understand features
Read path/to/new/config.symlink

# 2. Update MANUAL.md with new section
Edit MANUAL.md

# 3. Add to appropriate section:
#    - Features list
#    - Keybindings (if applicable)
#    - Usage examples
#    - Integration notes

# After adding a utility script:
# 1. Read the script to understand usage
Read path/to/script.symlink_local_bin.zsh

# 2. Update "Utility Scripts" section in MANUAL.md
#    - Script name and purpose
#    - Usage syntax
#    - Options and flags
#    - Examples (at least 2-3)
#    - Dependencies (if any)

# After modifying keybindings:
# 1. Find the relevant section (Shell/Tmux/Editor/Terminal)
# 2. Update the keybinding table
# 3. Note any changed behavior
```

#### Finding What Needs Documentation

Use these commands to discover configurations:

```bash
# Find all symlink files
find . -name "*.symlink" -o -name "*.symlink_config"

# Find all utility scripts
find . -name "*.symlink_local_bin.*"

# Check what's actually linked
ls -la ~/.config/
ls -la ~/.local/bin/
ls -la ~ | grep "^\."
```
