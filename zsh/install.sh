#!/bin/bash

if [ ! -d ~/.oh-my-zsh  ]; then
  echo "oh-my-zsh is not installed"
  exit 1
fi

cd ~/.oh-my-zsh
git reset --hard
git pull
cd -

cp -r .oh-my-zsh ~/
