#!/bin/bash
# is root user?
if [ $UID -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

install() {
    prog=$1
    if [ -x "`which apt`" ]; then
        echo "$prog not found, trying to install with apt"
        $SUDO apt update && $SUDO apt install $prog -y
    elif [ -x "`which yum`" ]; then
        echo "$prog not found, trying to install with yum"
        $SUDO yum install $prog -y
    else
        echo "$prog not found, please install it"
        return 1
    fi
    return 0
}

zshrc() {
    # zsh
    if [ ! -x "`which zsh`" ]; then
        install zsh
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    cp .zshrc ~/.zshrc
    echo ".zshrc copied to ~/.zshrc"

    echo 'run "chsh -s `which zsh`" to set your default shell'
    echo 'run "source ~/.zshrc" or restart your terminal to use zsh'
}

zshrc
