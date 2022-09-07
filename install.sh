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

confirm() {
    hint=$1
    default=$2
    read -p "$1 " choice
    case $choice in
    [yY][eE][sS] | [yY] )
        return 0;;
    [nN][oO] | [nN] )
        echo "Abort"
        exit 1;;
    * ) case $default in
        Y )
            return 0;;
        N )
            echo "Abort"
            exit 1;;
        esac ;;
    esac
}

zshrc() {
    # zsh
    if [ ! -x "`which zsh`" ]; then
        install zsh
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    if [ -f ~/.zshrc ]; then
        confirm "~/.zshrc exists, override(y/N)?" N
        cp -f ~/.zshrc ~/.zshrc.bak
        echo "-> existing ~/.zshrc copied to ~/.zshrc.bak"
    fi

    cp -f .zshrc ~/.zshrc
    echo "-> .zshrc copied to ~/.zshrc"

    echo 'hint: run "chsh -s `which zsh`" to set your default shell'
    echo 'hint: run "source ~/.zshrc" or restart your terminal to use zsh'
}

zshrc
