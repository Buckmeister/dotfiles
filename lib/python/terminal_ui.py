#!/usr/bin/env python3
"""
Terminal UI Components Library for Python Scripts
==================================================

A comprehensive UI library providing progress bars, status displays,
headers, and terminal control functions for consistent user experience.

Ported from: dotfiles/bin/lib/ui.zsh
Author: Aria Prime
Date: 2025-11-24

Usage:
    from terminal_ui import *

    draw_header("My Application", "Version 1.0")
    print_success("Operation completed!")
    update_progress(50, 100)

Features:
- Beautiful progress bars with customizable width and styling
- Professional status displays with phase tracking
- Elegant headers and box drawing
- Terminal control and cursor management
- Message printing with automatic color handling
- Optimized rendering with caching for zero flicker
"""

import sys
import time
import unicodedata
from typing import Optional, Tuple
from onedark import *

# ============================================================================
# Module State
# ============================================================================

# Silent mode flag (can be set by scripts)
UI_SILENT = False

# Global progress tracking variables
PROGRESS_TOTAL = 100
PROGRESS_CURRENT = 0

# Cache for last drawn state (avoid redundant redraws)
_PROGRESS_LAST_PERCENTAGE = -1
_PROGRESS_LAST_FILLED = -1
_PROGRESS_LAST_CURRENT = -1
_PROGRESS_LAST_TOTAL = -1
_PROGRESS_LAST_RENDERED = ""

# Pre-built character strings for performance
_PROGRESS_FILLED_CACHE = ""
_PROGRESS_EMPTY_CACHE = ""
_PROGRESS_CACHE_WIDTH = 0

# ============================================================================
# Terminal Control Functions
# ============================================================================

def hide_cursor():
    """Hide terminal cursor"""
    print(CURSOR_HIDE, end='', flush=True)

def show_cursor():
    """Show terminal cursor"""
    print(CURSOR_SHOW, end='', flush=True)

def clear_screen():
    """Clear entire screen and move to home"""
    print(f"{CLEAR_SCREEN}{CURSOR_HOME}", end='', flush=True)

def clear_line():
    """Clear current line"""
    print(CLEAR_LINE, end='', flush=True)

def move_cursor_to_line(line: int):
    """Move cursor to specific line"""
    print(f"\033[{line};1H", end='', flush=True)

def move_cursor_to(line: int, column: int):
    """Move cursor to specific position"""
    print(f"\033[{line};{column}H", end='', flush=True)

def save_cursor():
    """Save current cursor position"""
    print(SAVE_CURSOR, end='', flush=True)

def restore_cursor():
    """Restore saved cursor position"""
    print(RESTORE_CURSOR, end='', flush=True)

# ============================================================================
# Message Display Functions
# ============================================================================

def print_colored_message(color: str, message: str):
    """Display a colored message with automatic color reset"""
    print(f"{color}{message}{COLOR_RESET}", end='')

def print_status_message(color: str, emoji: str, message: str):
    """Display a status message with emoji and color"""
    print_colored_message(color, f"{emoji} {message}\n")

def print_success(message: str):
    """Print success message (green with checkmark)"""
    if UI_SILENT:
        return
    print_status_message(UI_SUCCESS_COLOR, "✅", message)

def print_warning(message: str):
    """Print warning message (yellow with warning sign)"""
    if UI_SILENT:
        return
    print_status_message(UI_WARNING_COLOR, "⚠️", message)

def print_error(message: str):
    """Print error message (red with X)"""
    if UI_SILENT:
        return
    print_status_message(UI_ERROR_COLOR, "❌", message)

def print_info(message: str):
    """Print info message (gray with info symbol)"""
    if UI_SILENT:
        return
    print_status_message(UI_INFO_COLOR, "ℹ️", message)

# ============================================================================
# Text Width Calculation Functions
# ============================================================================

def get_display_width(text: str) -> int:
    """
    Calculate the display width of text (handles emojis and Unicode)

    This function accounts for emoji characters that may display as 2 columns.
    Uses unicodedata to detect wide characters.
    """
    width = 0
    for char in text:
        # Get the East Asian Width property
        ea_width = unicodedata.east_asian_width(char)

        # Wide (W) and Fullwidth (F) characters take 2 columns
        # Emoji modifier sequences and flags also take 2 columns
        if ea_width in ('W', 'F'):
            width += 2
        # Check if it's an emoji (simplified heuristic)
        elif ord(char) >= 0x1F300:  # Most emojis start here
            width += 2
        else:
            width += 1

    return width

