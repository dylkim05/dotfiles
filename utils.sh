function link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        echo "Already linked: $dest, skipping"
    elif [ -f "$dest" ]; then
        echo "Real file exists: $dest, skipping"
    else
        ln -sf "$src" "$dest"
        echo "Linked: $dest"
    fi
}
