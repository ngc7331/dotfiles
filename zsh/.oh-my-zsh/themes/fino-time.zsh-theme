# ngc7331' modified version:

# fino-time.zsh-theme

# Use with a dark background and 256-color terminal!
# Meant for people with RVM and git. Tested only on OS X 10.7.

# You can set your computer name in the ~/.box-name file if you want.

# Borrowing shamelessly from these oh-my-zsh themes:
#   bira
#   robbyrussell
#
# Also borrowing from http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/

function user_prompt_info {
    echo " %{$FG[040]%}%n%{$reset_color%}"
}

function host_prompt_info {
    local box="${SHORT_HOST:-$HOST}"
    [[ -f ~/.box-name ]] && box="$(< ~/.box-name)"
    echo " %{$FG[239]%}@%{$reset_color%} %{$FG[033]%}${box:gs/%/%%}%{$reset_color%}"
}

function path_prompt_info {
    echo " %{$FG[239]%}in%{$reset_color%} %{$terminfo[bold]$FG[226]%}%~%{$reset_color%}"
}

function time_prompt_info {
    echo " %D - %*"
}

function pyvenv_prompt_info {
    [ $CONDA_DEFAULT_ENV ] && echo " %{$FG[239]%}using%{$reset_color%} $CONDA_DEFAULT_ENV"
    [ $VIRTUAL_ENV ] && echo " %{$FG[239]%}using%{$reset_color%} `basename $VIRTUAL_ENV`"
}

function prompt_char {
    [[ $UID -eq 0 ]] && echo "#" && return
    echo "$"
}

PROMPT="
╭─\$(user_prompt_info)\$(host_prompt_info)\$(path_prompt_info)\$(git_prompt_info)\$(pyvenv_prompt_info)
╰─\$(prompt_char) "

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[239]%}on%{$reset_color%} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[202]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# disable python venv prompt
VIRTUAL_ENV_DISABLE_PROMPT=true
