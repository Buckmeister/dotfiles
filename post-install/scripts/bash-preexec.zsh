#!/usr/bin/env zsh

# ============================================================================
# Bash PreExec Download Post-Install Script
# Downloads bash-preexec for shell timing functionality
# ============================================================================

echo "Setting up bash-preexec..."

# Download bash-preexec
if [[ ! -f "$HOME/.bash-preexec.sh" ]]; then
  echo "Downloading bash-preexec..."
  curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
else
  echo "bash-preexec already exists"
fi

echo "bash-preexec setup completed successfully!"