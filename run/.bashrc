for dir in /home/linuxbrew/.linuxbrew/bin /opt/homebrew/bin "$HOME/.local/share/mise/shims" "$HOME/.local/bin" "$HOME/bin"; do
  [ -d "$dir" ] && PATH="$dir:$PATH"
done
unset dir
export PATH

# machine-specific setup, not in the repo (wrap interactive-only lines in `if [[ $- == *i* ]]`)
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

case $- in
  *i*) ;;
  *) return ;;
esac

shopt -s histappend checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# kom igen nu
for DOTFILE in ~/.dotfiles/system/.*; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done
unset DOTFILE

export GPG_TTY=$(tty)

command -v mise >/dev/null && eval "$(mise activate bash)"

command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init bash --config ~/.dotfiles/oh-my-posh/aaron.omp.json)"
