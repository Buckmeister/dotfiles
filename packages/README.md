# Universal Package Management System

**Status**: 🚧 Foundation Phase - Schema and Manifest Complete
**Next**: Implementation of generator and installer scripts

---

## 📖 Overview

This directory contains the foundation for a **universal, cross-platform package management system** that enables defining packages once and installing them anywhere.

### The Vision

Instead of maintaining separate package lists for each platform:
- ❌ `Brewfile` for macOS
- ❌ `apt-packages.txt` for Ubuntu
- ❌ `choco-packages.txt` for Windows

Maintain **one universal manifest** that works everywhere:
- ✅ `packages.yaml` - One manifest, any platform

### Core Philosophy

1. **Write Once, Run Anywhere**: Define packages once, install on any OS
2. **Intelligent Mapping**: Automatic translation to platform-specific package names
3. **Flexible Priorities**: Required, recommended, optional filtering
4. **Rich Metadata**: Documentation built into the manifest
5. **Extensible**: Easy to add new package managers and platforms

---

## 📁 Directory Structure

```
packages/
├── README.md           # This file
├── SCHEMA.md           # Complete schema documentation
├── base.yaml           # Curated base manifest (~50 packages)
└── example.yaml        # Full-featured example (coming soon)
```

### File Purposes

**SCHEMA.md**
- Complete schema documentation
- Field reference with examples
- Best practices and conventions
- 200+ lines of comprehensive guidance

**base.yaml**
- Curated list of ~50 essential packages
- Cross-platform mappings for common tools
- Organized by category and priority
- Production-ready starting point

**example.yaml** (planned)
- Demonstrates all schema features
- Complex configurations and edge cases
- Learning resource for advanced usage

---

## 🚀 Quick Start

### 1. Review the Base Manifest

```bash
cat packages/base.yaml
```

This shows ~50 carefully curated packages with cross-platform mappings.

### 2. Understand the Schema

```bash
cat packages/SCHEMA.md
```

Complete documentation of the YAML format, fields, and conventions.

### 3. Plan Your Custom Manifest

Copy `base.yaml` as a starting point:
```bash
cp packages/base.yaml ~/.local/share/dotfiles/packages.yaml
```

Edit to match your needs:
- Remove packages you don't need
- Add packages specific to your workflow
- Adjust priorities (required/recommended/optional)
- Add platform restrictions

### 4. Wait for Implementation

The generator and installer scripts are coming next! They will:
- `generate_package_manifest` - Export from your current system
- `install_from_manifest` - Install on new systems
- `sync_packages` - Keep manifest synchronized

---

## 📦 Package Manifest Structure

### Minimal Example

```yaml
version: "1.0"

packages:
  - id: neovim
    install:
      brew: neovim
      apt: neovim
```

### Realistic Example

```yaml
version: "1.0"

metadata:
  name: "My Dev Environment"
  author: "Thomas"

settings:
  parallel_install: true

packages:
  - id: neovim
    name: "Neovim"
    description: "Modern Vim-based editor"
    category: editor
    priority: required
    platforms: [macos, linux, windows]
    install:
      brew: neovim
      apt: neovim
      choco: neovim
      winget: Neovim.Neovim
    alternatives:
      - method: cargo
        package: neovim
    dependencies: [git, curl]
```

See **SCHEMA.md** for complete field documentation.

---

## 🎯 Supported Package Managers

### System Package Managers
- **brew** - Homebrew (macOS/Linux)
- **brew_cask** - Homebrew Casks (GUI apps on macOS)
- **apt** - APT (Debian/Ubuntu)
- **yum** - YUM (CentOS/RHEL)
- **dnf** - DNF (Fedora)
- **pacman** - Pacman (Arch Linux)
- **choco** - Chocolatey (Windows)
- **winget** - Windows Package Manager

### Language Package Managers
- **cargo** - Rust
- **npm** - Node.js (global)
- **pip** - Python
- **pipx** - Python apps
- **gem** - Ruby
- **go** - Go

### Special Methods
- **source** - Build from source

