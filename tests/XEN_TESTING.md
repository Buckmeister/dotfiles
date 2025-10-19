# XEN/XCP-NG Testing Guide

Comprehensive and flexible testing framework for dotfiles installation validation on real XCP-NG virtual machines.

## 📋 Overview

The unified XEN test script (`test_xen.zsh`) provides a powerful, flexible testing framework that validates dotfiles installation on freshly provisioned VMs in an XCP-NG hypervisor environment. It supports multiple test modes, post-install script filtering, Windows/Linux testing, and integrated helper script deployment.

**Key Advantages Over Docker Testing:**
- ✅ Tests on real VMs (not containers) - full OS experience
- ✅ Tests actual cloud-init provisioning (production-like)
- ✅ Supports Windows testing via cloudbase-init
- ✅ Multi-host cluster support with automatic failover
- ✅ Integrated NFS helper script deployment

## 🚀 Quick Start

<!-- check_docs:script=./tests/test_xen.zsh -->
```bash
cd ~/.config/dotfiles

# Fast smoke test on Linux (30 seconds)
./tests/test_xen.zsh --basic --quick --skip-pi

# Basic Linux test
./tests/test_xen.zsh --basic --quick

# Windows test (takes longer - ~5-10 min)
./tests/test_xen.zsh --basic --windows-only

# Deploy helper scripts to NFS
./tests/test_xen.zsh --deploy-helpers

# Full validation
./tests/test_xen.zsh --comprehensive --quick
```
<!-- /check_docs -->

## 🎯 Test Script: `test_xen.zsh`

### Key Features

1. **Multiple Test Modes**: Choose between basic, comprehensive, or full validation
2. **PI Script Filtering**: Control which post-install scripts run during testing
3. **Windows & Linux Support**: Test both OS families on real VMs
4. **Integrated Deployment**: Deploy helper scripts to NFS shared storage
5. **Flexible Distribution Selection**: Test specific distros or all of them
6. **Cloud-Init Testing**: Validates actual cloud provisioning workflows
7. **Beautiful Output**: Progress tracking and detailed test results with OneDark theme

---

## 📚 Test Modes

### Basic Mode

**Purpose**: Quick validation of VM provisioning and SSH access
**Duration**: ~2-3 minutes per Linux VM, ~5-10 minutes per Windows VM

**Tests**:
- ✅ VM provisions successfully from template
- ✅ Cloud-init/Cloudbase-init executes correctly
- ✅ SSH access works with deployed key
- ✅ Aria user created automatically
- ✅ Network configuration correct
- ✅ VM accessible via network

**Usage**:
```bash
./tests/test_xen.zsh --basic --quick
```

### Comprehensive Mode (Default)

**Purpose**: Full validation of dotfiles installation on real VM
**Duration**: ~5-7 minutes per Linux VM, ~10-15 minutes per Windows VM

**Tests Everything in Basic Mode, Plus**:
- ✅ Dotfiles repository clones with submodules
- ✅ Setup script executes successfully
- ✅ Symlinks created correctly
- ✅ Librarian health check passes (no errors)
- ✅ Post-install scripts execute (configurable)
- ✅ Shell environment loads correctly
- ✅ Configuration files in place

**Usage**:
```bash
./tests/test_xen.zsh --comprehensive --quick
```

### Full Mode

**Purpose**: Maximum coverage - runs both basic AND comprehensive tests
**Duration**: ~7-10 minutes per Linux VM, ~15-20 minutes per Windows VM

**Usage**:
```bash
./tests/test_xen.zsh --full --quick
```

---

## 🎛️ Post-Install Script Control

One of the most powerful features is the ability to control which post-install scripts run during testing. This enables:
- **Faster iteration** when testing specific features
- **Isolated testing** of individual PI scripts
- **Reduced test time** by skipping slow package installations

### Skip All PI Scripts (Fastest)

Perfect for testing installation mechanics without waiting for package installations:

```bash
./tests/test_xen.zsh --skip-pi --quick
```

**Use Cases**:
- Testing symlink creation
- Validating directory structure
- Testing cloud-init provisioning
- Quick smoke tests after making changes
- VM provisioning verification

### Disable Specific PI Scripts

Disable scripts matching a glob pattern:

```bash
# Disable all package installation scripts
./tests/test_xen.zsh --disable-pi "*packages*" --quick

# Disable language servers
./tests/test_xen.zsh --disable-pi "language-servers" --quick

# Disable cargo-related scripts
./tests/test_xen.zsh --disable-pi "cargo-*" --quick
```

### Enable Only Specific PI Scripts

Enable ONLY scripts matching a pattern (all others disabled):

```bash
# Test only git configuration
./tests/test_xen.zsh --enable-pi "git-*" --quick

# Test only cargo packages
./tests/test_xen.zsh --enable-pi "cargo-packages" --quick

# Test only ruby-related scripts
./tests/test_xen.zsh --enable-pi "ruby-*" --quick
```

**Use Cases**:
- Validating a specific PI script works correctly
- Testing new PI script in isolation
- Debugging PI script issues
- Faster iteration when developing new scripts

---

## 🐧 Distribution Selection

### Quick Mode (Ubuntu only)

Fastest option - tests only Ubuntu (recommended for iteration):

```bash
./tests/test_xen.zsh --quick
```

### Specific Distribution

Test a specific Linux distribution:

```bash
./tests/test_xen.zsh --distro ubuntu
./tests/test_xen.zsh --distro debian
```

### Linux Only

Tests all supported Linux distributions:

```bash
./tests/test_xen.zsh --linux-only
```

**Supported Linux Distributions:**
- Ubuntu (Cloud Images template)
- Debian (Cloud Images template)

### Windows Only

Tests Windows distributions with cloudbase-init:

```bash
./tests/test_xen.zsh --windows-only
```

**Supported Windows Distributions:**
- w11cb (Windows 11 Pro with cloudbase-init pre-installed)

**Note**: Windows testing requires properly sysprepped templates with cloudbase-init. See **[Windows CloudBase-Init Troubleshooting Guide](../docs/WINDOWS_CLOUDBASE_INIT_TROUBLESHOOTING.md)** for setup details.

---

## 🪟 Windows Testing

Windows testing on XCP-NG uses **cloudbase-init** (the Windows equivalent of cloud-init) to automate VM provisioning.

### Windows Test Requirements

1. **✅ Sysprepped Template**: Windows template must be in OOBE state
2. **✅ CloudBase-Init Installed**: Pre-installed in template
3. **✅ Helper Script v2**: Uses `create-windows-vm-with-cloudinit-iso-v2.sh`
4. **✅ OpenStack ISO Format**: ConfigDrive uses `openstack/latest/` structure

### Windows Test Process

```bash
# Basic Windows test (fastest)
./tests/test_xen.zsh --basic --windows-only

# Comprehensive Windows test
./tests/test_xen.zsh --comprehensive --windows-only
```

**What Gets Tested:**
1. VM provisions from w11cb template
2. CloudBase-Init detects ConfigDrive ISO
3. Aria user created automatically
4. OpenSSH Server installs and starts
5. Network profile set to Private (SSH accessible)
6. SSH key deployed correctly
7. SSH access works without password

### Windows Test Phases

**Phase 1: VM Creation**
- Provisions Windows VM from template
- Attaches cloudbase-init ISO (OpenStack format)
- Waits for Windows boot and cloudbase-init completion
- Duration: ~5-10 minutes (Windows boot time)

**Phase 2: SSH Connection**
- Waits for OpenSSH Server to start
- Tests SSH key authentication
- Verifies aria user access
- Duration: ~1-2 minutes