def get_safe_display_width(text: str) -> int:
    """Safe display width calculation with fallback"""
    try:
        width = get_display_width(text)
        return width if width > 0 else len(text)
    except Exception:
        return len(text)

# ============================================================================
# Header and Box Drawing Functions
# ============================================================================

def draw_header(title: str, subtitle: str = "", width: int = 78):
    """
    Draw a beautiful header with box drawing characters

    Args:
        title: Main title text
        subtitle: Optional subtitle text
        width: Total width of the box (default 78)
    """
    print(f"{COLOR_BOLD}{UI_HEADER_COLOR}", end='')

    # Top border
    print(f"╔{'═' * (width - 2)}╗")

    # Title line (centered with proper emoji alignment)
    title_display_width = get_safe_display_width(title)
    title_left_padding = (width - title_display_width - 2) // 2
    title_right_padding = width - title_display_width - 2 - title_left_padding
    print(f"║{' ' * title_left_padding}{title}{' ' * title_right_padding}║")

    # Subtitle line (if provided)
    if subtitle:
        subtitle_display_width = get_safe_display_width(subtitle)
        subtitle_left_padding = (width - subtitle_display_width - 2) // 2
        subtitle_right_padding = width - subtitle_display_width - 2 - subtitle_left_padding
        print(f"║{' ' * subtitle_left_padding}{subtitle}{' ' * subtitle_right_padding}║")

    # Bottom border
    print(f"╚{'═' * (width - 2)}╝")

    print(f"{COLOR_RESET}\n", end='')

def draw_separator(width: int = 78, char: str = '─'):
    """Draw a simple separator line"""
    print(f"{UI_INFO_COLOR}{'─' * width}{COLOR_RESET}")

def draw_section_header(title: str, color: str = None):
    """
    Draw a section header (simpler than full box header)
    Used for subsections within scripts
    """
    if color is None:
        color = UI_ACCENT_COLOR
    print(f"\n{color}{COLOR_BOLD}═══ {title} ═══{COLOR_RESET}")

# ============================================================================
# Progress Bar System (Optimized for minimal repaints and zero flicker)
# ============================================================================

def _build_progress_chars(width: int, filled_char: str = '█', empty_char: str = '░'):
    """Build filled/empty character strings (called once per width)"""
    global _PROGRESS_FILLED_CACHE, _PROGRESS_EMPTY_CACHE, _PROGRESS_CACHE_WIDTH

    # Only rebuild if width changed
    if width != _PROGRESS_CACHE_WIDTH:
        _PROGRESS_FILLED_CACHE = filled_char * width
        _PROGRESS_EMPTY_CACHE = empty_char * width
        _PROGRESS_CACHE_WIDTH = width

def draw_progress_bar(current: int = None, total: int = None,
                      width: int = 50, filled_char: str = '█',
                      empty_char: str = '░') -> str:
    """
    Draw a beautiful progress bar (optimized version)

    Args:
        current: Current progress value (default: PROGRESS_CURRENT)
        total: Total value (default: PROGRESS_TOTAL)
        width: Width of the progress bar in characters
        filled_char: Character for filled portion
        empty_char: Character for empty portion

    Returns:
        Formatted progress bar string
    """
    global PROGRESS_CURRENT, PROGRESS_TOTAL

    if current is None:
        current = PROGRESS_CURRENT
    if total is None:
        total = PROGRESS_TOTAL

    # Safety checks
    current = max(0, current)
    total = max(1, total)
    current = min(current, total)

    percentage = (current * 100) // total
    filled = (current * width) // total
    empty = width - filled

    # Additional safety check for width
    if filled > width:
        filled = width
        empty = 0
    if filled < 0:
        filled = 0
        empty = width

    # Build character cache if needed
    _build_progress_chars(width, filled_char, empty_char)

    # Use substring operations (no subprocess overhead)
    filled_str = _PROGRESS_FILLED_CACHE[:filled]
    empty_str = _PROGRESS_EMPTY_CACHE[:empty]

    # Single formatted string for entire bar
    return f"{UI_PROGRESS_COLOR}[{filled_str}{empty_str}] {percentage:3d}% ({current}/{total}){COLOR_RESET}"