---

## 🗂️ Categories

Packages are organized into logical categories:

- `editor` - Text editors (Neovim, VS Code)
- `shell` - Shells and shell utilities (zsh, bash)
- `search` - Search tools (ripgrep, fd, fzf)
- `git` - Git and version control (git, gh, delta)
- `language` - Programming languages (Node, Python, Rust)
- `network` - Network utilities (curl, wget, httpie)
- `browser` - Web browsers (Firefox, Brave)
- `terminal` - Terminal emulators (Kitty, Alacritty)
- `development` - Dev tools (LSP servers, formatters)
- `utilities` - System utilities (htop, jq, tree)
- `container` - Docker, Kubernetes
- `font` - Nerd Fonts and typefaces

Categories enable filtered installation:
```bash
# Future command:
install_from_manifest --category editor,git
```

---

## 🎚️ Priority Levels

Each package has a priority level:

### `required`
- **Essential** packages needed for basic functionality
- Always installed by default
- Examples: git, curl, neovim, zsh

### `recommended`
- **Commonly used** packages most developers want
- Installed by default unless explicitly excluded
- Examples: ripgrep, bat, tmux, nodejs

### `optional`
- **Specialized** packages for specific needs
- User must explicitly opt-in
- Examples: Docker, Firefox, VS Code, fonts

Filter by priority:
```bash
# Future commands:
install_from_manifest --required-only
install_from_manifest --skip-optional
```

---

## 🌍 Platform Support

### Supported Platforms

- `macos` - macOS
- `linux` - Any Linux distribution
- `ubuntu` - Ubuntu specifically
- `debian` - Debian specifically
- `fedora` - Fedora specifically
- `arch` - Arch Linux specifically
- `windows` - Windows
- `wsl` - Windows Subsystem for Linux

### Platform Filtering

Packages can restrict to specific platforms:

```yaml
- id: hammerspoon
  platforms: [macos]  # macOS only
  install:
    brew_cask: hammerspoon
```

The installer automatically skips packages incompatible with current platform.

---

## 🔄 Planned Workflow

### Generate Manifest from Current System

```bash
# Export currently installed packages to manifest
generate_package_manifest

# Output: ~/.local/share/dotfiles/packages.yaml

# Merge with existing manifest (smart update)
generate_package_manifest --merge

# Interactive mode (prompts for metadata)
generate_package_manifest --interactive
```

### Install from Manifest on New System

```bash
# Install all required + recommended packages
install_from_manifest

# Install only required packages
install_from_manifest --required-only

# Install specific categories
install_from_manifest --category editor,git,search

# Dry run (preview what would be installed)
install_from_manifest --dry-run

# Use custom manifest
install_from_manifest --input ~/my-packages.yaml
```

### Keep Manifest Synchronized

```bash
# Add newly installed packages to manifest
sync_packages --add

# Remove uninstalled packages from manifest
sync_packages --remove

# Update all metadata
sync_packages --update

# Commit and push changes
sync_packages --push
```

---

## 📋 Implementation Roadmap

### ✅ Phase 1: Foundation (Complete)
- [x] Design YAML schema
- [x] Create comprehensive SCHEMA.md documentation
- [x] Build base.yaml with ~50 curated packages
- [x] Document architecture and workflow

### 🚧 Phase 2: Generator Script (Next)
- [ ] Implement `generate_package_manifest`
- [ ] Support brew (macOS)
- [ ] Support apt (Ubuntu/Debian)
- [ ] Interactive mode for mapping prompts
- [ ] Merge mode for updating existing manifest

### 📅 Phase 3: Installer Script
- [ ] Implement `install_from_manifest`
- [ ] Support brew + apt
- [ ] Category and priority filtering
- [ ] Dry-run mode
- [ ] Beautiful UI with progress bars
- [ ] Dependency resolution

### 📅 Phase 4: Sync Script
- [ ] Implement `sync_packages`
- [ ] Add/remove packages
- [ ] Git integration
- [ ] Smart merge capabilities

