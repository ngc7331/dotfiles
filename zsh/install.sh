#!/bin/bash

if [ ! -d ~/.oh-my-zsh  ]; then
  echo "oh-my-zsh is not installed"
  echo "See https://ohmyz.sh/#install for installation instructions"
  exit 1
fi

echo "Updating oh-my-zsh"
cd ~/.oh-my-zsh
git reset --hard
git pull
cd - > /dev/null

echo "Installing modifies"
cp -r .oh-my-zsh ~/

echo "Updating ~/.zshrc"
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="fino-time-mod"/g' ~/.zshrc

echo "Done"
echo
echo "Restart your terminal or run 'source ~/.zshrc' to see the changes"
echo "Run 'chsh -s $(which zsh)' to set zsh as your default shell"
echo
echo "In case you want to change the prompt color:"
echo "  1. Test the colors by running './color-test.sh'"
echo "  2. Update the 'ZSH_THEME_COLOR_XXX' in '~/.oh-my-zsh/themes/fino-time-mod.zsh-theme'"
