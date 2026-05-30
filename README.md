# dotfiles

Personal dotfiles for macOS, managed with symlinks.

## Setup

```sh
curl -fsSL https://raw.githubusercontent.com/dylkim05/dotfiles/main/setup.sh | bash
```

Or if already cloned:

```sh
./setup.sh
```

The setup script will:

1. Clone/sync the repo to `~/.dotfiles`
2. Symlink all config files to their target locations
3. Install JetBrains Mono Nerd Font
4. Install [Starship](https://starship.rs) prompt
5. Install zsh-autosuggestions

## Structure

```
.dotfiles/
├── git/
│   └── gitconfig         → ~/.gitconfig
├── shell/
│   ├── zshrc             → ~/.zshrc
│   ├── bashrc            → ~/.bashrc
│   └── starship/         → starship prompt config
├── zed/
│   ├── keymap.json       → ~/.config/zed/keymap.json
│   └── settings.json     → ~/.config/zed/settings.json
├── functions/
│   ├── print.sh          # logging helpers
│   └── utility.sh        # install/link helpers
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
