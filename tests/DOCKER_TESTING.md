# Docker Testing Guide

Flexible and comprehensive testing framework for dotfiles installation validation using Docker containers.

## 📋 Overview

The unified Docker test script (`test_docker.zsh`) provides a powerful, flexible testing framework that validates dotfiles installation on fresh Linux containers. It supports multiple test modes, post-install script filtering, and comprehensive feature validation.

## 🚀 Quick Start

```bash
cd ~/.config/dotfiles

# Fast smoke test (30 seconds)
./tests/test_docker.zsh --quick --skip-pi

# Basic installation test
./tests/test_docker.zsh --quick

# Full feature validation
./tests/test_docker.zsh --comprehensive --quick

# Test specific PI script
./tests/test_docker.zsh --enable-pi "git-*" --quick
```

## 🎯 Test Script: `test_docker.zsh`

### Key Features

1. **Multiple Test Modes**: Choose between basic, comprehensive, or full validation
2. **PI Script Filtering**: Control which post-install scripts run during testing
3. **Flexible Distribution Selection**: Test specific distros or all of them
4. **Installer Mode Selection**: Test dfauto, dfsetup, or both
5. **Librarian Health Checks**: Automatic error detection after installation
6. **Beautiful Output**: Progress tracking and detailed test results

---

## 📚 Test Modes

### Basic Mode (Default)

**Purpose**: Quick validation of installation mechanics
**Duration**: ~1-2 minutes per distribution

**Tests**:
- ✅ Web installer downloads and executes
- ✅ Repository clones with submodules
- ✅ Directory structure created correctly
- ✅ Git repository initialized
- ✅ Librarian health check passes (no errors)

**Usage**:
```bash
./tests/test_docker.zsh --basic --quick
```

### Comprehensive Mode

**Purpose**: Deep validation of all dotfiles features
**Duration**: ~2-3 minutes per distribution

**Tests Everything in Basic Mode, Plus**:
- ✅ Profile manager functionality
- ✅ Profile manifests (5 files) exist and valid
- ✅ Package management scripts present
- ✅ YAML manifest structure validation
- ✅ Wizard availability and help command
- ✅ Librarian executable and functional
- ✅ Script permissions correct

**Usage**:
```bash
./tests/test_docker.zsh --comprehensive --quick
```

### Full Mode

**Purpose**: Maximum coverage - runs both basic AND comprehensive tests
**Duration**: ~3-5 minutes per distribution

**Usage**:
```bash
./tests/test_docker.zsh --full --quick
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
./tests/test_docker.zsh --skip-pi --quick
```

**Use Cases**:
- Testing symlink creation
- Validating directory structure
- Testing profile system without packages
- Quick smoke tests after making changes

### Disable Specific PI Scripts

Disable scripts matching a glob pattern:

```bash
# Disable all package installation scripts
./tests/test_docker.zsh --disable-pi "*packages*" --quick

# Disable language servers
./tests/test_docker.zsh --disable-pi "language-servers" --quick

# Disable cargo-related scripts
./tests/test_docker.zsh --disable-pi "cargo-*" --quick
```

### Enable Only Specific PI Scripts

Enable ONLY scripts matching a pattern (all others disabled):

```bash
# Test only git configuration
./tests/test_docker.zsh --enable-pi "git-*" --quick

# Test only cargo packages
./tests/test_docker.zsh --enable-pi "cargo-packages" --quick

# Test only ruby-related scripts
./tests/test_docker.zsh --enable-pi "ruby-*" --quick
```

**Use Cases**:
- Validating a specific PI script works correctly
- Testing new PI script in isolation
- Debugging PI script issues
- Faster iteration when developing new scripts

---

## 🐧 Distribution Selection

### Quick Mode (Ubuntu 24.04 only)

Fastest option - tests only the latest Ubuntu LTS:

```bash
./tests/test_docker.zsh --quick
```

### Specific Distribution

Test a specific Linux distribution:

```bash
./tests/test_docker.zsh --distro ubuntu:24.04
./tests/test_docker.zsh --distro debian:12
./tests/test_docker.zsh --distro ubuntu:22.04
```

### All Distributions (Default)

Tests all supported distributions:
- Ubuntu 24.04 LTS
- Ubuntu 22.04 LTS
- Debian 12 (Bookworm)
- Debian 11 (Bullseye)

```bash
./tests/test_docker.zsh --all-distros
```

---

## 🔧 Installer Mode Selection

### Automatic Installer (Default)

Tests the non-interactive `dfauto` installer:

```bash
./tests/test_docker.zsh --dfauto
```

### Interactive Installer

Tests the interactive `dfsetup` installer (automated with simulated inputs):

