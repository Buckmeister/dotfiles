# Quick Installation Guide

**Get your development environment set up in seconds with one command.**

## 📖 Table of Contents

- [One-Line Installation](#-one-line-installation) - Fastest way to get started
- [What You Get](#-what-you-get) - Included tools and configurations
- [Prerequisites](#-prerequisites) - Required dependencies
- [Manual Installation](#-manual-installation) - Step-by-step setup
- [Supported Platforms](#-supported-platforms) - OS compatibility
- [Security](#-security) - Safety information
- [Publishing Your Fork](#-publishing-your-fork) - Host your own dotfiles
- [Symlink Architecture](#-symlink-architecture) - How the linking system works
- [Customization](#-customization) - Make it your own
- [Troubleshooting](#-troubleshooting) - Common issues and solutions
- [Pro Tips](#-pro-tips) - Best practices and workflows
- [Further Reading](#-further-reading) - Additional documentation

---

## 🚀 One-Line Installation

### macOS / Linux / WSL

**Interactive Menu (Recommended):**
```bash
curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup | sh
```

**Automatic (Install Everything):**
```bash
curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
```

### Windows (PowerShell)

For Windows with PowerShell (Run as Administrator):

**Interactive Menu (Recommended):**
```powershell
irm https://buckmeister.github.io/dotfiles/dfsetup.ps1 | iex
```

**Automatic (Install Everything):**
```powershell
irm https://buckmeister.github.io/dotfiles/dfauto.ps1 | iex
```

**Note:** WSL (Windows Subsystem for Linux) is recommended for the best experience. The PowerShell installer can set up WSL for you.

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

If you prefer to install manually or want more control over the process:

```bash
# 1. Clone the repository with submodules
git clone --recurse-submodules https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles

# 2. Navigate to the dotfiles directory
cd ~/.config/dotfiles

# 3. Run the setup script (launches interactive menu)
./setup

# Alternative: Install everything automatically without prompts
./setup --all-modules

# Alternative: Only create symlinks, skip post-install scripts
./setup --skip-pi
```

**What the setup script does:**
1. Detects your OS and package manager (macOS/brew, Linux/apt|dnf|pacman)
2. Creates necessary directories (`~/.tmp`, `~/.local/bin`, etc.)
3. Backs up existing configurations to `~/.tmp/dotfilesBackup-{timestamp}/`
4. Creates symlinks for all dotfiles (see [Symlink Architecture](#symlink-architecture))
5. Launches the interactive menu or runs post-install scripts

**Note:** The `--recurse-submodules` flag ensures the Neovim configuration (managed as a separate repository) is cloned automatically.

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
  curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup | less
  curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | less
  ```

## 📦 Publishing Your Fork

Want to enable one-line installation for your fork? This repository includes everything you need to publish your customized dotfiles with GitHub Pages hosting.

### How It Works

The repository includes bootstrap scripts in two locations:
- **Root directory** (`dfsetup`, `dfauto`, `dfsetup.ps1`, `dfauto.ps1`) - Source files for editing and local testing
- **docs/ directory** - Copies served via GitHub Pages for web installation

When someone runs `curl -fsSL https://YOUR-USERNAME.github.io/dotfiles/dfsetup | sh`, they're downloading the script from your `docs/` folder via GitHub Pages.

### Setup Steps

**1. Fork this repository** on GitHub to your account

**2. Update the repository URL** in all four bootstrap scripts:

Edit the `DOTFILES_REPO` variable in each file:
- `dfsetup` (line 28)
- `dfauto` (line 28)
- `dfsetup.ps1` (near top of file)
- `dfauto.ps1` (near top of file)

Change from:
```bash
DOTFILES_REPO="https://github.com/Buckmeister/dotfiles.git"
```

To your fork:
```bash
DOTFILES_REPO="https://github.com/YOUR-USERNAME/dotfiles.git"
```

**3. Sync the scripts** to docs/ folder:

```bash
# Copy updated scripts to docs/ for GitHub Pages hosting
cp dfsetup dfauto dfsetup.ps1 dfauto.ps1 docs/

# Verify the files are identical
diff dfsetup docs/dfsetup
diff dfauto docs/dfauto
diff dfsetup.ps1 docs/dfsetup.ps1
diff dfauto.ps1 docs/dfauto.ps1
```

**4. Enable GitHub Pages**:
- Go to your repository's Settings → Pages
- Under "Source", select: **Deploy from a branch**
- Under "Branch", select: **main** and folder: **/docs**
- Click **Save**

**5. Commit and push** all changes:

```bash
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1 docs/
git commit -m "Configure bootstrap scripts for personal fork"
git push origin main
```

**6. Wait for deployment** (usually 1-2 minutes):
- GitHub Actions will build and deploy your site
- Check the Actions tab to monitor progress
- Your scripts will be available at: `https://YOUR-USERNAME.github.io/dotfiles/`

**7. Test your installation** URLs:

```bash
# Test interactive installer (recommended)
curl -fsSL https://YOUR-USERNAME.github.io/dotfiles/dfsetup | sh

# Test automatic installer
curl -fsSL https://YOUR-USERNAME.github.io/dotfiles/dfauto | sh
```

### Your Installation URLs

After setup, share these commands with others (or use them yourself on new machines):

**Unix/Linux/macOS/WSL:**
```bash
# Interactive menu (recommended)
curl -fsSL https://YOUR-USERNAME.github.io/dotfiles/dfsetup | sh

# Automatic installation
curl -fsSL https://YOUR-USERNAME.github.io/dotfiles/dfauto | sh
```

**Windows PowerShell:**
```powershell
# Interactive menu (recommended)
irm https://YOUR-USERNAME.github.io/dotfiles/dfsetup.ps1 | iex

# Automatic installation
irm https://YOUR-USERNAME.github.io/dotfiles/dfauto.ps1 | iex
```

### Maintenance Tips

**Keep scripts synchronized:**
When you modify the bootstrap scripts, always copy them to `docs/`:
```bash
# After editing dfsetup, dfauto, or PowerShell scripts
cp dfsetup dfauto dfsetup.ps1 dfauto.ps1 docs/
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1 docs/
git commit -m "Update bootstrap scripts"
git push
```

**Optional: Create a sync helper:**
```bash
# Add to ~/.config/dotfiles/bin/sync_bootstrap_scripts.zsh
#!/usr/bin/env zsh
SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
cp "$SCRIPT_DIR"/{dfsetup,dfauto,dfsetup.ps1,dfauto.ps1} "$SCRIPT_DIR/docs/"
echo "✅ Bootstrap scripts synced to docs/ folder"
```

No external hosting needed - everything runs on GitHub Pages! 🎉

## 🔗 Symlink Architecture

This repository uses a convention-based symlink system to organize configuration files:

| Pattern | Destination | Example |
|---------|------------|---------|
| `*.symlink` | `~/.{basename}` | `zsh/zshrc.symlink` → `~/.zshrc` |
| `*.symlink_config` | `~/.config/{basename}` | `kitty.symlink_config/` → `~/.config/kitty/` |
| `*.symlink_local_bin.*` | `~/.local/bin/{basename}` | `get_github_url.symlink_local_bin.zsh` → `~/.local/bin/get_github_url` |

**Key benefits:**
- ✅ Keep all configurations in one repository
- ✅ Version control your entire environment
- ✅ Easy to sync across multiple machines
- ✅ Automatic backup before linking
- ✅ Safe to modify - changes reflect immediately

## 🎨 Customization

After installation, customize your setup to match your preferences:

### 1. Personal Settings

Edit `~/.config/dotfiles/config/personal.env` for personal configurations:
```bash
# Git identity
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"

# Editor preferences
export EDITOR="nvim"
export VISUAL="nvim"

# Custom paths
export PATH="$HOME/my-tools:$PATH"
```

### 2. Package Lists

Modify package lists in `~/.config/dotfiles/config/packages/`:
- `cargo-packages.list` - Rust command-line tools (ripgrep, fd, bat, etc.)
- `npm-packages.list` - Node.js global packages (language servers, CLI tools)
- `ruby-gems.list` - Ruby gems (solargraph, standard)
- `pip-packages.list` - Python tools (ipython, black, ruff)

**Example: Adding a Rust package**
```bash
echo "tokei" >> ~/.config/dotfiles/config/packages/cargo-packages.list
cd ~/.config/dotfiles
./setup  # Re-run cargo-packages script from menu
```

### 3. Re-run Specific Scripts

Use the interactive menu to selectively re-run post-install scripts:
```bash
cd ~/.config/dotfiles
./setup

# Or run individual scripts directly:
./post-install/scripts/cargo-packages.zsh
./post-install/scripts/npm-global-packages.zsh
```

### 4. Modify Configurations

Edit any dotfile directly in the repository:
```bash
# Example: Customize zsh configuration
vim ~/.config/dotfiles/zsh/zshrc.symlink

# Changes are immediately reflected (symlinked)
source ~/.zshrc
```

## 🐛 Troubleshooting

### Installation Issues

**Script fails to download:**
```bash
# Verify GitHub Pages connectivity
curl -I https://buckmeister.github.io

# Try with verbose output to see detailed error
curl -fsSL -v https://buckmeister.github.io/dotfiles/dfsetup | sh

# Alternative: Download and inspect the script first
curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup > /tmp/dfsetup
less /tmp/dfsetup  # Review the script
sh /tmp/dfsetup    # Run it
```

**Git clone fails:**
```bash
# Check SSH keys if using SSH URL
ssh -T git@github.com

# Use HTTPS instead of SSH (more reliable)
git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles

# Behind a firewall? Try with proxy
export https_proxy="http://proxy.example.com:8080"
git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
```

**Submodules not cloned:**
```bash
# Initialize and update submodules after cloning
cd ~/.config/dotfiles
git submodule update --init --recursive

# Verify Neovim config is present
ls -la nvim/nvim.symlink_config/
```

### Setup Issues

**Permission denied on scripts:**
```bash
# Make setup script executable
chmod +x ~/.config/dotfiles/setup ~/.config/dotfiles/bin/setup.zsh

# Run with explicit shell interpreter
sh ~/.config/dotfiles/setup
# or
zsh ~/.config/dotfiles/bin/setup.zsh
```

**Unknown package manager error:**
```bash
# Manually set package manager (one-time fix)
export DF_PKG_MANAGER="apt"  # or: brew, dnf, pacman
export DF_PKG_INSTALL_CMD="sudo apt install"
./setup

# Permanent fix: Install a supported package manager
# macOS: Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Linux: Use system package manager (usually already installed)
```

**Symlink conflicts:**
```bash
# Check what's blocking
ls -la ~/.zshrc ~/.config/nvim

# Backup existing configs manually
mkdir -p ~/.config/dotfiles-backup
mv ~/.zshrc ~/.bashrc ~/.config/nvim ~/.config/dotfiles-backup/

# Re-run setup
cd ~/.config/dotfiles && ./setup
```

### Post-Installation Issues

**Shell changes don't take effect:**
```bash
# Reload shell configuration
source ~/.zshrc  # for zsh
source ~/.bashrc  # for bash

# Or restart your terminal
```

**Command not found after installation:**
```bash
# Check if symlinks were created
ls -la ~/.local/bin/

# Verify PATH includes ~/.local/bin
echo $PATH | grep -o "$HOME/.local/bin"

# Add to PATH if missing (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

**Neovim configuration not loading:**
```bash
# Check if symlink exists
ls -la ~/.config/nvim

# Verify submodule was cloned
cd ~/.config/dotfiles
git submodule status

# Re-initialize submodule if needed
git submodule update --init --recursive nvim/nvim.symlink_config
```

### Getting Help

If you encounter issues not covered here:

1. **Check the Librarian** for system health:
   ```bash
   cd ~/.config/dotfiles
   ./bin/librarian.zsh
   ```

2. **Review the logs** in `~/.config/dotfiles/df_log.txt` (if enabled)

3. **Open an issue** on GitHub with:
   - Your OS and version (`uname -a`)
   - Error messages (full output)
   - Steps to reproduce

## 💡 Pro Tips

### Best Practices

**Idempotent by design:** Safe to run the installation multiple times - it won't break existing setups:
```bash
# Update your dotfiles to latest version
curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
```

**Automatic backups:** All existing configurations are automatically backed up before linking:
```bash
# Backups are stored here with timestamps
ls ~/.tmp/dotfilesBackup-*
```

**Selective installation:** Use the interactive menu to install only what you need:
```bash
cd ~/.config/dotfiles && ./setup
# Then use j/k to navigate, Space to select, Enter to execute
```

### Recommended Workflow

**New machine setup:**
1. Run one-line installer: `curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup | sh`
2. Select desired components from interactive menu
3. Restart terminal: `exec zsh` or open new terminal window
4. Verify installation: `cd ~/.config/dotfiles && ./bin/librarian.zsh`

**Updating your environment:**
```bash
# Pull latest changes
cd ~/.config/dotfiles
git pull

# Re-run setup for new features
./setup

# Update all installed packages and toolchains
./update
```

**Syncing across machines:**
```bash
# On machine A (after customization)
cd ~/.config/dotfiles
git add .
git commit -m "Update personal configurations"
git push

# On machine B
cd ~/.config/dotfiles
git pull
./setup  # Apply any new changes
```

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

*If you encounter any issues, please [open an issue](https://github.com/Buckmeister/dotfiles/issues) on GitHub.*
