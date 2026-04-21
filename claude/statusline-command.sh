#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin with session context information

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Cyberpunk 24-bit truecolor palette
CLR_MODEL='\033[38;2;255;46;196m'   # hot magenta #FF2EC4
CLR_CTX='\033[38;2;250;255;0m'      # neon yellow #FAFF00
CLR_QUOTA='\033[38;2;0;229;255m'    # neon cyan   #00E5FF
CLR_RST='\033[0m'

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
