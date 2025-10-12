#!/usr/bin/env zsh

# ============================================================================
# Python Package Management
# Using brew, pipx, and proper virtual environments
# ============================================================================

echo "Setting up Python package management..."

# ============================================================================
# CLI Tools via pipx (Isolated Python apps)
# ============================================================================

echo "Installing Python CLI tools via pipx..."

# Powerline (status line tool)
pipx upgrade powerline-status

# Other useful Python CLI tools (add as needed)
# pipx install black          # Code formatter (if not using LSP formatting)
# pipx install flake8         # Linter (if not using LSP)
# pipx install mypy           # Type checker
# pipx install poetry         # Modern Python package manager
# pipx install pre-commit     # Git hooks

# ============================================================================
# HTTPie with JWT Plugin (via pipx for proper plugin support)
# ============================================================================

echo "Setting up HTTPie with JWT authentication plugin..."

# Install HTTPie via pipx (allows proper plugin integration)
if ! pipx list | grep -q "httpie"; then
  echo "Installing httpie via pipx..."
  pipx install httpie --include-deps
else
  echo "httpie already installed via pipx ✓"
fi

# Add JWT authentication plugin to the same environment
if ! pipx list | grep -A 10 "httpie" | grep -q "httpie-jwt-auth"; then
  echo "Adding JWT authentication plugin..."
  pipx inject httpie httpie-jwt-auth
else
  echo "httpie-jwt-auth already injected ✓"
fi

echo "✅ HTTPie with JWT plugin configured!"
echo "   Usage: http --auth-type=jwt ..."

# ============================================================================
# Neovim Python Support (Special handling required)
# ============================================================================

echo "Setting up Neovim Python support..."

# Create a dedicated virtual environment for Neovim
NVIM_VENV="$HOME/.local/nvim-venv"

if [[ ! -d "$NVIM_VENV" ]]; then
  echo "Creating dedicated Neovim Python environment..."
  python3 -m venv "$NVIM_VENV"
fi

# Install pynvim in the dedicated environment
echo "Installing pynvim in dedicated environment..."
"$NVIM_VENV/bin/pip" install --upgrade pip
"$NVIM_VENV/bin/pip" install pynvim

# Create a symlink for Neovim to find
mkdir -p "$HOME/.local/bin"
ln -sf "$NVIM_VENV/bin/python" "$HOME/.local/bin/nvim-python3"

echo "✅ Neovim Python support configured at: $HOME/.local/bin/nvim-python3"

# ============================================================================
# Clean up old user packages (optional)
# ============================================================================

echo "Checking for old user-installed packages..."

# List current user packages that could be moved
OLD_PACKAGES=($(pip list --user --format=freeze | grep -E "^(httpie|httpie-jwt-auth)" | cut -d= -f1))

if [[ ${#OLD_PACKAGES[@]} -gt 0 ]]; then
  echo "Found old user packages that can be replaced:"
  for pkg in "${OLD_PACKAGES[@]}"; do
    echo "  - $pkg (consider removing with: pip uninstall --user $pkg)"
  done
  echo ""
  echo "After installing alternatives, you can clean these up with:"
  echo "  pip uninstall --user ${OLD_PACKAGES[*]}"
fi

echo "Python package setup completed! 🎵"
echo ""
echo "Summary:"
echo "  ✅ CLI tools: pipx (isolated environments)"
echo "  ✅ System tools: brew (better integration)"
echo "  ✅ Neovim: dedicated virtual environment"
echo "  🚫 No more --break-system-packages needed!"