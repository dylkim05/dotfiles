#!/usr/bin/env bash
source ./utils.sh

while IFS=' ' read -r src dest; do
    link_file "$HOME/.dotfiles/$src" "${dest/#\~/$HOME}"
done < "$HOME/.dotfiles/symlinks.conf"
