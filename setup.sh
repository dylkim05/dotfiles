#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/functions/print.sh"
source "$DIR/functions/utility.sh"

function install_homebrew() {
    section "Checking Homebrew"

    if [[ "$OSTYPE" != "darwin"* ]]; then
        info "Not macOS, skipping Homebrew install"
        return
    fi

    if is_installed brew; then
        warn "Homebrew already installed, skipping"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    section "Homebrew ready"
}

function sync_repo() {
    section "Syncing Git repository"

    if ! check_dir "$HOME/.dotfiles"; then
        git clone https://github.com/dylkim05/dotfiles.git "$HOME/.dotfiles"
        git -C "$HOME/.dotfiles" checkout main
    else
        info "Repo already exists, pulling latest changes"
        if git -C "$HOME/.dotfiles" diff --quiet && git -C "$HOME/.dotfiles" diff --cached --quiet; then
            git -C "$HOME/.dotfiles" pull
        else
            warn "Uncommitted changes detected, skipping pull"
        fi
    fi

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

    echo "Which shell are you setting up?"
    select shell_choice in "zsh" "bash"; do
        case "$shell_choice" in
            zsh)
                if brew list zsh-autosuggestions &>/dev/null; then
                    warn "Auto Suggestions already installed, skipping"
                else
                    info "Installing zsh-autosuggestions via Homebrew..."
                    brew install zsh-autosuggestions
                fi
                break
                ;;
            bash)
                if [ -f ~/.local/share/blesh/ble.sh ]; then
                    warn "ble.sh already installed, skipping"
                else
                    info "Installing ble.sh for bash autosuggestions..."
                    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
                    make -C ble.sh install PREFIX=~/.local
                fi
                break
                ;;
            *)
                warn "Invalid choice, please select 1 (zsh) or 2 (bash)"
                ;;
        esac
    done

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
    install_homebrew
    sync_repo
    link_dotfiles
    install_fonts
    install_starship
    install_autosuggestions
}

main
