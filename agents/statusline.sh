#!/usr/bin/env bash

IFS=$'\x1f' read -r dir model context five_hour five_reset seven_day < <(jq -r '[
  .workspace.current_dir // .cwd // "",
  ((.model | objects | .display_name // .id) // (.model | strings)) // "",
  .context_window.used_percentage // "",
  .rate_limits.five_hour.used_percentage // "",
  .rate_limits.five_hour.resets_at // "",
  .rate_limits.seven_day.used_percentage // ""
] | map(tostring) | join("\u001f")' 2>/dev/null)
dir=${dir:-$PWD}

reset=$'\e[0m' bold=$'\e[1m' dim=$'\e[2m'
red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m'

percent() {
  local n=${1%.*} color=$green
  ((n >= 50)) && color=$yellow
  ((n >= 80)) && color=$red
  printf '%s%s%%%s' "$color" "$n" "$reset"
}

path=${dir/#"$HOME"/'~'}
name=${path##*/}
parts=("$dim${path%"$name"}$reset$bold$name$reset")

if status=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  branch=$(sed -n 's/^# branch\.head //p' <<<"$status")
  read -r ahead behind < <(sed -n 's/^# branch\.ab +\([0-9]*\) -\([0-9]*\)/\1 \2/p' <<<"$status")
  if [[ -n $branch && $branch != "(detached)" ]]; then
    color=$green
    grep -qv '^#' <<<"$status" && color=$yellow
    [[ -e $(git -C "$dir" rev-parse --git-path MERGE_HEAD) ]] && color=$red
    sync=""
    ((ahead > 0)) && sync+="↑$ahead"
    ((behind > 0)) && sync+="↓$behind"
    parts+=("$color$branch$reset${sync:+ $dim$sync$reset}")
  fi
fi

[[ -n $model ]] && parts+=("$model")
[[ -n $context ]] && parts+=("ctx $(percent "$context")")
if [[ -n $five_hour ]]; then
  left=$((${five_reset%.*} - $(date +%s)))
  ((left > 0)) && reset_in=" $dim$((left / 3600))h$((left % 3600 / 60))m$reset"
  parts+=("5h $(percent "$five_hour")${reset_in:-}")
fi
[[ -n $seven_day ]] && parts+=("7d $(percent "$seven_day")")

separator=" $dim·$reset "
line=$(printf "%s$separator" "${parts[@]}")
printf '%s' "${line%"$separator"}"
