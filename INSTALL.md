# Quick Installation Guide

## 🚀 One-Line Installation

### macOS / Linux / WSL

For Unix-like systems, simply run:

```bash
curl -fsSL https://USERNAME.github.io/dfinstaller | sh
```

### Windows (PowerShell)

For Windows with PowerShell (Run as Administrator):

```powershell
irm https://USERNAME.github.io/install.ps1 | iex
```

**Note:** WSL (Windows Subsystem for Linux) is recommended for the best experience. The PowerShell installer can set up WSL for you.

**Replace `USERNAME` with your GitHub username!**

That's it! The script will:
- ✅ Detect your operating system (macOS, Linux, WSL)
- ✅ Check for required tools (git, zsh)
- ✅ Offer to install missing dependencies
- ✅ Clone the dotfiles repository to `~/.config/dotfiles`
- ✅ Run the interactive setup menu
- ✅ Configure your development environment

## 🎯 What You Get

The installation script automatically sets up:

- **Shell Configuration**: zsh with modern plugins and themes
- **Development Tools**: Language servers, formatters, linters
- **Package Managers**: cargo, npm, pip, gem, and more
- **Git Configuration**: Beautiful diffs with delta, optimized settings
- **Editor Setup**: Neovim with lua configuration, Vim with vim-plug
- **Terminal Tools**: Modern replacements (bat, ripgrep, fd, etc.)
- **Fonts**: Nerd Fonts for beautiful terminal icons

## 📋 Prerequisites

The bootstrap script will automatically install these if missing:

- **git** - Version control system
- **zsh** - Modern shell (recommended but not required)

## 🛠️ Manual Installation

If you prefer to install manually:

```bash
# 1. Clone the repository
git clone https://github.com/USERNAME/dotfiles.git ~/.config/dotfiles

# 2. Run the setup script
cd ~/.config/dotfiles
./setup

# Or run with all modules automatically:
./setup --all-modules
```

## 🌍 Supported Platforms

- ✅ **macOS** (Intel and Apple Silicon)
- ✅ **Linux** (Ubuntu, Debian, Fedora, Arch)
- ✅ **WSL** (Windows Subsystem for Linux) - Recommended for Windows users
- ✅ **Windows** (via PowerShell with Chocolatey)

## 🔒 Security

The bootstrap script:
- Uses HTTPS for all downloads
- Only installs from official package repositories
- Asks for confirmation before installing dependencies
- Can be reviewed before execution:
  ```bash
  curl -fsSL https://USERNAME.github.io/dfinstaller | less
  ```

## 📦 Publishing Your Fork

To enable one-line installation for your fork:

1. **Fork this repository** on GitHub
2. **Update the repository URL** in `dfinstaller`:
   ```bash
   DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles.git"
   ```
3. **Enable GitHub Pages**:
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: main, folder: /docs
   - Save
4. **Copy installation scripts** to docs folder:
   ```bash
   cp dfinstaller docs/dfinstaller
   cp install.ps1 docs/install.ps1
   ```
5. **Commit and push** the changes
6. **Share your installation command**:
   ```bash
   curl -fsSL https://YOUR_USERNAME.github.io/dfinstaller | sh
   ```

The scripts will be automatically available via GitHub Pages at:
```
https://YOUR_USERNAME.github.io/dfinstaller
https://YOUR_USERNAME.github.io/install.ps1
```

No external hosting needed! 🎉

## 🎨 Customization

After installation, customize your setup:

1. **Personal settings**: Edit `~/.config/dotfiles/config/personal.env`
   ```bash
   # Add your personal configurations
   export GIT_USER_NAME="Your Name"
   export GIT_USER_EMAIL="your.email@example.com"
   ```

2. **Package lists**: Modify package lists in `~/.config/dotfiles/config/packages/`
   - `cargo-packages.list` - Rust tools
   - `npm-packages.list` - Node.js global packages
   - `ruby-gems.list` - Ruby gems
   - `pip-packages.list` - Python tools

3. **Re-run specific scripts**: Use the interactive menu
   ```bash
   cd ~/.config/dotfiles
   ./setup
   ```

## 🐛 Troubleshooting

### Script fails to download
```bash
# Verify GitHub Pages connectivity
curl -I https://USERNAME.github.io

# Try with verbose output
curl -fsSL -v https://USERNAME.github.io/dfinstaller | sh
```

### Permission denied
```bash
# Ensure the script is executable
chmod +x ~/.config/dotfiles/dfinstaller

# Run with explicit shell
sh ~/.config/dotfiles/dfinstaller
```

### Git clone fails
```bash
# Check SSH keys if using SSH URL
ssh -T git@github.com

# Or use HTTPS URL in dfinstaller
DOTFILES_REPO="https://github.com/USERNAME/dotfiles.git"
```

## 💡 Tips

- **Fresh Installation**: The script is idempotent - safe to run multiple times
- **Update Dotfiles**: Just re-run the installation command to update
- **Backup**: Existing configs are backed up to `~/.tmp/dotfilesBackup-{timestamp}/`
- **Selective Setup**: Run `./setup` without `--all-modules` for interactive menu

## 📚 Further Reading

- [Main README](./README.md) - Complete documentation
- [CLAUDE.md](./CLAUDE.md) - Repository architecture and design
- [Configuration Guide](./config/README.md) - Detailed configuration options

## 🎵 Philosophy

This installation system follows the dotfiles philosophy:

> **Beautiful by default, customizable when needed**

The bootstrap script provides a polished, one-command installation experience while maintaining full transparency and customizability for power users.

---

**Enjoy your beautifully configured development environment!** ✨

*If you encounter any issues, please [open an issue](https://github.com/USERNAME/dotfiles/issues) on GitHub.*
