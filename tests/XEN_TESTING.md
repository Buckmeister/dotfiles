# XCP-NG VM Testing Guide

Flexible and comprehensive testing framework for dotfiles installation validation using real XCP-NG virtual machines (Linux & Windows).

## 📋 Overview

The enhanced XCP-NG test script (`test_xen.zsh`) provides a powerful, flexible testing framework that validates dotfiles installation on fresh VMs. It supports multiple test modes, post-install script filtering, Windows testing, and comprehensive debugging options.

**Key Advantages over Docker:**
- Real VMs with full OS environments
- Windows testing support
- Realistic hardware and networking conditions
- Testing VM provisioning and cloud-init/cloudbase-init

## 🚀 Quick Start

```bash
cd ~/.config/dotfiles

# Fast smoke test (2-3 minutes)
./tests/test_xen.zsh --basic --quick

# Full installation test
./tests/test_xen.zsh --comprehensive --quick

# Test git configs only on real VM
./tests/test_xen.zsh --enable-pi "git-*" --quick

# Debug failed test (keeps VM for inspection)
./tests/test_xen.zsh --quick --keep-vm --vm-name debug
```

## 🎯 Test Script: `test_xen.zsh`

### Key Features

1. **Multiple Test Modes**: Choose between basic validation, comprehensive testing, or full coverage
2. **PI Script Filtering**: Control which post-install scripts run during testing
3. **Windows Support**: Test both Linux and Windows VMs
4. **Development Options**: Debug with --keep-vm, custom VM names, skip librarian
5. **Flexible Distribution Selection**: Test specific distros, Linux-only, or Windows-only
6. **Beautiful Output**: Progress tracking, phase indicators, and detailed test results

---

## 📚 Test Modes

### Basic Mode

**Purpose**: VM provisioning and SSH validation only
**Duration**: ~2-3 minutes per Linux VM, ~10-12 minutes per Windows VM

**Tests**:
- ✅ VM created successfully with cloud-init/cloudbase-init
- ✅ VM receives IP address from DHCP
- ✅ SSH access functional
- ✅ Basic system information retrieved

**Usage**:
```bash
./tests/test_xen.zsh --basic --quick
```

**When to Use**:
- Testing VM creation scripts
- Validating cloud-init configurations
- Debugging networking issues
- Quick smoke tests of infrastructure

### Comprehensive Mode (Default)

**Purpose**: Full dotfiles installation validation
**Duration**: ~5-7 minutes per Linux VM

**Tests Everything in Basic Mode, Plus**:
- ✅ Prerequisites installed (zsh, git, build-essential)
- ✅ Repository cloned from GitHub
- ✅ Setup script runs successfully
- ✅ Git configuration applied
- ✅ Librarian health check passes
- ✅ Symlinks created correctly

**Usage**:
```bash
./tests/test_xen.zsh --comprehensive --quick
# or simply
./tests/test_xen.zsh --quick
```

**When to Use**:
- Validating full installation workflow
- Testing post-install scripts on real VMs
- Verifying everything works end-to-end
- Before releasing new versions

### Full Mode

**Purpose**: Maximum coverage - runs both basic AND comprehensive tests
**Duration**: ~7-10 minutes per Linux VM

**Usage**:
```bash
./tests/test_xen.zsh --full --quick
```

**When to Use**:
- Complete regression testing
- Validating major changes
- Pre-release testing

---

## 🎛️ Post-Install Script Control

One of the most powerful features is the ability to control which post-install scripts run during testing. This is **ESPECIALLY valuable for Xen** since real VMs boot slower than containers.

### Skip All PI Scripts (Fastest)

Perfect for testing installation mechanics without waiting for package installations:

```bash
./tests/test_xen.zsh --skip-pi --quick
```

**Benefits**:
- ~2 minutes faster per test
- Focus on VM provisioning and cloning
- Test installation framework without package overhead

**Use Cases**:
- Testing symlink creation
- Validating directory structure
- Testing cloud-init configurations
- Quick iteration during development

### Disable Specific PI Scripts

Disable scripts matching a glob pattern:

```bash
# Disable all package installation scripts
./tests/test_xen.zsh --disable-pi "*packages*" --quick

# Disable language servers (slow to install)
./tests/test_xen.zsh --disable-pi "language-servers" --quick

# Disable cargo-related scripts
./tests/test_xen.zsh --disable-pi "cargo-*" --quick
```

### Enable Only Specific PI Scripts

