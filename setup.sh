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

function install_fonts() {
    section "Installing Fonts"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
            warn "JetBrains Mono already installed, skipping"
        else
            info "Installing via Homebrew..."
            brew install --cask font-jetbrains-mono-nerd-font
        fi

    elif [[ "$OSTYPE" == "linux"* ]]; then
        if fc-list | grep -q "JetBrainsMono"; then
            warn "JetBrains Mono already installed, skipping"
        else
            info "Downloading JetBrains Mono Nerd Font..."
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"
            curl -fLo "$font_dir/JetBrainsMono.zip" \
                https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
            unzip -o "$font_dir/JetBrainsMono.zip" -d "$font_dir"
            rm "$font_dir/JetBrainsMono.zip"
            fc-cache -fv
        fi
    fi

    section "Successfully installed Fonts"
}

function install_starship() {
    section "Installing Starship"

    if is_installed starship; then
        warn "Starship already installed, skipping"
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
                    warn "zsh-autosuggestions already installed, skipping"
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
                        curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf -
                        bash ble-nightly/ble.sh --install ~/.local/share
                        rm -rf ble-nightly
                    fi
                    # Ensure ble.sh is sourced in .bashrc with quiet, interactive-only attach
                    if ! grep -q 'ble.sh --attach=none' ~/.bashrc 2>/dev/null; then
                        echo '[[ $- == *i* ]] && source -- ~/.local/share/blesh/ble.sh --attach=none 2>/dev/null' >> ~/.bashrc
                        info "Added ble.sh source line to ~/.bashrc"
                    else
                        info "ble.sh already sourced in ~/.bashrc"
                    fi

                    if ! grep -q 'ble-attach' ~/.bashrc 2>/dev/null; then
                        echo '[[ ! ${BLE_VERSION-} ]] || ble-attach 2>/dev/null' >> ~/.bashrc
                        info "Added ble-attach line to ~/.bashrc"
                    else
                        info "ble-attach already present in ~/.bashrc"
                    fi
                    break
                    ;;
        esac
    done

    section "Successfully installed Autosuggestions"
}

function install_gh_cli() {
    section "Installing GitHub CLI"

    if ! is_installed gh; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            info "Installing gh via Homebrew..."
            brew install gh

        elif [[ "$OSTYPE" == "linux"* ]]; then
            info "Installing gh via apt..."
            (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
                && sudo mkdir -p -m 755 /etc/apt/keyrings \
                && out=$(mktemp) && wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
                && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
                && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
                    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
                && sudo apt update \
                && sudo apt install gh -y

        else
            warn "Unsupported OS, skipping GitHub CLI install"
            return
        fi
    else
        warn "GitHub CLI already installed, skipping"
    fi

    if ! gh auth status &>/dev/null; then
        info "Not logged in, running gh auth login..."
        gh auth login
    else
        warn "Already authenticated with GitHub, skipping"
    fi

    section "GitHub CLI ready"
}

main() {
    install_homebrew
    sync_repo
    link_dotfiles
    install_fonts
    install_starship
    install_autosuggestions
    install_gh_cli
}

main
