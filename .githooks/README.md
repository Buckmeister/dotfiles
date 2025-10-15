# Git Hooks for Dotfiles Repository

Automated pre-commit checks to ensure code quality and consistency before commits.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Available Hooks](#available-hooks)
- [Installation Methods](#installation-methods)
- [Pre-Commit Framework](#pre-commit-framework)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Overview

This directory contains git hooks that automatically run checks before you commit changes. The hooks help maintain code quality by:

- **Validating syntax** of all shell scripts
- **Linting** with shellcheck (if available)
- **Checking formatting** with shfmt (if available)
- **Verifying file permissions** on executable scripts
- **Detecting common issues** (missing shebangs, line endings, etc.)

### Two Approaches

This repository supports **two approaches** for git hooks:

1. **Standalone Hook** (`.githooks/pre-commit`) - No dependencies, works out of the box
2. **Pre-Commit Framework** (`.pre-commit-config.yaml`) - Requires pip installation, more features

---

## Quick Start

### Method 1: Standalone Hook (Recommended)

```bash
# Install the standalone pre-commit hook
cd ~/.config/dotfiles
./.githooks/install-hooks.zsh
```

**Or** use git's hooksPath feature:

```bash
git config core.hooksPath .githooks
```

### Method 2: Pre-Commit Framework

```bash
# Install pre-commit framework
pip install pre-commit  # or: brew install pre-commit

# Install the hooks
cd ~/.config/dotfiles
pre-commit install

# (Optional) Run on all files
pre-commit run --all-files
```

---

## Available Hooks

### pre-commit

The main hook that runs before each commit. Performs the following checks:

#### 1. Syntax Validation ✅ **REQUIRED**
- Validates shell script syntax with `zsh -n`, `bash -n`, or `sh -n`
- Checks all staged `.sh`, `.zsh`, and `.bash` files
- **Blocks commit** on syntax errors

#### 2. Shellcheck Linting ⚠️ **OPTIONAL**
- Runs shellcheck on shell scripts (if installed)
- Provides warnings for common issues
- **Non-blocking** - shows warnings but doesn't prevent commit
- Excludes common false positives for zsh scripts

#### 3. Formatting Checks ⚠️ **OPTIONAL**
- Checks formatting with shfmt (if installed)
- Shows which files need reformatting
- **Non-blocking** - shows warnings but doesn't prevent commit

#### 4. File Permissions ✅ **REQUIRED**
- Verifies scripts in `bin/` and `post-install/scripts/` are executable
- **Blocks commit** on permission errors
- Suggests fix: `chmod +x <file>`

#### 5. Common Issues ✅ **REQUIRED**
- Checks for missing shebangs
- Detects CRLF line endings (should be LF)
- Warns about tabs and trailing whitespace
- **Blocks commit** on critical issues

#### 6. Quick Tests 🧪 **DISABLED BY DEFAULT**
- Can optionally run unit tests before commit
- Enable by setting `RUN_TESTS=true` in the hook

---

## Installation Methods

### Method 1: Symlink Installation

Creates symlinks from `.git/hooks/` to `.githooks/`:

```bash
# Automated installation
./.githooks/install-hooks.zsh

# Manual installation
ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
```

**Pros:**
- Simple and straightforward
- No external dependencies
- Works immediately after cloning

**Cons:**
- Symlinks must be created on each clone
- Need to run install script after cloning

### Method 2: Git HooksPath

Configure git to use `.githooks` directory directly:

```bash
# Local repository only
git config core.hooksPath .githooks

# Global (all repositories)
git config --global core.hooksPath ~/.config/dotfiles/.githooks
```

**Pros:**
- No symlinks needed
- Automatic on all clones (if set globally)
- Easy to update hooks

**Cons:**
- Must be configured on each machine
- Global setting affects all repositories

### Method 3: Pre-Commit Framework

Use the pre-commit framework for managed hooks:

```bash
# Install framework
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

**Pros:**
- Automatic updates
- Easy to manage multiple hooks
- Built-in caching
- Large ecosystem of hooks

**Cons:**
- External dependency (Python + pip)
- Slightly slower startup
- More complex configuration

---

## Pre-Commit Framework

If using the pre-commit framework (`.pre-commit-config.yaml`):

### Installation

```bash
# macOS
brew install pre-commit

# Linux/macOS (pip)
pip install pre-commit

# Activate hooks
cd ~/.config/dotfiles
pre-commit install
```

### Usage

```bash
# Automatic: Runs on git commit
git commit -m "Your message"

# Manual: Run on all files
pre-commit run --all-files

# Manual: Run specific hook
pre-commit run shellcheck --all-files

# Update hook versions
pre-commit autoupdate

# Uninstall hooks
pre-commit uninstall
```

### Configured Hooks

The `.pre-commit-config.yaml` includes:

- **General checks** (file size, merge conflicts, symlinks, etc.)
- **Shellcheck** (shell script linting)
- **shfmt** (shell script formatting)
- **Markdownlint** (markdown linting)
- **Custom local hooks** (zsh syntax, permissions, optional tests)

---

## Customization

### Standalone Hook Configuration

Edit `.githooks/pre-commit` and modify variables at the top:

```zsh
# Enable quick tests before commit
RUN_TESTS=true

# Skip shellcheck
SKIP_SHELLCHECK=true

# Skip shfmt formatting checks
SKIP_SHFMT=true

# Enable verbose output
VERBOSE=true
```

### Pre-Commit Framework Configuration

Edit `.pre-commit-config.yaml`:

```yaml
# Disable a specific hook
- id: shellcheck
  # Comment out or remove this hook

# Change hook arguments
- id: shfmt
  args:
    - -i
    - '4'  # Use 4 spaces instead of 2

# Add new hooks
- repo: https://github.com/some/repo
  rev: v1.0.0
  hooks:
    - id: my-hook
```

### Hook-Specific Exclusions

#### Shellcheck Exclusions

The standalone hook excludes:
- `SC1090` - Can't follow non-constant source
- `SC1091` - Not following sourced file
- `SC2034` - Variable appears unused
- `SC2154` - Variable referenced but not assigned

To add more:

```zsh
# In .githooks/pre-commit
shellcheck -s "$shell_type" \
    -e SC1090 \
    -e SC1091 \
    -e SC2034 \
    -e SC2154 \
    -e SC2086 \  # Add your exclusion
    "$file"
```

---

## Skipping Hooks

Sometimes you need to commit without running hooks:

### Skip All Hooks

```bash
git commit --no-verify -m "Your message"
# or
git commit -n -m "Your message"
```

### Skip Specific Hooks (Pre-Commit Framework Only)

```bash
# Skip shellcheck only
SKIP=shellcheck git commit -m "Your message"

# Skip multiple hooks
SKIP=shellcheck,shfmt git commit -m "Your message"
```

### When to Skip

**Appropriate:**
- Emergency hotfixes
- Work-in-progress commits on feature branches
- Committing broken code that will be fixed in next commit
- External dependencies causing false positives

**Not Appropriate:**
- Main/master branch commits
- Pull request final commits
- Release commits

---

## Troubleshooting

### Hook Not Running

**Problem:** Pre-commit hook doesn't execute

**Solutions:**
```bash
# Check if hook exists
ls -la .git/hooks/pre-commit

# Check if hook is executable
chmod +x .git/hooks/pre-commit

# Check git config
git config core.hooksPath

# Reinstall hooks
./.githooks/install-hooks.zsh
```

### Permission Denied Errors

**Problem:** `Permission denied: .githooks/pre-commit`

**Solution:**
```bash
# Make hook executable
chmod +x .githooks/pre-commit

# Check ownership
ls -la .githooks/pre-commit

# Fix if needed
sudo chown $USER:staff .githooks/pre-commit
```

### Shellcheck Not Found

**Problem:** Hook warns "shellcheck not found"

**Solution:**
```bash
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt-get install shellcheck

# Or skip shellcheck checks
SKIP_SHELLCHECK=true git commit -m "Your message"
```

### shfmt Not Found

**Problem:** Hook warns "shfmt not found"

**Solution:**
```bash
# macOS
brew install shfmt

# Linux/macOS (Go)
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Or skip shfmt checks
SKIP_SHFMT=true git commit -m "Your message"
```

### Hook Fails on macOS/Linux Differences

**Problem:** Hooks work on one OS but not another

**Solution:**
- Ensure scripts use portable constructs
- Test on both platforms if possible
- Use `case "${DF_OS:-$(get_os)}" in` for OS-specific code
- Check line endings: `git config core.autocrlf false`

### Pre-Commit Framework Slow

**Problem:** Hooks take a long time to run

**Solutions:**
```bash
# Skip hooks for quick commits
git commit --no-verify

# Run only on changed files (default)
pre-commit run

# Enable caching (pre-commit does this automatically)

# Disable slow hooks in .pre-commit-config.yaml
```

---

## Best Practices

### 1. Commit Often, Push Less

- Make small, frequent commits locally
- Use `--no-verify` for WIP commits if needed
- Clean up history before pushing
- Always run hooks before final push

### 2. Fix Issues, Don't Skip

- Take time to fix issues reported by hooks
- Skipping masks problems that could cause issues later
- Use `--no-verify` sparingly and intentionally

### 3. Keep Hooks Fast

- Don't run full test suite in pre-commit (use CI/CD instead)
- Quick syntax checks are fine
- Heavy linting can be optional
- Consider adding `RUN_TESTS=true` only for important branches

### 4. Document Exceptions

```bash
# Good: Explain why you're skipping
git commit --no-verify -m "WIP: Breaking change, fixing in next commit"

# Bad: No context
git commit --no-verify -m "stuff"
```

### 5. Test Hooks Locally

```bash
# Test the pre-commit hook manually
./.githooks/pre-commit

# Test with pre-commit framework
pre-commit run --all-files

# Test on specific files
pre-commit run --files bin/setup.zsh
```

### 6. Keep Hooks Updated

```bash
# For pre-commit framework
pre-commit autoupdate

# For standalone hooks
git pull origin main
./.githooks/install-hooks.zsh
```

---

## Hook Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Pre-Commit Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Checking staged files...
ℹ Found 3 shell script(s) to check

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Syntax Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All syntax checks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  2. Shellcheck Linting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ Found 1 shellcheck issue(s) (non-blocking)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  3. Formatting Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All formatting checks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  4. File Permissions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All permission checks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  5. Common Issues
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ No common issues found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All pre-commit checks passed!

ℹ Proceeding with commit...
```

---

## Integration with CI/CD

The pre-commit hooks provide **local validation**, while the GitHub Actions workflow provides **comprehensive CI/CD testing**.

### Division of Responsibility

**Pre-Commit Hooks (Local):**
- Quick syntax validation
- Basic linting
- Permission checks
- Catch obvious errors before commit

**GitHub Actions CI/CD (Remote):**
- Full test suite (unit + integration)
- Docker installation tests
- Multi-platform validation
- Comprehensive linting and validation

This two-tier approach ensures:
- Fast local feedback (< 5 seconds)
- Comprehensive remote validation (10-15 minutes)
- Developers aren't blocked by slow tests
- All code is thoroughly tested before merge

---

## Contributing

### Adding New Hooks

1. Create hook file in `.githooks/`:
   ```bash
   touch .githooks/post-commit
   chmod +x .githooks/post-commit
   ```

2. Write hook logic (use existing hooks as template)

3. Test hook:
   ```bash
   ./.githooks/post-commit
   ```

4. Document in this README

5. Add to `.pre-commit-config.yaml` if using framework

### Modifying Existing Hooks

1. Edit `.githooks/pre-commit`
2. Test changes thoroughly
3. Update documentation
4. Consider backward compatibility
5. Update `.pre-commit-config.yaml` if needed

---

## References

- **Git Hooks Documentation:** https://git-scm.com/docs/githooks
- **Pre-Commit Framework:** https://pre-commit.com/
- **Shellcheck:** https://www.shellcheck.net/
- **shfmt:** https://github.com/mvdan/sh
- **GitHub Actions CI/CD:** [`../.github/workflows/README.md`](../.github/workflows/README.md)

---

**Created:** 2025-10-15
**Status:** Production Ready ✨
**Maintainer:** Thomas + Aria (Claude Code)