def update_progress(current: int, total: int = None, width: int = 50):
    """
    Update progress bar with current values (optimized repaint, zero flicker)

    Args:
        current: Current progress value
        total: Total value (default: PROGRESS_TOTAL)
        width: Width of the progress bar
    """
    global PROGRESS_CURRENT, PROGRESS_TOTAL
    global _PROGRESS_LAST_PERCENTAGE, _PROGRESS_LAST_FILLED
    global _PROGRESS_LAST_CURRENT, _PROGRESS_LAST_TOTAL, _PROGRESS_LAST_RENDERED

    if total is None:
        total = PROGRESS_TOTAL

    PROGRESS_CURRENT = current
    PROGRESS_TOTAL = total

    # Calculate what changed
    percentage = (current * 100) // total
    filled = (current * width) // total

    # Skip redraw if nothing visually changed
    if (percentage == _PROGRESS_LAST_PERCENTAGE and
        filled == _PROGRESS_LAST_FILLED and
        current == _PROGRESS_LAST_CURRENT and
        total == _PROGRESS_LAST_TOTAL):
        return

    # Build the complete rendered string
    rendered_bar = draw_progress_bar(current, total, width)

    # Skip redraw if rendered output is identical (ultimate flicker prevention)
    if rendered_bar == _PROGRESS_LAST_RENDERED:
        return

    # Update cache
    _PROGRESS_LAST_PERCENTAGE = percentage
    _PROGRESS_LAST_FILLED = filled
    _PROGRESS_LAST_CURRENT = current
    _PROGRESS_LAST_TOTAL = total
    _PROGRESS_LAST_RENDERED = rendered_bar

    # Anti-flicker redraw technique:
    # 1. Move to start of line
    # 2. Clear entire line completely
    # 3. Redraw on clean slate
    print(f"\r\033[2KProgress: {rendered_bar}", end='', flush=True)

def increment_progress(increment: int = 1):
    """Increment progress by one step (optimized)"""
    global PROGRESS_CURRENT, PROGRESS_TOTAL
    PROGRESS_CURRENT += increment
    update_progress(PROGRESS_CURRENT, PROGRESS_TOTAL)

def reset_progress_cache():
    """Reset progress bar cache (call when starting new progress sequence)"""
    global _PROGRESS_LAST_PERCENTAGE, _PROGRESS_LAST_FILLED
    global _PROGRESS_LAST_CURRENT, _PROGRESS_LAST_TOTAL, _PROGRESS_LAST_RENDERED

    _PROGRESS_LAST_PERCENTAGE = -1
    _PROGRESS_LAST_FILLED = -1
    _PROGRESS_LAST_CURRENT = -1
    _PROGRESS_LAST_TOTAL = -1
    _PROGRESS_LAST_RENDERED = ""

# ============================================================================
# Advanced Status Display System
# ============================================================================

def update_status_display(phase_name: str, operation_name: str,
                         current: int = None, total: int = None,
                         success_count: int = 0, error_count: int = 0,
                         line_offset: int = 7):
    """
    Display comprehensive status with phase tracking

    Args:
        phase_name: Name of current phase
        operation_name: Name of current operation
        current: Current progress (default: PROGRESS_CURRENT)
        total: Total progress (default: PROGRESS_TOTAL)
        success_count: Number of successful operations
        error_count: Number of errors
        line_offset: Line number to start drawing at
    """
    global PROGRESS_CURRENT, PROGRESS_TOTAL

    if current is None:
        current = PROGRESS_CURRENT
    if total is None:
        total = PROGRESS_TOTAL

    # Clear the status area and redraw
    move_cursor_to_line(line_offset)

    # Phase line
    print(f"{' ' * 80}\r{COLOR_BOLD}{UI_ACCENT_COLOR}Phase: {phase_name:<20}{COLOR_RESET}")

    # Current operation line
    print(f"{' ' * 80}\r{UI_INFO_COLOR}Current: {operation_name:<40}{COLOR_RESET}\n")

    # Progress bar
    print(f"{' ' * 80}\r", end='')
    print_colored_message(UI_PROGRESS_COLOR, "Progress: ")
    print(draw_progress_bar(current, total))
    print("\n")

    # Statistics
    print(f"{' ' * 80}\r", end='')
    print(f"{UI_SUCCESS_COLOR}✅ Success: {success_count}{COLOR_RESET}  "
          f"{UI_ERROR_COLOR}❌ Errors: {error_count}{COLOR_RESET}")

