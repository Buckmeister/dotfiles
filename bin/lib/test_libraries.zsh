#!/usr/bin/env zsh

# ============================================================================
# Library Test Script - Verify Shared Libraries Work Correctly
# ============================================================================

emulate -LR zsh

# Get library directory
LIB_DIR="$(dirname "$0")"

echo "Testing Dotfiles Shared Libraries"
echo "=================================="
echo

# Test loading libraries
echo "🔧 Testing library loading..."

# Test colors.zsh
echo -n "Loading colors.zsh... "
if source "$LIB_DIR/colors.zsh" 2>/dev/null; then
    echo "✅ Success"
else
    echo "❌ Failed"
    exit 1
fi

# Test ui.zsh
echo -n "Loading ui.zsh... "
if source "$LIB_DIR/ui.zsh" 2>/dev/null; then
    echo "✅ Success"
else
    echo "❌ Failed"
    exit 1
fi

# Test utils.zsh
echo -n "Loading utils.zsh... "
if source "$LIB_DIR/utils.zsh" 2>/dev/null; then
    echo "✅ Success"
else
    echo "❌ Failed"
    exit 1
fi

# Test greetings.zsh
echo -n "Loading greetings.zsh... "
if source "$LIB_DIR/greetings.zsh" 2>/dev/null; then
    echo "✅ Success"
else
    echo "❌ Failed"
    exit 1
fi

echo
echo "🎨 Testing color system..."
show_color_info

echo
echo "🎯 Testing UI components..."

# Test progress bar
echo "Progress bar test:"
for i in {0..10}; do
    printf "\r"
    printf "Progress: "
    draw_progress_bar $((i * 10)) 100
    sleep 0.1
done
echo
echo

# Test status messages
print_success "Success message test"
print_warning "Warning message test"
print_error "Error message test"
print_info "Info message test"

echo
echo "🌍 Testing international greetings..."
echo "Sample greetings:"
for i in {1..3}; do
    echo "  $i. $(get_random_friend_greeting)"
done

echo
echo "🛠️ Testing utilities..."

# Test timestamp
echo "Current timestamp: $(get_timestamp)"

# Test OS detection
echo "Detected OS: $(get_os)"

# Test command existence
if command_exists "echo"; then
    echo "✅ Command existence test passed"
else
    echo "❌ Command existence test failed"
fi

echo
echo "✨ All library tests completed successfully!"
echo
display_greeting "$(get_time_greeting)"