eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# bun completions
[ -s "/Users/dylankim/.bun/_bun" ] && source "/Users/dylankim/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# lean (elan), only if installed
[[ -d "$HOME/.elan/bin" ]] && export PATH="$HOME/.elan/bin:$PATH"
