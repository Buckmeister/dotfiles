# Docker Testing Guide

Comprehensive testing strategy for dotfiles installation validation using Docker containers.

## 📋 Overview

The Docker test suite validates the complete dotfiles installation workflow on fresh Linux containers, testing all recent features including the new profiling and package management systems.

## 🧪 Test Scripts

### 1. Basic Installation Test (`test_docker_install.zsh`)

**Purpose**: Quick validation of web installer functionality
**Duration**: ~2-3 minutes per distribution
**Coverage**:
- Web installer downloads and executes
- Repository clones successfully
- Basic directory structure created
- Git repository initialized

**Usage**:
```bash
cd ~/.config/dotfiles

# Full test suite (all distributions + both modes)
./tests/test_docker_install.zsh

# Quick test (Ubuntu 24.04 + dfauto only)
./tests/test_docker_install.zsh --quick

# Specific distribution
./tests/test_docker_install.zsh --distro debian:12
```

**Tested Distributions**:
- Ubuntu 24.04 LTS
- Ubuntu 22.04 LTS
- Debian 12 (Bookworm)
- Debian 11 (Bullseye)

**Tested Installers**:
- `dfauto` - Automatic, non-interactive installation
- `dfsetup` - Interactive installation (optional)

---

### 2. Comprehensive Validation Test (`test_docker_comprehensive.zsh`)

**Purpose**: Deep validation of all dotfiles features
**Duration**: ~3-5 minutes per distribution
**Coverage**:
- ✅ Web installer functionality
- ✅ Profile manager availability and commands
- ✅ Profile manifests existence (5 manifests)
- ✅ Package management system
- ✅ Wizard availability
- ✅ Librarian execution
- ✅ Script permissions
- ✅ YAML manifest validation

**Usage**:
```bash
cd ~/.config/dotfiles

# Full comprehensive test
./tests/test_docker_comprehensive.zsh

# Quick comprehensive test (Ubuntu 24.04 only)
./tests/test_docker_comprehensive.zsh --quick

# Specific distribution
./tests/test_docker_comprehensive.zsh --distro ubuntu:24.04
```

**What It Tests**:

#### Phase 1: Prerequisites Installation
- curl, git, zsh installation
- Package manager detection

#### Phase 2: Web Installer
- dfauto web installer execution
- Repository cloning with submodules
- Automatic setup with all modules

#### Phase 3: Basic Verification
- Dotfiles directory structure
- Git repository integrity
- Core script availability

#### Phase 4: Profile System Validation
- `profile_manager.zsh` executable
- `--help` flag functionality
- `list` command output
- `show standard` command output
- Profile manifests existence:
  - `profiles/manifests/minimal-packages.yaml`
  - `profiles/manifests/standard-packages.yaml`
  - `profiles/manifests/full-packages.yaml`
  - `profiles/manifests/work-packages.yaml`
  - `profiles/manifests/personal-packages.yaml`

#### Phase 5: Package Management Validation
- Package management scripts presence
- Manifest YAML structure validation
- Package count verification
- Command availability checks

#### Phase 6: System Tools Validation
- `wizard.zsh` executable and help
- `librarian.zsh` executable and output
- `link_dotfiles.zsh` executable

---

## 📊 Test Matrix

| Test Script | Distributions | Installers | Duration | Coverage |
|-------------|---------------|------------|----------|----------|
| `test_docker_install.zsh` | 4 | 2 | ~10-15 min | Basic |
| `test_docker_comprehensive.zsh` | 3 | 1 | ~10-15 min | Complete |

---

## 🚀 Quick Start

### Run All Tests (Recommended)
```bash
cd ~/.config/dotfiles

# Basic + Comprehensive tests
./tests/test_docker_install.zsh --quick
./tests/test_docker_comprehensive.zsh --quick
```

### Fast Validation (1 distribution)
```bash
# Just Ubuntu 24.04 comprehensive test
./tests/test_docker_comprehensive.zsh --quick
```

### Full Test Suite (CI/CD)
```bash
# All distributions, all tests
./tests/test_docker_install.zsh
./tests/test_docker_comprehensive.zsh
```

---

## 🔍 What Each Test Validates

### Web Installer Tests
- ✅ OS detection (Linux, WSL, macOS)
- ✅ Package manager detection (apt, dnf, yum, pacman)
- ✅ Dependency installation (git, zsh)
- ✅ Repository cloning
- ✅ Submodule initialization
- ✅ Setup script execution

### Profile System Tests
- ✅ `profile_manager.zsh` functionality
- ✅ Profile listing and display
- ✅ Manifest file existence
- ✅ YAML parsing capability
- ✅ Package count accuracy

### Package Management Tests
- ✅ `install_from_manifest` script presence
- ✅ `generate_package_manifest` script presence
- ✅ Manifest YAML validation
- ✅ Cross-platform package mappings
- ✅ Priority levels (required/recommended/optional)

### Librarian Tests
- ✅ Execution without errors
- ✅ Configuration management section
- ✅ System health reporting

### Wizard Tests
- ✅ Executable permissions
- ✅ Help flag functionality
- ✅ Manifest generation capability