```bash
./tests/test_docker.zsh --dfsetup --quick
```

### Both Installers

Tests both dfauto AND dfsetup:

```bash
./tests/test_docker.zsh --both-modes --quick
```

---

## 💡 Common Usage Patterns

### Fast Smoke Test (30 seconds)
Quick validation after making changes:
```bash
./tests/test_docker.zsh --skip-pi --basic --quick
```

### Test Git Configuration Only
Validate git-related PI scripts work:
```bash
./tests/test_docker.zsh --enable-pi "git-*" --quick
```

### Test Profile System (No PI Scripts)
Validate profile manager without package installations:
```bash
./tests/test_docker.zsh --comprehensive --skip-pi --quick
```

### Test Cargo Packages on Debian
Validate Rust package installation on Debian:
```bash
./tests/test_docker.zsh --enable-pi "cargo-*" --distro debian:12
```

### Full Regression Test (Slow but Thorough)
Complete validation before releasing:
```bash
./tests/test_docker.zsh --full --both-modes --all-distros
```

### Test Interactive Installer
Validate dfsetup works without PI overhead:
```bash
./tests/test_docker.zsh --dfsetup --skip-pi --quick
```

### Test All Distros Without Packages
Validate installation mechanics across all distributions:
```bash
./tests/test_docker.zsh --skip-pi --all-distros
```

---

## 📊 Test Matrix Examples

| Command | Distributions | Installers | PI Scripts | Time | Purpose |
|---------|--------------|------------|------------|------|---------|
| `--quick --skip-pi` | 1 | 1 | None | 30s | Smoke test |
| `--quick` | 1 | 1 | All | 2m | Quick validation |
| `--comprehensive --quick` | 1 | 1 | All | 3m | Feature validation |
| `--enable-pi "git-*" --quick` | 1 | 1 | Git only | 1m | Test git configs |
| `--all-distros --skip-pi` | 4 | 1 | None | 2m | Multi-distro check |
| `--full --both-modes --all-distros` | 4 | 2 | All | 40m | Full regression |

---

## 🔍 What Gets Tested

### Phase 1: Prerequisites
- Package manager detection (apt, dnf, yum, pacman)
- curl installation
- git installation

### Phase 2: Web Installer
- Installer downloads successfully
- Repository clones from GitHub
- Submodules initialized (nvim config)
- Setup script executes

### Phase 3: Basic Installation Verification
- `~/.config/dotfiles` directory exists
- Git repository properly initialized
- `bin/setup.zsh` present and executable

### Phase 4: Librarian Health Check
- Librarian executes without errors
- Output scanned for ERROR markers
- Warnings logged but non-fatal
- Installation quality validated

### Phase 5: Comprehensive Features (if --comprehensive or --full)
- Profile manager executable and functional
- `--help`, `list`, `show` commands work
- All 5 profile manifests exist:
  - minimal-packages.yaml
  - standard-packages.yaml
  - full-packages.yaml
  - work-packages.yaml
  - personal-packages.yaml
- Package management scripts present
- YAML manifests have valid structure
- Package counts accurate
- Wizard executable with working --help
- link_dotfiles.zsh present

---

## 🐛 Debugging Failed Tests

### View Live Container Logs

The test script shows you how to follow logs in real-time:

```bash
# The script outputs this command:
docker logs -f dotfiles-test-ubuntu-24-04-dfauto
```

### Manual Container Testing

```bash
# Start interactive container
docker run -it --rm ubuntu:24.04 bash

# Inside container, run installation manually:
apt-get update && apt-get install -y curl git
curl -fsSL https://buckmeister.github.io/dfauto | sh
cd ~/.config/dotfiles

# Test specific components:
./bin/profile_manager.zsh list
./bin/librarian.zsh
ls -la profiles/manifests/
```

### Test Specific PI Script in Isolation

```bash
# Test only the script you're debugging
./tests/test_docker.zsh --enable-pi "your-script-name" --quick

# Watch it run in detail:
docker logs -f dotfiles-test-ubuntu-24-04-dfauto
```

### Check Librarian Output

```bash
# Run comprehensive test to see full librarian output
docker run --rm ubuntu:24.04 bash -c "
  apt-get update -qq && apt-get install -y -qq curl git
  curl -fsSL https://buckmeister.github.io/dfauto | sh
  cd ~/.config/dotfiles
  ./bin/librarian.zsh
"
```

---

## 📈 Expected Output

### Successful Basic Test

