function link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        info "Already linked: $dest, skipping"
    elif [ -f "$dest" ]; then
        warn "Real file exists at $dest, backing up to $dest.bak"
        mv "$dest" "$dest.bak"
        ln -sf "$src" "$dest"
        info "Linked: $dest"
    else
        ln -sf "$src" "$dest"
        echo "Linked: $dest"
    fi
}

function check_dir() {
    if [[ -d "$1" ]]; then
        return 0
    else
        return 1
    fi

}
function is_installed() {
    command -v "$1" &>/dev/null
}
