#!/bin/bash

has() { type "$1" &>/dev/null; }

BATTERY_DANGER=20

get_current_load() {
  local current_bat percentage

  if has "pmset"; then
    current_bat="$(pmset -g ps | grep -o '[0-9]\+%' | tr -d '%')"
  elif has "ioreg"; then
    local _battery_info _max_cap _cur_cap
    _battery_info="$(ioreg -n AppleSmartBattery)"
    _max_cap="$(echo "$_battery_info" | awk '/MaxCapacity/{print $5}')"
    _cur_cap="$(echo "$_battery_info" | awk '/CurrentCapacity/{print $5}')"
    current_bat="$(awk -v cur="$_cur_cap" -v max="$_max_cap" 'BEGIN{ printf("%.2f\n", cur/max*100) }')"
  fi

  echo "$current_bat"
}

get_percentage() {
  local current_load="${1:-$(get_current_load)}"
  local percentage="$(echo "$current_load" | awk '{print int($1+0.5)}')"

  if [ -n "$percentage" ]; then
    echo "$percentage"
  fi
}

get_icon() {
  local load
  load="${1:-$(get_current_load)}"

  local icons=(
    "󰂑"
    "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑"
    "󰂑"
    "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑" "󰂑"
  )

  local icon_index="$(echo "$load" | awk '{print int($1/10+0.5)}')"

  if is_charging; then icon_index=$(($icon_index + 10)); fi

  echo -e "${icons[$icon_index]}"
}

# is_charging returns true if the battery is charging
is_charging() {
  if has "pmset"; then
    pmset -g ps | grep -E "Battery Power|charged" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      return 1
    else
      return 0
    fi
  elif has "ioreg"; then
    ioreg -c AppleSmartBattery | grep "IsCharging" | grep "Yes" >/dev/null 2>&1
    return $?
  else
    return 1
  fi
}

# battery_color_ansi colourizes the battery level for the terminal
battery_color_ansi() {
  local percentage
  percentage="${1:-$(get_percentage)}"

  if is_charging; then
    [[ -n $percentage ]] && echo -e "\033[32m${percentage}%\033[0m"
  else
    if [ "${percentage%%%*}" -ge "$BATTERY_DANGER" ]; then
      echo -e "\033[34m${percentage}%\033[0m"
    else
      echo -e "\033[31m${percentage}%\033[0m"
    fi
  fi
}

battery_color_kitty() {
  local load
  load="${1:-$(get_current_load)}"
  local percentage="$(get_percentage "$load")"

  echo -e "$(get_icon) ${percentage}%"
}

battery_color_tmux() {
  local percentage
  percentage="${1:-$(get_percentage)}"

  if is_charging; then
    [[ -n $percentage ]] && echo -e "#[fg=green]$(get_icon) ${percentage}%#[default]"
  else
    if [ "${percentage%%%*}" -ge "$BATTERY_DANGER" ]; then
      echo -e "#[fg=blue]$(get_icon) ${percentage}%#[default]"
    else
      echo -e "#[fg=red]$(get_icon) ${percentage}%#[default]"
    fi
  fi
}

get_remain() {
  local time_remain

  if has "pmset"; then
    time_remain="$(pmset -g ps | grep -o '[0-9]\+:[0-9]\+')"
    if [ -z "$time_remain" ]; then
      time_remain="no estimate"
    fi
  elif has "ioreg"; then
    local itte
    itte="$(ioreg -n AppleSmartBattery | awk '/InstantTimeToEmpty/{print $5}')"
    time_remain="$(awk -v remain="$itte" 'BEGIN{ printf("%dh%dm\n", remain/60, remain%60) }')"
    if [ -z "$time_remain" ] || [ "${time_remain%%h*}" -gt 10 ]; then
      time_remain="no estimate"
    fi
  else
    time_remain="no estimate"
  fi

  echo "$time_remain"
  if [ "$time_remain" = "no estimate" ]; then
    return 1
  fi
}

for i in "$@"; do
  case "$i" in
    "-h" | "--help")
      echo "usage: battery [--help|-h][--ansi|--tmux][-r|--remain]" 1>&2
      echo "  Getting the remaining battery, then" 1>&2
      echo "  outputs and colourizes with options" 1>&2
      exit
      ;;
    "--numeric")
      get_percentage
      exit $?
      ;;
    "--ansi")
      battery_color_ansi "$(get_percentage)"
      exit $?
      ;;
    "--kitty")
      battery_color_kitty "$(get_percentage)"
      exit $?
      ;;
    "--tmux")
      battery_color_tmux "$(get_percentage)"
      exit $?
      ;;
    "-r" | "--remain")
      get_remain
      exit $?
      ;;
    -* | --*)
      echo "$i: unknown option" 1>&2
      exit 1
      ;;
  esac
done

get_current_load
