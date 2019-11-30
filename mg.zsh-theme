# My personal zsh theme, forked from agnoster's theme (https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/agnoster.zsh-theme)
#
# Controlled by the following environment variables
#   MGPROMPT_SHOW_CONTEXT ->  if set, this will show the standard "<user>@<hostname>" prompt in the
#                             first segment.
#

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

MGPROMPT_HAPPY_EMOJIS=(😀 😁 😄 😆 😊 😍 🥰 😚 🤩 🤗 🐵 🐶 🐱 🐼 🐸 😇 🤓 🤠 🥳 🤑 👾 🤖)
MGPROMPT_HAPPY_EMOJIS_LENGTH=${#MGPROMPT_HAPPY_EMOJIS[@]}
MGPROMPT_SAD_EMOJIS=(😮 😯 😫 😓 😲 😖 😞 😢 😭 😧 😰 😱 😵 😡 😠 🤬 🤕 🤮 😈 ☠️  💩 🤢 😷)
MGPROMPT_SAD_EMOJIS_LENGTH=${#MGPROMPT_SAD_EMOJIS[@]}

MGPROMPT_NOW=/tmp/MGPROMPT_NOW_$(echo $$) 

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ -n "$MGPROMPT_SHOW_CONTEXT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue $CURRENT_FG '%~'
}

# Magic hook which is called when a command line has been evaluated. We
# use it start the timer for the requested command.
zle-line-finish() {
  echo -n $(date +%s%N) > $MGPROMPT_NOW
}

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

# Calculates the amount of time that the previous command took to execute, with
# microsecond precision. N.B. will print ∞ if no previous timestamp is found (i.e. the first command when the shell is started)
# Can also print an incorrect number if /tmp/MGPROMPT_NOW_<shell PID> already exists...
# Should not be used for performance metrics, as this attempts to account for the time it takes to parse this file, draw the prompt, etc., but this is not perfect...
generate_time_taken() {
  local NOW=$(date +%s%N)
  if [[ -e $MGPROMPT_NOW ]]; then
    printf "%.6fs" "$((($NOW - $(cat ${MGPROMPT_NOW}))/1000000000.0))"
  else
    echo -n "∞"
  fi
}

# Magic hook functions to detect whether we are in vi cmd or
# vi insert mode, and set the cursor to block or beam as
# appropriate (i.e. via the 'echo' commands)
function zle-line-init zle-keymap-select {
    case $KEYMAP in
      vicmd)
        echo -ne '\e[1 q';;
      viins|main)
        echo -ne '\e[5 q';;
    esac
}

zle -N zle-line-init
zle -N zle-keymap-select

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
  
  symbols+=$(generate_emoji)

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

## Get a random emoji:

PROMPT='%{%f%b%k%}$(build_prompt) '
RPS1='↳ $(generate_time_taken)'
