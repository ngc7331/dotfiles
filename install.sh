#!/bin/bash
if [ ! -x "`which zsh`" ]; then
    apt install zsh -y
fi

cp .zshrc ~/.zshrc
