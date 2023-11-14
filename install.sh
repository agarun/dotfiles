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
ln -sfn ~/.dotfiles/git/.gitconfig-work ~
ln -sfn ~/.dotfiles/git/.gitignore ~

ln -sfn ~/.dotfiles/run/.bash_profile ~

ln -sfn ~/.dotfiles/vim/.vimrc ~
if [ "$(find ~/.dotfiles/vim/ -mindepth 1 -type d)" ]; then
  yes | /bin/cp -rf ~/.dotfiles/vim/* ~/.vim/
fi

ln -sfn ~/.dotfiles/tmux/.tmux.conf ~

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # WSL2 / Linux
  # VS Code
  rm -rf /mnt/c/Users/Aaron/AppData/Roaming/Code/User/settings.json
  cp ~/.dotfiles/vscode/settings.json /mnt/c/Users/Aaron/AppData/Roaming/Code/User/settings.json
  rm -rf /mnt/c/Users/Aaron/AppData/Roaming/Code/User/keybindings.json
  cp ~/.dotfiles/vscode/keybindings.json /mnt/c/Users/Aaron/AppData/Roaming/Code/User/keybindings.json
  # Setup Git for Windows
  # https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-git (credentials) + gpg keys
  git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-wincred.exe"
  echo "pinentry-program \"/mnt/c/Program Files/Git/usr/bin/pinentry.exe\" --timeout 0" > ~/.gnupg/gpg-agent.conf
  echo "pinentry-timeout 0" >> ~/.gnupg/gpg-agent.conf
elif [ "$(uname)" == "Darwin" ]; then
  # MacOS
  # VS Code
  rm -rf $HOME/Library/Application Support/Code/User/settings.json
  cp ~/.dotfiles/vscode/settings.json $HOME/Library/Application Support/Code/User/settings.json
  rm -rf $HOME/Library/Application Support/Code/User/keybindings.json
  cp ~/.dotfiles/vscode/keybindings.json $HOME/Library/Application Support/Code/User/keybindings.json
  # skhd
  ln -sfn ~/.dotfiles/.skhdrc ~
fi

echo '😎'
