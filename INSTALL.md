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
curl -fsSL https://buckmeister.github.io/dfsetup | sh
```

**Automatic (Install Everything):**
```bash
curl -fsSL https://buckmeister.github.io/dfauto | sh
```

### Windows (PowerShell)

For Windows with PowerShell (Run as Administrator):

**Interactive Menu (Recommended):**
```powershell
irm https://buckmeister.github.io/dfsetup.ps1 | iex
```

**Automatic (Install Everything):**
```powershell
irm https://buckmeister.github.io/dfauto.ps1 | iex
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

**For detailed information about each configuration, keybindings, and features, see [MANUAL.md](./MANUAL.md).**

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
  curl -fsSL https://buckmeister.github.io/dfsetup | less
  curl -fsSL https://buckmeister.github.io/dfauto | less
  ```

## 📦 Publishing Your Fork

Want to enable one-line installation for your fork with clean URLs? You'll need two repositories: one for your dotfiles and one for GitHub Pages hosting.

### How It Works

This setup uses **User Pages** for root-level URLs (`https://YOUR-USERNAME.github.io/dfsetup`):

**Two-Repository Architecture:**
1. **`YOUR-USERNAME/dotfiles`** - Your main dotfiles repository
2. **`YOUR-USERNAME/YOUR-USERNAME.github.io`** - User Pages site (hosts installer scripts)

When someone runs `curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh`, they're downloading from your User Pages repository, which then clones your dotfiles repository.

### Setup Steps

**1. Fork the dotfiles repository** on GitHub to your account

**2. Update the repository URL** in all four bootstrap scripts in your fork:

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

Commit and push these changes to your dotfiles repository.

**3. Create the User Pages repository** on GitHub:

```bash
# Create a new repository named YOUR-USERNAME.github.io on GitHub
# Then clone it locally
git clone https://github.com/YOUR-USERNAME/YOUR-USERNAME.github.io.git
cd YOUR-USERNAME.github.io

# Initialize with README
cat > README.md << 'EOF'
# My Dotfiles Installation

Bootstrap installation scripts for my personal dotfiles.

## Installation

**macOS / Linux / WSL:**
```bash
curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh
```

**Windows (PowerShell):**
```powershell
irm https://YOUR-USERNAME.github.io/dfsetup.ps1 | iex
```
EOF

git add README.md
git commit -m "Initial commit"
git push origin main
```

**4. Copy installer scripts** from your dotfiles repository:

```bash
# From your dotfiles repository directory
cd /path/to/YOUR-USERNAME/dotfiles

# Copy all four installer scripts to User Pages repo
cp dfsetup dfauto dfsetup.ps1 dfauto.ps1 ../YOUR-USERNAME.github.io/

# Optional: Copy index.html landing page
cp docs/index.html ../YOUR-USERNAME.github.io/
```

**5. Commit and push** to User Pages repository:

```bash
cd ../YOUR-USERNAME.github.io
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1 index.html
git commit -m "Add dotfiles installation scripts"
git push origin main
```

**6. Enable GitHub Pages** (if not auto-enabled):
- Go to repository Settings → Pages
- Source should automatically be set to: **Deploy from a branch → main → / (root)**
- If not, select it and click **Save**

**7. Wait for deployment** (usually 1-2 minutes):
- GitHub will automatically deploy your site
- Check the Actions tab to monitor progress
- Your scripts will be available at: `https://YOUR-USERNAME.github.io/dfsetup`

**8. Test your installation** URLs:

```bash
# Test interactive installer (recommended)
curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh

# Test automatic installer
curl -fsSL https://YOUR-USERNAME.github.io/dfauto | sh
```

### Your Installation URLs

After setup, share these clean commands with others (or use them yourself on new machines):

**Unix/Linux/macOS/WSL:**
```bash
# Interactive menu (recommended)
curl -fsSL https://YOUR-USERNAME.github.io/dfsetup | sh

# Automatic installation
curl -fsSL https://YOUR-USERNAME.github.io/dfauto | sh
```

