#!/bin/bash

set -e

AUTO=${AUTO:-}

if [ ! "$(which zsh)" ]; then 
  if [ ! "${AUTO}" ]; then
    echo "zsh is not installed"
    echo "Please install zsh before running this script"
    echo "Or set AUTO=1 to try install zsh automatically"
    exit 1
  fi

  echo "Installing zsh"
  if [ "$(which apt)" ]; then
    sudo apt install zsh
  elif [ "$(which dnf)" ]; then
    sudo dnf install zsh
  elif [ "$(which yum)" ]; then
    sudo yum install zsh
  else
    echo "Unsupported OS, please install zsh manually"
    exit 1
  fi
fi

if [ ! -d ~/.oh-my-zsh  ]; then
  if [ ! "${AUTO}" ]; then
    echo "oh-my-zsh is not installed"
    echo "Please install oh-my-zsh before running this script"
    echo "See https://ohmyz.sh/#install for installation instructions"
    echo "Or set AUTO=1 to try install oh-my-zsh automatically"
    exit 1
  fi

  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Installing customs"
cp -r ./custom/* ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo "Updating ~/.zshrc"
sed -i 's/^ZSH_THEME=".*"$/ZSH_THEME="fino-time-mod"/g' ~/.zshrc
sed -i 's/^plugins=\(.*\)$/plugins=(cp git gpg-agent timer)/g' ~/.zshrc

echo "Done"
echo
echo "Restart your terminal or run 'source ~/.zshrc' to see the changes"
echo "Run 'chsh -s $(which zsh)' to set zsh as your default shell"
echo
echo "In case you want to change the prompt color:"
echo "  1. Test the colors by running './color-test.sh'"
echo "  2. Update the 'ZSH_THEME_COLOR_XXX' in '~/.oh-my-zsh/themes/fino-time-mod.zsh-theme'"
