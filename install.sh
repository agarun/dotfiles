#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

backup() {
  mkdir -p "$BACKUP"
  mv "$1" "$BACKUP/$(basename "$1")"
  echo "  backed up $1"
}

link() {
  local src="$DOTFILES/$1" dest=$2
  [ "$(readlink "$dest" 2>/dev/null)" = "$src" ] && return
  if [ -L "$dest" ]; then rm "$dest"; elif [ -e "$dest" ]; then backup "$dest"; fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  linked $dest"
}

make_local() {
  local file="$DOTFILES/$1"
  if [ -e "$file" ]; then cat >/dev/null; return; fi
  cat > "$file"
  echo "  created $1"
}

# NOTE: Windows symlinks need admin rights or Developer Mode. Missing ones are created together after an admin prompt.
win_pending=()

winlink() {
  local src="$DOTFILES/$1" dest=$2
  [ -L "$dest" ] && return
  [ -e "$dest" ] && backup "$dest"
  mkdir -p "$(dirname "$dest")"
  if (cd /mnt/c && cmd.exe /c mklink "$(wslpath -w "$dest")" "$(wslpath -w "$src")" >/dev/null 2>&1); then
    echo "  linked $dest"
  else
    win_pending+=("$dest|$src")
  fi
}

winlink_flush() {
  [ ${#win_pending[@]} -eq 0 ] && return
  local script="$win/AppData/Local/Temp/dotfiles-links.ps1" entry dest src
  mkdir -p "$(dirname "$script")"
  : > "$script"
  for entry in "${win_pending[@]}"; do
    dest=${entry%%|*} src=${entry#*|}
    printf "New-Item -ItemType SymbolicLink -Force -Path '%s' -Target '%s' | Out-Null\n" \
      "$(wslpath -w "$dest")" "$(wslpath -w "$src")" >> "$script"
  done
  echo "  creating ${#win_pending[@]} Windows link(s): approve the admin prompt"
  (cd /mnt/c && powershell.exe -NoProfile -Command \
    "Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$(wslpath -w "$script")'") || true
  rm -f "$script"
  for entry in "${win_pending[@]}"; do
    dest=${entry%%|*}
    if [ -L "$dest" ]; then echo "  linked $dest"; else echo "  FAILED $dest"; fi
  done
}

# ask VAR "question": read an answer from the terminal, blank if there is none
ask() {
  local answer=''
  if (: </dev/tty) 2>/dev/null; then read -r -p "$2" answer </dev/tty || true; fi
  printf -v "$1" '%s' "$answer"
}

is_mac() { [ "$(uname -s)" = Darwin ]; }
is_wsl() { grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }

# ⋇ Shell

make_local bash/.bashrc.local <<'EOF'
. ~/.dotfiles/bash/.bashrc
EOF

make_local bash/.bash_profile.local <<'EOF'
. ~/.dotfiles/bash/.bash_profile
EOF

if [ -f "$HOME/.bashrc.local" ] && [ ! -L "$HOME/.bashrc.local" ]; then
  cat "$HOME/.bashrc.local" >> "$DOTFILES/bash/.bashrc.local"
  backup "$HOME/.bashrc.local"
  echo "  moved ~/.bashrc.local into bash/.bashrc.local"
fi

link bash/.bashrc.local       "$HOME/.bashrc"
link bash/.bash_profile.local "$HOME/.bash_profile"

# ⋇ Git

for old in "$HOME/.gitconfig-work" "$HOME/.gitignore"; do
  [ -L "$old" ] && rm "$old"
done

if [ ! -e "$DOTFILES/git/.gitconfig.local" ]; then
  ask work_email "Work git email (blank for none): "
  if [ -n "$work_email" ]; then
    ask work_dir "Work repos folder, e.g. ~/Projects/Work/: "
    case $work_dir in */) ;; *) work_dir="$work_dir/" ;; esac
  fi

  printf '[include]\n\tpath = ~/.dotfiles/git/.gitconfig\n' > "$DOTFILES/git/.gitconfig.local"
  if [ -n "$work_email" ]; then
    printf '\n[includeIf "gitdir:%s"]\n\tpath = ~/.dotfiles/git/.gitconfig-work.local\n' "$work_dir" >> "$DOTFILES/git/.gitconfig.local"
    printf '[user]\n\temail = %s\n\n[commit]\n\tgpgsign = false\n' "$work_email" > "$DOTFILES/git/.gitconfig-work.local"
    echo "  created git/.gitconfig-work.local"
  fi
  echo "  created git/.gitconfig.local"
fi

link git/.gitconfig.local "$HOME/.gitconfig"

# ⋇ Tools

link mise/config.toml "$HOME/.config/mise/config.toml"
link vim/.vimrc       "$HOME/.vimrc"

# ⋇ Packages

brew=$(command -v brew || ls /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew 2>/dev/null | head -1 || true)
if [ -n "$brew" ]; then
  "$brew" trust jandedobbeleer/oh-my-posh >/dev/null 2>&1 || true
  "$brew" bundle check --no-upgrade --file "$DOTFILES/brew/Brewfile" >/dev/null ||
    "$brew" bundle install --no-upgrade --file "$DOTFILES/brew/Brewfile" || echo "  brew bundle failed, see above"
else
  echo "  Homebrew not found, install it from https://brew.sh then re-run"
fi

mise=$(command -v mise || ls "$HOME/.local/bin/mise" 2>/dev/null || true)
if [ -n "$mise" ]; then
  "$mise" install --yes || echo "  mise install failed, see above"
else
  echo "  mise not found, install it with: curl https://mise.run | sh"
fi

# ⋇ macOS

if is_mac; then
  bash_path=/opt/homebrew/bin/bash
  if [ -x "$bash_path" ] && [ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" != "$bash_path" ]; then
    grep -qx "$bash_path" /etc/shells || echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$bash_path"
    echo "  login shell is now $bash_path, open a new terminal"
  fi

  link macos/.skhdrc "$HOME/.skhdrc"
  vscode="$HOME/Library/Application Support/Code/User"
  link vscode/settings.json    "$vscode/settings.json"
  link vscode/keybindings.json "$vscode/keybindings.json"
fi

# ⋇ WSL + Windows

if is_wsl; then
  link wsl/gpg-agent.conf "$HOME/.gnupg/gpg-agent.conf"
  git config --global --get credential.helper >/dev/null ||
    git config --global credential.helper \
      '/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-wincred.exe'

  if [ ! -e "$DOTFILES/windows/hotkeys.local.ahk" ]; then
    ask neue_url "Neue URL for the AHK hotkey (blank to skip): "
  fi

  make_local windows/hotkeys.local.ahk <<EOF
#Requires AutoHotkey v2.0

NeueUrl := "$neue_url"

#Include $(wslpath -w "$DOTFILES/windows/hotkeys.ahk")
EOF

  win=$(wslpath "$(cd /mnt/c && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
  startup="$win/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"

  winlink windows/hotkeys.local.ahk               "$startup/hotkeys.ahk"
  winlink wezterm/wezterm.lua                     "$win/.wezterm.lua"
  winlink windows/powertoys-keyboard-manager.json "$win/AppData/Local/Microsoft/PowerToys/Keyboard Manager/default.json"
  winlink vscode/settings.json                    "$win/AppData/Roaming/Code/User/settings.json"
  winlink vscode/keybindings.json                 "$win/AppData/Roaming/Code/User/keybindings.json"

  winlink_flush

  [ -f "$startup/Shortcuts.ahk" ] && backup "$startup/Shortcuts.ahk"
fi

echo "Done."
