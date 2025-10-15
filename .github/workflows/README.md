# GitHub Actions CI/CD Workflows

This directory contains automated testing and validation workflows for the dotfiles repository.

## Overview

The CI/CD pipeline automatically tests the dotfiles installation, configuration, and scripts on every push and pull request to ensure everything works correctly across platforms.

## Workflows

### `test.yml` - Main CI/CD Pipeline

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**Jobs:**

#### 1. Unit Tests
- **Platform:** Ubuntu Latest
- **Purpose:** Run unit test suite (`tests/run_tests.zsh unit`)
- **Tests:** Individual library components (colors, ui, utils, validators, etc.)
- **Artifacts:** Unit test logs and reports

#### 2. Integration Tests
- **Platform:** Ubuntu Latest
- **Purpose:** Run integration test suite (`tests/run_tests.zsh integration`)
- **Tests:** Complete workflows and script interactions
- **Artifacts:** Integration test logs and reports

#### 3. Docker Installation Tests
- **Platform:** Ubuntu Latest (with Docker)
- **Purpose:** Test dotfiles installation on fresh Linux containers
- **Matrix:**
  - ubuntu:24.04
  - ubuntu:22.04
  - debian:12
- **Tests:** Full installation via web installer (dfauto mode)
- **Artifacts:** Docker test logs per distribution

#### 4. Symlink Validation
- **Platform:** Ubuntu Latest
- **Purpose:** Verify symlink creation works correctly
- **Tests:**
  - Creates symlinks via `bin/link_dotfiles.zsh`
  - Verifies minimum expected symlinks
  - Checks `~/.local/bin` and `~/.config` directories

#### 5. Library Validation
- **Platform:** Ubuntu Latest
- **Purpose:** Verify all shared libraries load correctly
- **Tests:**
  - Loads each library in `bin/lib/*.zsh`
  - Tests UI component functions
  - Ensures no syntax errors in libraries

#### 6. Script Validation
- **Platform:** Ubuntu Latest
- **Purpose:** Verify all scripts are valid and executable
- **Tests:**
  - Checks executable permissions
  - Validates shebang lines
  - Performs syntax checking on all `.zsh` files

#### 7. Documentation Validation
- **Platform:** Ubuntu Latest
- **Purpose:** Verify documentation completeness
- **Tests:**
  - Checks for required documentation files
  - Validates markdown formatting
  - Checks for broken links (basic)
- **Required Documentation:**
  - `README.md`
  - `MANUAL.md`
  - `INSTALL.md`
  - `CLAUDE.md`
  - `bin/lib/README.md`
  - `post-install/README.md`
  - `post-install/ARGUMENT_PARSING.md`
  - `tests/README.md`

#### 8. macOS Syntax Check
- **Platform:** macOS Latest
- **Purpose:** Verify scripts are compatible with macOS zsh
- **Tests:**
  - Syntax checking on macOS zsh
  - Library loading verification
  - Platform-specific compatibility checks

#### 9. Test Summary
- **Platform:** Ubuntu Latest
- **Purpose:** Aggregate and report overall test results
- **Depends on:** All other test jobs
- **Output:** Comprehensive test summary with pass/fail status

---

## Workflow Status

Add this badge to your README.md to display workflow status:

```markdown
![Dotfiles CI/CD](https://github.com/YOUR_USERNAME/dotfiles/workflows/Dotfiles%20CI%2FCD%20Pipeline/badge.svg)
```

---

## Local Testing

Before pushing changes, you can run tests locally to catch issues early:

### Run All Tests

```bash
# Full test suite
./tests/run_tests.zsh

# Unit tests only
./tests/run_tests.zsh unit

# Integration tests only
./tests/run_tests.zsh integration
```

### Docker Tests

```bash
# Quick test (Ubuntu 24.04 only)
./tests/test_docker_install.zsh --quick

# Full test (all distributions)
./tests/test_docker_install.zsh

# Specific distribution
./tests/test_docker_install.zsh --distro ubuntu:24.04
```

### Syntax Checking

```bash
# Check all zsh scripts for syntax errors
for script in bin/*.zsh bin/lib/*.zsh post-install/scripts/*.zsh; do
  zsh -n "$script" && echo "✓ $script" || echo "✗ $script"
done
```

### Symlink Validation

```bash
# Test symlink creation
./bin/link_dotfiles.zsh

# Verify symlinks
ls -la ~/.local/bin | head -20
ls -la ~/.config | head -20
```

---

## Artifacts

Test artifacts are automatically uploaded and retained for 30 days:

- **Unit Test Results:** `unit-test-results`
- **Integration Test Results:** `integration-test-results`
- **Docker Test Results:** `docker-test-results-<distro>`

