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

These wrappers provide helpful error messages and OS-specific installation instructions if zsh is missing.

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
# System health check and status report
./bin/librarian.zsh

# Create a backup of the dotfiles repository
./backup

# Generate new brew install script from current system
~/.local/bin/generate_brew_install_script
```

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
- **Document Changes**: Update this file and README.md as appropriate
- **Preserve the Vision**: This is a "symphony" - every component should harmonize

The goal is to create not just a functional dotfiles system, but a delightful experience that brings joy to daily development work.