Enable ONLY scripts matching a pattern (all others disabled):

```bash
# Test only git configuration on real VM
./tests/test_xen.zsh --enable-pi "git-*" --quick

# Test only cargo packages
./tests/test_xen.zsh --enable-pi "cargo-packages" --quick

# Test only ruby-related scripts
./tests/test_xen.zsh --enable-pi "ruby-*" --quick
```

**Why This Is HUGE for Xen**:
- Real VMs take 2-3 minutes just to boot
- Package installations on VMs are slower than containers
- Testing specific PI scripts in realistic environment
- Faster iteration when developing new scripts

---

## 🐧 Distribution Selection

### Quick Mode (Ubuntu only)

Fastest option - tests only Ubuntu:

```bash
./tests/test_xen.zsh --quick
```

### Specific Distribution

Test a specific distribution:

```bash
./tests/test_xen.zsh --distro ubuntu
./tests/test_xen.zsh --distro debian
./tests/test_xen.zsh --distro w11       # Windows 11
```

### Linux Only

Test all Linux distributions (skip slow Windows VMs):

```bash
./tests/test_xen.zsh --linux-only
```

**Saves**: ~10-15 minutes per Windows VM

### Windows Only

Test only Windows distributions:

```bash
./tests/test_xen.zsh --windows-only
```

### All Distributions (Default without --quick)

Tests all supported distributions:
- Linux: ubuntu, debian
- Windows: w11

```bash
./tests/test_xen.zsh
```

---

## 🐛 Development & Debugging Options

### Keep VMs After Testing

Don't destroy VMs when tests complete (for manual debugging):

```bash
./tests/test_xen.zsh --quick --keep-vm
```

**Provides**:
- SSH access to failed VMs
- Manual inspection of installation
- Debugging post-install script issues
- Iterative testing without recreating VMs

**Cleanup**: Manually destroy VMs later:
```bash
# List VMs
xe vm-list name-label='aria-test-*'

# Destroy specific VM
xe vm-shutdown uuid=<UUID> force=true
xe vm-destroy uuid=<UUID>
```

### Custom VM Name Prefix

Use custom VM name prefix (default: `aria-test`):

```bash
./tests/test_xen.zsh --quick --vm-name debug
```

**Use Cases**:
- Multiple test runs in parallel
- Different test scenarios
- Organized VM naming

### Skip Librarian Check

Skip librarian health check for faster iteration:

```bash
./tests/test_xen.zsh --quick --no-librarian
```

**Saves**: ~10-15 seconds per test

**When to Use**:
- Testing VM provisioning only
- Rapid iteration during development
- Focus on installation mechanics

### Custom XCP-NG Host

Use a different XCP-NG host:

```bash
./tests/test_xen.zsh --quick --host my-xen-host.local
```

---

## 💡 Common Usage Patterns

### Fast Smoke Test (2-3 min)
Quick validation after making changes:
```bash
./tests/test_xen.zsh --basic --skip-pi --quick
```

### Test Git Configuration Only (4-5 min)
Validate git-related PI scripts on real VM:
```bash
./tests/test_xen.zsh --enable-pi "git-*" --quick
```

### Test VM Provisioning Without Installation (2-3 min)
Validate cloud-init and VM creation:
```bash
./tests/test_xen.zsh --basic --quick
```

### Debug Failed Installation (keeps VM)
Debug issues by keeping VM accessible:
```bash
./tests/test_xen.zsh --quick --keep-vm --vm-name debug
```

### Test Full Installation Without PI Overhead (3-4 min)
Validate installation mechanics without packages:
```bash
./tests/test_xen.zsh --comprehensive --skip-pi --quick
```

### Test Linux Only (Skip Slow Windows)
Test all Linux distros, skip Windows:
```bash
./tests/test_xen.zsh --linux-only
```

### Full Regression Test (SLOW but Thorough)
Complete validation before releasing:
```bash
./tests/test_xen.zsh --full --linux-only
```

### Test Windows VM Provisioning
Quick Windows VM validation:
```bash
./tests/test_xen.zsh --basic --windows-only
```

---

## 📊 Test Matrix Examples

