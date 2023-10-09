# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# oh-my-posh theme
eval "`oh-my-posh init bash --config ~/Projects/dotfiles/oh-my-posh/aaron.omp.json`"

# kom igen nu
for DOTFILE in ~/.dotfiles/system/.*; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done
