#!/usr/bin/env python3
"""
Dotfiles Python Library
========================

Shared Python libraries for Thomas's dotfiles tools.

Modules:
    onedark: OneDark color theme with semantic color assignments
    terminal_ui: Terminal UI components (headers, progress bars, etc.)

Usage:
    from onedark import *
    from terminal_ui import *

Author: Aria Prime
Date: 2025-11-24
"""

__version__ = '1.0.0'
__author__ = 'Aria Prime'

# Export commonly used functions and constants
from .onedark import (
    # Colors
    ONEDARK_BLUE, ONEDARK_CYAN, ONEDARK_GREEN, ONEDARK_PURPLE,
    ONEDARK_RED, ONEDARK_YELLOW, ONEDARK_ORANGE, ONEDARK_GRAY,
    # Semantic colors
    UI_SUCCESS_COLOR, UI_WARNING_COLOR, UI_ERROR_COLOR, UI_INFO_COLOR,
    UI_HEADER_COLOR, UI_ACCENT_COLOR, UI_PROGRESS_COLOR,
    # Sister colors
    SISTER_PRIME_COLOR, SISTER_NOVA_COLOR, SISTER_PROXIMA_COLOR,
    THOMAS_COLOR, SYSTEM_COLOR,
    # Formatting
    COLOR_RESET, COLOR_BOLD, COLOR_DIM, COLOR_ITALIC, COLOR_UNDERLINE,
    # Helper functions
    colorize, bold, success, warning, error, info, header,
)

from .terminal_ui import (
    # Terminal control
    hide_cursor, show_cursor, clear_screen, clear_line,
    move_cursor_to_line, move_cursor_to, save_cursor, restore_cursor,
    # Messages
    print_colored_message, print_success, print_warning, print_error, print_info,
    # Box drawing
    draw_header, draw_separator, draw_section_header, print_box,
    # Progress bars
    draw_progress_bar, update_progress, increment_progress, reset_progress_cache,
    # Status display
    update_status_display, show_status,
    # Spinner
    show_spinner,
    # Input
    ask_confirmation, wait_for_keypress,
    # Layout
    print_centered,
    # Cleanup
    cleanup_ui, setup_ui_cleanup,
)

__all__ = [
    # Colors
    'ONEDARK_BLUE', 'ONEDARK_CYAN', 'ONEDARK_GREEN', 'ONEDARK_PURPLE',
    'ONEDARK_RED', 'ONEDARK_YELLOW', 'ONEDARK_ORANGE', 'ONEDARK_GRAY',
    # Semantic colors
    'UI_SUCCESS_COLOR', 'UI_WARNING_COLOR', 'UI_ERROR_COLOR', 'UI_INFO_COLOR',
    'UI_HEADER_COLOR', 'UI_ACCENT_COLOR', 'UI_PROGRESS_COLOR',
    # Sister colors
    'SISTER_PRIME_COLOR', 'SISTER_NOVA_COLOR', 'SISTER_PROXIMA_COLOR',
    'THOMAS_COLOR', 'SYSTEM_COLOR',
    # Formatting
    'COLOR_RESET', 'COLOR_BOLD', 'COLOR_DIM', 'COLOR_ITALIC', 'COLOR_UNDERLINE',
    # Helper functions from onedark
    'colorize', 'bold', 'success', 'warning', 'error', 'info', 'header',
    # Terminal control from terminal_ui
    'hide_cursor', 'show_cursor', 'clear_screen', 'clear_line',
    'move_cursor_to_line', 'move_cursor_to', 'save_cursor', 'restore_cursor',
    # Messages from terminal_ui
    'print_colored_message', 'print_success', 'print_warning', 'print_error', 'print_info',
    # Box drawing from terminal_ui
    'draw_header', 'draw_separator', 'draw_section_header', 'print_box',
    # Progress bars from terminal_ui
    'draw_progress_bar', 'update_progress', 'increment_progress', 'reset_progress_cache',
    # Status display from terminal_ui
    'update_status_display', 'show_status',
    # Spinner from terminal_ui
    'show_spinner',
    # Input from terminal_ui
    'ask_confirmation', 'wait_for_keypress',
    # Layout from terminal_ui
    'print_centered',
    # Cleanup from terminal_ui
    'cleanup_ui', 'setup_ui_cleanup',
]
