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
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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

source $ZSH/oh-my-zsh.sh

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
unsetopt HIST_VERIFY # Don't expand history entries (e.g. `!` characters) and require a second ENTER press.

REPORTTIME=5 # Magic zsh variable to report stats for long-running commands (more than 5 secs)

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ip='ip --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lld='lsd -halF'
alias treed='lsd --tree'
alias adog='git log --all --decorate --oneline --graph'

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
alias vim='nvim'
export PAGER=$(which less)
export GIT_PAGER=$(which delta)
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/bat.conf"

# Make bat play nicely with man pages; see https://github.com/sharkdp/bat#man
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Used by the delta diff tool; see https://github.com/dandavison/delta#environment
export DELTA_PAGER="$(which bat) --style=plain"
export PATH=~/.local/bin:${HOME}/Tools/bin:$PATH

# XDG directories
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg

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

# nvm setup from AUR package
if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
  source /usr/share/nvm/init-nvm.sh
# but the installer from GitHub does things a little differently...
elif [[ -e $XDG_CONFIG_HOME/nvm/nvm.sh ]]; then
  export NVM_DIR="$XDG_CONFIG_HOME/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

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

# Incantation to launch a Jupyter Lab server. Run `docker logs jupyterlab` to get the container
# URL w/ the access token. N.B. we use --name to help enforce only running one instance of this
# container at any given time.
function launch-jupyter {
  docker run --rm -d --user `id -u`:`id -g` -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v ~/Workspace:/home/jovyan/work --name=jupyterlab jupyter/all-spark-notebook
}

function mkcd {
  if [[ ! -e $1 ]]; then
    mkdir -p $1
  fi
  cd $1
}

function refresh_ctags  {
  ctags -R --tag-relative=yes --exclude=.git --exclude=build .
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
# Inspired by https://medium.com/@mreichelt/how-to-show-x11-windows-within-docker-on-mac-50759f4b65cb
function xdocker {
  # `host.docker.internal` is a magic DNS name courtesy of Docker Desktop on Windows and Mac;
  # see https://docs.docker.com/docker-for-windows/networking/ for an explanation
  docker run -e DISPLAY=host.docker.internal:0 -e LIBGL_ALWAYS_INDIRECT=1 $@
}

# Enable vi-style bindings
set -o vi

# Allow expected backspace behavior in vi insert mode
bindkey "^?" backward-delete-char

MGPROMPT_HAPPY_EMOJIS=(😀 😁 😄 😆 😊 😍 🥰 😚 🤩 🤗 🐵 🐶 🐱 🐼 🐸 😇 🤓 🤠 🥳 🤑 👾 🤖)
MGPROMPT_HAPPY_EMOJIS_LENGTH=${#MGPROMPT_HAPPY_EMOJIS[@]}
MGPROMPT_SAD_EMOJIS=(😮 😯 😫 😓 😲 😖 😞 😢 😭 😧 😰 😱 😵 😡 😠 🤬 🤕 🤮 😈 ☠️  💩 🤢 😷)
MGPROMPT_SAD_EMOJIS_LENGTH=${#MGPROMPT_SAD_EMOJIS[@]}

# Emoji: generate an emoji based on current statuses
# N.B we add 1 to the index to account for the fact that bash array indices start at 1...
# Also N.B. we are assuming that the length of the emoji arrays is less than 256!
generate_emoji() {
  local emojis emojis_len
  if [[ $RETVAL -eq 0 ]]; then
    emojis=("${MGPROMPT_HAPPY_EMOJIS[@]}")
    emojis_len=$MGPROMPT_HAPPY_EMOJIS_LENGTH
  else
    emojis=("${MGPROMPT_SAD_EMOJIS[@]}")
    emojis_len=$MGPROMPT_SAD_EMOJIS_LENGTH
  fi

  echo -n ${emojis[$((($(od -A n -t d -N 1 /dev/urandom) % $emojis_len) + 1))]}
}

# Powerlevel9k stuff
# Use the generate_emoji function to create a prompt segment
POWERLEVEL9K_CUSTOM_EMOJI="generate_emoji"
POWERLEVEL9K_CUSTOM_EMOJI_BACKGROUND='029'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_emoji dir_writable dir vcs vi_mode)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs command_execution_time)

# Always show time taken
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='238'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='208'

# Show the vi mode
POWERLEVEL9K_VI_INSERT_MODE_STRING='I'
POWERLEVEL9K_VI_COMMAND_MODE_STRING='N'
POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND='003'
POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND='054'

plugins=(zsh-syntax-highlighting)

# Finally, execute any additional commands specific to the local installation
EXRC=$XDG_DATA_HOME/.zshexrc
if [[ -f $EXRC ]]; then
  . $EXRC
fi

# Powerlevel10k stuff
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