| Command | VMs | Mode | PI Scripts | Time | Purpose |
|---------|-----|------|------------|------|---------|
| `--basic --quick` | 1 | Basic | N/A | 2-3m | VM provisioning test |
| `--quick` | 1 | Comprehensive | All | 5-7m | Quick validation |
| `--skip-pi --quick` | 1 | Comprehensive | None | 3-4m | Installation mechanics |
| `--enable-pi "git-*" --quick` | 1 | Comprehensive | Git only | 4-5m | Test git configs |
| `--linux-only` | 2 | Comprehensive | All | 10-14m | All Linux distros |
| `--windows-only` | 1 | Comprehensive | N/A | 10-15m | Windows validation |
| `--full --linux-only` | 2 | Full | All | 14-20m | Full regression |

---

## 🔍 What Gets Tested

### Phase 1: VM Creation
- XCP-NG VM provisioned via helper script
- Cloud-init ISO attached (Linux) or Cloudbase-init (Windows)
- VM receives UUID and VDI UUID
- VM boots successfully

### Phase 2: Network & SSH
- VM receives IP address via DHCP
- Guest tools report IP to hypervisor
- SSH service starts and accepts connections
- Authentication works with deployed key

### Phase 3: Prerequisites (Comprehensive Mode)
- Package manager functional (apt, dnf, etc.)
- Essential packages installed (zsh, git, build-essential)
- Prerequisites installed successfully

### Phase 4: Repository & PI Filtering (Comprehensive Mode)
- GitHub repository accessible
- Repository clones with submodules
- PI scripts filtered based on options
- Disabled scripts renamed to .disabled

### Phase 5: Installation (Comprehensive Mode)
- Setup script executes successfully
- All enabled PI scripts run
- Git configuration applied
- Symlinks created

### Phase 6: Librarian Health Check (Comprehensive Mode)
- Librarian executes without errors
- Output scanned for ERROR markers
- Warnings logged but non-fatal
- Installation quality validated

### Phase 7: Verification (Comprehensive Mode)
- System information retrieved
- Git config validated
- Symlink count verified
- Installation results confirmed

### Windows-Specific Testing
- OpenSSH Server installation
- PowerShell access verification
- Windows version detection
- Git repository accessibility check

---

## 🐛 Debugging Failed Tests

### View Live VM

When using `--keep-vm`, the script provides SSH access:

```bash
# After test completes
ssh -i ~/.ssh/aria_xen_key aria@<VM_IP>

# Or access via XCP-NG console
xe console uuid=<VM_UUID>
```

### Manual VM Testing

```bash
# Connect to XCP-NG host
ssh -i ~/.ssh/aria_xen_key root@opt-bck01.bck.intern

# Create test VM manually
cd /root/aria-scripts
./create-vm-with-cloudinit-iso.sh ubuntu

# Get VM IP
xe vm-list name-label='aria-test-*' params=networks

# SSH to VM
ssh -i ~/.ssh/aria_xen_key aria@<IP>

# Test installation manually
git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./bin/setup.zsh --all-modules
./bin/librarian.zsh
```

### Test Specific PI Script in Isolation

```bash
# Test only the script you're debugging
./tests/test_xen.zsh --enable-pi "your-script-name" --quick --keep-vm

# SSH to kept VM and inspect
ssh -i ~/.ssh/aria_xen_key aria@<VM_IP>
cd ~/.config/dotfiles
ls -la post-install/scripts/
cat post-install/scripts/your-script-name.log
```

### Check Librarian Output

```bash
# Run with --keep-vm to access VM
./tests/test_xen.zsh --quick --keep-vm

# SSH to VM and run librarian manually
ssh -i ~/.ssh/aria_xen_key aria@<VM_IP>
cd ~/.config/dotfiles
./bin/librarian.zsh
```

### Windows Debugging

```bash
# Keep Windows VM for debugging
./tests/test_xen.zsh --distro w11 --keep-vm

# SSH to Windows VM
ssh -i ~/.ssh/aria_xen_key aria@<VM_IP>

# Check OpenSSH status
powershell.exe -Command "Get-Service sshd"

# Check cloudbase-init logs
powershell.exe -Command "Get-Content C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\cloudbase-init.log -Tail 50"
```

---

## 📈 Expected Output

### Successful Comprehensive Test

