# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# kom igen nu
for DOTFILE in "~/dotfiles/system/.{aliases,functions}"; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done