```
╔════════════════════════════════════════════════════════════════════════════╗
║                         Unified Docker Testing                             ║
║                      Flexible and Comprehensive                            ║
╚════════════════════════════════════════════════════════════════════════════╝

═══ Test Configuration ═══
ℹ️  Test mode: basic
ℹ️  Installer mode: dfauto
ℹ️  Post-install scripts: ALL DISABLED (--skip-pi)
ℹ️  Distributions: 1
   • ubuntu:24.04
ℹ️  Total tests to run: 1

   ⏱️  Estimated time: ~1 minutes

╔════════════════════════════════════════════════════════════════════════════╗
║                      Docker Test: ubuntu:24.04                             ║
║                       Running dfauto installer                             ║
╚════════════════════════════════════════════════════════════════════════════╝

ℹ️  Container: dotfiles-test-ubuntu-24-04-dfauto
ℹ️  Installer URL: https://buckmeister.github.io/dfauto
ℹ️  Test mode: basic

   💡 Follow live: docker logs -f dotfiles-test-ubuntu-24-04-dfauto

═══ Running Test Phases ═══
ℹ️  Phase 1/5: Pulling container image...
ℹ️  Phase 2/5: Installing prerequisites...
ℹ️  Phase 3/5: Running web installer...
ℹ️  Phase 4/5: Verifying installation...
✅ Dotfiles directory created
✅ Git repository initialized
✅ Setup script found
ℹ️  Phase 5/5: Running librarian health check...
✅ Librarian health check passed
   → Complete
   Distribution: Ubuntu 24.04.3 LTS
   Install mode: dfauto
   Dotfiles location: ~/.config/dotfiles

✅ Test passed: ubuntu:24.04 with dfauto

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
- Docker daemon running
- Internet connection (for pulling images and cloning repo)
- Zsh shell (for test script)

### Check Docker Status
```bash
docker ps  # Should succeed (even if empty)
```

---

## 📝 Help and Options

View all available options:

```bash
./tests/test_docker.zsh --help
```

This shows the complete help screen with all test modes, PI control options, distribution selection, and usage examples.

---

## 🎯 CI/CD Integration

### GitHub Actions Example

```yaml
name: Docker Tests

on: [push, pull_request]

jobs:
  quick-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Quick smoke test
        run: |
          chmod +x tests/test_docker.zsh
          ./tests/test_docker.zsh --skip-pi --quick

  full-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Comprehensive validation
        run: |
          chmod +x tests/test_docker.zsh
          ./tests/test_docker.zsh --comprehensive --all-distros
```

---

## 🚧 Test Development

### Adding New Tests

When adding new features to dotfiles, update the comprehensive test section in `test_docker.zsh`:

```bash
# In run_comprehensive_tests() function:
echo 'INFO:Testing new feature...'

if [ -x ./bin/new_feature.zsh ]; then
    echo 'SUCCESS:new_feature.zsh is executable'
else
    echo 'FAILED:new_feature.zsh not found'
    exit 1
fi
```

Test locally:
```bash
./tests/test_docker.zsh --comprehensive --quick
```

---

## 📚 Related Documentation

- [Main README](../README.md) - Repository overview
- [Testing README](README.md) - General testing guidelines
- [Profiles README](../profiles/README.md) - Profile system
- [Packages README](../packages/README.md) - Package management

---

## 🤝 Contributing

When adding features or fixing bugs:

1. Test your changes with Docker tests:
   ```bash
   ./tests/test_docker.zsh --quick
   ```

2. Add tests for new features in `test_docker.zsh`

3. Run full test suite before committing:
   ```bash
   ./tests/test_docker.zsh --comprehensive --all-distros
   ```

4. Update this documentation if adding new test modes

---

## 💡 Pro Tips

1. **Use `--skip-pi` during development** - Iterate faster when testing installation mechanics

2. **Use `--enable-pi` to test specific scripts** - Debug individual PI scripts in isolation

3. **Watch container logs** - `docker logs -f <container-name>` shows real-time progress

4. **Test on multiple distros before releasing** - `--all-distros` catches platform-specific issues

5. **Start with `--quick`** - Always run quick tests first before full suite

6. **Combine options for targeted testing**:
   ```bash
   # Example: Test git configs on Debian without other scripts
   ./tests/test_docker.zsh --enable-pi "git-*" --distro debian:12
   ```

---

## 🔄 Migration from Old Scripts

The old test scripts have been archived but remain available:

- `tests/archive/test_docker_install.zsh` - Old basic test (now part of --basic mode)
- `tests/archive/test_docker_comprehensive.zsh` - Old comprehensive test (now --comprehensive mode)

The new unified script (`test_docker.zsh`) replaces both with enhanced functionality and flexibility.

---

*Flexible testing enables rapid iteration. Test smart, ship fast!* 🐳✨
