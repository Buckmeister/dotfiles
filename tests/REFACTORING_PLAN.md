# Test Suite Refactoring Plan

## Overview

Refactor the test suites to maximize code reuse, leverage our beautiful shared libraries (`bin/lib/`), and extract common testing patterns into reusable utilities.

## Current State Analysis

### Shared Libraries (Perfect! ✨)

Located in `bin/lib/`:
- **colors.zsh** - OneDark color scheme, semantic UI colors, terminal control sequences
- **ui.zsh** - Headers, sections, progress bars, status messages
- **utils.zsh** - OS detection, directory management, common utilities
- **greetings.zsh** - Friendly, multilingual messages

### Tests Using Shared Libraries Well ✅

- ✅ **test_docker_install.zsh** - Perfect use of all shared libraries
- ✅ **test_xen_install.zsh** - Perfect use of all shared libraries
- ✅ **Unit tests** (test_colors.zsh, test_ui.zsh, etc.) - Use test_framework.zsh well

### Tests Needing Refactoring 🔧

1. **run_tests.zsh** (212 lines)
   - ❌ Uses embedded colors (lines 27-33) instead of `colors.zsh`
   - ❌ Doesn't use `ui.zsh` for headers/sections
   - ❌ Duplicates header drawing logic
   - ✅ Has good test organization structure

2. **test_framework.zsh** (345 lines)
   - ❌ Duplicates color definitions (lines 40-47) instead of using `colors.zsh`
   - ✅ Excellent assertion functions (keep these!)
   - ✅ Good test organization pattern
   - 💡 Could use `ui.zsh` for test output formatting

## Common Patterns to Extract

### Pattern 1: Wait/Retry Logic

**Found in:**
- `test_xen_install.zsh:158-171` - `wait_for_vm_ssh()`
- `test_xen_install.zsh:417-427` - Windows VM SSH wait loop

**Should become:**
```zsh
wait_for_condition() {
    local condition_cmd="$1"
    local timeout_seconds="${2:-120}"
    local check_interval="${3:-2}"
    local progress_message="${4:-Waiting...}"

    # Returns 0 on success, 1 on timeout
}
```

### Pattern 2: SSH Helper Functions

**Found in:**
- `test_xen_install.zsh:144-156` - `xen_ssh()`, `vm_ssh()`

**Should become:**
```zsh
remote_ssh() {
    local ssh_key="$1"
    local host="$2"
    local user="$3"
    shift 3
    local command="$@"

    ssh -i "$ssh_key" -o StrictHostKeyChecking=no \
        -o ConnectTimeout=10 -o BatchMode=yes \
        "$user@$host" "$command" 2>&1
}
```

### Pattern 3: Output Parsing with Markers

**Found in:**
- `test_docker_install.zsh:173-203` - PROGRESS:, SUCCESS:, FAILED:, INFO: markers
- `test_xen_install.zsh:296-318` - Same pattern

**Should become:**
```zsh
parse_test_output() {
    local line="$1"

    case "$line" in
        PROGRESS:*)
            local msg="${line#PROGRESS:}"
            print_info "$msg"
            ;;
        SUCCESS:*)
            local msg="${line#SUCCESS:}"
            print_success "$msg"
            ;;
        FAILED:*)
            local msg="${line#FAILED:}"
            print_error "$msg"
            ;;
        INFO:*)
            local msg="${line#INFO:}"
            echo "   ${COLOR_COMMENT}$msg${COLOR_RESET}"
            ;;
    esac
}
```

### Pattern 4: Test Result Tracking

**Found in:**
- `run_tests.zsh:36-38` - Test tracking variables
- `test_docker_install.zsh:244-265` - Test result tracking
- `test_xen_install.zsh:603-636` - Similar pattern

