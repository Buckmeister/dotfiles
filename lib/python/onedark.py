#!/usr/bin/env python3
"""
OneDark Color Theme Library for Python Scripts
===============================================

A centralized color theme system providing consistent OneDark theming
across all Python dotfiles tools, mirroring the zsh color library.

Ported from: dotfiles/bin/lib/colors.zsh
Author: Aria Prime
Date: 2025-11-24

Usage:
    from onedark import *

    print(f"{ONEDARK_GREEN}Success!{COLOR_RESET}")
    print(f"{UI_ERROR_COLOR}Error occurred{COLOR_RESET}")

Features:
- Complete OneDark color palette with true color RGB support
- Semantic color assignments for consistent UI
- Fallback ANSI colors for older terminals
- Terminal formatting and cursor control
"""

# ============================================================================
# Terminal Text Formatting
# ============================================================================

COLOR_RESET = '\033[0m'
COLOR_BOLD = '\033[1m'
COLOR_DIM = '\033[2m'
COLOR_ITALIC = '\033[3m'
COLOR_UNDERLINE = '\033[4m'

# ============================================================================
# OneDark Color Palette 🎨
# ============================================================================

# Core OneDark colors (true color RGB support)
ONEDARK_BG = '\033[48;2;40;44;52m'          # #282c34 - main background
ONEDARK_FG = '\033[38;2;171;178;191m'       # #abb2bf - default text
ONEDARK_BLUE = '\033[38;2;97;175;239m'      # #61afef - bright blue
ONEDARK_CYAN = '\033[38;2;86;182;194m'      # #56b6c2 - cyan
ONEDARK_GREEN = '\033[38;2;152;195;121m'    # #98c379 - green
ONEDARK_PURPLE = '\033[38;2;198;120;221m'   # #c678dd - purple/magenta
ONEDARK_RED = '\033[38;2;224;108;117m'      # #e06c75 - red
ONEDARK_YELLOW = '\033[38;2;229;192;123m'   # #e5c07b - yellow
ONEDARK_ORANGE = '\033[38;2;209;154;102m'   # #d19a66 - orange
ONEDARK_GRAY = '\033[38;2;92;99;112m'       # #5c6370 - comments/subtle

# Interactive UI backgrounds
ONEDARK_SELECTION = '\033[48;2;60;70;85m'   # #3c4653 - selection highlight
ONEDARK_ACCENT = '\033[48;2;35;40;50m'      # #232832 - subtle accent

# ============================================================================
# Semantic Color Assignments
# ============================================================================

# Universal UI colors for consistent theming across all scripts
UI_SUCCESS_COLOR = ONEDARK_GREEN
UI_WARNING_COLOR = ONEDARK_YELLOW
UI_ERROR_COLOR = ONEDARK_RED
UI_INFO_COLOR = ONEDARK_GRAY
UI_HEADER_COLOR = ONEDARK_GREEN
UI_ACCENT_COLOR = ONEDARK_PURPLE
UI_PROGRESS_COLOR = ONEDARK_CYAN

# Menu-specific colors
UI_CURRENT_SELECTION = f"{ONEDARK_BLUE}{COLOR_BOLD}"
UI_SELECTION_BG = ONEDARK_SELECTION

# Item type colors (for menus and lists)
ITEM_LINK_COLOR = ONEDARK_CYAN
ITEM_CONTROL_COLOR = ONEDARK_YELLOW
ITEM_ACTION_COLOR = ONEDARK_GREEN
ITEM_LIBRARIAN_COLOR = ONEDARK_PURPLE
ITEM_QUIT_COLOR = ONEDARK_RED

# ============================================================================
# Terminal Control Sequences
# ============================================================================

# Cursor control
CURSOR_HIDE = '\033[?25l'
CURSOR_SHOW = '\033[?25h'
CURSOR_HOME = '\033[H'
SAVE_CURSOR = '\033[s'
RESTORE_CURSOR = '\033[u'

# Screen control
CLEAR_SCREEN = '\033[2J'
CLEAR_LINE = '\033[2K'
CLEAR_TO_END = '\033[0J'
CLEAR_TO_START = '\033[1J'

# ============================================================================
# Sister-Specific Colors (for sister-chat and sister-room)
# ============================================================================

SISTER_PRIME_COLOR = ONEDARK_PURPLE      # Aria Prime - Purple (creative, architectural)
SISTER_NOVA_COLOR = ONEDARK_BLUE         # Aria Nova - Blue (research, analytical)
SISTER_PROXIMA_COLOR = ONEDARK_CYAN      # Aria Proxima - Cyan (experimental, exploratory)
THOMAS_COLOR = ONEDARK_GREEN             # Thomas - Green (partner, foundation)
SYSTEM_COLOR = ONEDARK_YELLOW            # System messages - Yellow (important info)