**Phase 3: CloudBase-Init Verification**
- Checks cloudbase-init service present
- Verifies plugin execution in logs
- Confirms ConfigDrive detection
- Validates aria user creation
- Duration: ~30 seconds

### Troubleshooting Windows Tests

If Windows tests fail, consult the comprehensive troubleshooting guide:

**📚 [Windows CloudBase-Init Troubleshooting Guide](../docs/WINDOWS_CLOUDBASE_INIT_TROUBLESHOOTING.md)**

**Common Issues:**
- ISO volume label must be `config-2` (not `CIDATA`)
- Template must be sysprepped (OOBE state)
- Network profile must be Private (for SSH access)
- ISO structure must be OpenStack format (`openstack/latest/`)

---

## 📦 Helper Script Deployment

The test script includes integrated helper script deployment to NFS shared storage, making scripts accessible from all cluster hosts automatically.

### Deployment Commands

```bash
# Deploy all helper scripts to NFS
./tests/test_xen.zsh --deploy-helpers

# List scripts on NFS share
./tests/test_xen.zsh --list-helpers

# Verify NFS access across all hosts
./tests/test_xen.zsh --verify-helpers

# Migrate existing scripts from /root/aria-scripts
./tests/test_xen.zsh --migrate-helpers

# Show cluster status
./tests/test_xen.zsh --cluster-status
```

### Helper Scripts Deployed

**Linux VM Provisioning:**
- `create-vm-with-cloudinit-iso.sh` - Provisions Linux VMs with cloud-init

**Windows VM Provisioning:**
- `create-windows-vm-with-cloudinit-iso-v2.sh` - Provisions Windows VMs with cloudbase-init
- Includes all fixes for cloudbase-init issues

**Management Scripts:**
- `cleanup-test-vms.sh` - Cleans up test VMs
- `list-test-vms.sh` - Lists current test VMs

### NFS Shared Storage

**Location:** `/run/sr-mount/75fa3703-d020-e865-dd0e-3682b83c35f6/aria-scripts/`
**SR:** xenstore1 (NFS shared storage)
**Benefits:**
- Single source of truth for helper scripts
- All XCP-NG hosts access same scripts
- Automatic shared/local failover
- No per-host script management

### Deployment Workflow

1. **Deploy scripts** to NFS shared storage:
   ```bash
   ./tests/test_xen.zsh --deploy-helpers
   ```

2. **Verify** all hosts can access:
   ```bash
   ./tests/test_xen.zsh --verify-helpers
   ```

3. **Run tests** - scripts are auto-detected:
   ```bash
   ./tests/test_xen.zsh --basic --quick
   ```

The test script automatically detects helper scripts from NFS shared storage with fallback to local `/root/aria-scripts/` if needed.

---

## 🔧 Development & Debugging

### Keep VM After Testing

Don't destroy VMs after testing (for manual inspection):

```bash
./tests/test_xen.zsh --quick --keep-vm
```

**Use Cases:**
- Debugging failed tests
- Inspecting VM state manually
- Testing manual fixes
- Examining log files

**Cleanup:**
```bash
# List kept VMs
xe vm-list name-label=aria-test-*

# Manually destroy when done
xe vm-shutdown uuid=<UUID> force=true
xe vm-destroy uuid=<UUID>
```

### Custom VM Name Prefix

Use custom VM name for parallel testing or debugging:

```bash
./tests/test_xen.zsh --quick --vm-name debug
./tests/test_xen.zsh --quick --vm-name test2
```

**Benefits:**
- Run multiple tests in parallel
- Easier identification in XCP-NG
- Keep different test iterations

### Skip Librarian Check

Skip librarian health check for faster iteration:

```bash
./tests/test_xen.zsh --quick --no-librarian
```

**Use When:**
- Testing installation mechanics only
- Rapid iteration on setup script
- Known librarian issues to investigate separately

### Specific Host Selection

Use a specific XCP-NG host (default: opt-bck01.bck.intern):

