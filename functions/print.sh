if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    BOLD=$'\e[1m' DIM=$'\e[2m' RED=$'\e[31m' GREEN=$'\e[32m' YELLOW=$'\e[33m' BLUE=$'\e[34m' RESET=$'\e[0m'
else
    BOLD='' DIM='' RED='' GREEN='' YELLOW='' BLUE='' RESET=''
fi

STEP=0
TOTAL_STEPS=0

header() { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }
step()   { STEP=$((STEP + 1)); printf '\n%s[%d/%d]%s %s%s%s\n' "$BLUE" "$STEP" "$TOTAL_STEPS" "$RESET" "$BOLD" "$*" "$RESET"; }
ok()     { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
skip()   { printf '  %s– %s%s\n' "$DIM" "$*" "$RESET"; }
info()   { printf '  %s→%s %s\n' "$BLUE" "$RESET" "$*"; }
warn()   { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
error()  { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

run() {
    "$@" 2>&1 | while IFS= read -r line; do
        printf '    %s%s%s\n' "$DIM" "$line" "$RESET"
    done
    return "${PIPESTATUS[0]}"
}
