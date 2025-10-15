# Dotfiles Test Suite 🧪

Beautiful, comprehensive testing framework for the dotfiles repository with stunning OneDark-themed output and reusable utilities.

## Overview

The test suite is organized into three main categories:
- **Unit Tests** - Test individual library components
- **Integration Tests** - Test complete workflows and interactions
- **End-to-End Tests** - Test full installation on real systems (Docker, XCP-NG VMs)

## Quick Start

```bash
# Run all tests (unit + integration)
./tests/run_tests.zsh

# Run only unit tests
./tests/run_tests.zsh unit

# Run only integration tests
./tests/run_tests.zsh integration

# Run Docker installation tests
./tests/test_docker_install.zsh --quick

# Run XCP-NG VM installation tests
./tests/test_xen_install.zsh --quick
```

## Architecture

### Shared Libraries

All tests leverage the beautiful shared libraries from `bin/lib/`:

- **`colors.zsh`** - OneDark color scheme, semantic UI colors
- **`ui.zsh`** - Headers, sections, progress bars, status messages
- **`utils.zsh`** - OS detection, directory management, utilities
- **`greetings.zsh`** - Friendly, multilingual messages

### Test Libraries

#### `tests/lib/test_framework.zsh`

Lightweight unit testing framework with assertion functions:

```zsh
source "tests/lib/test_framework.zsh"

test_suite "My Test Suite"

test_case "should do something" '
    assert_equals "expected" "actual"
    assert_true "$condition"
    assert_file_exists "/path/to/file"
'

run_tests
```

**Assertion Functions:**
- `assert_equals` - Values must match
- `assert_not_equals` - Values must differ
- `assert_true` / `assert_false` - Boolean checks
- `assert_contains` / `assert_not_contains` - String matching
- `assert_file_exists` / `assert_file_not_exists` - File checks
- `assert_dir_exists` - Directory checks
- `assert_command_exists` - Command availability
- `assert_exit_code` - Exit code validation

#### `tests/lib/test_helpers.zsh`

High-level utilities for integration and E2E tests:

```zsh
source "tests/lib/test_helpers.zsh"

# Test result tracking
init_test_tracking
track_test_result "Test Name" true
print_test_summary  # Beautiful summary with OneDark colors

# Wait/retry utilities
wait_for_condition "test -f /tmp/ready" 60 2 "Waiting for file" true
wait_for_ssh ~/.ssh/key user host 120 true

# SSH helpers
remote_ssh ~/.ssh/key user host "ls -la"

# Output parsing
some_command | while read line; do
    parse_test_output "$line"  # Handles PROGRESS:, SUCCESS:, FAILED:, INFO:
done

# Phase-based testing
print_test_phase 1 5 "Creating VM"
print_phase_context "This may take a few minutes"

# Cleanup handlers
cleanup() { docker rm -f test-container; }
register_cleanup_handler cleanup

# Prerequisites checking
check_prereq_file ~/.ssh/key "SSH key"
check_prereq_command docker "Docker daemon"
check_prereq_ssh ~/.ssh/key root host "XCP-NG host"
```

## Test Structure

```
tests/
├── lib/
│   ├── test_framework.zsh      # Unit testing framework
│   └── test_helpers.zsh         # Integration/E2E test utilities
│
├── unit/                        # Unit tests for libraries
│   ├── test_colors.zsh
│   ├── test_ui.zsh
│   ├── test_utils.zsh
│   ├── test_greetings.zsh
│   ├── test_validators.zsh
│   └── test_package_managers.zsh
│
├── integration/                 # Integration tests for workflows
│   ├── test_symlinks.zsh
│   ├── test_update_system.zsh
│   ├── test_librarian.zsh
│   ├── test_post_install_scripts.zsh
│   ├── test_help_flags.zsh
│   ├── test_wrappers.zsh
│   ├── test_github_downloaders.zsh
│   ├── test_error_handling.zsh
│   ├── test_setup_workflow.zsh
│   └── test_package_management.zsh
│
├── run_tests.zsh                # Main test runner
├── test_docker_install.zsh      # Docker E2E tests
├── test_xen_install.zsh         # XCP-NG VM E2E tests
│
├── REFACTORING_PLAN.md          # Detailed refactoring documentation
└── README.md                    # This file
```

## Writing Tests

### Unit Tests

Create a file in `tests/unit/` following this pattern:

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load library under test
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_ROOT/bin/lib/your_library.zsh"

# Define test suite
test_suite "Your Library"

# Write test cases
test_case "should do something" '
    assert_equals "expected" "$(your_function)"
'

test_case "should handle errors" '
    assert_false "$(your_function_that_should_fail)"
'

# Run tests
run_tests
```

### Integration Tests

Create a file in `tests/integration/` using the same pattern, plus test helpers:

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"
source "$SCRIPT_DIR/../lib/test_helpers.zsh"  # Add this!

# Load shared libraries
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "${DOTFILES_ROOT}/bin/lib/colors.zsh"
source "${DOTFILES_ROOT}/bin/lib/ui.zsh"

# Write tests using both frameworks
test_suite "Integration Test"

test_case "should work end-to-end" '
    init_test_tracking
    track_test_result "Part 1" true
    track_test_result "Part 2" true

    # Your test logic here

    assert_equals "0" "$TEST_FAILED"
'

run_tests
```

### End-to-End Tests

See `test_docker_install.zsh` or `test_xen_install.zsh` as examples. Key patterns:

```zsh
# Initialize tracking
init_test_tracking

# Run tests
for test_case in "${TEST_CASES[@]}"; do
    if run_my_test "$test_case"; then
        track_test_result "$test_case" true
    else
        track_test_result "$test_case" false
    fi
done

# Print summary
print_test_summary  # Returns 0 if all passed, 1 if any failed
```

