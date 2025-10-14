# Universal Package Manifest Schema

**Version**: 1.0
**Purpose**: Define a cross-platform package manifest format for dotfiles management

---

## Overview

This schema enables describing packages once and installing them across any platform (macOS, Linux, Windows) using the appropriate package manager. It supports multiple package sources (system packages, language-specific tools, GUI applications) and provides rich metadata for documentation and filtering.

---

## File Format

**Format**: YAML
**Extension**: `.yaml` or `.yml`
**Encoding**: UTF-8

---

## Top-Level Structure

```yaml
version: "1.0"              # Schema version (required)
metadata:                   # Manifest information (optional)
  name: string
  description: string
  author: string
  last_updated: date

settings:                   # Global settings (optional)
  auto_confirm: boolean
  parallel_install: boolean
  skip_installed: boolean

repositories:              # Package repositories (optional)
  taps: []
  ppas: []
  repos: []

packages: []               # Package definitions (required)
```

---

## Metadata Section

Optional information about the manifest itself:

```yaml
metadata:
  name: "My Development Environment"
  description: "Cross-platform packages for web development"
  author: "Thomas"
  last_updated: "2025-10-14"
  repository: "https://github.com/username/dotfiles"
```

**Fields:**
- `name`: Human-readable name for this manifest
- `description`: What this manifest provides
- `author`: Maintainer name
- `last_updated`: ISO 8601 date (YYYY-MM-DD)
- `repository`: Git repository URL (optional)

---

## Settings Section

Global behavior settings:

```yaml
settings:
  auto_confirm: false        # Skip confirmation prompts
  parallel_install: true     # Install packages concurrently
  skip_installed: true       # Don't reinstall existing packages
  prefer_native: true        # Prefer system package manager over alternatives
```

**Fields:**
- `auto_confirm`: Boolean (default: `false`)
- `parallel_install`: Boolean (default: `true`)
- `skip_installed`: Boolean (default: `true`)
- `prefer_native`: Boolean (default: `true`)

---

## Repositories Section

Third-party package sources that must be added before installing packages:

### Homebrew Taps (macOS)

```yaml
repositories:
  taps:
    - name: "homebrew/cask-fonts"
      platforms: [macos]

    - name: "microsoft/git"
      platforms: [macos]
      url: "https://github.com/microsoft/git"  # optional
```

### APT PPAs (Ubuntu/Debian)

```yaml
repositories:
  ppas:
    - name: "ppa:neovim-ppa/unstable"
      platforms: [ubuntu, debian]

    - name: "ppa:git-core/ppa"
      platforms: [ubuntu]
```

### YUM/DNF Repos (Fedora/RHEL)

```yaml
repositories:
  repos:
    - name: "docker-ce"
      platforms: [fedora, rhel, centos]
      url: "https://download.docker.com/linux/fedora/docker-ce.repo"
```

**Common Fields:**
- `name`: Repository identifier (required)
- `platforms`: Array of OS names (required)
- `url`: Repository URL (optional, some package managers can infer)

---

## Packages Section

The heart of the manifest - package definitions.

### Minimal Package Definition

```yaml
packages:
  - id: ripgrep
    install:
      brew: ripgrep
      apt: ripgrep
```

### Complete Package Definition

```yaml
packages:
  - id: neovim                          # Unique identifier (required)
    name: "Neovim"                      # Display name (optional)
    description: "Modern Vim"           # Short description (optional)
    category: editor                    # Category tag (optional)
    priority: required                  # Installation priority (optional)
    platforms: [macos, linux, windows]  # Supported platforms (optional)

    install:                            # Installation mappings (required)
      brew: neovim
      apt: neovim
      yum: neovim
      choco: neovim
      winget: Neovim.Neovim

    alternatives:                       # Alternative installation methods (optional)
      - method: cargo
        package: neovim
        platforms: [linux]

    post_install:                       # Post-installation commands (optional)
      macos: "nvim --headless +PlugInstall +qall"
      linux: "nvim --headless +PlugInstall +qall"

    dependencies: [git, curl]           # Package dependencies (optional)
    conflicts: [vim]                    # Conflicting packages (optional)
```

---

## Package Fields Reference

### Required Fields

#### `id` (string)
Unique identifier for the package. Used internally and for dependency resolution.

**Rules:**
- Lowercase alphanumeric and hyphens only
- Must be unique within manifest
- Recommended: Use the most common package name

**Examples:**
- `neovim`
- `ripgrep`
- `fzf`
- `github-cli`

#### `install` (object)
Mapping of package manager to package name.

