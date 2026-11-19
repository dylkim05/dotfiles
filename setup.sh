#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/functions/print.sh"
source "$DIR/functions/utility.sh"

DOTFILES="$HOME/.dotfiles"
STOW_PACKAGES=(zsh bash starship zed)
TOTAL_STEPS=5

function install_homebrew() {
    step "Homebrew"

    if is_installed brew; then
        skip "already installed"
        return
    fi

    info "installing Homebrew (this asks for your password)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return

    eval "$(/opt/homebrew/bin/brew shellenv)"
    ok "installed"
}

function sync_repo() {
    step "Repository"

    if ! check_directory "$DOTFILES"; then
        run git clone --branch main https://github.com/dylkim05/dotfiles.git "$DOTFILES" || return
        ok "cloned to ~/.dotfiles"
    elif ! git -C "$DOTFILES" diff --quiet || ! git -C "$DOTFILES" diff --cached --quiet; then
        warn "uncommitted changes, skipped pull"
    else
        run git -C "$DOTFILES" pull --ff-only || return
        ok "up to date"
    fi
}

function install_packages() {
    step "Packages"

    if brew bundle check --no-upgrade --file="$DOTFILES/Brewfile" &>/dev/null; then
        skip "everything in the Brewfile is installed"
        return
    fi

    run brew bundle install --no-upgrade --file="$DOTFILES/Brewfile" || return
    ok "installed Brewfile packages"
}

function link_dotfiles() {
    step "Dotfiles"

    prepare_stow_targets "${STOW_PACKAGES[@]}"
    run stow --dir="$DOTFILES" --target="$HOME" --no-folding --restow "${STOW_PACKAGES[@]}" || return
    ok "linked ${STOW_PACKAGES[*]}"
}

function gh_login() {
    step "GitHub CLI"

    if gh auth status &>/dev/null; then
        skip "already logged in"
        return
    fi

    info "logging in"
    gh auth login || return
    ok "logged in"
}

main() {
    if [[ "$OSTYPE" != "darwin"* || "$(uname -m)" != "arm64" ]]; then
        error "This setup only supports Apple Silicon Macs"
        exit 1
    fi

    header "dotfiles setup"

    local fn
    for fn in install_homebrew sync_repo install_packages link_dotfiles gh_login; do
        if ! "$fn"; then
            error "setup stopped: $fn failed"
            exit 1
        fi
    done

    printf '\n%s✓ Done in %ds%s\n\n' "$GREEN$BOLD" "$SECONDS" "$RESET"
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main
