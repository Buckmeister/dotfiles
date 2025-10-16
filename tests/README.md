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

#### `tests/lib/test_pi_helpers.zsh`

Post-install script testing utilities (400+ lines):

```zsh
source "tests/lib/test_pi_helpers.zsh"

# Create test scripts
create_test_pi_script "/tmp/test.zsh" "echo 'test'"
create_test_pi_scripts "/tmp/scripts" "script1" "script2" "script3"

# Mark scripts as ignored/disabled
mark_script_ignored "/tmp/test.zsh" "Temporarily disabled"
mark_script_disabled "/tmp/test.zsh" "Feature not ready"

# Set up test environment
setup_test_pi_environment "/tmp/test_env"  # Creates enabled/disabled/ignored scripts
cleanup_test_pi_scripts  # Automatic cleanup

# Count and list scripts
count_enabled_scripts "/tmp/scripts"    # Returns: 3
count_disabled_scripts "/tmp/scripts"   # Returns: 2
list_enabled_scripts "/tmp/scripts"     # Lists paths
list_disabled_scripts "/tmp/scripts"    # Lists paths

# Execute enabled scripts only
execute_enabled_scripts "/tmp/scripts"

# Assertions for tests
assert_script_enabled "/tmp/test.zsh"
assert_script_disabled "/tmp/test.zsh"
assert_enabled_count "/tmp/scripts" 5
```

**Purpose:** Comprehensive utilities for testing post-install script filtering (.ignored/.disabled), execution, and counting.

#### `tests/lib/xen_cluster.zsh`

XCP-NG cluster management library (470+ lines):

```zsh
source "tests/lib/xen_cluster.zsh"

# Host availability checking
is_host_available "opt-bck01.bck.intern"  # Returns: true/false

# Get available hosts with priority
get_available_hosts  # Returns array of available hosts sorted by priority

# Select host using strategy (priority, round-robin, random, least-loaded)
select_host "priority"

# Host health monitoring
check_host_health "opt-bck01.bck.intern"

# VM lifecycle management
create_xen_vm "ubuntu-24.04" "dotfiles-test-vm"
start_xen_vm "vm-uuid"
stop_xen_vm "vm-uuid"
destroy_xen_vm "vm-uuid"

# NFS operations
deploy_to_nfs_storage "local-script.zsh" "remote-name.zsh"
verify_nfs_deployment "remote-name.zsh"
```

**Purpose:** Multi-host XCP-NG cluster management with automatic failover, health monitoring, and NFS shared storage support.

### Phase 5: Configuration-Driven Testing

> **✅ Verified October 16, 2025**: Complete end-to-end validation performed
> - ✅ XEN Cluster: All 4 nodes operational, 52 VMs running (13 per node)
> - ✅ Docker Testing: Web installer functional on Ubuntu 24.04
> - ✅ Test Configuration: `test_config.yaml` and `run_suite.zsh` operational
> - ✅ NFS Shared Storage: Accessible from all cluster hosts
> - ✅ Zero bugs found during comprehensive infrastructure testing

The Phase 5 testing infrastructure (implemented October 2025) provides a flexible, modular system for comprehensive testing across multiple platforms.

#### `test_config.yaml` - Centralized Test Configuration

**Location:** `tests/test_config.yaml` (590 lines)

**Purpose:** Single source of truth for all test execution configuration

**Key Sections:**

1. **Global Configuration**
   - Parallel execution (up to 4 concurrent tests)
   - Default timeouts and caching
   - Results directory
   - Cleanup behavior

2. **Test Suites**
   - `smoke` (~2-5 min) - Fast feedback loop, 1 distro, basic components
   - `standard` (~10-15 min) - Multiple distros, core tests, before commits
   - `comprehensive` (~30-45 min) - All distros, all tests, before releases

3. **Test Components**
   - `installation` - Setup, directory structure, prerequisites
   - `symlinks` - Creation, verification, backup handling
   - `config` - OS detection, package managers, shell loading
   - `scripts` - Post-install scripts, librarian, menu TUI
   - `filtering` - .ignored/.disabled script filtering tests
   - `integration` - Full workflows, reinstallation, upgrades

