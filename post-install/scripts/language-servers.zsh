#!/usr/bin/env zsh

# ============================================================================
# Language Servers Setup Post-Install Script
# Downloads and installs various language servers (JDT.LS, OmniSharp, etc.)
# ============================================================================

echo "Setting up language servers..."

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
# JDT.LS (Java Language Server)
# ============================================================================

echo "Installing JDT.LS..."

# Try to use our specialized JDT.LS downloader from PATH
if command -v get_jdtls_url >/dev/null 2>&1; then
  echo "Using JDT.LS downloader to fetch latest version..."
  download_url=$(get_jdtls_url -s)

  if [[ $? -eq 0 && -n "$download_url" ]]; then
    echo "✅ Found JDT.LS URL: $download_url"
  else
    echo "⚠️  JDT.LS downloader failed, using version-independent fallback..."
    download_url="https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"
  fi
else
  echo "⚠️  JDT.LS downloader not available in PATH, using version-independent fallback..."
  download_url="https://ftp.fau.de/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz"
fi

# Clean up existing installation
if [[ -d "/usr/local/share/jdt.ls" ]]; then
  case "$DF_OS" in
    macos)
      rm -rf "/usr/local/share/jdt.ls"/*
      ;;
    linux)
      sudo rm -rf "/usr/local/share/jdt.ls"/*
      ;;
  esac
fi

# Download and extract
echo "Downloading JDT.LS from: $download_url"
case "$DF_OS" in
  macos)
    curl -fLo "/usr/local/share/jdt.ls/jdt-language-server.tar.gz" --create-dirs "$download_url"
    tar xzf "/usr/local/share/jdt.ls/jdt-language-server.tar.gz" --directory="/usr/local/share/jdt.ls" --strip-components=1
    ;;
  linux)
    sudo curl -fLo "/usr/local/share/jdt.ls/jdt-language-server.tar.gz" --create-dirs "$download_url"
    sudo tar xzf "/usr/local/share/jdt.ls/jdt-language-server.tar.gz" --directory="/usr/local/share/jdt.ls" --strip-components=1
    ;;
esac

echo "JDT.LS installation completed!"

# ============================================================================
# OmniSharp (C# Language Server)
# ============================================================================

echo "Installing OmniSharp..."
case "$DF_OS" in
  macos)
    [[ -d "/usr/local/share/omnisharp" ]] && rm -rf "/usr/local/share/omnisharp/*"
    curl -fLo "/usr/local/share/omnisharp/omnisharp-osx.tar.gz" --create-dirs \
      "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.37.6/omnisharp-osx.tar.gz"
    tar xzf "/usr/local/share/omnisharp/omnisharp-osx.tar.gz" --directory="/usr/local/share/omnisharp"
    ;;
  linux)
    [[ -d "/usr/local/share/omnisharp" ]] && sudo rm -rf "/usr/local/share/omnisharp/*"
    sudo curl -fLo "/usr/local/share/omnisharp/omnisharp-linux.tar.gz" --create-dirs \
      "https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-linux-x64.tar.gz"
    sudo tar xzf "/usr/local/share/omnisharp/omnisharp-linux.tar.gz" --directory="/usr/local/share/omnisharp"
    ;;
esac

# ============================================================================
# Rust Analyzer (for Linux only, macOS uses brew)
# ============================================================================

if [[ "$DF_OS" == "linux" ]]; then
  echo "Installing rust-analyzer..."
  curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
  chmod +x ~/.local/bin/rust-analyzer
fi

echo "Language servers setup completed successfully!"