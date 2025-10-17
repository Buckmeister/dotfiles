# Windows Subsystem for Linux (WSL) Guide

A comprehensive guide to installing and using these dotfiles on Windows Subsystem for Linux (WSL).

## Table of Contents

- [What is WSL?](#what-is-wsl)
- [Why Use WSL?](#why-use-wsl)
- [Prerequisites](#prerequisites)
- [WSL Installation](#wsl-installation)
- [Dotfiles Installation on WSL](#dotfiles-installation-on-wsl)
- [Windows Interoperability](#windows-interoperability)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Known Limitations](#known-limitations)
- [Best Practices](#best-practices)

---

## What is WSL?

**Windows Subsystem for Linux (WSL)** is a compatibility layer for running Linux binary executables natively on Windows 10 and Windows 11. WSL2, the current version, provides a full Linux kernel running inside a lightweight virtual machine, offering near-native Linux performance on Windows.

### WSL1 vs WSL2

- **WSL1**: Translation layer (slower I/O, better Windows file system integration)
- **WSL2**: Full Linux kernel in lightweight VM (faster, better compatibility, recommended)

**We recommend WSL2** for the best experience with these dotfiles.

---

## Why Use WSL?

✅ **Best of Both Worlds**: Windows desktop with full Linux development environment
✅ **Native Performance**: True Linux kernel with near-native performance
✅ **Seamless Integration**: Access Windows files, run Windows apps from Linux
✅ **Development Tools**: Use Linux tools, package managers, and workflows
✅ **Docker Support**: Run Docker Desktop with WSL2 backend
✅ **Cost Effective**: No need for dual-boot or separate Linux machine

---

## Prerequisites

### System Requirements

- **Windows 10**: Version 2004 (Build 19041) or higher
- **Windows 11**: Any version
- **Architecture**: x64 or ARM64
- **Virtualization**: Must be enabled in BIOS/UEFI
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 10GB+ free space

### Check Your Windows Version

```powershell
# Run in PowerShell
winver
```

Or:

```powershell
# Check build number
systeminfo | findstr /B /C:"OS Version"
```

---

## WSL Installation

### Method 1: Quick Install (Recommended)

**Windows 11 or Windows 10 (Build 19041+):**

```powershell
# Open PowerShell or Windows Terminal as Administrator
wsl --install
```

This automatically:
- Enables WSL and Virtual Machine Platform
- Downloads and installs Ubuntu (default distro)
- Sets WSL2 as default
- Installs Linux kernel update

**Reboot** your computer after installation.

### Method 2: Manual Install

If the quick install doesn't work:

#### Step 1: Enable WSL

```powershell
# Run as Administrator
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

#### Step 2: Enable Virtual Machine Platform

```powershell
# Run as Administrator
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**Reboot** your computer.

#### Step 3: Download Linux Kernel Update

Download and install: [WSL2 Linux kernel update package](https://aka.ms/wsl2kernel)

#### Step 4: Set WSL2 as Default

```powershell
wsl --set-default-version 2
```

#### Step 5: Install a Linux Distribution

**Option A: Microsoft Store**
- Open Microsoft Store
- Search for "Ubuntu", "Debian", or your preferred distro
- Click "Get" and install

**Option B: Command Line**
```powershell
# List available distributions
wsl --list --online

# Install Ubuntu (recommended)
wsl --install -d Ubuntu

# Or install Debian
wsl --install -d Debian
```

### Verify Installation

```powershell
# Check WSL version
wsl --status

# List installed distributions
wsl --list --verbose

# Should show version 2
```

### First Launch

1. Launch your distribution from Start Menu (e.g., "Ubuntu")
2. Wait for installation to complete (first launch only)
3. Create a Unix username (can be different from Windows username)
4. Set a password (you'll need this for sudo)

---

## Dotfiles Installation on WSL

Once WSL is set up, installing the dotfiles is the same as on Linux!

### Option 1: Interactive Installation (Recommended)

```bash
# One-line interactive installer
curl -fsSL https://buckmeister.github.io/dotfiles/dfsetup | sh
```

This launches the TUI menu where you can select which post-install scripts to run.

### Option 2: Automatic Installation

```bash
# One-line automatic installer (installs everything)
curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
```

This automatically installs all modules without prompts.

### Option 3: Manual Installation

```bash
# Clone the repository
git clone --recurse-submodules https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles

# Run the setup script
cd ~/.config/dotfiles
./setup
```

### Post-Installation

```bash
# Restart your shell to apply changes
exec zsh

# Or simply open a new WSL window
```

---

## Windows Interoperability

WSL2 provides seamless integration with Windows. Here are the key features:

### Accessing Windows Files

Windows drives are mounted under `/mnt/`:

```bash
# Your Windows C: drive
cd /mnt/c/Users/YourUsername

# Your Windows Desktop
cd /mnt/c/Users/YourUsername/Desktop

# Your Windows Documents
cd /mnt/c/Users/YourUsername/Documents
```

**Best Practice**: Keep your Linux files in the Linux filesystem (`~`) for better performance. Only access Windows files when needed.

### Accessing Linux Files from Windows

**Windows File Explorer**:
```
\\wsl$\Ubuntu\home\username
```

Or simply type in File Explorer:
```
\\wsl$
```

### Running Windows Commands from Linux

```bash
# Open File Explorer in current directory
explorer.exe .

# Open a file in Windows default application
cmd.exe /c start myfile.pdf

# Run PowerShell commands
powershell.exe -Command "Get-Date"

# Use Windows clipboard
echo "hello" | clip.exe
```

### Running Linux Commands from Windows

```powershell
# In PowerShell or Command Prompt
wsl ls -la
wsl cat ~/.bashrc
wsl --distribution Ubuntu cat /etc/os-release
```

### Path Translation

WSL automatically translates paths:

```bash
# This works! WSL translates the Windows path
cd /mnt/c/Users/Thomas/Documents

# Or use wslpath utility
wslpath "C:\Users\Thomas\Documents"
# Output: /mnt/c/Users/Thomas/Documents

wslpath -w ~/Documents
# Output: \\wsl$\Ubuntu\home\username\Documents
```

### Networking

WSL2 uses a virtualized network adapter:

```bash
# Get your WSL IP address
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# Access Windows localhost from WSL
curl http://localhost:8080

# Access WSL services from Windows (use WSL IP or localhost)
# Windows can access WSL services via localhost automatically
```

---

## Performance Optimization

### 1. Use Linux Filesystem for Project Files

**SLOW**: `/mnt/c/Users/YourName/Projects/myproject`
**FAST**: `~/Projects/myproject`

File I/O is significantly faster in the native Linux filesystem.

### 2. Exclude WSL from Windows Defender

Windows Defender can slow down file operations. Add exclusions:

```powershell
# Run in PowerShell as Administrator
# Replace USERNAME with your Windows username
Add-MpPreference -ExclusionPath "C:\Users\USERNAME\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc"

# For multiple distributions, add each one
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu"
```

**Security Note**: Only exclude if you trust your Linux environment.

### 3. Configure .wslconfig

Create `C:\Users\YourUsername\.wslconfig` (Windows side):

```ini
[wsl2]
# Limit memory (8GB)
memory=8GB

# Limit processors (4 cores)
processors=4

# Enable swap
swap=4GB

# Disable page reporting
pageReporting=false

# Network mode (NAT is default and stable)
networkingMode=NAT
```

**Restart WSL** after changes:
```powershell
wsl --shutdown
```

### 4. Git Performance

For better Git performance on Windows-side repos:

```bash
# In ~/.gitconfig or project .git/config
git config core.fscache true
git config core.preloadindex true
```

### 5. Docker Desktop Integration

If using Docker Desktop with WSL2 backend:

```bash
# Docker Desktop integration automatically configures this
docker --version

# Use Docker from WSL - no separate Docker installation needed!
docker ps
docker-compose up
```

---

## Troubleshooting

### WSL2 Won't Start

**Problem**: `WslRegisterDistribution failed with error: 0x800701bc`

**Solution**: Install the [WSL2 Linux kernel update](https://aka.ms/wsl2kernel)

---

### Can't Access Windows Files

**Problem**: `/mnt/c` is empty or not accessible

**Solution**:
```bash
# Check if automount is enabled
cat /etc/wsl.conf

# If [automount] section is disabled, edit:
sudo nano /etc/wsl.conf

# Add or modify:
[automount]
enabled = true
mountFsTab = true

# Restart WSL
# In PowerShell:
wsl --shutdown
```

---

### Slow File Operations

**Problem**: File operations on `/mnt/c/` are very slow

**Solution**:
1. **Move projects to Linux filesystem** (`~`)
2. **Exclude from Windows Defender** (see Performance section)
3. **Use WSL2** (not WSL1): `wsl --set-version Ubuntu 2`

---

### Network Connection Issues

**Problem**: Can't access internet from WSL

**Solution**:
```bash
# Check DNS resolution
cat /etc/resolv.conf

# If DNS is wrong, regenerate it
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'

# Or use Google's DNS permanently
sudo nano /etc/wsl.conf

# Add:
[network]
generateResolvConf = false

# Then manually create /etc/resolv.conf with Google DNS
```

---

### Port Forwarding

**Problem**: Need to access WSL service from another machine

**Solution**:
```powershell
# In PowerShell as Administrator
# Forward port 3000 from WSL to Windows
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=$(wsl hostname -I)

# Check existing forwards
netsh interface portproxy show all

# Remove a forward
netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=0.0.0.0
```

---

### Permission Denied Errors

**Problem**: Permission errors when running scripts

**Solution**:
```bash
# Fix script permissions
chmod +x ~/.local/bin/scriptname

# Fix repository permissions
chmod +x ~/.config/dotfiles/bin/*.zsh
```

---

### systemd Not Available

**Problem**: `systemctl` doesn't work

**Note**: WSL2 doesn't use systemd by default. Most modern distros include init alternatives.

**Solution** (Windows 11 build 22H2+):
```bash
# Edit /etc/wsl.conf
sudo nano /etc/wsl.conf

# Add:
[boot]
systemd=true

# Restart WSL from PowerShell
wsl --shutdown
```

---

## Known Limitations

### Things That Don't Work

- **GUI Applications**: Limited support (requires WSLg on Windows 11)
- **USB Devices**: No direct access to USB devices (use usbipd-win workaround)
- **Low-level Hardware**: No direct hardware access
- **Some Kernel Modules**: Custom kernel modules may not work
- **Filesystem Permissions**: Windows files have simplified permissions

### Workarounds

**GUI Apps**: Use **WSLg** (Windows 11) or **X Server** (VcXsrv, Xming)
**USB**: Use [usbipd-win](https://github.com/dorssel/usbipd-win)
**Hardware**: Use Windows-side tools and interop

---

## Best Practices

### 1. Keep Projects in Linux Filesystem

```bash
# Good - fast performance
~/Projects/myproject

# Bad - slow performance
/mnt/c/Users/YourName/Projects/myproject
```

### 2. Use Git from Linux

```bash
# Configure Git in WSL
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Use SSH keys from Linux side
ssh-keygen -t ed25519 -C "your.email@example.com"
```

### 3. Use Windows Terminal

Windows Terminal provides:
- Multiple tabs
- Split panes
- Better performance
- Customizable appearance
- GPU acceleration

Download from Microsoft Store: **Windows Terminal**

### 4. Configure Git Credential Manager

```bash
# Use Windows Git Credential Manager from WSL
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager-core.exe"
```

### 5. Backup Your Data

```bash
# Export your distribution
wsl --export Ubuntu backup.tar

# Import on another machine
wsl --import Ubuntu C:\WSL\Ubuntu backup.tar
```

### 6. Use Separate Distribution for Experiments

```bash
# Create a new distribution for testing
wsl --import TestUbuntu C:\WSL\TestUbuntu ubuntu-base.tar
wsl -d TestUbuntu
```

---

## Additional Resources

### Official Documentation

- [Microsoft WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [WSL GitHub Repository](https://github.com/microsoft/WSL)
- [WSL Best Practices](https://docs.microsoft.com/en-us/windows/wsl/filesystems)

### Community

- [WSL Subreddit](https://www.reddit.com/r/WSL/)
- [WSL GitHub Issues](https://github.com/microsoft/WSL/issues)
- [Stack Overflow WSL Tag](https://stackoverflow.com/questions/tagged/wsl)

### Tools

- [Windows Terminal](https://github.com/microsoft/terminal)
- [WSLg (GUI Apps)](https://github.com/microsoft/wslg)
- [Docker Desktop with WSL2](https://docs.docker.com/desktop/windows/wsl/)
- [VS Code Remote - WSL](https://code.visualstudio.com/docs/remote/wsl)

---

## Getting Help

If you encounter issues with the dotfiles on WSL:

1. **Check this guide** for common issues
2. **Review the main [README](../README.md)** for general setup
3. **Check [INSTALL.md](INSTALL.md)** for installation details
4. **Search [GitHub Issues](https://github.com/Buckmeister/dotfiles/issues)**
5. **Open a new issue** with WSL-specific details

### Include in Bug Reports

- Windows version: `winver`
- WSL version: `wsl --version`
- Distribution: `wsl --list --verbose`
- Dotfiles detection: Run in WSL: `cat /proc/version`

---

**Happy developing on WSL!** 🪟🐧✨
