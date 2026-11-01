# Aaron's dotfiles

For a list of my most-used apps, see [APPS.md](APPS.md).

## Setup

1. First, Install [Homebrew](https://brew.sh) and [mise](https://mise.jdx.dev/getting-started.html).\
   On Windows, also install [Git for Windows](https://gitforwindows.org/) (for gpg).
2. Clone and install this repo:

```sh
git clone https://github.com/agarun/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

## Sync

The `dotfiles-sync` command pulls the repo and re-runs `install.sh` for you.

Shared config is committed and `source`'d in, while local files (e.g. `.bashrc.local`) are .gitignore'd and symlinked in.