**Windows PowerShell:**
```powershell
# Interactive menu (recommended)
irm https://YOUR-USERNAME.github.io/dfsetup.ps1 | iex

# Automatic installation
irm https://YOUR-USERNAME.github.io/dfauto.ps1 | iex
```

### Maintenance

**Keep scripts synchronized** between repositories:

When you modify bootstrap scripts in your dotfiles repo, sync them to your User Pages repo:

```bash
# After editing bootstrap scripts in dotfiles repository
cd ~/.config/dotfiles
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1
git commit -m "Update bootstrap scripts"
git push

# Copy to User Pages repository
cp dfsetup dfauto dfsetup.ps1 dfauto.ps1 ~/YOUR-USERNAME.github.io/

# Commit and push to User Pages repo
cd ~/YOUR-USERNAME.github.io
git add dfsetup dfauto dfsetup.ps1 dfauto.ps1
git commit -m "Sync installer scripts from dotfiles repo"
git push
```

**Optional: Create a sync helper script:**

```bash
# Add to ~/.config/dotfiles/bin/sync_installers.zsh
#!/usr/bin/env zsh
DOTFILES_DIR="$(dirname "$(realpath "$0")")/.."
USER_PAGES_DIR="$HOME/YOUR-USERNAME.github.io"

if [[ ! -d "$USER_PAGES_DIR" ]]; then
    echo "❌ User Pages repository not found at: $USER_PAGES_DIR"
    exit 1
fi

# Copy installer scripts
cp "$DOTFILES_DIR"/{dfsetup,dfauto,dfsetup.ps1,dfauto.ps1} "$USER_PAGES_DIR/"

echo "✅ Installer scripts synced to User Pages repository"
echo "💡 Don't forget to commit and push: cd $USER_PAGES_DIR && git add . && git commit && git push"
```

No external hosting needed - everything runs on GitHub Pages! 🎉

## 🔗 Symlink Architecture

This repository uses a convention-based symlink system to organize configuration files:

| Pattern | Destination | Example |
|---------|------------|---------|
| `*.symlink` | `~/.{basename}` | `configs/shell/zsh/zshrc.symlink` → `~/.zshrc` |
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
vim ~/.config/dotfiles/configs/shell/zsh/zshrc.symlink

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
curl -fsSL -v https://buckmeister.github.io/dfsetup | sh

# Alternative: Download and inspect the script first
curl -fsSL https://buckmeister.github.io/dfsetup > /tmp/dfsetup
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
ls -la configs/editors/nvim/nvim.symlink_config/
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
git submodule update --init --recursive configs/editors/nvim/nvim.symlink_config
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
curl -fsSL https://buckmeister.github.io/dfauto | sh
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
1. Run one-line installer: `curl -fsSL https://buckmeister.github.io/dfsetup | sh`
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

Complete documentation suite:

- **[MANUAL.md](./MANUAL.md)** - **Configuration guide:** Comprehensive reference for all configurations, keybindings, and utility scripts
- **[README.md](./README.md)** - **Quick start:** Project overview and primary commands
- **[CLAUDE.md](./CLAUDE.md)** - **Architecture guide:** Repository structure and development workflow
- **[TESTING.md](./TESTING.md)** - **Testing guide:** Test suite documentation

**New to the configurations?** Start with **[MANUAL.md](./MANUAL.md)** to learn about shell keybindings, tmux shortcuts, editor configurations, and utility scripts.

## 🎵 Philosophy

This installation system follows the dotfiles philosophy:

> **Beautiful by default, customizable when needed**

The bootstrap script provides a polished, one-command installation experience while maintaining full transparency and customizability for power users.

---

**Enjoy your beautifully configured development environment!** ✨

*If you encounter any issues, please [open an issue](https://github.com/Buckmeister/dotfiles/issues) on GitHub.*
