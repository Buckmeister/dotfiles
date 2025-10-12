#!/usr/bin/env zsh

# ============================================================================
# Development Toolchains Setup Post-Install Script
# Installs language toolchains (Haskell, Rust, etc.) with OS detection
# ============================================================================

echo "Setting up development toolchains..."

# Check OS context
[[ -z "$DF_OS" ]] && {
  echo "Warning: DF_OS not set, detecting OS..."
  case "$(uname -s)" in
    Darwin*)  DF_OS="macos" ;;
    Linux*)   DF_OS="linux" ;;
    *)        DF_OS="unknown" ;;
  esac
}

# ============================================================================
# Haskell Toolchain (Stack + GHCup)
# ============================================================================

if ! command -v stack >/dev/null 2>&1; then
  echo "Installing Haskell Stack..."
  curl -sSL https://get.haskellstack.org/ | sh
else
  echo "Haskell Stack already installed"
fi

if ! command -v ghcup >/dev/null 2>&1; then
  echo "Installing GHCup..."
  case "$DF_OS" in
    macos)
      # Install GHCup to /usr/local/share/ghcup for consistency
      [[ -d "/usr/local/share/ghcup" ]] && rm -rf "/usr/local/share/ghcup/*"
      curl -fLo "/usr/local/share/ghcup/ghcup" --create-dirs \
        "https://downloads.haskell.org/~ghcup/x86_64-apple-darwin-ghcup"
      chmod 755 "/usr/local/share/ghcup/ghcup"
      ln -sf "/usr/local/share/ghcup/ghcup" ~/.local/bin/
      ;;
    linux)
      curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
      chmod go-w "$HOME/.ghci" 2>/dev/null || true
      ;;
  esac
else
  echo "GHCup already installed"
fi

# ============================================================================
# Rust Toolchain
# ============================================================================

if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
  echo "Rust toolchain already installed"
fi

# ============================================================================
# Starship Prompt (if not installed via package manager)
# ============================================================================

if ! command -v starship >/dev/null 2>&1; then
  echo "Installing Starship prompt..."
  case "$DF_OS" in
    linux)
      sh -c "$(curl -fsSL https://starship.rs/install.sh)"
      ;;
    *)
      echo "Starship should be installed via package manager on $DF_OS"
      ;;
  esac
else
  echo "Starship already installed"
fi

echo "Toolchains setup completed successfully!"