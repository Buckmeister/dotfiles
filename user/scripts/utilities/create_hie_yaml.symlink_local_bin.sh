#!/usr/bin/env bash

# ============================================================================
# Create HIE YAML Configuration
# ============================================================================
#
# Creates a hie.yaml configuration file for Haskell IDE Engine (HIE) and
# Haskell Language Server (HLS). This file tells the language server how
# to build your Haskell project.
#
# Usage:
#   create_hie_yaml [OPTIONS]
#
# Options:
#   -o, --output FILE   Output file path (default: ./hie.yaml)
#   -h, --help          Show this help message
#
# What is HIE/HLS?
#   Haskell IDE Engine (HIE) and Haskell Language Server (HLS) provide
#   IDE features for Haskell development, including:
#   - Code completion
#   - Type information
#   - Error checking
#   - Code navigation
#
# ============================================================================

# ============================================================================
# Colors (bash-compatible)
# ============================================================================

if [[ -t 1 ]]; then
    BLUE='\033[38;2;97;175;239m'
    PURPLE='\033[38;2;198;120;221m'
    GREEN='\033[38;2;152;195;121m'
    RED='\033[38;2;224;108;117m'
    YELLOW='\033[38;2;229;192;123m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    BLUE='' PURPLE='' GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

# ============================================================================
# Help Function
# ============================================================================

show_help() {
    cat <<EOF
${BOLD}${PURPLE}Create HIE YAML Configuration${RESET}

Creates a hie.yaml configuration file for Haskell IDE Engine (HIE) and
Haskell Language Server (HLS).

${BOLD}${PURPLE}USAGE${RESET}
    create_hie_yaml [OPTIONS]

${BOLD}${PURPLE}OPTIONS${RESET}
    -o, --output FILE   Output file path (default: ./hie.yaml)
    -h, --help          Show this help message

${BOLD}${PURPLE}EXAMPLES${RESET}
    ${BLUE}# Create hie.yaml in current directory${RESET}
    create_hie_yaml

    ${BLUE}# Create in specific location${RESET}
    create_hie_yaml -o ~/my-project/hie.yaml

${BOLD}${PURPLE}WHAT IS HIE.YAML?${RESET}
    The hie.yaml file tells Haskell Language Server how to build your
    project. It's required for proper IDE support in Haskell projects.

${BOLD}${PURPLE}WHAT DOES IT DO?${RESET}
    This script creates a simple hie.yaml with Stack cradle configuration:
    ${YELLOW}cradle: { stack: {} }${RESET}

    This tells the language server to use Stack for building your project.

${BOLD}${PURPLE}ABOUT HASKELL LANGUAGE SERVER${RESET}
    Haskell Language Server (HLS) provides IDE features for Haskell:
    • Code completion and IntelliSense
    • Type information on hover
    • Error checking and diagnostics
    • Go to definition
    • Find references
    • Code formatting

${BOLD}${PURPLE}WHEN TO USE THIS${RESET}
    Run this in your Haskell project root directory when:
    • Setting up a new Haskell project
    • Your IDE isn't recognizing your Haskell code
    • You get "cradle" errors from HLS

${BOLD}${PURPLE}LEARN MORE${RESET}
    • Haskell Language Server: https://github.com/haskell/haskell-language-server
    • HIE YAML docs: https://github.com/haskell/hie-bios#explicit-configuration

EOF
    exit 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

OUTPUT_FILE="./hie.yaml"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}❌ Error: Unknown option: $1${RESET}" >&2
            echo -e "${BLUE}   Use 'create_hie_yaml --help' for usage information${RESET}" >&2
            exit 1
            ;;
    esac
done

# ============================================================================
# Create HIE YAML
# ============================================================================

echo -e "${BLUE}ℹ️  Creating HIE configuration...${RESET}"

# Create the configuration file
echo 'cradle: { stack: {}}' > "$OUTPUT_FILE"

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Created: ${BOLD}$OUTPUT_FILE${RESET}"
    echo -e "${BLUE}ℹ️  Configuration: Stack cradle${RESET}"
    echo -e "${YELLOW}💡 Tip: Restart your editor/LSP to pick up the new configuration${RESET}"
else
    echo -e "${RED}❌ Error: Failed to create $OUTPUT_FILE${RESET}" >&2
    exit 1
fi