Access artifacts from the Actions tab in GitHub after workflow completion.

---

## Extending the Workflow

### Adding New Test Jobs

1. Add a new job to `.github/workflows/test.yml`:

```yaml
my-custom-test:
  name: My Custom Test
  runs-on: ubuntu-latest

  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Run custom test
      run: |
        ./my-test-script.sh
```

2. Update the `test-summary` job to include your new job:

```yaml
test-summary:
  needs:
    - unit-tests
    - integration-tests
    - my-custom-test  # Add this
```

### Testing Additional Platforms

Add to the matrix in `docker-install-test`:

```yaml
matrix:
  distro:
    - ubuntu:24.04
    - ubuntu:22.04
    - debian:12
    - fedora:39        # Add new distro
    - arch:latest      # Add new distro
```

---

## Troubleshooting

### Workflow Fails Locally but Passes in CI

**Possible Causes:**
- Different zsh versions
- Different environment variables
- Missing dependencies in local environment

**Solution:**
```bash
# Check zsh version
zsh --version

# Install missing dependencies
sudo apt-get install zsh git curl

# Run tests in clean environment
docker run --rm -it ubuntu:24.04 bash
```

### Workflow Fails in CI but Passes Locally

**Possible Causes:**
- Interactive prompts (use `--yes` or similar flags)
- Missing environment variables
- macOS-specific code running on Linux

**Solution:**
- Add `DEBIAN_FRONTEND=noninteractive` to environment
- Use OS detection: `case "${DF_OS:-$(get_os)}" in ...`
- Check for TTY: `if [ -t 0 ]; then ...`

### Artifact Upload Failures

**Possible Causes:**
- Artifact path doesn't exist
- Permissions issues
- Artifact size exceeds limit

**Solution:**
```yaml
- name: Upload results
  if: always()  # Upload even if tests fail
  uses: actions/upload-artifact@v4
  with:
    name: my-results
    path: |
      tests/**/*.log
      tests/**/*.xml
    if-no-files-found: warn  # Don't fail if no files
```

---

## Best Practices

### 1. Use Matrix Builds for Cross-Platform Testing

```yaml
strategy:
  fail-fast: false  # Continue even if one fails
  matrix:
    os: [ubuntu-latest, macos-latest]
    distro: [ubuntu:24.04, debian:12]
```

### 2. Cache Dependencies

```yaml
- name: Cache brew packages
  uses: actions/cache@v4
  with:
    path: ~/Library/Caches/Homebrew
    key: ${{ runner.os }}-brew-${{ hashFiles('**/Brewfile') }}
```

### 3. Run Jobs in Parallel

Jobs without dependencies run in parallel automatically. Use `needs:` only when necessary:

```yaml
job-a:
  runs-on: ubuntu-latest
  steps: [...]

job-b:
  runs-on: ubuntu-latest
  steps: [...]  # Runs in parallel with job-a

job-c:
  needs: [job-a, job-b]  # Waits for both
  runs-on: ubuntu-latest
  steps: [...]
```

### 4. Use Workflow Dispatch for Manual Testing

```yaml
on:
  workflow_dispatch:
    inputs:
      distro:
        description: 'Distribution to test'
        required: true
        default: 'ubuntu:24.04'
```

---

## Performance

**Typical Workflow Duration:** ~10-15 minutes

| Job | Duration |
|-----|----------|
| Unit Tests | ~2 min |
| Integration Tests | ~3 min |
| Docker Install Tests | ~5-8 min (per distro) |
| Symlink Validation | ~1 min |
| Library Validation | ~1 min |
| Script Validation | ~1 min |
| Documentation Validation | ~1 min |
| macOS Syntax Check | ~2 min |

---

## Security

### Secrets

No secrets are currently required for the workflow. If you add features that need secrets:

```yaml
steps:
  - name: Use secret
    env:
      MY_SECRET: ${{ secrets.MY_SECRET }}
    run: |
      echo "Using secret..."
```

Add secrets via: **Repository Settings → Secrets and variables → Actions**

### Permissions

The workflow uses minimal permissions:

```yaml
permissions:
  contents: read  # Read repository contents
  actions: read   # Read workflow results
```

---

## References

- **GitHub Actions Documentation:** https://docs.github.com/en/actions
- **Workflow Syntax:** https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
- **Test Documentation:** [`../tests/README.md`](../tests/README.md)
- **Action: checkout@v4:** https://github.com/actions/checkout
- **Action: upload-artifact@v4:** https://github.com/actions/upload-artifact

---

**Created:** 2025-10-15
**Status:** Production Ready ✨
**Maintainer:** Thomas + Aria (Claude Code)