```
╔════════════════════════════════════════════════════════════════════════════╗
║                     XCP-NG VM Testing - Enhanced                           ║
║                  Flexible and comprehensive validation                     ║
╚════════════════════════════════════════════════════════════════════════════╝

═══ Test Configuration ═══
ℹ️  Test mode: comprehensive
ℹ️  XCP-NG Host: opt-bck01.bck.intern
ℹ️  Distributions: 1
   • Ubuntu
ℹ️  Total tests to run: 1

   ⏱️  Estimated time: ~5-7 minutes

═══ Prerequisites Check ═══
✅ SSH key found
✅ XCP-NG host accessible: opt-bck01.bck.intern
✅ Linux helper script ready

╔════════════════════════════════════════════════════════════════════════════╗
║                       XCP-NG VM Test: Ubuntu                               ║
║                     Testing dotfiles installation                          ║
╚════════════════════════════════════════════════════════════════════════════╝

ℹ️  XCP-NG Host: opt-bck01.bck.intern
ℹ️  Distribution: Ubuntu
ℹ️  Test mode: Comprehensive (Full installation)
ℹ️  Post-install scripts: ALL ENABLED

═══ Test Phases ═══
ℹ️  Phase 1/6: Creating VM with cloud-init configuration...
✅ VM created: a1b2c3d4-e5f6-7890-abcd-ef1234567890
   IP address: 192.168.1.100

ℹ️  Phase 2/6: Waiting for VM to boot and cloud-init to complete...
✅ VM is accessible via SSH

ℹ️  Phase 3/6: Installing prerequisites...
✅ Prerequisites installed

ℹ️  Phase 4/6: Cloning repository and configuring PI scripts...
   → Cloning repository
✅ Repository cloned

ℹ️  Phase 5/6: Running dotfiles installation...
   → Running setup
✅ Git repository initialized
✅ Setup script found
✅ Git configuration applied
   → Running librarian health check
✅ Librarian health check passed
   → Complete

✅ Dotfiles installation complete

ℹ️  Phase 6/6: Verifying installation results...
   Distribution: Ubuntu 24.04 LTS
   Git User: Aria
   Git Email: aria@example.com
   Dotfiles: /home/aria/.config/dotfiles
   Symlinks: 45 files
✅ Installation verified

═══ Cleanup ═══
ℹ️  Removing test VM and cloud-init ISO...
✅ Cleanup complete

✅ Test passed: Ubuntu ✨

═══ Test Results Summary ═══
ℹ️  📊 Test Statistics:
   Total tests:  1
   Passed:       1
   Failed:       0

✅ All tests passed! 🎉
```

---

## 🔧 Prerequisites

### Required

**SSH Key**: `~/.ssh/aria_xen_key`
```bash
# Generate key if needed
ssh-keygen -t ed25519 -f ~/.ssh/aria_xen_key -C "aria-xen-automation"

# Deploy to XCP-NG host
~/.config/xen/deploy-aria-key.sh
```

**XCP-NG Host**: Accessible via SSH with `xe` commands
- Default: `opt-bck01.bck.intern`
- Customize with `--host` flag

**Helper Scripts on XCP-NG**:
- Linux: `/root/aria-scripts/create-vm-with-cloudinit-iso.sh`
- Windows: `/root/aria-scripts/create-windows-vm-with-cloudinit-iso.sh`

**Cloud-init Templates**: Hub templates or custom cloud-init capable images

**Windows Requirements** (for Windows testing):
- Windows templates with cloudbase-init
- OpenSSH Server installation via cloudbase-init
- Guest tools for IP reporting

### Verify Prerequisites

```bash
# Check SSH key
ls -la ~/.ssh/aria_xen_key

# Check XCP-NG connectivity
ssh -i ~/.ssh/aria_xen_key root@opt-bck01.bck.intern "xe host-list"

# Check helper scripts
ssh -i ~/.ssh/aria_xen_key root@opt-bck01.bck.intern "ls -la /root/aria-scripts/*.sh"
```

---

## 📝 Help and Options

View all available options:

```bash
./tests/test_xen.zsh --help
```

This shows the complete help screen with all test modes, PI control options, distribution selection, debugging options, and usage examples.

---

## 🎯 CI/CD Integration

### GitHub Actions Example

```yaml
name: XCP-NG VM Tests

on: [push, pull_request]

jobs:
  xen-smoke-test:
    runs-on: self-hosted  # Needs XCP-NG access
    steps:
      - uses: actions/checkout@v3

      - name: Install zsh
        run: sudo apt-get update && sudo apt-get install -y zsh

      - name: Deploy SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ARIA_XEN_KEY }}" > ~/.ssh/aria_xen_key
          chmod 600 ~/.ssh/aria_xen_key

      - name: Quick smoke test
        run: |
          chmod +x tests/test_xen.zsh
          ./tests/test_xen.zsh --basic --skip-pi --quick

  xen-full-test:
    runs-on: self-hosted  # Needs XCP-NG access
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Setup environment
        run: |
          sudo apt-get update && sudo apt-get install -y zsh
          mkdir -p ~/.ssh
          echo "${{ secrets.ARIA_XEN_KEY }}" > ~/.ssh/aria_xen_key
          chmod 600 ~/.ssh/aria_xen_key

      - name: Comprehensive validation
        run: |
          chmod +x tests/test_xen.zsh
          ./tests/test_xen.zsh --comprehensive --linux-only
```