```bash
./tests/test_xen.zsh --quick --host opt-bck02.bck.intern
```

**Available Hosts:**
- opt-bck01.bck.intern (192.168.188.11) - Primary
- opt-bck02.bck.intern (192.168.188.12) - Failover
- opt-bck03.bck.intern (192.168.188.13) - Failover
- lat-bck04.bck.intern (192.168.188.19) - Failover

---

## 💡 Examples

### Development Workflows

```bash
# Fast iteration on setup script (30 seconds)
./tests/test_xen.zsh --basic --quick --skip-pi

# Test git configuration only (real VM)
./tests/test_xen.zsh --enable-pi "git-*" --quick

# Debug failed test (keep VM for inspection)
./tests/test_xen.zsh --quick --keep-vm --vm-name debug

# Test without PI overhead
./tests/test_xen.zsh --comprehensive --skip-pi --quick

# Test specific PI script in isolation
./tests/test_xen.zsh --enable-pi "cargo-packages" --distro ubuntu
```

### Deployment Workflows

```bash
# Initial deployment to cluster
./tests/test_xen.zsh --deploy-helpers

# Verify deployment across all hosts
./tests/test_xen.zsh --verify-helpers

# Check what's deployed
./tests/test_xen.zsh --list-helpers

# Migrate from old location
./tests/test_xen.zsh --migrate-helpers
```

### Windows Testing Workflows

```bash
# Basic Windows test
./tests/test_xen.zsh --basic --windows-only

# Comprehensive Windows validation
./tests/test_xen.zsh --comprehensive --windows-only

# Windows + Linux full regression
./tests/test_xen.zsh --full
```

### Full Regression Testing

```bash
# Test all Linux distros thoroughly
./tests/test_xen.zsh --full --linux-only

# Test everything (SLOW but comprehensive)
./tests/test_xen.zsh --full

# All distros, basic mode only (faster)
./tests/test_xen.zsh --basic --linux-only
```

---

## 🏗️ Test Infrastructure

### XCP-NG Cluster

**Primary Host:** opt-bck01.bck.intern (192.168.188.11)
**Failover Hosts:**
- opt-bck02.bck.intern (192.168.188.12)
- opt-bck03.bck.intern (192.168.188.13)
- lat-bck04.bck.intern (192.168.188.19)

### Storage Repositories

**ISO Storage (isostore1):**
- UUID: 8521cd2e-af19-987e-966b-e68e4435f475
- Type: iso
- Purpose: Cloud-init/cloudbase-init ISO storage

**NFS Shared Storage (xenstore1):**
- UUID: 75fa3703-d020-e865-dd0e-3682b83c35f6
- Type: nfs
- Purpose: Helper scripts and shared data
- Mount: `/run/sr-mount/75fa3703-d020-e865-dd0e-3682b83c35f6/`

### Templates Required

**Linux Templates:**
- Ubuntu (Cloud Images from cloud-init Hub)
- Debian (Cloud Images from cloud-init Hub)

**Windows Templates:**
- w11cb (Windows 11 Pro, sysprepped, cloudbase-init installed)

### SSH Access

**SSH Key:** `~/.ssh/aria_xen_key`
**Deployment:** Must be deployed to XCP-NG hosts before testing
**User:** `root` on XCP-NG, `aria` on provisioned VMs

---

## 🔍 Troubleshooting

### Test Failures

**Linux VM Provisioning Fails:**
1. Check template availability: `xe template-list name-label=~Cloud`
2. Verify network configuration on host
3. Check helper script exists and is executable
4. Review cloud-init logs in VM: `/var/log/cloud-init.log`

**Windows VM Provisioning Fails:**
1. Verify template is properly sysprepped (OOBE state)
2. Check cloudbase-init installed in template
3. Verify helper script v2 deployed
4. See [Windows CloudBase-Init Troubleshooting Guide](../docs/WINDOWS_CLOUDBASE_INIT_TROUBLESHOOTING.md)

