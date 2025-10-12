#!/usr/bin/env zsh

# ============================================================================
# Lombok Download Post-Install Script
# Downloads Project Lombok for Java development
# ============================================================================

echo "Setting up Project Lombok..."

# Check OS context
[[ -z "$DF_OS" ]] && {
  echo "Warning: DF_OS not set, detecting OS..."
  case "$(uname -s)" in
    Darwin*)  DF_OS="macos" ;;
    Linux*)   DF_OS="linux" ;;
    *)        DF_OS="unknown" ;;
  esac
}

# Create Lombok directory
if [[ ! -d "/usr/local/share/lombok" ]]; then
  echo "Creating Lombok directory: '/usr/local/share/lombok'"

  case "$DF_OS" in
    macos)
      mkdir -p "/usr/local/share/lombok"
      ;;
    linux)
      sudo mkdir -p "/usr/local/share/lombok"
      ;;
    *)
      echo "Warning: Unknown OS, attempting to create directory..."
      mkdir -p "/usr/local/share/lombok" 2>/dev/null || sudo mkdir -p "/usr/local/share/lombok"
      ;;
  esac
fi

# Download Lombok
echo "Downloading Lombok..."
case "$DF_OS" in
  macos)
    curl https://projectlombok.org/downloads/lombok.jar > /usr/local/share/lombok/lombok.jar
    ;;
  linux)
    curl https://projectlombok.org/downloads/lombok.jar | sudo tee /usr/local/share/lombok/lombok.jar > /dev/null
    ;;
  *)
    echo "Warning: Unknown OS, attempting standard download..."
    curl https://projectlombok.org/downloads/lombok.jar > /usr/local/share/lombok/lombok.jar 2>/dev/null || \
    curl https://projectlombok.org/downloads/lombok.jar | sudo tee /usr/local/share/lombok/lombok.jar > /dev/null
    ;;
esac

echo "Lombok setup completed successfully!"