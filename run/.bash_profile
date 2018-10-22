# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# TODO: temporarily, until I split out my zsh config 🤨
if  [ -z $ZSH_VERSION ]; then
  # Append to the Bash history file, rather than overwriting it
  shopt -s histappend

  # Autocorrect typos in path names when using `cd`
  shopt -s cdspell

  # Add `killall` tab completion for common apps
  complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
fi

# kom igen nu
for DOTFILE in ~/.dotfiles/system/.*; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done
