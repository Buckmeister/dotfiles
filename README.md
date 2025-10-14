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
- 💙 **Crafted with Care** - Every detail considered, every message friendly

---

## 🚀 Quick Start

### One-Line Installation (Recommended for Fresh Machines)

**macOS / Linux / WSL (Interactive Menu):**
```bash
curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup | sh
```

**Or for automatic installation (everything):**
```bash
curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
```

**Windows PowerShell (Interactive Menu):**
```powershell
irm https://buckmeister.github.io/dotfiles/dfsetup.ps1 | iex
```

**Or for automatic installation (everything):**
```powershell
irm https://buckmeister.github.io/dotfiles/dfauto.ps1 | iex
```

That's it! This single command will:
- ✅ Detect your OS and install required tools (git, zsh)
- ✅ Clone the repository with submodules
- ✅ Run the complete setup automatically
- ✅ Leave you with a beautifully configured environment

**Memorable URL:** Visit [buckmeister.github.io/dotfiles](https://buckmeister.github.io/dotfiles/) for easy installation commands

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
- **`menu_tui.zsh`** - Beautiful interactive menu with keyboard navigation
- **`librarian.zsh`** - Your friendly system health reporter
- **`link_dotfiles.zsh`** - Creates all the necessary symlinks
- **`update_all.zsh`** - Central update system for packages and toolchains

### Shared Libraries
- **`colors.zsh`** - OneDark color scheme for consistent UI
- **`ui.zsh`** - Progress bars, headers, and beautiful output
- **`utils.zsh`** - OS detection and common utilities
- **`greetings.zsh`** - Friendly messages to brighten your day

### Configuration Files
Meticulously crafted configurations for:
- **Shells**: zsh, bash, starship prompt
- **Editors**: [Neovim](https://github.com/Buckmeister/lualoves.nvim) (git submodule), Vim, Emacs
- **Terminals**: Kitty, Alacritty
- **Tools**: tmux, git, ranger, and more
- **macOS**: Karabiner keyboard remapping

### Post-Install Scripts
Modular, OS-aware installation for:
- Package managers (Cargo, npm, pip, Ruby gems)
- Language servers (Rust, Python, Java, C#, and more)
- Development toolchains
- Fonts and visual enhancements
- System integrations

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

See [TESTING.md](TESTING.md) for detailed testing documentation.

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

For detailed information about the architecture, component structure, and development workflow, see:
- **[CLAUDE.md](CLAUDE.md)** - Repository architecture and technical documentation
- **[TESTING.md](TESTING.md)** - Testing infrastructure and guidelines
- **[TeamBio.md](TeamBio.md)** - Team information and project context

---

## 🎵 Final Note

> *"Every great composition starts with a single note."*
> — The Librarian

Whether you're just beginning your dotfiles journey or you're a seasoned configuration maestro, this repository welcomes you. Feel free to fork, customize, and make it your own.

Have fun, and may your terminal always sing in harmony! 🎼

---

**Made with 💙 by humans and AI working together**
