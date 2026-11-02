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

win_links=()

winlink() {
  local dest=$2
  [ -L "$dest" ] && return
  if [ -e "$dest" ]; then mkdir -p "$BACKUP" && cp "$dest" "$BACKUP/" && echo "  backed up $dest"; fi
  mkdir -p "$(dirname "$dest")"
  win_links+=("$dest|$DOTFILES/$1")
}

winlink_flush() {
  [ ${#win_links[@]} -eq 0 ] && return
  local entry script

  script=$(
    echo '$links = @('
    for entry in "${win_links[@]}"; do
      echo "  '$(wslpath -w "${entry%%|*}")|$(wslpath -w "${entry#*|}")'"
    done
    echo ')'
    cat <<'PS'
foreach ($line in $links) {
  $dest, $target = $line -split '\|', 2
  $tmp = "$dest.dotfiles-new"
  try {
    New-Item -ItemType SymbolicLink -Force -Path $tmp -Target $target -ErrorAction Stop | Out-Null
    if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force }
    Move-Item -LiteralPath $tmp -Destination $dest
  } catch {
    Write-Warning "${dest}: $_"
  }
}
PS
  )

  echo "  creating ${#win_links[@]} Windows link(s): approve the admin prompt"
  (cd /mnt/c && powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -Wait \
    -ArgumentList '-NoProfile','-EncodedCommand','$(printf '%s' "$script" | iconv -t UTF-16LE | base64 -w0)'") || true

  for entry in "${win_links[@]}"; do
    if [ -L "${entry%%|*}" ]; then echo "  linked ${entry%%|*}"; else echo "  FAILED ${entry%%|*} (left as it was)"; fi
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

link bash/.bashrc.local       "$HOME/.bashrc"
link bash/.bash_profile.local "$HOME/.bash_profile"

# ⋇ Git

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

# ⋇ Workspaces

make_local workspaces.local.json <<'EOF'
{}
EOF

link herdr/ws "$HOME/bin/ws"

# ⋇ Packages

brew=$(command -v brew || ls /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew 2>/dev/null | head -1 || true)
if [ -n "$brew" ]; then
  "$brew" analytics off
  "$brew" trust jandedobbeleer/oh-my-posh >/dev/null 2>&1 || true
  "$brew" bundle check --no-upgrade --file "$DOTFILES/brew/Brewfile" &>/dev/null ||
    "$brew" bundle install --no-upgrade --file "$DOTFILES/brew/Brewfile" || echo "  brew bundle failed, see above"
else
  echo "  Homebrew not found, install it from https://brew.sh then re-run"
fi

mise=$(command -v mise || ls "$HOME/.local/bin/mise" 2>/dev/null || true)
if [ -n "$mise" ]; then
  "$mise" install --yes --quiet || echo "  mise install failed, see above"
else
  echo "  mise not found, install it with: curl https://mise.run | sh"
fi

# ⋇ Agents

merge_json() {
  local target=$2 merged
  [ -f "$target" ] || echo '{}' > "$target"
  merged=$(jq -s 'def m($a; $b): if ($a | type) == "object" and ($b | type) == "object" then reduce ($b | keys_unsorted[]) as $k ($a; .[$k] = m($a[$k]; $b[$k]))
    elif ($a | type) == "array" and ($b | type) == "array" then $a + ($b - $a) else $b end; m(.[0]; .[1])' "$target" "$DOTFILES/$1") || return 0
  [ "$merged" = "$(jq . "$target")" ] && return
  printf '%s\n' "$merged" > "$target"
  echo "  updated $target"
}

merge_toml() {
  local target=$2 merged
  touch "$target"
  merged=$(awk '
    function put(t,  i) { for (i = 1; i <= n; i++) if (tb[i] == t && !done[i]++) print line[i] }
    BEGIN { seen[""] = 1 }
    FNR == 1 { t = "" }
    /^\[/ { if (NR != FNR) { put(t); seen[substr($0, 2, length($0) - 2)] = 1 } t = substr($0, 2, length($0) - 2) }
    NR == FNR { if (/=/) { tb[++n] = t; key[n] = $1; line[n] = $0 } next }
    /=/ { for (i = 1; i <= n; i++) if (tb[i] == t && key[i] == $1) { if (!done[i]++) print line[i]; next } }
    { print }
    END { if (NR == FNR || !FNR) t = ""; put(t); for (i = 1; i <= n; i++) if (!done[i]) { if (!seen[tb[i]]++) printf "\n[%s]\n", tb[i]; put(tb[i]) } }
  ' "$DOTFILES/$1" "$target")
  [ "$merged" = "$(cat "$target")" ] && return
  printf '%s\n' "$merged" > "$target"
  echo "  updated $target"
}

if command -v jq >/dev/null; then
  for dir in "$HOME"/.claude*/; do
    [ -d "$dir" ] && merge_json agents/claude/settings.json "${dir}settings.json"
  done
  [ -d "$HOME/.copilot" ] && merge_json agents/copilot/settings.json "$HOME/.copilot/settings.json"
fi
if [ -d "$HOME/.codex" ]; then
  merge_toml agents/codex/config.toml "$HOME/.codex/config.toml"
fi

# ⋇ macOS

if is_mac; then
  bash_path=/opt/homebrew/bin/bash
  if [ -x "$bash_path" ] && [ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" != "$bash_path" ]; then
    grep -qx "$bash_path" /etc/shells || echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$bash_path"
    echo "  login shell is now $bash_path, open a new terminal"
  fi

  link macos/.skhdrc              "$HOME/.skhdrc"
  link gnupg/gpg-agent.macos.conf "$HOME/.gnupg/gpg-agent.conf"
  link wezterm/wezterm.lua        "$HOME/.wezterm.lua"
  link rex/init.lua               "$HOME/.config/rex/init.lua"
  "$DOTFILES/rex/defaults.sh"
  vscode="$HOME/Library/Application Support/Code/User"
  link vscode/settings.json    "$vscode/settings.json"
  link vscode/keybindings.json "$vscode/keybindings.json"
fi

# ⋇ WSL + Windows

if is_wsl; then
  link gnupg/gpg-agent.conf "$HOME/.gnupg/gpg-agent.conf"
  link windows/chrome-host  "$HOME/bin/chrome-host"
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

  win=$(cd /mnt/c && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
  if [ -z "$win" ]; then
    echo "  can't find Windows (is cmd.exe on PATH?), skipping Windows links"
  else
    win=$(wslpath "$win")
    startup="$win/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"

    winlink windows/hotkeys.local.ahk               "$startup/hotkeys.ahk"
    winlink wezterm/wezterm.lua                     "$win/.wezterm.lua"
    winlink windows/powertoys-keyboard-manager.json "$win/AppData/Local/Microsoft/PowerToys/Keyboard Manager/default.json"
    winlink vscode/settings.json                    "$win/AppData/Roaming/Code/User/settings.json"
    winlink vscode/keybindings.json                 "$win/AppData/Roaming/Code/User/keybindings.json"
    winlink_flush
  fi
fi

echo "Done."
