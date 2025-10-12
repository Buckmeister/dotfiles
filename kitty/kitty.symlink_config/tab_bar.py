# pyright: reportMissingImports=false
import datetime
import re
import shlex
from subprocess import Popen, PIPE


from kitty.fast_data_types import Screen

# from kitty.rgb import Color
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title
from kitty.utils import color_as_int


def calc_draw_spaces(*args) -> int:
    length = 0
    for i in args:
        if not isinstance(i, str):
            i = str(i)
        length += len(i)
    return length


def get_battery_status() -> str:
    try:
        session = Popen(
            shlex.split("/bin/zsh -l -c 'battery --kitty'"),
            stdout=PIPE,
            stderr=PIPE,
        )
        stdout, _ = session.communicate()

        if session.returncode == 0:
            return re.sub(r"^\s*(.*)\s*$", r"\1", stdout.decode("utf8"))
    except Exception:
        pass
    return "N/A"


def _draw_icon(
    draw_data: DrawData, screen: Screen, index: int, template: str = "  󰄛  "
) -> int:
    if index != 1:
        return 0

    # "█",
    # "█",
    bar_terminator = "█"
    left_padding = "  "
    right_padding = ""

    saved_crs_fg, saved_crs_bg, saved_crs_bd, saved_crs_it = (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    )

    screen.cursor.bold = screen.cursor.italic = True

    screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
    screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))

    screen.draw(left_padding)
    screen.draw(template)
    screen.draw(right_padding)

    screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
    screen.cursor.bg = 0
    screen.draw(bar_terminator)
    screen.draw(draw_data.sep)

    (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    ) = (
        saved_crs_fg,
        saved_crs_bg,
        saved_crs_bd,
        saved_crs_it,
    )
    return screen.cursor.x


# "█",
# "█",
def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    ExtraData: ExtraData,
) -> int:
    bar_terminator_l = "█"
    bar_terminator_l_active = "█"
    bar_terminator_r = "█"
    bar_terminator_r_active = "█"
    bar_terminator_r_last = ""
    overlength_indicator = " …"
    right_padding = " "

    saved_crs_fg, saved_crs_bg, saved_crs_bd, saved_crs_it = (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    )

    if draw_data.leading_spaces:
        screen.cursor.bg = 0
        screen.draw(" " * draw_data.leading_spaces)

    if tab.is_active:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.active_bg))
        screen.cursor.bg = 0
        screen.draw(bar_terminator_l_active)

        screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
        screen.cursor.bg = as_rgb(color_as_int(draw_data.active_bg))
        screen.cursor.bold = screen.cursor.italic = True
    else:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.cursor.bg = 0
        screen.draw(bar_terminator_l)

        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
        screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))

    draw_title(draw_data, screen, tab, index)

    trailing_spaces = min(max_title_length - 1, draw_data.trailing_spaces)
    max_title_length -= trailing_spaces
    extra = screen.cursor.x - before - max_title_length

    if extra > 0:
        screen.cursor.x -= extra + len(overlength_indicator)
        screen.draw(overlength_indicator)

    if trailing_spaces:
        screen.cursor.bg = 0
        screen.draw(" " * trailing_spaces)

    screen.cursor.bold = screen.cursor.italic = False

    if tab.is_active:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.active_bg))
        screen.cursor.bg = 0
        screen.draw(bar_terminator_r_active)
    else:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.cursor.bg = 0
        screen.draw(bar_terminator_r)

    if is_last:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.cursor.bg = 0
        screen.draw(bar_terminator_r_last)
        screen.draw(right_padding)
    else:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
        screen.cursor.bg = 0
        screen.draw(draw_data.sep)
    (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    ) = (
        saved_crs_fg,
        saved_crs_bg,
        saved_crs_bd,
        saved_crs_it,
    )
    return screen.cursor.x


def _draw_right_status(
    draw_data: DrawData,
    screen: Screen,
    is_last: bool,
) -> int:
    if not is_last:
        return 0

    saved_crs_fg, saved_crs_bg, saved_crs_bd, saved_crs_it = (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    )

    right_status_length = 1

    # "█",
    # "█",
    bar_terminator = ""
    right_status_length += len(bar_terminator)

    clock_icon = " "
    time = datetime.datetime.now().strftime("%H:%M")
    separator = " ︙ "
    # battery_icon = "󰂑"
    battery_status = get_battery_status()
    padding = "  "

    cells = [
        padding,
        clock_icon,
        time,
        separator,
        battery_status,
        padding,
    ]

    for cell in cells:
        right_status_length += calc_draw_spaces(cell)

    draw_spaces = screen.columns - screen.cursor.x - right_status_length

    if draw_spaces > 0:
        bg = screen.cursor.bg
        screen.cursor.bg = 0
        screen.draw(" " * draw_spaces)
        screen.cursor.bg = bg

    if screen.columns - screen.cursor.x > right_status_length:
        screen.cursor.x = screen.columns - right_status_length

    screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
    screen.cursor.bg = 0

    screen.draw(bar_terminator)

    screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
    screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))

    screen.cursor.bold = screen.cursor.italic = True

    for cell in cells:
        screen.draw(cell)

    (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    ) = (
        saved_crs_fg,
        saved_crs_bg,
        saved_crs_bd,
        saved_crs_it,
    )
    return screen.cursor.x


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    _draw_icon(draw_data, screen, index, template="󰘧 ")
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        draw_data,
        screen,
        is_last,
    )

    return screen.cursor.x
