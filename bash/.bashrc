export DOTFILES="$HOME/.dotfiles"

# ---- PATH --------------------------------------------------------------------

for brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$brew" ] && eval "$("$brew" shellenv)"
done
unset brew

# Last one listed ends up first in PATH.
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

# ---- Interactive only from here ----------------------------------------------

case $- in
  *i*) ;;
  *) return ;;
esac

shopt -s histappend checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ---- Completion --------------------------------------------------------------

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

# ---- Config ------------------------------------------------------------------

. "$DOTFILES/bash/exports.sh"
. "$DOTFILES/bash/aliases.sh"
. "$DOTFILES/bash/functions.sh"
. "$DOTFILES/bash/wsl.sh"

# ---- Tools -------------------------------------------------------------------

export GPG_TTY=$(tty)

if command -v mise >/dev/null; then
  eval "$(mise activate bash)"
  eval "$(mise completion bash)"
fi

command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init bash --config "$DOTFILES/oh-my-posh/aaron.omp.json")"