4. **Docker Configuration**
   - 7 supported distros (Ubuntu 20.04/22.04/24.04, Debian 11/12, Fedora 39, Rocky Linux 9)
   - Resource limits (2GB RAM, 2 CPUs)
   - Container reuse and cleanup options

5. **XCP-NG Configuration**
   - 4-host cluster (opt-bck01/02/03, lat-bck04)
   - NFS shared storage (SR UUID: 75fa3703-d020-e865-dd0e-3682b83c35f6)
   - 4 OS templates (Ubuntu 22.04/24.04, Debian 12, Rocky Linux 9)
   - VM resources (2GB RAM, 2 vCPUs)
   - Host selection strategies (priority, round-robin, random, least-loaded)
   - Automatic failover support

6. **Reporting Configuration**
   - JSON export for CI/CD
   - HTML reports
   - JUnit XML for CI systems
   - GitHub Actions integration

**Example Usage:**

```yaml
# Add custom test component
components:
  mycomponent:
    description: "My custom tests"
    tests:
      mytest:
        description: "Test something"
        timeout: 60
        tags: [custom, quick]

# Add to smoke suite
suites:
  smoke:
    components:
      - name: mycomponent
        tests:
          - mytest
```

#### `run_suite.zsh` - Modular Test Runner

**Location:** `tests/run_suite.zsh` (605 lines)

**Purpose:** Orchestrate test execution based on test_config.yaml

**Features:**
- YAML configuration parser
- Suite-based execution (smoke/standard/comprehensive)
- Component filtering
- Tag-based selection
- Docker and XEN test execution
- JSON result export
- Beautiful OneDark-themed output

**Command Examples:**

```bash
# Run test suites
./tests/run_suite.zsh --suite smoke          # Quick tests (2-5 min)
./tests/run_suite.zsh --suite standard       # Standard (10-15 min)
./tests/run_suite.zsh --suite comprehensive  # Full suite (30-45 min)

# Test specific components
./tests/run_suite.zsh --component installation
./tests/run_suite.zsh --component symlinks
./tests/run_suite.zsh --component filtering

# Test specific platforms
./tests/run_suite.zsh --docker ubuntu:24.04
./tests/run_suite.zsh --xen ubuntu-24.04

# Export results for CI/CD
./tests/run_suite.zsh --suite standard --json
./tests/run_suite.zsh --suite comprehensive --json --report
```

**Output:**
- Real-time progress updates
- Test pass/fail tracking
- Duration reporting
- Success rate calculation
- Failed test details
- JSON export: `tests/results/test_results.json`

#### XCP-NG Cluster Testing

**4-Host Cluster Setup:**

| Host | IP | Role | Priority | Tags |
|------|----|----|----------|------|
| opt-bck01.bck.intern | 192.168.188.11 | Primary | 1 (highest) | opt, primary |
| opt-bck02.bck.intern | 192.168.188.12 | Failover | 2 | opt, failover |
| opt-bck03.bck.intern | 192.168.188.13 | Failover | 3 | opt, failover |
| lat-bck04.bck.intern | 192.168.188.19 | Failover | 4 | lat, failover |

**Features:**
- **Multi-Host Failover:** Automatic fallback if primary unavailable
- **Health Monitoring:** 10-second timeout health checks
- **Load Balancing:** Round-robin, random, or least-loaded strategies
- **Shared NFS Storage:** Deploy scripts once, available to all hosts

**NFS Shared Storage:**
- SR UUID: `75fa3703-d020-e865-dd0e-3682b83c35f6`
- Mount path: `/var/run/sr-mount/75fa3703-d020-e865-dd0e-3682b83c35f6/`
- Scripts directory: `.../dotfiles-test-helpers/`
- Deployment tool: `./tests/deploy_xen_helpers.zsh`

**Helper Script Deployment:**

```bash
# Deploy helpers to NFS (all hosts have access)
./tests/deploy_xen_helpers.zsh

# Verify deployment
./tests/deploy_xen_helpers.zsh --verify

# Update existing scripts
./tests/deploy_xen_helpers.zsh --update
```

## Test Structure

