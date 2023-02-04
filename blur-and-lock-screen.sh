#!/usr/bin/zsh

# Determine if the script is being invoked directly or sourced
# From https://stackoverflow.com/a/28776166
sourced=0
if [ -n "$ZSH_VERSION" ]; then
  case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd -- "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd -- "$(dirname -- "${.sh.file}")" && pwd -P)/$(basename -- "${.sh.file}")" ] && sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && sourced=1
else # All other shells: examine $0 for known shell binary filenames.
     # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|-sh|dash|-dash) sourced=1;; esac
fi

function blur-and-lock-screen {
  # if [[ $XDG_SESSION_TYPE != "x11" ]]; then
  #   # Default to vlock
  #   if command -v "vlock" &>/dev/null; then
  #     vlock -a
  #     return 0
  #   else
  #     echo "Could not lock screen because vlock could not be found"
  #     return 1
  #   fi
  # fi

  for dep in "maim" "convert" "i3lock"; do
    if ! command -v $dep &>/dev/null; then
      echo "Could not lock screen because $dep could not be found"
      return 1
    fi
  done

  local SSHOT_PATH=/tmp/lockscreenshot

  maim | convert - -blur 0x5 $SSHOT_PATH

  if [[ ! -f $SSHOT_PATH ]]; then
    echo "Could not lock screen because $SSHOT_PATH could not be found"
    return 1
  fi

  i3lock -efi $SSHOT_PATH
}

if [[ sourced -eq 0 ]]; then
  blur-and-lock-screen
fi
