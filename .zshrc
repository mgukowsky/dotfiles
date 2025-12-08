# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=30

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Set up autocompletion for docker/docker compose, if needed
if [[ ! -e $ZSH/completions/_docker ]] && command -v docker >&/dev/null; then
  mkdir -p $ZSH/completions
  docker completion zsh > $ZSH/completions/_docker
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
HISTFILESIZE=${HISTSIZE}
SAVEHIST=${HISTSIZE}
setopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${HOME}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Various bash options; mainly from https://github.com/tonylambiris/dotfiles/blob/master/dot.zshrc
setopt extended_history         # Also record time and duration of commands.
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.
setopt share_history            # Allow multiple sessions to share history file
setopt inc_append_history       # Append to history file
setopt share_history            # Allow multiple shells to play nicely together with history file
setopt globdots                 # Have autocomplete to enumerate hidden files
unsetopt HIST_VERIFY # Don't expand history entries (e.g. `!` characters) and require a second ENTER press.

REPORTTIME=5 # Magic zsh variable to report stats for long-running commands (more than 5 secs)

export PATH=~/.local/bin:${HOME}/Tools/bin:$PATH

# Add ruby gems to path; from https://guides.rubygems.org/faqs/
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

# XDG directories
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Produce colored output in less and man (https://unix.stackexchange.com/questions/119/colors-in-man-pages)
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)
export GROFF_NO_SGR=1
export LESS="--RAW-CONTROL-CHARS"
[[ -f ~/.LESS_TERMCAP ]] && . ~/.LESS_TERMCAP

export EDITOR=$(which nvim)
export PAGER=$(which less)
export GIT_PAGER=$(which delta)
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/bat.conf"

# Make bat play nicely with man pages; see https://github.com/sharkdp/bat#man
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Used by the delta diff tool; see https://github.com/dandavison/delta#environment
export DELTA_PAGER="$(which bat) --style=plain"

# Function to pretty print help messages using bat, per
# https://github.com/sharkdp/bat#highlighting---help-messages
function bathelp {
  "$@" --help |& bat --plain --language=help
}

# Enable reverse search with Ctrl-R
bindkey -v
bindkey '^R' history-incremental-search-backward

# Scan for mode change every 50ms
export KEYTIMEOUT=5

# FZF integration (CTRL-T, CTRL-R, ALT-C). Also triggered in some
# circumstances by the `**<TAB>` sequence.
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

#export FZF_DEFAULT_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {}"'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND

# TODO: Temporarily disabled, as this is causing issues with powerlevel10k
# nvm setup from AUR package
# if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
#   source /usr/share/nvm/init-nvm.sh
# # but the installer from GitHub does things a little differently...
# elif [[ -e $XDG_CONFIG_HOME/nvm/nvm.sh ]]; then
#   export NVM_DIR="$XDG_CONFIG_HOME/nvm"
#   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# fi

# Start the ssh-agent automatically, if needed.
# From https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    # Powerlevel zsh scripts don't like IO during initialization, so we only print if
    # something goes wrong.
    if [[ -v $SSH_AGENT_PID ]]; then
      echo "Failed to start ssh-agent..."
    fi
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add &> /dev/null;
    if [[ $? -ne 0 ]]; then
      echo "Failed to add ssh key..."
    fi
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

function mkcd {
  if [[ ! -e $1 ]]; then
    mkdir -p $1
  fi
  cd $1
}