**Should become:**
```zsh
# Tracking variables
typeset -g -i TEST_TOTAL=0
typeset -g -i TEST_PASSED=0
typeset -g -i TEST_FAILED=0
typeset -g -a TEST_FAILED_LIST=()

track_test_result() {
    local test_name="$1"
    local test_passed="$2"  # true/false

    ((TEST_TOTAL++))
    if [[ "$test_passed" = true ]]; then
        ((TEST_PASSED++))
    else
        ((TEST_FAILED++))
        TEST_FAILED_LIST+=("$test_name")
    fi
}

print_test_summary() {
    draw_section_header "Test Results Summary"
    print_info "📊 Test Statistics:"
    echo "   Total tests:  $TEST_TOTAL"
    echo "   ${COLOR_SUCCESS}Passed:       $TEST_PASSED${COLOR_RESET}"
    echo "   ${COLOR_ERROR}Failed:       $TEST_FAILED${COLOR_RESET}"

    if [[ $TEST_FAILED -gt 0 ]]; then
        print_error "Failed tests:"
        for failed in "${TEST_FAILED_LIST[@]}"; do
            echo "   - $failed"
        done
        return 1
    else
        print_success "All tests passed! 🎉"
        print_success "$(get_random_friend_greeting)"
        return 0
    fi
}
```

### Pattern 5: Cleanup Handlers

**Found in:**
- `test_docker_install.zsh:296-304` - Docker cleanup + trap
- `test_xen_install.zsh:667-692` - XEN cleanup + trap

**Should become:**
```zsh
register_cleanup_handler() {
    local cleanup_function="$1"
    trap "$cleanup_function" EXIT INT TERM
}
```

### Pattern 6: Phase-Based Testing

**Found in:**
- `test_docker_install.zsh:164-183` - Phase 1/4, Phase 2/4, etc.
- `test_xen_install.zsh:208-360` - Phase 1/5 through Phase 5/5

**Should become:**
```zsh
print_test_phase() {
    local current_phase="$1"
    local total_phases="$2"
    local phase_description="$3"

    print_info "Phase $current_phase/$total_phases: $phase_description..."
}
```

## New File: tests/lib/test_helpers.zsh

Create a new shared library for common test utilities:

```zsh
#!/usr/bin/env zsh

# ============================================================================
# Test Helpers Library for Dotfiles Testing
# ============================================================================
#
# Reusable utilities for integration and end-to-end tests.
# Complements test_framework.zsh (unit testing) with higher-level helpers.
#
# Usage:
#   source "tests/lib/test_helpers.zsh"
#
# ============================================================================

# Load dependencies
TESTS_LIB_DIR="${0:a:h}"
DOTFILES_ROOT="${TESTS_LIB_DIR:h:h}"

source "${DOTFILES_ROOT}/bin/lib/colors.zsh"
source "${DOTFILES_ROOT}/bin/lib/ui.zsh"
source "${DOTFILES_ROOT}/bin/lib/utils.zsh"

# ============================================================================
# Test Result Tracking
# ============================================================================

typeset -g -i TEST_TOTAL=0
typeset -g -i TEST_PASSED=0
typeset -g -i TEST_FAILED=0
typeset -g -a TEST_FAILED_LIST=()

# ... functions here ...

# ============================================================================
# Wait/Retry Utilities
# ============================================================================

# ... functions here ...

# ============================================================================
# SSH Helpers
# ============================================================================

# ... functions here ...

# ============================================================================
# Output Parsing
# ============================================================================

# ... functions here ...

# ============================================================================
# Phase-Based Testing
# ============================================================================

# ... functions here ...

# ============================================================================
# Cleanup Handlers
# ============================================================================

# ... functions here ...
```

## Refactoring Steps

### Step 1: Create test_helpers.zsh ✅

- [ ] Create `tests/lib/test_helpers.zsh`
- [ ] Implement test result tracking functions
- [ ] Implement wait/retry utilities
- [ ] Implement SSH helper functions
- [ ] Implement output parsing utilities
- [ ] Implement phase-based testing helpers
- [ ] Implement cleanup handler registration

### Step 2: Refactor test_framework.zsh ✅