**Note**: XCP-NG tests require self-hosted runners with network access to the XCP-NG host.

---

## 🚧 Test Development

### Adding New Tests

When adding new features to dotfiles, update the test script if needed:

```bash
# Add to comprehensive test validation
# In test_comprehensive_linux() function, phase 6:

local verify_output=$(vm_ssh "$vm_ip" "
    echo 'INFO:Distribution:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')
    # Add your new verification here:
    echo 'INFO:New feature:' \$(test -f ~/.config/new-feature && echo 'Present' || echo 'Missing')
")
```

Test locally:
```bash
./tests/test_xen.zsh --comprehensive --quick --keep-vm
```

---

## 📚 Related Documentation

- [Main README](../README.md) - Repository overview
- [Docker Testing](DOCKER_TESTING.md) - Docker-based testing
- [Testing README](README.md) - General testing guidelines
- [Profiles README](../profiles/README.md) - Profile system
- [Packages README](../packages/README.md) - Package management

---

## 🤝 Contributing

When adding features or fixing bugs:

1. Test your changes with XCP-NG tests:
   ```bash
   ./tests/test_xen.zsh --quick
   ```

2. Use PI filtering for faster iteration:
   ```bash
   ./tests/test_xen.zsh --enable-pi "your-new-script" --quick
   ```

3. Debug with kept VMs:
   ```bash
   ./tests/test_xen.zsh --quick --keep-vm --vm-name dev
   ```

4. Run full test suite before committing:
   ```bash
   ./tests/test_xen.zsh --comprehensive --linux-only
   ```

5. Update this documentation if adding new test modes

---

## 💡 Pro Tips

1. **Use `--skip-pi` during development** - Test VM provisioning and installation mechanics without package overhead

2. **Use `--enable-pi` for targeted testing** - Debug individual PI scripts in realistic VM environment

3. **Use `--keep-vm` for debugging** - SSH into failed VMs to inspect issues manually

4. **Test Linux only during iteration** - Skip slow Windows VMs during development (`--linux-only`)

5. **Use `--basic` for infrastructure changes** - Quick validation of VM creation and cloud-init

6. **Combine options for powerful testing**:
   ```bash
   # Example: Test git configs on real VM, keep it for inspection
   ./tests/test_xen.zsh --enable-pi "git-*" --quick --keep-vm --vm-name git-test
   ```

7. **Clean up kept VMs** - Remember to destroy VMs after debugging:
   ```bash
   ssh -i ~/.ssh/aria_xen_key root@opt-bck01.bck.intern \
     "xe vm-list name-label='aria-test-*' --minimal | xargs -I {} xe vm-destroy uuid={} force=true"
   ```

---

## 🆚 XCP-NG vs Docker Testing

### When to Use XCP-NG Tests

- Testing on real hardware/VMs
- Validating cloud-init configurations
- Windows dotfiles development
- Testing performance-sensitive scripts
- Validating full OS integration

### When to Use Docker Tests

- Fast iteration (containers boot faster)
- Testing multiple Linux distributions quickly
- CI/CD pipelines (easier to set up)
- No hypervisor access available
- Quick smoke tests

### Best Practice

Use both! Docker for fast iteration, XCP-NG for realistic validation:

```bash
# Quick validation with Docker
./tests/test_docker.zsh --quick

# Realistic validation with XCP-NG
./tests/test_xen.zsh --quick

# Full regression: Both platforms
./tests/test_docker.zsh --comprehensive --all-distros
./tests/test_xen.zsh --comprehensive --linux-only
```

---

## 🔄 Migration from Old Script

The old `test_xen_install.zsh` has been archived but remains available:
- Location: `tests/archive/test_xen_install.zsh`
- Functionality: Preserved in new script's `--comprehensive` mode

The new unified script (`test_xen.zsh`) replaces it with enhanced functionality:
- Multiple test modes
- PI script filtering
- Development options
- Better debugging support
- Improved output formatting

---

*Real VMs, real testing, real confidence!* 🚀✨
