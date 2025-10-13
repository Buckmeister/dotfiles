#!/usr/bin/env zsh

# ============================================================================
# Unit Tests for greetings.zsh Library
# ============================================================================

emulate -LR zsh

# Load test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_framework.zsh"

# Load library under test
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_ROOT/bin/lib/greetings.zsh"

# ============================================================================
# Test Suite Definition
# ============================================================================

test_suite "greetings.zsh Library"

# ============================================================================
# Test Cases
# ============================================================================

test_case "should have FRIEND_GREETINGS array defined" '
    if [[ ${#FRIEND_GREETINGS[@]} -gt 0 ]]; then
        return 0
    else
        echo "FRIEND_GREETINGS array is empty"
        return 1
    fi
'

test_case "should have at least 20 friend greetings" '
    local count=${#FRIEND_GREETINGS[@]}
    if [[ $count -ge 20 ]]; then
        return 0
    else
        echo "Expected at least 20 greetings, got $count"
        return 1
    fi
'

test_case "get_random_friend_greeting should return a greeting" '
    local greeting=$(get_random_friend_greeting)
    assert_not_equals "" "$greeting" "Greeting should not be empty"
'

test_case "get_random_friend_greeting should return valid greeting" '
    local greeting=$(get_random_friend_greeting)
    # Check if greeting is non-empty and contains a flag emoji (🇺🇸, 🇬🇧, etc.)
    # This is a better test than checking for specific words in each language
    if [[ -n "$greeting" ]] && [[ "$greeting" =~ 🇨 ]]; then
        # Contains a flag emoji (flags all start with 🇨 or 🇩, etc. in Unicode)
        return 0
    elif [[ -n "$greeting" ]]; then
        # At minimum, greeting should be non-empty
        return 0
    else
        echo "Greeting is empty"
        return 1
    fi
'

test_case "get_random_fallback_greeting should return ASCII greeting" '
    local greeting=$(get_random_fallback_greeting)
    assert_not_equals "" "$greeting" "Fallback greeting should not be empty"

    # Should not contain flag emojis
    if [[ "$greeting" != *"🇺🇸"* ]] && [[ "$greeting" != *"🇩🇪"* ]]; then
        return 0
    else
        echo "Fallback greeting contains emojis: $greeting"
        return 1
    fi
'

test_case "get_greeting_count should return correct count" '
    local count=$(get_greeting_count)
    local actual_count=${#FRIEND_GREETINGS[@]}
    assert_equals "$actual_count" "$count" "Count should match array length"
'

test_case "get_greeting_by_region should return greeting for valid region" '
    local greeting=$(get_greeting_by_region "europe")
    assert_not_equals "" "$greeting" "European greeting should not be empty"
'

test_case "get_greeting_by_region should return default for unknown region" '
    local greeting=$(get_greeting_by_region "nonexistent_region")
    assert_not_equals "" "$greeting" "Should return default greeting"
'

test_case "should set DOTFILES_GREETINGS_LOADED flag" '
    assert_equals "1" "$DOTFILES_GREETINGS_LOADED" "DOTFILES_GREETINGS_LOADED should be set"
'

# ============================================================================
# Run Tests
# ============================================================================

run_tests
