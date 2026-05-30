#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/functions/print.sh"
source "$DIR/functions/utility.sh"

function sync_repo() {
    section "Syncing Git repository"

    if ! check_dir "$HOME/.dotfiles"; then
        git clone https://github.com/dylkim05/dotfiles.git "$HOME/.dotfiles"
    fi

    git -C "$HOME/.dotfiles" checkout main
    git -C "$HOME/.dotfiles" pull

    section "Successfully synced Git repository"
}

function link_dotfiles() {
    section "Linking Dotfiles"

    while IFS=' ' read -r src dest; do
        link_file "$HOME/.dotfiles/$src" "${dest/#\~/$HOME}"
    done < "$HOME/.dotfiles/symlinks.conf"

    section "Successfully linked Dotfiles"
}

function install_starship() {
    section "Installing Starship"

    if is_installed starship; then
        warn "Starship already installed, skipping"
        return
    else
        curl -sS https://starship.rs/install.sh | sh -s -- --yes &>/dev/null
    fi

    section "Successfully installed Starship"
}

function install_autosuggestions() {
    section "Installing Autosuggestions"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if brew list zsh-autosuggestions &>/dev/null; then
            warn "Auto Suggestions already installed, skipping"
            section "Successfully Installed Auto Suggestions"
            return
        fi

        info "Installing via Homebrew..."

        brew install zsh-autosuggestions
    fi

    section "Successfully installed Autosuggestions"
}

function install_fonts() {
    section "Installing Fonts"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
            warn "JetBrains Mono already installed, skipping"
            section "Successfully Installed Fonts"
            return
        fi

        info "Installing via Homebrew..."

        brew install --cask font-jetbrains-mono-nerd-font

    elif [[ "$OSTYPE" == "linux"* ]]; then
        if fc-list | grep -q "JetBrainsMono"; then
            warn "JetBrains Mono already installed, skipping"
            section "Successfully Installed Fonts"
            return
        fi

        info "Downloading JetBrains Mono Nerd Font..."

        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"
        curl -fLo "$font_dir/JetBrainsMono.zip" \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -o "$font_dir/JetBrainsMono.zip" -d "$font_dir"
        rm "$font_dir/JetBrainsMono.zip"
        fc-cache -fv
    fi

    info "Done!"
}

main() {
    sync_repo
    link_dotfiles
    install_fonts
    install_starship
    install_autosuggestions
}

main