**Supported Package Managers:**
- `brew`: Homebrew (macOS/Linux)
- `brew_cask`: Homebrew Casks (GUI apps on macOS)
- `apt`: APT (Debian/Ubuntu)
- `yum`: YUM (CentOS/RHEL)
- `dnf`: DNF (Fedora)
- `pacman`: Pacman (Arch Linux)
- `choco`: Chocolatey (Windows)
- `winget`: Windows Package Manager
- `cargo`: Rust package manager
- `npm`: Node.js package manager
- `pip`: Python package manager
- `pipx`: Python app installer
- `gem`: Ruby package manager
- `go`: Go package manager

**Special Values:**
- `null`: Package not available for this package manager
- `false`: Explicitly skip this package manager

**Examples:**

Simple mapping:
```yaml
install:
  brew: bat
  apt: bat
```

Different names:
```yaml
install:
  brew: ripgrep
  apt: ripgrep
  winget: BurntSushi.ripgrep.MSVC
```

GUI application:
```yaml
install:
  brew_cask: docker
  choco: docker-desktop
  winget: Docker.DockerDesktop
```

Not available everywhere:
```yaml
install:
  brew_cask: hammerspoon  # macOS only
  apt: null
  choco: null
```

### Optional Fields

#### `name` (string)
Human-readable display name. Used in UI output.

**Default**: Titlecased `id`

**Examples:**
```yaml
name: "Neovim"
name: "GitHub CLI"
name: "Ripgrep"
```

#### `description` (string)
Brief description of what the package does. Used for documentation and search.

**Recommended length**: 40-80 characters

**Examples:**
```yaml
description: "Hyperextensible Vim-based text editor"
description: "Ultra-fast text search tool"
description: "Fuzzy finder for the command line"
```

#### `category` (string)
Logical grouping for filtering and organization.

**Recommended categories:**
- `editor`: Text editors
- `shell`: Shells and shell utilities
- `search`: Search and find tools
- `git`: Git and version control
- `language`: Programming language toolchains
- `network`: Network utilities
- `browser`: Web browsers
- `terminal`: Terminal emulators
- `development`: General development tools
- `utilities`: System utilities
- `productivity`: Productivity applications
- `media`: Media players and editors
- `database`: Database tools
- `container`: Docker, Kubernetes, etc.

**Examples:**
```yaml
category: editor
category: search
category: development
```

#### `priority` (string)
Installation importance level. Used for filtering.

**Valid values:**
- `required`: Essential packages (always installed)
- `recommended`: Commonly needed packages (installed by default)
- `optional`: Nice-to-have packages (user must opt-in)

**Default**: `recommended`

**Examples:**
```yaml
priority: required      # Core tools
priority: recommended   # Commonly used
priority: optional      # Specialized tools
```

#### `platforms` (array)
Operating systems where this package is available/relevant.

**Valid platforms:**
- `macos`: macOS
- `linux`: Any Linux distribution
- `ubuntu`: Ubuntu specifically
- `debian`: Debian specifically
- `fedora`: Fedora specifically
- `arch`: Arch Linux specifically
- `windows`: Windows
- `wsl`: Windows Subsystem for Linux

**Default**: All platforms (unrestricted)

**Examples:**
```yaml
platforms: [macos, linux, windows]     # Cross-platform
platforms: [macos]                      # macOS only
platforms: [linux]                      # Linux only
platforms: [ubuntu, debian]             # Debian-based only
```

#### `alternatives` (array)
Alternative installation methods beyond system package managers.

**Structure:**
```yaml
alternatives:
  - method: string          # Installation method (required)
    package: string         # Package identifier (required)
    platforms: [string]     # Supported platforms (optional)
    command: string         # Custom install command (optional)
```

**Supported methods:**
- `cargo`: Rust crates
- `npm`: Node.js packages
- `pip`: Python packages
- `pipx`: Python applications
- `gem`: Ruby gems
- `go`: Go packages
- `source`: Build from source

**Examples:**

Install from Cargo:
```yaml
alternatives:
  - method: cargo
    package: ripgrep
    platforms: [linux, macos]
```

Install from source:
```yaml
alternatives:
  - method: source
    platforms: [linux]
    command: |
      git clone https://github.com/neovim/neovim.git
      cd neovim && make CMAKE_BUILD_TYPE=Release
      sudo make install
```

Multiple alternatives:
```yaml
alternatives:
  - method: npm
    package: "@angular/cli"
    platforms: [macos, linux, windows]

  - method: pipx
    package: httpie
    platforms: [linux]
```

#### `post_install` (object or string)
Commands to run after package installation.

