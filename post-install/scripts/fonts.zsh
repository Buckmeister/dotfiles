#!/usr/bin/env zsh

# ============================================================================
# Fonts Setup Post-Install Script
# Downloads and installs Nerd Fonts (primarily for Linux)
# ============================================================================

echo "Setting up fonts..."

# Check OS context
[[ -z "$DF_OS" ]] && {
  echo "Warning: DF_OS not set, detecting OS..."
  case "$(uname -s)" in
    Darwin*)  DF_OS="macos" ;;
    Linux*)   DF_OS="linux" ;;
    *)        DF_OS="unknown" ;;
  esac
}

case "$DF_OS" in
  macos)
    echo "Fonts should be installed via Homebrew on macOS (brew install font-*)"
    echo "Skipping manual font installation"
    ;;

  linux)
    echo "Installing Nerd Fonts for Linux..."

    # Create fonts directory
    mkdir -p ~/.local/share/fonts

    # Create temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download and install popular Nerd Fonts
    fonts=(
      "FiraCode.zip"
      "Iosevka.zip"
      "JetBrainsMono.zip"
      "Hack.zip"
      "Meslo.zip"
    )

    for font in "${fonts[@]}"; do
      echo "Downloading $font..."
      wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/$font" 2>/dev/null || {
        echo "Warning: Failed to download $font"
        continue
      }

      echo "Installing $font..."
      unzip -o "$font" -d ~/.local/share/fonts
      rm "$font"
    done

    # Refresh font cache
    echo "Refreshing font cache..."
    fc-cache -f -v

    # Clean up
    cd - >/dev/null
    rm -rf "$temp_dir"
    ;;

  *)
    echo "Unknown OS: $DF_OS. Skipping font installation."
    ;;
esac

echo "Fonts setup completed successfully!"