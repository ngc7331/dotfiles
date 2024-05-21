# ngc7331's modified version of
# fino-time.zsh-theme

# Use with a dark background and 256-color terminal!
# Meant for people with RVM and git. Tested only on OS X 10.7.

# You can set your computer name in the ~/.box-name file if you want.

# Borrowing shamelessly from these oh-my-zsh themes:
#   bira
#   robbyrussell
#
# Also borrowing from http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/

ZSH_THEME_COLOR_USER=033
ZSH_THEME_COLOR_HOST=033
ZSH_THEME_COLOR_PATH=034
ZSH_THEME_COLOR_TIME=239
ZSH_THEME_COLOR_GIT=214
ZSH_THEME_COLOR_PYVENV=214

ZSH_THEME_COLOR_DARK=239

function __dark {
    echo "%{$FG[${ZSH_THEME_COLOR_DARK}]%}$1%{$reset_color%}"
}

function __color {
    echo "%{$FG[$1]%}$2%{$reset_color%}"
}

function user_prompt_info {
    echo " $(__color ${ZSH_THEME_COLOR_USER} '%n')"
}

function host_prompt_info {
    local box="${SHORT_HOST:-$HOST}"
    [[ -f ~/.box-name ]] && box="$(< ~/.box-name)"
    echo " $(__dark @) $(__color ${ZSH_THEME_COLOR_HOST} ${box:gs/%/%%})"
}

function path_prompt_info {
    echo " $(__dark in) $(__color ${ZSH_THEME_COLOR_PATH} '%~')"
}

function time_prompt_info {
    echo " $(__dark [) $(__color ${ZSH_THEME_COLOR_TIME} '%D - %*') $(__dark ])"
}

function pyvenv_prompt_info {
    #[ $CONDA_DEFAULT_ENV ] && echo " $(__dark using) $CONDA_DEFAULT_ENV"
    #[ $VIRTUAL_ENV ] && echo " $(__dark using) `basename $VIRTUAL_ENV`"
    [ $CONDA_DEFAULT_ENV ] && echo " $(__dark using) $(__color ${ZSH_THEME_COLOR_PYVENV} $CONDA_DEFAULT_ENV)"
    [ $VIRTUAL_ENV ] && echo " $(__dark using) $(__color ${ZSH_THEME_COLOR_PYVENV} $(basename $VIRTUAL_ENV))"
}

function prompt_char {
    [[ $UID -eq 0 ]] && echo "#" && return
    echo "$"
}

PROMPT="
╭─\$(user_prompt_info)\$(host_prompt_info)\$(path_prompt_info)\$(git_prompt_info)\$(pyvenv_prompt_info)\$(time_prompt_info)
╰─\$(prompt_char) "

ZSH_THEME_GIT_PROMPT_PREFIX=" $(__dark on) %{$FG[${ZSH_THEME_COLOR_GIT}]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# disable python venv prompt
VIRTUAL_ENV_DISABLE_PROMPT=true
