export PATH="/opt/homebrew/bin:$HOME/bin:$PATH";

eval "$(mise activate bash)"

for DOTFILE in ~/.dotfiles/system/.*; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

[[ $- != *i* ]] && return

eval "$(oh-my-posh init zsh --config ~/.dotfiles/oh-my-posh/aaron.omp.json)"
