#!/usr/bin/env bash

echo '💭… '

current_folder="$(pwd)"
dotfiles_folder="$HOME/.dotfiles"

if [ "$current_folder" != "$dotfiles_folder" ]; then
  echo "This project needs to be cloned into the ~/.dotfiles directory"
fi

echo '☀️… '

if test $(which brew); then
  brew analytics off
  brew update
fi

cd ~/.dotfiles/brew
brew bundle
cd ..

ln -sfn ~/.dotfiles/git/.gitconfig ~
ln -sfn ~/.dotfiles/git/.gitignore ~

ln -sfn ~/.dotfiles/run/.bash_profile ~

ln -sfn ~/.dotfiles/vim/.vimrc ~
yes | /bin/cp -rf ~/.dotfiles/vim/* ~/.vim/

ln -sfn ~/.dotfiles/tmux/.tmux.conf ~

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # WSL2 / Linux
  rm -rf /mnt/c/Users/Aaron/AppData/Roaming/Code/User/settings.json
  cp ~/.dotfiles/vscode/settings.json /mnt/c/Users/Aaron/AppData/Roaming/Code/User/settings.json
elif [ "$(uname)" == "Darwin" ]; then
  # MacOS
  rm -rf $HOME/Library/Application Support/Code/User/settings.json
  cp ~/.dotfiles/vscode/settings.json $HOME/Library/Application Support/Code/User/settings.json

  ln -sfn ~/.dotfiles/.skhdrc ~
fi

echo '😎'
