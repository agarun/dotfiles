if [ -n "$WSL_DISTRO_NAME" ]; then
  if [ "$(wslinfo --networking-mode 2>/dev/null)" = mirrored ]; then
    export WSL_WINDOWS_HOST_IP=127.0.0.1
  elif ip link show wsltap up 2>/dev/null | grep -q UP; then
    export WSL_WINDOWS_HOST_IP="$(ip -4 -o addr show wsltap 2>/dev/null |
      awk '{ split($4, ip, "[./]"); print ip[1] "." ip[2] "." ip[3] ".254"; exit }')"
  else
    export WSL_WINDOWS_HOST_IP="$(ip -4 route show dev eth0 proto kernel 2>/dev/null |
      awk '{ split($1, ip, "[./]"); print ip[1] "." ip[2] "." ip[3] "." ip[4] + 1; exit }')"
  fi

  __wsl2_osc7() {
    printf "\033]7;file://%s%s\033\\" "$HOSTNAME" "$PWD"
  }
  __wsl2_title() {
    printf "\033]0;%s\033\\" "${1:-bash}"
  }
  __wsl2_preexec_armed=1
  __wsl2_preexec() {
    if [ -n "$__wsl2_preexec_armed" ]; then
      __wsl2_preexec_armed=
      [ -n "$COMP_LINE" ] && return   # skip tab-completion noise
      __wsl2_title "$BASH_COMMAND"
    fi
  }
  trap '__wsl2_preexec' DEBUG
  export PROMPT_COMMAND="__wsl2_preexec_armed=1; __wsl2_osc7; __wsl2_title bash${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

# `open <dir>`
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
  open() {
    local target=${1:-.}
    [ -e "$target" ] && target=$(wslpath -w "$target")
    explorer.exe "$target"
    return 0
  }

  alias wgit='/mnt/c/Program\ Files/Git/git-cmd.exe'
fi
