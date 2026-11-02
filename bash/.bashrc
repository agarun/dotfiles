export DOTFILES="$HOME/.dotfiles"

for brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$brew" ] && eval "$("$brew" shellenv)"
done
unset brew

path_dirs=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/bin"
  "$HOME/bin"
)
for dir in "${path_dirs[@]}"; do
  [ -d "$dir" ] && PATH="$dir:$PATH"
done
unset dir path_dirs
export PATH

# interactive sessions start here

case $- in
  *i*) ;;
  *) return ;;
esac

shopt -s histappend checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ⋇ completions

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

if [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
elif [ -d "$HOMEBREW_PREFIX/etc/bash_completion.d" ]; then
  for file in "$HOMEBREW_PREFIX"/etc/bash_completion.d/*; do
    [ -r "$file" ] && . "$file"
  done
  unset file
fi

# ⋇ configs

. "$DOTFILES/bash/exports.sh"
. "$DOTFILES/bash/aliases.sh"
. "$DOTFILES/bash/functions.sh"
. "$DOTFILES/bash/wsl.sh"

# ⋇ tooling

export GPG_TTY=$(tty)

if command -v mise >/dev/null; then
  eval "$(mise activate bash)"
  eval "$(mise completion bash)"
fi

command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init bash --config "$DOTFILES/oh-my-posh/aaron.omp.json")"

if command -v zoxide >/dev/null; then
  eval "$(zoxide init bash)"
  _z_complete() {
    __zoxide_z_complete
    [[ $COMP_CWORD == 1 && $2 && ! $COMPREPLY ]] && mapfile -t COMPREPLY < <(zoxide query --exclude "$PWD" -- "$2" 2>/dev/null)
  }
  complete -F _z_complete -o filenames z
fi
