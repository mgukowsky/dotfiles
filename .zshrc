# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/mgukowsky/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel9k/powerlevel9k"

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
HISTSIZE=1000
SAVEHIST=1000
setopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mgukowsky/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
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
export PATH=$PATH:${HOME}/Tools/bin

# Enable reverse search with Ctrl-R
bindkey -v
bindkey '^R' history-incremental-search-backward

# Scan for mode change every 50ms
export KEYTIMEOUT=5

function mkcd {
  if [[ ! -e $1 ]]; then
    mkdir -p $1
  fi
  cd $1
}

function refresh_ctags  {
  ctags -R --tag-relative=yes --exclude=.git --exclude=build .
}

# Enable a certain dirty word which can fix commands
eval $(thefuck --alias)

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
