# Post-Install Script Argument Parsing Standard

This document defines the standardized approach to argument parsing in post-install scripts.

## Table of Contents

- [Current State](#current-state)
- [Standard Pattern](#standard-pattern)
- [When to Add Arguments](#when-to-add-arguments)
- [Reusable Code Snippet](#reusable-code-snippet)
- [Examples](#examples)

---

## Current State

As of 2025-10-15, the post-install script collection includes:

- **15 total scripts**
- **3 scripts with argument parsing** (cargo-packages, npm-global-packages, ruby-gems)
- **12 scripts without arguments** (simple installers that perform one specific task)

### Scripts with Arguments

| Script | Arguments | Purpose |
|--------|-----------|---------|
| `cargo-packages.zsh` | `--update`, `--help` | Install or update Rust packages |
| `npm-global-packages.zsh` | `--update`, `--help` | Install or update npm packages |
| `ruby-gems.zsh` | `--update`, `--help` | Install or update Ruby gems |

### Scripts without Arguments

The following scripts perform single-purpose installation tasks and don't require arguments:

- `bash-preexec.zsh` - Download bash-preexec script
- `fonts.zsh` - Install Nerd Fonts (Linux only)
- `ghcup-packages.zsh` - Install Haskell Language Server
- `git-delta-config.zsh` - Configure Git to use delta
- `git-delta.zsh` - Install git-delta
- `git-settings-general.zsh` - Configure Git global settings
- `language-servers.zsh` - Install JDT.LS, OmniSharp, rust-analyzer
- `lombok.zsh` - Download Project Lombok JAR
- `luarocks-packages.zsh` - Install Lua packages
- `python-packages.zsh` - Setup pipx, HTTPie, Neovim Python
- `toolchains.zsh` - Install Haskell, Rust, Starship
- `vim-setup.zsh` - Install vim-plug and plugins

---

## Standard Pattern

All scripts that accept arguments **MUST** follow this standardized pattern:

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# ... (Load shared libraries section)

# ============================================================================
# Configuration
# ============================================================================

# Define configuration variables here
UPDATE_MODE=false
VERBOSE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --verbose|-v)
            VERBOSE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description of what this script does.

OPTIONS:
  --update       Update existing installations instead of installing new
  --verbose, -v  Show verbose output
  --help, -h     Show this help message

EXAMPLES:
  $(basename "$0")              # Fresh installation
  $(basename "$0") --update     # Update existing installations
  $(basename "$0") --verbose    # Verbose output

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Dependency Declaration
# ============================================================================

# ... (Continue with rest of script)
```

### Key Requirements

1. **Consistent Structure**
   - Place argument parsing section AFTER configuration, BEFORE dependency declaration
   - Use clear section headers with `# ========...========`

2. **Standard Arguments**
   - `--help` or `-h` - Display usage information (REQUIRED for all scripts with arguments)
   - `--update` - Update mode for package manager scripts (OPTIONAL, only when applicable)
   - `--verbose` or `-v` - Verbose output (OPTIONAL)

3. **Help Format**
   - Use heredoc (`cat <<EOF ... EOF`)
   - Include: Usage line, description, OPTIONS section, EXAMPLES section
   - Show both long form (`--help`) and short form (`-h`) where applicable

4. **Error Handling**
   - Use `print_error` for unknown options (requires shared libraries)
   - Suggest `--help` for usage information
   - Exit with status 1 on error

5. **Parsing Pattern**
   - Use `for arg in "$@"` loop (NOT `while getopts`)
   - Use `case` statement for option matching
   - Use `;;` to end each case branch

---

## When to Add Arguments

### ✅ Add Arguments When:

1. **Package Management with Update Mode**
   - Script installs packages that can be updated later
   - Examples: cargo-packages, npm-packages, ruby-gems
   - Required argument: `--update`

2. **Configuration with Multiple Modes**
   - Script can operate in different modes
   - Example: A script that can configure OR reset settings
   - Required arguments: mode-specific flags

3. **Optional Behaviors**
   - Script has optional features users might want to enable/disable
   - Example: verbose output, dry-run mode, skip confirmations

### ❌ Don't Add Arguments When:

1. **Single-Purpose Installers**
   - Script downloads and installs a single component
   - Examples: bash-preexec, lombok, language-servers
   - No arguments needed - script does one thing

2. **Configuration-Only Scripts**
   - Script reads from config files and applies settings
   - Example: git-settings-general
   - Configuration changes go in `config/*.env` files, not arguments

3. **Idempotent Installers**
   - Script checks if already installed and skips if present
   - No need for `--update` or `--force` flags
   - Examples: fonts, vim-setup, toolchains

### 🤔 Consider Adding `--help` When:

Even scripts without other arguments might benefit from `--help` if:
- The installation process is complex
- There are prerequisites users should know about
- The script has multiple phases that might be unclear
- Users might want to understand what the script does before running it

**Current recommendation:** Keep simple installers argument-free for now. Users can read the script header comments or use `head -20 script.zsh` to understand what it does.

---

## Reusable Code Snippet

### Basic Argument Parsing (--help only)

```zsh
# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            cat <<EOF
Usage: $(basename "$0")

[Description of what this script does]

Run this script without arguments to perform the installation.

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "This script does not accept arguments. Use --help for information."
            exit 1
            ;;
    esac
done
```

### Package Manager Pattern (--update + --help)

```zsh
# ============================================================================
# Configuration
# ============================================================================

PACKAGE_LIST="$CONFIG_DIR/packages/your-packages.list"
UPDATE_MODE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

[Description of what this script installs]

OPTIONS:
  --update    Update installed packages instead of installing new ones
  --help, -h  Show this help message

EXAMPLES:
  $(basename "$0")           # Install packages from list
  $(basename "$0") --update  # Update all installed packages

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "Your Package Manager" "Updating packages"
    # ... update logic ...
else
    draw_header "Your Package Manager" "Installing packages"
    # ... install logic ...
fi
```

### Extended Pattern (Multiple Options)

```zsh
# ============================================================================
# Configuration
# ============================================================================

DRY_RUN=false
VERBOSE=false
FORCE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --verbose|-v)
            VERBOSE=true
            ;;
        --force|-f)
            FORCE=true
            ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

[Description]

OPTIONS:
  --dry-run      Show what would be done without making changes
  --verbose, -v  Show detailed output
  --force, -f    Force reinstallation even if already installed
  --help, -h     Show this help message

EXAMPLES:
  $(basename "$0")                # Normal operation
  $(basename "$0") --dry-run      # Preview changes
  $(basename "$0") --force -v     # Force reinstall with verbose output

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done
```

---

## Examples

### Example 1: cargo-packages.zsh (Current Implementation)

```zsh
# ============================================================================
# Configuration
# ============================================================================

PACKAGE_LIST="$CONFIG_DIR/packages/cargo-packages.list"
UPDATE_MODE=false

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE_MODE=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [OPTIONS]"
            echo ""
            echo "OPTIONS:"
            echo "  --update    Update installed packages instead of installing new ones"
            echo "  --help, -h  Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Main Execution
# ============================================================================

if $UPDATE_MODE; then
    draw_header "Cargo Packages" "Updating Rust packages"
    # ... update logic ...
else
    draw_header "Cargo Packages" "Installing Rust packages"
    # ... install logic ...
fi
```

**Usage:**
```bash
# Fresh installation
./cargo-packages.zsh

# Update existing packages
./cargo-packages.zsh --update

# Show help
./cargo-packages.zsh --help
```

### Example 2: Simple Installer (No Arguments)

```zsh
#!/usr/bin/env zsh

emulate -LR zsh

# ============================================================================
# Load Shared Libraries
# ============================================================================

# ... (library loading code)

# ============================================================================
# Main Execution
# ============================================================================

draw_header "Simple Installer" "Installing component"
echo

# Check if already installed
if [[ -f "$INSTALL_PATH" ]]; then
    print_success "Already installed"
    exit 0
fi

# Download and install
if download_file "$URL" "$INSTALL_PATH" "Component"; then
    print_success "Installation complete!"
else
    print_error "Installation failed"
    exit 1
fi
```

**No arguments needed** - script is idempotent and does one thing.

---

## Migration Guide

If you need to add arguments to an existing script:

### Step 1: Add Configuration Section

```zsh
# ============================================================================
# Configuration
# ============================================================================

# Add your configuration variables
UPDATE_MODE=false
```

### Step 2: Add Argument Parsing Section

Insert AFTER Configuration, BEFORE Dependency Declaration:

```zsh
# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            # ... help text ...
            exit 0
            ;;
        *)
            print_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done
```

### Step 3: Update Main Execution

Modify your main execution to use the parsed arguments:

```zsh
if $UPDATE_MODE; then
    # Update path
else
    # Install path
fi
```

### Step 4: Test

```bash
# Test help
./your-script.zsh --help

# Test normal operation
./your-script.zsh

# Test with arguments
./your-script.zsh --update
```

---

## Best Practices

1. **Keep It Simple**
   - Don't add arguments unless there's a clear need
   - Simple installers don't need `--force` or `--verbose` flags

2. **Be Consistent**
   - Use the exact patterns shown in this document
   - All scripts should look similar in structure

3. **Provide Good Help**
   - Include usage line, options, and examples
   - Show common use cases in examples section

4. **Use Shared Libraries**
   - Always use `print_error` for error messages
   - Use `draw_header` for consistent UI
   - Leverage OneDark color scheme

5. **Test Unknown Arguments**
   - Always include the `*)` catch-all case
   - Provide helpful error message suggesting `--help`

6. **Document in Script Header**
   - Update the script header comment block
   - List supported arguments in the file header

---

## Future Considerations

### Potential Helper Function

If many scripts need identical argument parsing, we could add to `bin/lib/utils.zsh`:

```zsh
# Parse standard post-install script arguments
# Usage: parse_standard_args "$@"
# Sets: HELP_REQUESTED, UPDATE_MODE, VERBOSE
function parse_standard_args() {
    HELP_REQUESTED=false
    UPDATE_MODE=false
    VERBOSE=false

    for arg in "$@"; do
        case "$arg" in
            --update) UPDATE_MODE=true ;;
            --verbose|-v) VERBOSE=true ;;
            --help|-h) HELP_REQUESTED=true ;;
            *)
                print_error "Unknown option: $arg"
                return 1
                ;;
        esac
    done

    return 0
}
```

**Decision:** Not implementing this yet. The inline pattern is clear and maintainable. A helper function adds indirection without much benefit for ~15 scripts.

---

## Compliance Checklist

When writing or updating a post-install script, verify:

- [ ] Arguments are only added when truly needed
- [ ] `--help` is implemented if any arguments exist
- [ ] Help text includes: usage, description, options, examples
- [ ] Argument parsing uses `for arg in "$@"` + `case` pattern
- [ ] Catch-all `*)` case provides helpful error message
- [ ] Configuration variables defined BEFORE argument parsing
- [ ] Section headers follow standard format
- [ ] `print_error` used for error messages
- [ ] Script header comments document supported arguments

---

**Created:** 2025-10-15
**Status:** Production Standard
**Last Updated:** 2025-10-15
**Maintainer:** Thomas + Aria (Claude Code)