**SSH Timeout:**
1. Check VM has IP address: `xe vm-list name-label=aria-test-* params=networks`
2. Verify SSH key deployed correctly
3. For Windows: Check network profile (must be Private, not Public)
4. Check OpenSSH service running (Windows)

### Helper Script Issues

**Scripts Not Found:**
```bash
# Check NFS mount
xe sr-list uuid=75fa3703-d020-e865-dd0e-3682b83c35f6

# Verify scripts exist
ssh root@opt-bck01.bck.intern "ls -la /run/sr-mount/75fa3703-d020-e865-dd0e-3682b83c35f6/aria-scripts/"

# Deploy if missing
./tests/test_xen.zsh --deploy-helpers
```

**NFS Access Issues:**
```bash
# Verify NFS access
./tests/test_xen.zsh --verify-helpers

# Check SR mount on host
ssh root@opt-bck01.bck.intern "mount | grep 75fa3703"
```

### Common Issues

**"SSH key not found":**
- Deploy SSH key to XCP-NG host first
- Ensure `~/.ssh/aria_xen_key` exists and has correct permissions

**"Cannot connect to XCP-NG host":**
- Verify host is reachable: `ping opt-bck01.bck.intern`
- Check SSH key is deployed
- Verify you have permissions to run `xe` commands

**"No available hosts found":**
- Initialize cluster: Import `tests/lib/xen_cluster.zsh`
- Check network connectivity to all hosts
- Verify SSH access to cluster hosts

---

## 📊 Performance

### Test Duration Estimates

**Basic Mode:**
- Linux VM: ~2-3 minutes
- Windows VM: ~5-10 minutes (Windows boot time)

**Comprehensive Mode:**
- Linux VM: ~5-7 minutes
- Windows VM: ~10-15 minutes

**Full Mode:**
- Linux VM: ~7-10 minutes
- Windows VM: ~15-20 minutes

**With `--skip-pi`:**
- Reduces test time by 40-60%
- Linux: ~30-60 seconds (basic)
- Windows: ~5-7 minutes (basic)

### Optimization Tips

1. **Use `--skip-pi`** for testing installation mechanics
2. **Use `--quick`** to test only Ubuntu
3. **Use `--basic`** when you don't need librarian validation
4. **Use `--enable-pi "specific-*"`** to test one script at a time
5. **Use `--linux-only`** to skip slow Windows VMs during iteration

---

## 🚦 Best Practices

### Pre-Test Checklist

- [ ] SSH key deployed to XCP-NG host
- [ ] Helper scripts deployed to NFS (`--deploy-helpers`)
- [ ] Templates available in XCP-NG
- [ ] Sufficient storage in SR
- [ ] Network connectivity verified

### During Development

1. Start with `--basic --quick --skip-pi` (fastest feedback)
2. Add specific PI scripts with `--enable-pi` as you develop
3. Test comprehensive mode before committing
4. Use `--keep-vm` when debugging failures
5. Clean up test VMs regularly

### Before Release

1. Run full test suite: `--full --linux-only`
2. Test Windows if applicable: `--full --windows-only`
3. Verify helper scripts deployed: `--verify-helpers`
4. Check test VMs cleaned up properly
5. Document any new requirements

---

## 📚 Related Documentation

- **[Docker Testing Guide](DOCKER_TESTING.md)** - Container-based testing
- **[Windows CloudBase-Init Troubleshooting](../docs/WINDOWS_CLOUDBASE_INIT_TROUBLESHOOTING.md)** - Windows VM troubleshooting
- **[WSL Guide](../docs/WSL.md)** - Windows Subsystem for Linux support
- **[Test Framework](lib/test_framework.zsh)** - Testing library API

---

**Happy Testing!** 🎉

For issues or questions about XCP-NG testing, consult the troubleshooting guides or check the helper script logs on the XCP-NG host.