---

## 🐛 Debugging Failed Tests

### View Live Container Logs
```bash
# Start test in background
./tests/test_docker_comprehensive.zsh --quick &

# Watch logs (container name shown in test output)
docker logs -f dotfiles-comprehensive-test-ubuntu-24-04
```

### Manual Container Testing
```bash
# Start interactive container
docker run -it --rm ubuntu:24.04 bash

# Inside container:
apt-get update && apt-get install -y curl git zsh
curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
cd ~/.config/dotfiles
./bin/profile_manager.zsh list
./bin/librarian.zsh
```

### Check Specific Components
```bash
# After test failure, inspect specific issue
docker run --rm ubuntu:24.04 bash -c "
  apt-get update -qq && apt-get install -y -qq curl git zsh
  curl -fsSL https://buckmeister.github.io/dotfiles/dfauto | sh
  cd ~/.config/dotfiles
  ls -la profiles/manifests/
  ./bin/profile_manager.zsh show standard
"
```

---

## 📈 Expected Output

### Successful Test Output
```
════════════════════════════════════════════════════════════════
🐳 Dotfiles Comprehensive Testing - ubuntu:24.04
════════════════════════════════════════════════════════════════

📋 Phase 1/6: Installing Prerequisites
✅ Prerequisites installed

════════════════════════════════════════════════════════════════
🚀 Phase 2/6: Running Web Installer (dfauto)
════════════════════════════════════════════════════════════════
[Web installer output...]
✅ Repository cloned successfully

════════════════════════════════════════════════════════════════
✅ Phase 3/6: Basic Installation Verification
════════════════════════════════════════════════════════════════
✅ Dotfiles directory exists
✅ Git repository initialized
✅ Setup script found

════════════════════════════════════════════════════════════════
📦 Phase 4/6: Profile System Validation
════════════════════════════════════════════════════════════════
✅ profile_manager.zsh is executable
✅ profile_manager --help works
✅ All profile manifests found (5)

════════════════════════════════════════════════════════════════
📦 Phase 5/6: Package Management Validation
════════════════════════════════════════════════════════════════
✅ Package management scripts present
✅ minimal-packages.yaml: 10 packages
✅ standard-packages.yaml: 25 packages
[...]

════════════════════════════════════════════════════════════════
🔧 Phase 6/6: System Tools Validation
════════════════════════════════════════════════════════════════
✅ wizard.zsh is executable
✅ librarian.zsh is executable

════════════════════════════════════════════════════════════════
🎉 ALL TESTS PASSED
════════════════════════════════════════════════════════════════
```

---

## 🔧 Prerequisites

### Required
- Docker daemon running
- Internet connection (for pulling images and cloning repo)
- Zsh shell (for test scripts)

### Optional
- `tee` command (for logging output)

### Check Docker Status
```bash
docker ps  # Should show running containers or empty list (not error)
```

---

## 📝 Test Development

### Adding New Tests

1. **Identify what to test**:
   - New feature added to dotfiles
   - Edge case or regression

2. **Choose test script**:
   - Basic functionality → `test_docker_install.zsh`
   - New feature validation → `test_docker_comprehensive.zsh`

3. **Add test phase**:
```bash
# In test_comprehensive_installation function
echo '════════════════════════════════════════════════════════════════'
echo '📦 Phase 7/7: New Feature Validation'
echo '════════════════════════════════════════════════════════════════'
echo

if [ -x ./bin/new_feature.zsh ]; then
    echo '✅ new_feature.zsh is executable'
else
    echo '❌ FAILED: new_feature.zsh not found'
    exit 1
fi
```

4. **Test locally**:
```bash
./tests/test_docker_comprehensive.zsh --quick
```

---

## 🎯 CI/CD Integration

### GitHub Actions Example
```yaml
name: Docker Tests

on: [push, pull_request]

jobs:
  docker-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run comprehensive Docker tests
        run: |
          chmod +x tests/*.zsh
          tests/test_docker_comprehensive.zsh
```

### GitLab CI Example
```yaml
docker-tests:
  stage: test
  image: docker:latest
  services:
    - docker:dind
  script:
    - apk add --no-cache zsh
    - cd tests
    - ./test_docker_comprehensive.zsh
```

---

## 📚 Related Documentation

- [Main README](../README.md) - Repository overview
- [Profiles README](../profiles/README.md) - Profile system documentation
- [Packages README](../packages/README.md) - Package management documentation
- [Testing README](README.md) - General testing guidelines

---

## 🤝 Contributing

When adding new features to the dotfiles system, please:

1. Add corresponding tests to `test_docker_comprehensive.zsh`
2. Update this documentation
3. Run the test suite before committing
4. Document any new test requirements

---

## 💡 Tips

- Use `--quick` for rapid iteration during development
- Check container logs with `docker logs -f <container-name>`
- Test on multiple distributions before finalizing
- Keep tests idempotent (can run multiple times)

---

*Docker testing ensures our dotfiles work reliably across different Linux distributions. Test often, ship confidently!* 🐳✨