### 📅 Phase 5: Expansion
- [ ] Add yum/dnf support (Fedora/RHEL)
- [ ] Add choco support (Windows)
- [ ] Add winget support (Windows)
- [ ] Support cargo, npm, pip, pipx
- [ ] Repository management (taps, PPAs)

### 📅 Phase 6: Polish
- [ ] Comprehensive testing
- [ ] Update MANUAL.md
- [ ] Add to dotfiles setup flow
- [ ] Migration guide from Brewfile
- [ ] Example manifests for different use cases

---

## 🎓 Learning Resources

### Getting Started
1. Read **SCHEMA.md** for complete field reference
2. Study **base.yaml** for real examples
3. Copy base.yaml and customize for your needs

### Advanced Usage
- Platform-specific packages
- Alternative installation methods
- Post-install commands
- Dependency management
- Repository management

### Contributing
- Test manifests on different platforms
- Report bugs and edge cases
- Suggest new package mappings
- Contribute to package database

---

## 💡 Design Decisions

### Why YAML?

- **Human-readable**: Easy to read and edit
- **Comments**: Document package choices
- **Structure**: Hierarchical and flexible
- **Standard**: Well-supported, many parsers
- **Git-friendly**: Clean diffs

### Why Not Just Use Brewfile?

Brewfile is great for macOS, but:
- ❌ macOS-only (doesn't help on Linux/Windows)
- ❌ No package metadata or descriptions
- ❌ No priority levels or categories
- ❌ No cross-platform mappings
- ❌ Limited to Homebrew packages

Universal manifest:
- ✅ Works on any platform
- ✅ Rich metadata and documentation
- ✅ Flexible filtering and organization
- ✅ Maps to any package manager
- ✅ Includes system + language packages

### File Locations

**Base manifest** (version controlled):
- Location: `~/.config/dotfiles/packages/base.yaml`
- Purpose: Curated starting point in git repo
- Usage: Template for new manifests

**User manifest** (not version controlled):
- Location: `~/.local/share/dotfiles/packages.yaml`
- Purpose: User's custom package list
- Usage: Generated from system or customized from base

Scripts will support both locations and can merge them.

---

## 🤝 Integration with Dotfiles

This package management system integrates seamlessly with the dotfiles:

### Shared Libraries

Package scripts will use the same UI libraries:
- `bin/lib/colors.zsh` - OneDark color scheme
- `bin/lib/ui.zsh` - Progress bars and headers
- `bin/lib/utils.zsh` - OS detection and helpers
- `bin/lib/greetings.zsh` - Friendly messages

### Setup Integration

Future integration with `./setup`:
```bash
./setup
# → Links dotfiles
# → Launches menu
#    → [New Option] "Install Packages from Manifest"
```

### Consistent Experience

- Same look and feel as other dotfiles tools
- Same friendly, encouraging tone
- Same cross-platform approach
- Same attention to detail

---

## 🌟 Benefits

### For You

- **One manifest** instead of multiple package lists
- **Documentation** built-in (descriptions, categories)
- **Confidence** when setting up new machines
- **Flexibility** to customize per-machine if needed
- **Version control** your entire development environment

### For Teams

- **Standardization** across team members
- **Onboarding** new developers faster
- **Consistency** across development machines
- **Sharing** package discoveries easily

### For Future You

- **Migration** to new machines is effortless
- **Disaster recovery** with one command
- **Experimentation** with different tools (easy rollback)
- **Documentation** of why you installed each tool

---

## 📞 Getting Help

- **Schema questions**: See SCHEMA.md
- **Examples**: Study base.yaml
- **Bug reports**: GitHub issues (when scripts are ready)
- **Feature requests**: Discussions welcome!

---

## 🙏 Acknowledgments

This system draws inspiration from:
- **Homebrew Bundle** - Brewfile concept
- **Ansible** - YAML-based configuration
- **Nix** - Declarative package management
- **dotfiles community** - Sharing and standardization

Designed with love for cross-platform development. 💙

---

*Phase 1 Complete - Ready for implementation!* ✨
