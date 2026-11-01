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

# Open VS Code right away
c() {
	(code "${@:-.}" >/dev/null 2>&1 &)
}
complete -o filenames -A file c

dotfiles-sync() {
	git -C "$DOTFILES" pull --rebase --autostash && "$DOTFILES/install.sh"
}
