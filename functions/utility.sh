function prepare_stow_targets() {
    local file destination

    (cd "$HOME/.dotfiles" && find "$@" -type f) | while read -r file; do
        destination="$HOME/${file#*/}"
        if [[ "$destination" -ef "$HOME/.dotfiles/$file" ]]; then
            continue
        elif [[ -L "$destination" ]]; then
            warn "Removing stale symlink: $destination"
            rm "$destination"
        elif [[ -e "$destination" ]]; then
            warn "Backing up $destination"
            mv "$destination" "$destination.backup.$(date +%Y%m%d%H%M%S)"
        fi
    done
}

function check_directory() {
    [[ -d "$1" ]]
}

function is_installed() {
    command -v "$1" &>/dev/null
}
