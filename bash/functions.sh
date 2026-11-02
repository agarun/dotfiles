# Create a directory and cd into it
mkd() {
	mkdir -p "$@" && cd "$_"
}
complete -o filenames -A directory mkd

# Size of a file, or of everything in the current directory
fs() {
	if [ $# -gt 0 ]; then
		du -sh -- "$@"
	else
		du -sh .[^.]* ./* 2>/dev/null
	fi
}
complete -o filenames -A file fs

# What's listening on which port. `ports 3000` to filter.
ports() {
	sudo lsof -iTCP -sTCP:LISTEN -nP |
		awk 'NR > 1 { sub(/.*:/, "", $9); print $9, $2 }' |
		sort -u -k1,1n |
		while read -r port pid; do
			[ -n "$1" ] && [ "$port" != "$1" ] && continue
			printf '%-6s %-8s %s\n' "$port" "$pid" "$(ps -p "$pid" -o args=)"
		done
}

# List or prune worktrees
worktrees() {
	local prune= g repo roots
	[ "$1" = prune ] && { prune=1; shift; }
	roots=("$@")
	[ $# -eq 0 ] && roots=("$HOME/Projects" "$DOTFILES")
	[ -n "$prune" ] || printf '%6s  %-15s %-6s %-30s %s\n' SIZE COMMIT STATE BRANCH PATH
	find "${roots[@]}" -maxdepth 4 -name node_modules -prune -o -name .git -type d -print -prune 2>/dev/null |
		while read -r g; do
			repo=${g%/.git}
			[ -n "$prune" ] && { git -C "$repo" worktree prune -v; continue; }
			git -C "$repo" worktree list --porcelain 2>/dev/null | awk -v RS= -F'\n' 'NR > 1 {
				p = b = x = ""
				for (i = 1; i <= NF; i++)
					if ($i ~ /^worktree /) p = substr($i, 10)
					else if ($i ~ /^branch /) { b = $i; sub(/^branch refs\/heads\//, "", b) }
					else if ($i == "detached") b = "(detached)"
					else if ($i ~ /^prunable/) x = 1
				print p "\t" b "\t" x
			}' | while IFS=$'\t' read -r p b x; do
				if [ -n "$x" ]; then
					printf '%6s  %-15s %-6s %-30s %s\n' - - gone "$b" "${p/#$HOME/\~}"
				else
					printf '%6s  %-15s %-6s %-30s %s\n' "$(du -sh "$p" 2>/dev/null | cut -f1)" \
						"$(git -C "$p" log -1 --format=%cr | sed 's/ ago//')" \
						"$([ -n "$(git -C "$p" status --porcelain | head -1)" ] && echo dirty || echo clean)" \
						"$b" "${p/#$HOME/\~}"
				fi
			done
		done
}

# Open VS Code right away
c() {
	(code "${@:-.}" >/dev/null 2>&1 &)
}
complete -o filenames -A file c

dotfiles-sync() {
	git -C "$DOTFILES" pull --rebase --autostash && "$DOTFILES/install.sh"
}
