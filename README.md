# dotfiles

Personal dotfiles for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```sh
git clone https://github.com/dylkim05/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script (Apple Silicon Macs only) will:

1. Install [Homebrew](https://brew.sh) if not already present
2. Clone/sync the repo to `~/.dotfiles`
3. Install everything in the `Brewfile` (git, gh, stow, [Starship](https://starship.rs), zsh-autosuggestions, JetBrains Mono Nerd Font, Zed)
4. Symlink each package into `$HOME` with Stow (existing files are backed up as `.bak.<timestamp>`, stale symlinks are replaced)
5. Log in to the GitHub CLI if needed

To add a tool, add it to the `Brewfile` and re-run `./setup.sh` (or `brew bundle`).

## Structure

Each top-level package directory mirrors `$HOME`, and Stow links its files into place.

```
.dotfiles/
├── zsh/.zshrc                          → ~/.zshrc
├── bash/.bashrc                        → ~/.bashrc  (minimal fallback, prompt only)
├── starship/.config/starship.toml      → ~/.config/starship.toml
├── zed/.config/zed/
│   ├── keymap.json                     → ~/.config/zed/keymap.json
│   └── settings.json                   → ~/.config/zed/settings.json
├── functions/
│   ├── print.sh                        # logging helpers
│   └── utility.sh                      # install/link helpers
├── Brewfile                            # declarative tool/app installs
└── setup.sh                            # bootstrap script
```

## Adding a New Dotfile

1. Put the file in a package at the same path it has relative to `$HOME`,
   e.g. `ghostty/.config/ghostty/config` → `~/.config/ghostty/config`
2. If it's a new package, add its name to `STOW_PACKAGES` in `setup.sh`
3. Re-run `./setup.sh`, or link it directly:
   ```sh
   stow -d ~/.dotfiles -t ~ --no-folding <package>
   ```

To remove a package's links: `stow -d ~/.dotfiles -t ~ -D <package>`
