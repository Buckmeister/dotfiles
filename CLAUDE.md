# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Team Context & Project Information

**IMPORTANT**: Before working on any tasks, please review these files to understand the project context and team dynamics:

- **TeamBio.md**: Contains information about team member Thomas Burk, including his background, interests, and project goals. Understanding his passion for IT and music integration helps tailor solutions and communication appropriately.

- **Meetings.md**: Contains internal project notes, meeting summaries, and current project status. This file is git-ignored and contains sensitive context about project history, challenges, and ongoing objectives. Always consider this information when planning work and making recommendations.

These files provide essential context for understanding not just the technical aspects of the repository, but also the human element and project journey. Please incorporate this understanding into all interactions and technical decisions.

## Repository Architecture

This is a personal dotfiles repository that uses a symlink-based architecture to manage configuration files across different applications and tools. The repository structure follows these conventions:

### Symlink Patterns
- `*.symlink` files → linked to `~/.{basename}`
- `*.symlink_config` directories → linked to `~/.config/{basename}`
- `*.symlink_local_bin.*` files → linked to `~/.local/bin/{basename}`

### Key Components
- **Primary Setup Script**: `setup.zsh` - Cross-platform, OS-aware setup with automatic detection
- **Legacy Scripts**: `install_mac.zsh`, `install_zorin16.zsh` - Platform-specific (deprecated)
- **Package Management**: `brew/install_packages.zsh` contains all Homebrew packages
- **Post-Install Scripts**: `post-install/scripts/` contains modular, OS-aware installation scripts
- **Configuration Directories**: Each application has its own directory (vim, zsh, tmux, etc.)

### OS Detection and Context
The setup.zsh script automatically detects the operating system and exports context variables:
- `DF_OS`: Detected OS (macos, linux, windows, unknown)
- `DF_PKG_MANAGER`: Package manager (brew, apt, choco)
- `DF_PKG_INSTALL_CMD`: Installation command for the detected package manager

All post-install scripts receive these variables and can adapt their behavior accordingly.

## Common Commands

### Primary Setup (Recommended)
```bash
# Full cross-platform setup (creates symlinks, installs tools)
./setup.zsh

# Skip post-install scripts (symlinks only)
./setup.zsh --skip-pi

# Show help and detected OS
./setup.zsh --help
```

### Legacy Setup Scripts (Deprecated)
```bash
# Legacy macOS setup (use ./setup.zsh instead)
./install_mac.zsh

# Legacy Linux setup (use ./setup.zsh instead)
./install_zorin16.zsh
```

### Package Management
```bash
# Generate new brew install script from current system
~/.local/bin/generate_brew_install_script

# Individual post-install scripts (OS-aware)
./post-install/scripts/cargo-packages.zsh
./post-install/scripts/npm-global-packages.zsh
./post-install/scripts/pip-packages.zsh
./post-install/scripts/ruby-gems.zsh
./post-install/scripts/vim-setup.zsh
./post-install/scripts/toolchains.zsh
./post-install/scripts/language-servers.zsh
./post-install/scripts/fonts.zsh
./post-install/scripts/lombok.zsh
./post-install/scripts/bash-preexec.zsh

# System health and status reporting
./post-install/scripts/librarian.zsh
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
# System health check and status report
./post-install/scripts/librarian.zsh

# Manual verification steps:
# 1. Run setup.zsh in clean environment
# 2. Check symlink creation with `ls -la ~` and `ls -la ~/.config`
# 3. Verify application configs load correctly
# 4. Use librarian.zsh to get comprehensive system status
```

## Configuration Structure

### Shell Configuration
- **zsh**: Main shell with zplug plugin management
- **bash**: Backup configuration for compatibility
- **aliases**: Shared command aliases across shells

### Development Tools
- **vim/nvim**: Vim configuration with vim-plug package manager
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

## Development Notes

### Language Support
The dotfiles include configurations for:
- **Haskell**: GHC, Stack, HIE setup
- **Rust**: Cargo packages and rust-analyzer
- **Python**: IPython, pip packages
- **JavaScript/Node**: npm global packages
- **Java**: JDT.LS language server, Maven
- **C#**: OmniSharp language server

### Backup Strategy
Installation scripts automatically backup existing configurations to `~/.tmp/dotfilesBackup-{timestamp}/` before creating symlinks.

### Platform Support
- **Primary**: macOS (install_mac.zsh)
- **Secondary**: Ubuntu/Zorin (install_zorin16.zsh)
- **Portable**: Cross-platform configs where possible