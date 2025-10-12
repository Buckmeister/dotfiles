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
- 💙 **Crafted with Care** - Every detail considered, every message friendly

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Run the cross-platform setup
./setup
```

That's it! The setup script will:
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

### Shared Libraries
- **`colors.zsh`** - OneDark color scheme for consistent UI
- **`ui.zsh`** - Progress bars, headers, and beautiful output
- **`utils.zsh`** - OS detection and common utilities
- **`greetings.zsh`** - Friendly messages to brighten your day

### Configuration Files
Meticulously crafted configurations for:
- **Shells**: zsh, bash, starship prompt
- **Editors**: Neovim, Vim, Emacs
- **Terminals**: Kitty, Alacritty
- **Tools**: tmux, git, ranger, and more
- **macOS**: Karabiner keyboard remapping

### Post-Install Scripts
Modular, OS-aware installation for:
- Programming languages (Cargo, npm, pip, Ruby gems)
- Language servers (Rust, Python, Java, C#, and more)
- Development toolchains
- Fonts and visual enhancements
- System integrations

---

## 🎹 The Interactive Experience

When you run `./bin/setup.zsh`, you're greeted with an elegant TUI menu:

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

### Skip Post-Install Scripts, do only Dotfile linking
```bash
./bin/setup.zsh --skip-pi
```

### Run All Post-Install Scripts Silently, do Dotfile linking, as well
```bash
./bin/librarian.zsh --all-pi
```

### System Health Check
```bash
./bin/librarian.zsh
```

### Create a Backup
```bash
./backup
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
- **[TeamBio.md](TeamBio.md)** - Team information and project context

---

## 🎵 Final Note

> *"Every great composition starts with a single note."*
> — The Librarian

Whether you're just beginning your dotfiles journey or you're a seasoned configuration maestro, this repository welcomes you. Feel free to fork, customize, and make it your own.

Have fun, and may your terminal always sing in harmony! 🎼

---

**Made with 💙 by humans and AI working together**
