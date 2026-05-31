# dotfiles

Personal dotfiles for macOS, managed with symlinks.

## Setup

```sh
git clone https://github.com/dylkim05/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:

1. Install [Homebrew](https://brew.sh) if not already present
2. Clone/sync the repo to `~/.dotfiles`
3. Symlink all config files to their target locations (existing files are backed up as `.bak`)
4. Install JetBrains Mono Nerd Font
5. Install [Starship](https://starship.rs) prompt
6. Install shell autosuggestions (zsh-autosuggestions or ble.sh depending on your shell choice)

You can also install all tools declaratively via the Brewfile:

```sh
brew bundle
```

## Structure

```
.dotfiles/
├── shell/
│   ├── zshrc             → ~/.zshrc
│   ├── bashrc            → ~/.bashrc
│   └── starship/         # starship prompt config
├── zed/
│   ├── keymap.json       → ~/.config/zed/keymap.json
│   └── settings.json     → ~/.config/zed/settings.json
├── functions/
│   ├── print.sh          # logging helpers
│   └── utility.sh        # install/link helpers
├── Brewfile              # declarative tool/app installs
├── symlinks.conf         # symlink mappings (src → dest)
└── setup.sh              # bootstrap script
```

## Adding a New Dotfile

1. Place the file under the appropriate directory in `~/.dotfiles`
2. Add a line to `symlinks.conf`:
   ```
   relative/path/to/file ~/.target/path
   ```
3. Re-run `./setup.sh` to apply