# Creates a proxy device that tunnels serial traffic from a WSL2 Windows host's COM port.
# The proxy device can then be accessed as a normal serial device (e.g. with minicom,
# screen, picocom, etc.). Requires that 'com2tcp' is accessible using the PATH on the Windows
# host side. Binaries can be retrieved from https://sourceforge.net/projects/com0com/files/com2tcp/1.3.0.0/
#
# Based on https://gist.github.com/DraTeots/e0c669608466470baa6c
function wsl2-com-proxy {
  COMSPEC=$(wslpath $(wslvar COMSPEC))

  if [[ $# -eq 1 && $1 == "kill" ]]; then
    kill $(pgrep -f 'socat.*cfmakeraw')
    kill -9 $(pgrep -f 'com2tcp')
    # Unfortunately hub4com.exe forks on the Windows side and will not die even when
    # the shell job that spawned it exits, so we have to go through the Windows shell to stop it.
    $COMSPEC /C "TASKKILL /F /IM hub4com.exe" 2>/dev/null
    echo "Removed COM proxy"
  elif [[ $# -eq 1 && $1 =~ "^[0-9]*$" ]]; then
    BAUD=115200
    PORT=8765
    VCOM=/tmp/comproxy/${1}

    if [[ -h $VCOM ]]; then
      echo "$VCOM already exists..."
      return 1
    fi

    # Start up the TCP server on the Windows side. While the internet indicates that the
    # 'com2tcp-rfc2217' variant is the best choice to tunnel serial traffic, that program seems
    # unable to take a baud rate argument, whereas the com2tcp version seems to work fine.
    $COMSPEC /C "com2tcp --baud $BAUD COM${1} $PORT" &

    # Retrieve the host PC's IP for the WSL network, which hosts the COM port server.
    WSL_HOST_IP=$($COMSPEC /C "ipconfig" 2>/dev/null | grep -A7 WSL | grep "IPv4 Address" | sed -r -e 's/.*\s(([0-9]{1,3}\.?){4}).*/\1/')

    # Use socat to wire everything up. The net result here is that the traffic from WSL_HOST_IP will
    # be sent to VCOM. We use a pty here rather than a /dev/ttyS* device, since those seem to be
    # borked ATM. 'cfmakeraw' should allow socat to forward the serial traffic correctly; if this
    # causes an issue, try replacing it with 'raw,echo=0'.
    socat tcp-connect:${WSL_HOST_IP}:${PORT} pty,cfmakeraw,link=${VCOM} &

    # If everything went according to plan, this symlink should have been created.
    echo "Created virtual COM port as $VCOM"
  else
    echo "Usage: wsl2-com-proxy [kill|PORTNUMBER]"
    return 1
  fi
}

# N.B. This will only work if there is an X server running on Windows!
function wsl2-xforward {
  export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
  export LIBGL_ALWAYS_INDIRECT=1
}

# Docker wrapper to start a container with X11-forwarding.
# Also works from within WSL, provided a call to wsl2-xforward has been made.
#
# Windows and Mac may need to tweak xserver options to allow remote connections first.
# Mac and Linux may need to run `xhost + 127.0.0.1` first to whitelist localhost connections to xserver.
#
# N.B. this command will also work when invoked directly from the Windows command prompt!
#
# N.B. this command does NOT provide network isolation when running on Linux, and should NOT be
# used to provide a sandbox!
#
# Inspired by https://medium.com/@mreichelt/how-to-show-x11-windows-within-docker-on-mac-50759f4b65cb
function xdocker {
  # Detect if we're running in a WSL instance, as the command will be a little different.
  # From https://stackoverflow.com/a/38859331
  if grep -qi microsoft /proc/version; then
    # `host.docker.internal` is a magic DNS name courtesy of Docker Desktop on Windows and Mac;
    # see https://docs.docker.com/docker-for-windows/networking/ for an explanation
    docker run -e DISPLAY=host.docker.internal:0 -e LIBGL_ALWAYS_INDIRECT=1 $@
  else
    # From https://dzone.com/articles/docker-x11-client-via-ssh
    # N.B. we are NOT providing network isolation!
    echo "Entering X-forwarded container; note that network isolation is NOT provided!"
    echo "DO NOT use this container as a sandbox!"
    docker run --net=host -e LIBGL_ALWAYS_INDIRECT=1 --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" $@
  fi
}

# venv convenience function
function vact {
  if [[ ! -e ./venv ]]; then
    python3 -m venv venv
  fi
  . ./venv/bin/activate
}

# Map a device type to an xinput ID. N.B. that only the first matching device ID will be returned
# (i.e. may not work properly in the event of multiple touchpads, etc.).
# Expects an argument that can be matched against the output of udevadm, e.g "TOUCHPAD" as in "ID_INPUT_TOUCHPAD".
# Inspired by https://unix.stackexchange.com/questions/671817/how-to-get-xinput-device-id-of-touchscreen-without-using-manufacturer-string
function get_xinput_id {
  if [[ $# -ne 1 ]]; then
    echo "Usage: get_xinput_id DEVICE_TYPE"
    echo "\te.g. get_xinput_id TOUCHSCREEN"
    echo "\te.g. get_xinput_id TOUCHPAD"
    return -1
  fi

  for input_event in $(ls /dev/input/event*); do
    if udevadm info --query=property --name=$input_event | grep $1 >& /dev/null; then
      local devpath=$(udevadm info --query=property --name=$input_event | grep DEVNAME | sed -r -e 's/.*\=(.*)/\1/')

      # N.B. if you omit the "; do ... done" pieces bash will consider your for loop to be a one-liner and will only
      # execute any commands after the first line once, even if they're indented ;)
      for xinput_id in $(xinput list --id-only); do
        local devnode=$(xinput list-props $xinput_id | grep "Device Node" | sed -r -e 's/.*\"(.*)\"/\1/')
        if [[ $devnode == $devpath ]]; then
          return $xinput_id
        fi
      done
    fi
  done
}

# Rotate the screen as well as relevant peripherals
function tablet-mode {
  local xrandr_arg
  local xinput_matrix

  get_xinput_id "TOUCHPAD"
  local touchpad_id=$?

  get_xinput_id "TOUCHSCREEN"
  local touchscreen_id=$?

  local ON="on"
  local OFF="off"

  if [[ $# -eq 1 && $1 == $ON ]]; then
    xrandr_arg="left"

    # N.B. we have to use a matrix here, as xinput expects each element of the matrix as a separate argument, therefore
    # we need to expand the array in order to pass each element distinctly; using a string would cause
    # the matrix to only be passed as a single argument, which xinput wouldn't understand.
    xinput_matrix=(0 -1 1 1 0 0 0 0 1)
  elif [[ $# -eq 1 && $1 == $OFF ]]; then
    xrandr_arg="normal"
    xinput_matrix=(0 0 0 0 0 0 0 0 0)
  else
    echo "Usage: tablet-mode $ON|$OFF"
    return 1
  fi

  # Rotate the screen...
  xrandr -o $xrandr_arg

  # Then rotate the touchpad and touchscreen (if present) to reflect the new orientation
  if [[ $touchpad_id -ne -1 ]]; then
    xinput set-prop $touchpad_id --type=float 'Coordinate Transformation Matrix' ${xinput_matrix[@]}
    echo "rotated touchpad with xinput id $touchpad_id"
  fi

  # TODO: gross duplication
  if [[ $touchscreen_id -ne -1 ]]; then
    xinput set-prop $touchscreen_id --type=float 'Coordinate Transformation Matrix' ${xinput_matrix[@]}
    echo "rotated touchscreen with xinput id $touchscreen_id"
  fi
}

# Put a laptop into low-power mode by stopping unneeded programs and putting hardware into low-power mode
function power-saver-mode {
  # Non-mission critical programs and services that we can safely stop to save power
  local POWPROGS=(picom dunst gitstatusd)
  local POWSERVICES=(docker expressvpn ntpd)
  local AMDDPMFILE=/sys/class/drm/card0/device/power_dpm_force_performance_level
  local AMDPOWPROFFILE=/sys/class/drm/card0/device/pp_power_profile_mode

  # Put CPU in low power mode
  echo "Putting CPU in low power mode..."
  sudo cpupower frequency-set -g powersave

  for prog in $POWPROGS; do
    if [[ -n "`pgrep $prog`" ]]; then
      echo "Killing $prog..."
      pkill $prog
    else
      echo "Not killing $prog because it isn't running"
    fi
  done

  for serv in $POWSERVICES; do
    echo "Stopping the $serv service..."
    sudo systemctl stop $serv
  done

  # If using an AMD gpu, put it in low power mode
  if [[ -n "`lsmod | grep amdgpu`" ]]; then
    echo "AMD GPU detected; putting it into power saving mode..."

    echo "manual" | sudo tee $AMDDPMFILE >/dev/null

    # Extract the ID of the power saver profile
    local AMDPOWPROFILEID=`cat $AMDPOWPROFFILE | grep POWER_SAVING | sed -re 's/^\s*([0-9]*).*/\1/'`
    echo "$AMDPOWPROFILEID" | sudo tee $AMDPOWPROFFILE >/dev/null
  fi

  echo 'Disabling radios (`rfkill unblock all` to unblock)...'
  rfkill block all
}

# Enable vi-style bindings
set -o vi

# Use local cache for CPM.cmake
export CPM_SOURCE_CACHE="$XDG_CACHE_HOME/.cpm"


# Allow expected backspace behavior in vi insert mode
bindkey "^?" backward-delete-char

# Source a given script if present
function source_if_present {
  if [[ $# -ne 1 ]]; then
    echo "Usage: source_if_present <path_to_script>"
    return -1
  fi

  if [[ -f $1 ]]; then
    . $1
  fi
}

source_if_present $XDG_DATA_HOME/sh/aliases.sh

# Pull in additional shell modules; these will need to be setup with symlinks in the
# appropriate location.
source_if_present $XDG_DATA_HOME/bin/blur-and-lock-screen.sh

# Finally, execute any additional commands specific to the local installation
source_if_present $XDG_DATA_HOME/.zshexrc

# Powerlevel10k stuff
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