def show_status(message: str, status_type: str = "info"):
    """
    Simple status display for basic operations

    Args:
        message: Status message to display
        status_type: Type of status (success, warning, error, info)
    """
    if status_type == "success":
        print_success(message)
    elif status_type == "warning":
        print_warning(message)
    elif status_type == "error":
        print_error(message)
    else:  # info or any other type
        print_info(message)

# ============================================================================
# Loading and Spinner Functions
# ============================================================================

def show_spinner(message: str, duration: int = 3):
    """
    Simple spinner animation

    Args:
        message: Message to display with spinner
        duration: Duration in seconds
    """
    frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']

    hide_cursor()

    for i in range(duration * 10):
        frame = frames[i % len(frames)]
        print(f"\r{UI_ACCENT_COLOR}{frame}{COLOR_RESET} {message}", end='', flush=True)
        time.sleep(0.1)

    print(f"\r{UI_SUCCESS_COLOR}✓{COLOR_RESET} {message}")
    show_cursor()

# ============================================================================
# Input and Confirmation Functions
# ============================================================================

def ask_confirmation(message: str, default: str = "n") -> bool:
    """
    Ask for user confirmation with colored prompt

    Args:
        message: Question to ask
        default: Default answer ('y' or 'n')

    Returns:
        True if user confirmed, False otherwise
    """
    default_display = "y/N" if default == "n" else "Y/n"

    print(f"{UI_ACCENT_COLOR}{message} [{default_display}]: {COLOR_RESET}", end='', flush=True)
    response = input().strip().lower()

    answer = response if response else default
    return answer in ('y', 'yes')

def wait_for_keypress():
    """Wait for any keypress to continue (returns to menu/previous screen)"""
    print_colored_message(UI_HEADER_COLOR, "\nPress Enter to continue...")
    input()

# ============================================================================
# Layout and Formatting Helpers
# ============================================================================

def print_centered(text: str, width: int = 80, color: str = None):
    """
    Print a centered line of text

    Args:
        text: Text to center
        width: Total width to center within
        color: Color to use (default: UI_INFO_COLOR)
    """
    if color is None:
        color = UI_INFO_COLOR

    padding = (width - len(text)) // 2
    print(f"{color}{' ' * padding}{text}{' ' * padding}{COLOR_RESET}")

def print_box(text: str, padding: int = 2, color: str = None):
    """
    Print text in a box

    Args:
        text: Text to put in box
        padding: Padding around text
        color: Color to use (default: UI_INFO_COLOR)
    """
    if color is None:
        color = UI_INFO_COLOR

    text_width = len(text)
    box_width = text_width + padding * 2 + 2

    print(f"{color}", end='')
    print(f"┌{'─' * (box_width - 2)}┐")
    print(f"│{' ' * padding}{text}{' ' * padding}│")
    print(f"└{'─' * (box_width - 2)}┘")
    print(f"{COLOR_RESET}", end='')

# ============================================================================
# Cleanup and Safety Functions
# ============================================================================

def cleanup_ui():
    """Ensure cursor is shown and screen state is clean on exit"""
    show_cursor()
    print(f"\n{COLOR_RESET}", end='', flush=True)

def setup_ui_cleanup():
    """Set up proper cleanup on script exit"""
    import atexit
    import signal

    # Register cleanup on normal exit
    atexit.register(cleanup_ui)

    # Register cleanup on interrupt signals
    def signal_handler(sig, frame):
        cleanup_ui()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)


# ============================================================================
# Demo and Testing
# ============================================================================

if __name__ == '__main__':
    # Demo the UI library
    print()
    draw_header("Terminal UI Library Demo", "Python Port of ui.zsh")

    print()
    draw_section_header("Message Types")
    print_success("Operation completed successfully")
    print_warning("This is a warning message")
    print_error("An error occurred")
    print_info("This is an informational message")

    print()
    draw_section_header("Progress Bar")
    reset_progress_cache()
    for i in range(0, 101, 10):
        update_progress(i, 100)
        time.sleep(0.1)
    print()

    print()
    draw_section_header("Box Drawing")
    print_box("This text is in a box!")

    print()
    draw_section_header("Centered Text")
    print_centered("This text is centered", 78, UI_ACCENT_COLOR)

    print()
    draw_separator()

    print(f"\n{UI_SUCCESS_COLOR}✓ Demo complete!{COLOR_RESET}\n")