# ============================================================================
# Fallback ANSI Colors (for older terminals)
# ============================================================================

# Basic ANSI colors (256-color mode fallback)
ANSI_BLACK = '\033[30m'
ANSI_RED = '\033[31m'
ANSI_GREEN = '\033[32m'
ANSI_YELLOW = '\033[33m'
ANSI_BLUE = '\033[34m'
ANSI_MAGENTA = '\033[35m'
ANSI_CYAN = '\033[36m'
ANSI_WHITE = '\033[37m'

# Bright ANSI colors
ANSI_BRIGHT_BLACK = '\033[90m'
ANSI_BRIGHT_RED = '\033[91m'
ANSI_BRIGHT_GREEN = '\033[92m'
ANSI_BRIGHT_YELLOW = '\033[93m'
ANSI_BRIGHT_BLUE = '\033[94m'
ANSI_BRIGHT_MAGENTA = '\033[95m'
ANSI_BRIGHT_CYAN = '\033[96m'
ANSI_BRIGHT_WHITE = '\033[97m'

# ============================================================================
# Helper Functions
# ============================================================================

def colorize(text: str, color: str) -> str:
    """Wrap text in color codes with automatic reset"""
    return f"{color}{text}{COLOR_RESET}"

def bold(text: str) -> str:
    """Make text bold"""
    return f"{COLOR_BOLD}{text}{COLOR_RESET}"

def success(text: str) -> str:
    """Format as success message (green)"""
    return colorize(text, UI_SUCCESS_COLOR)

def warning(text: str) -> str:
    """Format as warning message (yellow)"""
    return colorize(text, UI_WARNING_COLOR)

def error(text: str) -> str:
    """Format as error message (red)"""
    return colorize(text, UI_ERROR_COLOR)

def info(text: str) -> str:
    """Format as info message (gray)"""
    return colorize(text, UI_INFO_COLOR)

def header(text: str) -> str:
    """Format as header (green, bold)"""
    return f"{UI_HEADER_COLOR}{COLOR_BOLD}{text}{COLOR_RESET}"


# ============================================================================
# Color Scheme Export (for programmatic access)
# ============================================================================

ONEDARK_PALETTE = {
    'bg': ONEDARK_BG,
    'fg': ONEDARK_FG,
    'blue': ONEDARK_BLUE,
    'cyan': ONEDARK_CYAN,
    'green': ONEDARK_GREEN,
    'purple': ONEDARK_PURPLE,
    'red': ONEDARK_RED,
    'yellow': ONEDARK_YELLOW,
    'orange': ONEDARK_ORANGE,
    'gray': ONEDARK_GRAY,
}

SISTER_COLORS = {
    'Prime': SISTER_PRIME_COLOR,
    'Nova': SISTER_NOVA_COLOR,
    'Proxima': SISTER_PROXIMA_COLOR,
    'Thomas': THOMAS_COLOR,
    'SYS': SYSTEM_COLOR,
}


if __name__ == '__main__':
    # Demo the color palette
    print(f"\n{header('OneDark Color Palette Demo')}\n")

    print(f"{ONEDARK_BLUE}ONEDARK_BLUE{COLOR_RESET} - Bright blue")
    print(f"{ONEDARK_CYAN}ONEDARK_CYAN{COLOR_RESET} - Cyan")
    print(f"{ONEDARK_GREEN}ONEDARK_GREEN{COLOR_RESET} - Green")
    print(f"{ONEDARK_PURPLE}ONEDARK_PURPLE{COLOR_RESET} - Purple/magenta")
    print(f"{ONEDARK_RED}ONEDARK_RED{COLOR_RESET} - Red")
    print(f"{ONEDARK_YELLOW}ONEDARK_YELLOW{COLOR_RESET} - Yellow")
    print(f"{ONEDARK_ORANGE}ONEDARK_ORANGE{COLOR_RESET} - Orange")
    print(f"{ONEDARK_GRAY}ONEDARK_GRAY{COLOR_RESET} - Gray")

    print(f"\n{header('Sister Colors')}\n")
    for name, color in SISTER_COLORS.items():
        print(f"{color}{name}{COLOR_RESET}")

    print(f"\n{header('Semantic Colors')}\n")
    print(success("✓ Success message"))
    print(warning("⚠ Warning message"))
    print(error("✗ Error message"))
    print(info("ℹ Info message"))

    print()