## Output Parsing Protocol

The test helpers support a standard output protocol for structured feedback:

```bash
# In your test scripts/containers/VMs:
echo "PROGRESS:Doing something"      # Shown as info with arrow
echo "SUCCESS:Task completed"        # Shown as green success
echo "FAILED:Task failed"            # Shown as red error
echo "INFO:Additional information"   # Shown as gray comment
```

Then parse with:

```zsh
your_command | while IFS= read -r line; do
    parse_test_output "$line"
done
```

## Docker Installation Tests

Tests dotfiles installation on fresh Linux containers:

```bash
# Full test suite (all distros)
./tests/test_docker_install.zsh

# Quick test (Ubuntu only)
./tests/test_docker_install.zsh --quick

# Specific distribution
./tests/test_docker_install.zsh --distro ubuntu:24.04
```

**Supported Distributions:**
- ubuntu:24.04
- ubuntu:22.04
- debian:12
- debian:11

**Test Modes:**
- `dfauto` - Automatic installation (non-interactive)
- `dfsetup` - Interactive installation (with simulated input)

## XCP-NG VM Installation Tests

Tests dotfiles on real VMs (Linux & Windows):

```bash
# Full test suite (all distros)
./tests/test_xen_install.zsh

# Quick test (Ubuntu only)
./tests/test_xen_install.zsh --quick

# Specific distribution
./tests/test_xen_install.zsh --distro ubuntu
./tests/test_xen_install.zsh --distro w11      # Windows 11

# Custom XCP-NG host
./tests/test_xen_install.zsh --host my-xen-host.local
```

**Supported Distributions:**
- **Linux**: ubuntu (24.04), debian (12)
- **Windows**: w11, win10, win2022, win2019

**Prerequisites:**
- SSH access to XCP-NG host
- SSH key: `~/.ssh/aria_xen_key`
- Helper scripts uploaded to XCP-NG host
- Cloud-init templates (Linux) or Windows templates with cloudbase-init

## Design Philosophy

### Consistency

All tests use the same:
- OneDark color scheme from `colors.zsh`
- UI components from `ui.zsh`
- Utility functions from `utils.zsh`
- Friendly greetings from `greetings.zsh`

This creates a **unified, beautiful experience** across all test output.

### Reusability

Common patterns are extracted into `test_helpers.zsh`:
- Test result tracking
- Wait/retry logic
- SSH operations
- Output parsing
- Phase-based testing
- Cleanup handling

This follows the **DRY principle** and makes writing new tests much easier.

### Beauty

Every test output is:
- ✨ Color-coded with OneDark theme
- 📊 Progressively updated with phases
- 🎯 Clear and actionable
- 💙 Friendly and encouraging

## Test Output Example

```
╔════════════════════════════════════════════════════════════════════════════╗
║                         Dotfiles Test Suite Runner                         ║
║                     Execute unit and integration tests                     ║
╚════════════════════════════════════════════════════════════════════════════╝

ℹ️ Running 6 unit test suite(s)...

═══ Running: test_colors ═══

Running Test Suite: colors.zsh Library
══════════════════════════════════════════════════════════════════════════════

  ▸ should define COLOR_RESET ... ✓
  ▸ should define COLOR_BOLD ... ✓
  ▸ should define OneDark primary colors ... ✓
  ▸ should define UI semantic colors ... ✓
  ▸ should set DOTFILES_COLORS_LOADED flag ... ✓
  ▸ should define terminal control sequences ... ✓
  ▸ should prevent multiple loading ... ✓

──────────────────────────────────────────────────────────────────────────────
Test Summary:
  Total:   7
  Passed:  7

✓ All tests PASSED

✅ Suite PASSED: test_colors

═══ Test Suite Summary ═══

ℹ️ 📊 Test Results:
   Total Suites:  6
   Passed:        6

✅ ALL TEST SUITES PASSED ✓ ✓ ✓
```

## Troubleshooting

### Tests Fail to Load Shared Libraries

**Error:** `Error: Could not load shared libraries`

**Solution:** Ensure you're running tests from the dotfiles root or using absolute paths:

```bash
cd ~/.config/dotfiles
./tests/run_tests.zsh
```

### Docker Tests Fail

**Error:** `Docker daemon is not running`

**Solution:** Start Docker Desktop and verify with:

```bash
docker ps
```

### XCP-NG Tests Can't Connect

**Error:** `Cannot connect to XCP-NG host`

**Solution:**
1. Check SSH key exists: `ls -la ~/.ssh/aria_xen_key`
2. Test SSH access: `ssh -i ~/.ssh/aria_xen_key root@host`
3. Verify helper scripts uploaded to `/root/aria-scripts/`

## Contributing

When adding new tests:

1. **Use Shared Libraries** - Import `colors.zsh`, `ui.zsh`, `utils.zsh`
2. **Use Test Helpers** - Leverage `test_helpers.zsh` utilities
3. **Follow Conventions** - Match existing test structure and naming
4. **Beautiful Output** - Use OneDark colors and UI components
5. **Document** - Add comments explaining complex test logic

## References

- **Refactoring Plan**: `tests/REFACTORING_PLAN.md`
- **Shared Libraries**: `bin/lib/*.zsh`
- **XCP-NG Setup**: `~/.config/xen/README.md`
- **XCP-NG Windows**: `~/.config/xen/WINDOWS_TESTING.md`

---

**Created:** 2025-10-15
**Status:** Production Ready ✨
**Maintainer:** Thomas + Aria (Claude Code)