**Format 1: Platform-specific commands**
```yaml
post_install:
  macos: "brew services start postgresql"
  linux: "systemctl enable postgresql"
  windows: "sc start postgresql"
```

**Format 2: Universal command**
```yaml
post_install: "nvim --headless +PlugInstall +qall"
```

**Use cases:**
- Start services
- Initialize configuration
- Install plugins
- Set permissions
- Symlink files

#### `dependencies` (array)
Other packages (by `id`) that must be installed first.

**Examples:**
```yaml
dependencies: [git, curl]
dependencies: [python3, pip]
```

**Note**: Installation script will resolve dependencies and install in correct order.

#### `conflicts` (array)
Packages (by `id`) that conflict with this package.

**Examples:**
```yaml
conflicts: [vim]           # neovim conflicts with vim
conflicts: [docker-io]     # docker-ce conflicts with docker-io
```

**Note**: Installation script will warn or prevent installation if conflicts exist.

---

## Complete Examples

### Minimal Manifest

```yaml
version: "1.0"

packages:
  - id: neovim
    install:
      brew: neovim
      apt: neovim

  - id: ripgrep
    install:
      brew: ripgrep
      apt: ripgrep
```

### Realistic Development Environment

```yaml
version: "1.0"

metadata:
  name: "Web Development Environment"
  description: "Full-stack JavaScript development tools"
  last_updated: "2025-10-14"

settings:
  auto_confirm: false
  parallel_install: true
  skip_installed: true

repositories:
  taps:
    - name: "homebrew/cask-fonts"
      platforms: [macos]

packages:
  # Core editor
  - id: neovim
    name: "Neovim"
    description: "Hyperextensible Vim-based text editor"
    category: editor
    priority: required
    platforms: [macos, linux, windows]
    install:
      brew: neovim
      apt: neovim
      choco: neovim
      winget: Neovim.Neovim
    alternatives:
      - method: source
        platforms: [linux]
    dependencies: [git, curl]

  # Search tools
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

  # Language toolchains
  - id: nodejs
    name: "Node.js"
    description: "JavaScript runtime"
    category: language
    priority: required
    install:
      brew: node
      apt: nodejs
      choco: nodejs
      winget: OpenJS.NodeJS

  # GUI applications
  - id: docker
    name: "Docker Desktop"
    description: "Container platform"
    category: container
    priority: recommended
    platforms: [macos, windows]
    install:
      brew_cask: docker
      choco: docker-desktop
      winget: Docker.DockerDesktop
    post_install:
      macos: "open /Applications/Docker.app"
```

---

## Best Practices

### Naming Conventions

1. **Package IDs**: Use lowercase with hyphens
   - ✅ `github-cli`, `font-fira-code`
   - ❌ `GitHub_CLI`, `FontFiraCode`

2. **Categories**: Use singular nouns
   - ✅ `editor`, `language`, `tool`
   - ❌ `editors`, `languages`, `tools`

3. **Descriptions**: Start with capital, no period
   - ✅ "Fast text search tool"
   - ❌ "fast text search tool."

### Organization

1. **Group by category** within packages array
2. **Required packages first**, then recommended, then optional
3. **Comment sections** for readability

Example:
```yaml
packages:
  # ============================================================
  # Core Development Tools (Required)
  # ============================================================

  - id: git
    # ...

  - id: neovim
    # ...

  # ============================================================
  # Shell Enhancements (Recommended)
  # ============================================================

  - id: starship
    # ...
```

### Testing

Always test your manifest:

1. **Validate YAML syntax**: Use `yamllint` or online validator
2. **Test on clean system**: Use Docker or VM
3. **Verify cross-platform**: Test on multiple OSes
4. **Document quirks**: Add comments for unusual configurations

---

## Schema Evolution

This is version 1.0 of the schema. Future versions will maintain backward compatibility where possible.

**Versioning**:
- `1.x`: Backward compatible additions
- `2.x`: Breaking changes (migration guide provided)

**Deprecation policy**:
- Fields marked deprecated in version N
- Removed in version N+2
- Migration warnings provided

---

## Future Considerations

Features being considered for future versions:

- **Version constraints**: Specify minimum/maximum package versions
- **Conditional installation**: Install based on environment variables
- **Package groups**: Install bundles of related packages
- **Profiles**: Different sets for laptop/desktop/server
- **Lock files**: Pin exact versions for reproducibility
- **Hooks**: Pre/post install hooks at package level
- **Variables**: Template system for reusable values

---

*Schema designed with love for the universal dotfiles project* 💙
