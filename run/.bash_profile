# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# in case there's a generated .profile which is 
# often disabled by a .bash_profile existing
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# kom igen nu
for DOTFILE in ~/.dotfiles/system/.*; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

# oh-my-posh theme
eval "`oh-my-posh init bash --config ~/.dotfiles/oh-my-posh/aaron.omp.json`"