- [ ] Remove embedded color definitions (lines 40-47)
- [ ] Import `colors.zsh` at the top
- [ ] Replace `TEST_COLOR_*` with standard color variables
- [ ] Use `ui.zsh` functions where appropriate
- [ ] Keep all assertion functions (they're perfect!)
- [ ] Add proper header comments

### Step 3: Refactor run_tests.zsh ✅

- [ ] Remove embedded color definitions (lines 27-33)
- [ ] Import `colors.zsh`, `ui.zsh`, `utils.zsh`
- [ ] Replace manual header drawing with `draw_header()`
- [ ] Replace manual section drawing with `draw_section_header()`
- [ ] Use `print_success()`, `print_error()`, `print_info()`
- [ ] Consider importing `test_helpers.zsh` for summary functions

### Step 4: Extract Patterns from test_docker_install.zsh ✅

- [ ] Extract output parsing to `parse_test_output()` in test_helpers
- [ ] Extract result tracking to test_helpers functions
- [ ] Extract cleanup pattern
- [ ] Update test_docker_install.zsh to use extracted functions
- [ ] Verify tests still pass

### Step 5: Extract Patterns from test_xen_install.zsh ✅

- [ ] Extract `wait_for_vm_ssh()` to generic `wait_for_condition()`
- [ ] Extract SSH helpers to test_helpers
- [ ] Extract result tracking to test_helpers functions
- [ ] Extract cleanup pattern
- [ ] Extract phase printing
- [ ] Update test_xen_install.zsh to use extracted functions
- [ ] Verify tests still pass

### Step 6: Update Unit Tests (If Needed) ✅

- [ ] Check if any unit tests need updates
- [ ] Ensure compatibility with refactored test_framework.zsh
- [ ] Run full test suite: `./tests/run_tests.zsh`

### Step 7: Documentation ✅

- [ ] Update `tests/lib/test_helpers.zsh` with comprehensive comments
- [ ] Update `test_framework.zsh` header comments
- [ ] Create `tests/README.md` documenting the test architecture
- [ ] Add examples of using test_helpers.zsh
- [ ] Update CLAUDE.md with testing information

### Step 8: Testing ✅

- [ ] Run unit tests: `./tests/run_tests.zsh unit`
- [ ] Run integration tests: `./tests/run_tests.zsh integration`
- [ ] Run Docker tests: `./tests/test_docker_install.zsh --quick`
- [ ] Run XEN tests: `./tests/test_xen_install.zsh --quick`
- [ ] Verify all tests pass

## Expected Benefits

### Code Reduction
- **test_framework.zsh**: Remove ~20 lines (color duplication)
- **run_tests.zsh**: Remove ~20 lines (color duplication, manual drawing)
- **test_docker_install.zsh**: Extract ~50 lines to shared utilities
- **test_xen_install.zsh**: Extract ~80 lines to shared utilities
- **Total**: ~170 lines moved to reusable library

### Consistency Improvements
- ✨ All tests use same color scheme (OneDark)
- ✨ All tests use same UI components (headers, sections, messages)
- ✨ All tests use same output parsing pattern
- ✨ All tests use same result tracking
- ✨ All tests use same cleanup patterns

### Maintainability
- 🎯 Single source of truth for test utilities
- 🎯 Easier to add new tests (less boilerplate)
- 🎯 Changes to test patterns update all tests
- 🎯 Follows DRY principle

### Developer Experience
- 💙 Beautiful, consistent output across all tests
- 💙 Easy to understand test flow
- 💙 Reusable patterns for new tests
- 💙 Comprehensive documentation

## Implementation Notes

### Backward Compatibility
- Keep all existing test file APIs stable
- Ensure refactored tests produce identical output
- No breaking changes to test_framework.zsh API

### Testing Strategy
- Run each test type after refactoring
- Verify output is identical (or improved)
- Check exit codes match expectations
- Ensure cleanup handlers work properly

### Code Style
- Follow existing shared library patterns
- Use OneDark color scheme consistently
- Maintain friendly, encouraging tone
- Include comprehensive comments

## Success Criteria

- [ ] All tests pass after refactoring
- [ ] Zero duplicated color definitions
- [ ] All tests use shared libraries
- [ ] Common patterns extracted to test_helpers.zsh
- [ ] Code reduction of ~170 lines
- [ ] Consistent output across all tests
- [ ] Documentation updated
- [ ] CLAUDE.md updated with test architecture

---

**Created:** 2025-10-15
**Status:** Planning Complete - Ready for Implementation
**Priority:** High - Improves codebase quality significantly