```
tests/
├── lib/                                    # Test libraries
│   ├── test_framework.zsh                  # Unit testing framework
│   ├── test_helpers.zsh                    # Integration/E2E test utilities
│   ├── test_pi_helpers.zsh                 # Post-install script testing (Phase 5)
│   └── xen_cluster.zsh                     # XEN cluster management (Phase 5)
│
├── unit/                                   # Unit tests for libraries
│   ├── test_colors.zsh
│   ├── test_ui.zsh
│   ├── test_utils.zsh
│   ├── test_greetings.zsh
│   ├── test_validators.zsh
│   ├── test_package_managers.zsh
│   ├── test_arguments.zsh
│   └── test_edge_cases.zsh
│
├── integration/                            # Integration tests for workflows
│   ├── test_symlinks.zsh
│   ├── test_update_system.zsh
│   ├── test_librarian.zsh
│   ├── test_post_install_scripts.zsh
│   ├── test_post_install_filtering.zsh     # .ignored/.disabled filtering
│   ├── test_help_flags.zsh
│   ├── test_wrappers.zsh
│   ├── test_github_downloaders.zsh
│   ├── test_error_handling.zsh
│   ├── test_setup_workflow.zsh
│   ├── test_package_management.zsh
│   ├── test_menu_tui.zsh                   # TUI menu integration tests
│   ├── test_wizard.zsh                     # Wizard integration tests
│   └── test_profile_manager.zsh            # Profile manager tests
│
├── results/                                # Test results (Phase 5)
│   ├── test_results.json                   # JSON export
│   ├── test_report.html                    # HTML report
│   ├── junit.xml                           # JUnit XML for CI
│   ├── docker-*.log                        # Docker test logs
│   └── xen-*.log                           # XEN test logs
│
├── test_config.yaml                        # Centralized test configuration (Phase 5)
├── run_suite.zsh                           # Modular test runner (Phase 5)
├── run_tests.zsh                           # Main test runner
├── test_docker_install.zsh                 # Docker E2E tests
├── test_xen_install.zsh                    # XCP-NG VM E2E tests
├── deploy_xen_helpers.zsh                  # XEN helper deployment (Phase 5)
│
├── REFACTORING_PLAN.md                     # Detailed refactoring documentation
└── README.md                               # This file
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

## See Also

### User-Facing Documentation

- **[TESTING.md](../TESTING.md)** - Comprehensive testing guide for users (how to run tests, write tests, best practices)
- **[README.md](../README.md)** - Main repository documentation
- **[INSTALL.md](../INSTALL.md)** - Installation guide and troubleshooting
- **[MANUAL.md](../MANUAL.md)** - User manual with keybindings and daily workflows

### Developer Documentation

- **[CLAUDE.md](../CLAUDE.md)** - Project philosophy, architecture, and AI assistant guidance
- **[ACTION_PLAN.md](../ACTION_PLAN.md)** - Project roadmap, Phase 5 testing infrastructure details
- **[tests/REFACTORING_PLAN.md](REFACTORING_PLAN.md)** - Test suite refactoring documentation

### Related Systems

- **[packages/README.md](../packages/README.md)** - Universal package management (tested via manifests)
- **[post-install/README.md](../post-install/README.md)** - Post-install scripts (.ignored/.disabled filtering tested here)
- **[profiles/README.md](../profiles/README.md)** - Configuration profiles (profile application tested)
- **[bin/lib/README.md](../bin/lib/README.md)** - Shared libraries API reference (tested by unit tests)

### Test Infrastructure

- **[test_config.yaml](test_config.yaml)** - Centralized test configuration (Phase 5)
- **[run_suite.zsh](run_suite.zsh)** - Modular test runner (Phase 5)
- **[lib/test_framework.zsh](lib/test_framework.zsh)** - Unit testing framework
- **[lib/test_helpers.zsh](lib/test_helpers.zsh)** - Integration test utilities
- **[lib/test_pi_helpers.zsh](lib/test_pi_helpers.zsh)** - Post-install script testing
- **[lib/xen_cluster.zsh](lib/xen_cluster.zsh)** - XCP-NG cluster management

### External Resources

- **XCP-NG Setup**: `~/.config/xen/README.md` (if exists)
- **XCP-NG Windows Testing**: `~/.config/xen/WINDOWS_TESTING.md` (if exists)

---

**Created:** 2025-10-15
**Status:** Production Ready ✨
**Maintainer:** Thomas + Aria (Claude Code)
