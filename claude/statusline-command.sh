#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin with session context information

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
session_name=$(echo "$input" | jq -r '.session.name // .session.title // empty')
session_id=$(echo "$input" | jq -r '.session_id // .session.id // empty')

# Cyberpunk 24-bit truecolor palette.
# Raw escape sequences (not `tput setaf`) because `tput` only takes a single
# 0-255 color index, which can't express these specific RGB values.
CLR_MODEL='\033[38;2;255;46;196m'   # hot magenta #FF2EC4
CLR_CTX='\033[38;2;250;255;0m'      # neon yellow #FAFF00
CLR_QUOTA='\033[38;2;0;229;255m'    # neon cyan   #00E5FF
CLR_SESSION='\033[38;2;57;255;20m'  # neon green  #39FF14
CLR_RST='\033[0m'

# Resolve session label: prefer a human-friendly name; otherwise abbreviate
# a UUID-style id to 6 alphanumeric characters (a la `git rev-parse --short`).
if [ -n "$session_name" ]; then
  session_label="$session_name"
elif [ -n "$session_id" ]; then
  if [[ "$session_id" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    session_label=$(echo "$session_id" | tr -d -- '-' | cut -c1-6)
  else
    session_label="$session_id"
  fi
else
  session_label=""
fi

# Build optional quota string
if [ -n "$five_hr" ] && [ -n "$seven_day" ]; then
  quota_str=$(printf "%.0f%%/%.0f%%" "$five_hr" "$seven_day")
elif [ -n "$five_hr" ]; then
  quota_str=$(printf "%.0f%%/--" "$five_hr")
elif [ -n "$seven_day" ]; then
  quota_str=$(printf "--/%.0f%%" "$seven_day")
else
  quota_str=""
fi

# Base segment (always present): model — 3 specifiers, 3 args
printf "%b%s%b" \
  "$CLR_MODEL" "󱜙 $model" "$CLR_RST"

# Optional session segment — 3 specifiers, 3 args
if [ -n "$session_label" ]; then
  printf " %b%s%b" \
    "$CLR_SESSION" "󱅰 $session_label" "$CLR_RST"
fi

# Optional ctx segment — 3 specifiers, 3 args
if [ -n "$used_pct" ]; then
  printf " %b%s%.0f%%%b" \
    "$CLR_CTX" " " "$used_pct" "$CLR_RST"
fi

# Optional quota segment — 3 specifiers, 3 args
if [ -n "$quota_str" ]; then
  printf " %b%s%b" \
    "$CLR_QUOTA" "󰊚 $quota_str" "$CLR_RST"
fi
