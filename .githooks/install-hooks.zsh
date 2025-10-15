#!/usr/bin/env zsh

# ============================================================================
# Git Hooks Installation Script
# ============================================================================
#
# This script installs the custom git hooks from .githooks/ directory
# into the .git/hooks/ directory.
#
# Usage:
#   ./githooks/install-hooks.zsh
#
# Alternatively, configure git to use .githooks directory:
#   git config core.hooksPath .githooks
# ============================================================================

emulate -LR zsh
setopt ERR_EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo "${GREEN}✓${NC} $1"
}

print_error() {
    echo "${RED}✗${NC} $1"
}

print_warning() {
    echo "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BLUE}  $1${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

print_header "Git Hooks Installation"

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ $? -ne 0 ]]; then
    print_error "Not a git repository"
    exit 1
fi

GITHOOKS_DIR="$REPO_ROOT/.githooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Check if .githooks directory exists
if [[ ! -d "$GITHOOKS_DIR" ]]; then
    print_error ".githooks directory not found"
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
if [[ ! -d "$GIT_HOOKS_DIR" ]]; then
    print_info "Creating .git/hooks directory..."
    mkdir -p "$GIT_HOOKS_DIR"
fi

print_info "Installing hooks from .githooks/ to .git/hooks/"
echo ""

# Install each hook
INSTALLED=0
SKIPPED=0

for hook in "$GITHOOKS_DIR"/*; do
    # Skip this install script and README
    if [[ "$(basename "$hook")" == "install-hooks.zsh" ]] || \
       [[ "$(basename "$hook")" == "README.md" ]]; then
        continue
    fi

    # Skip directories
    if [[ -d "$hook" ]]; then
        continue
    fi

    hook_name=$(basename "$hook")
    target="$GIT_HOOKS_DIR/$hook_name"

    # Check if hook already exists
    if [[ -f "$target" ]] || [[ -L "$target" ]]; then
        print_warning "Hook already exists: $hook_name (skipping)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Create symlink
    if ln -s "../../.githooks/$hook_name" "$target" 2>/dev/null; then
        print_success "Installed: $hook_name"
        INSTALLED=$((INSTALLED + 1))
    else
        print_error "Failed to install: $hook_name"
    fi
done

echo ""
print_header "Installation Summary"

echo "Installed: $INSTALLED hook(s)"
echo "Skipped:   $SKIPPED hook(s)"

if [[ $INSTALLED -gt 0 ]]; then
    echo ""
    print_success "Git hooks installed successfully!"
    echo ""
    print_info "The hooks will run automatically before commits"
    print_info "To skip hooks: git commit --no-verify"
fi

echo ""
print_info "Alternative: Configure git to use .githooks directly:"
echo "  ${BLUE}git config core.hooksPath .githooks${NC}"

echo ""
