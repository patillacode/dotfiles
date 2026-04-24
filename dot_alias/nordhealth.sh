# nordhealth.sh — nordhealth-specific utilities

certex() {
    local input output

    # Colors
    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local BOLD='\033[1m'
    local RESET='\033[0m'

    if [[ $# -eq 0 ]]; then
        # Interactive mode
        echo "${BOLD}${CYAN}=== PKCS#12 to PEM Converter ===${RESET}"
        echo

        # List available .p12 and .pfx files (sorted)
        local found=()
        for f in *.p12 *.pfx; do
            [[ -e "$f" ]] && found+=("$f")
        done

        # Sort alphabetically (case-insensitive)
        IFS=$'\n' found=($(printf '%s\n' "${found[@]}" | sort -f))
        unset IFS

        if [[ ${#found[@]} -eq 0 ]]; then
            echo "${RED}No .p12 or .pfx files found in current directory.${RESET}"
            return 1
        fi

        echo "${BOLD}Available certificates:${RESET}"
        local i=1
        for f in "${found[@]}"; do
            printf "  ${YELLOW}%2d)${RESET} %s\n" "$i" "$f"
            ((i++))
        done
        echo

        printf "${BOLD}Select certificate [1-%d]:${RESET} " "${#found[@]}"
        read -r selection

        # Validate selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#found[@]} )); then
            input="${found[$selection]}"
            # Adjust for bash (0-indexed) vs zsh (1-indexed)
            [[ -z "$input" ]] && input="${found[$((selection-1))]}"
        else
            echo "${RED}Invalid selection.${RESET}"
            return 1
        fi

        echo "${GREEN}Selected:${RESET} $input"
        echo

        # Strip either extension for default output
        local base="${input%.p12}"
        base="${base%.pfx}"
        local default_output="${base}.pem"

        printf "${BOLD}Output .pem file${RESET} [${CYAN}%s${RESET}]: " "$default_output"
        read -r output
        output="${output:-$default_output}"
    else
        # CLI mode
        input="$1"
        if [[ -n "$2" ]]; then
            output="$2"
        else
            local base="${input%.p12}"
            base="${base%.pfx}"
            output="${base}.pem"
        fi
    fi

    # Validate input exists
    if [[ ! -f "$input" ]]; then
        echo "${RED}Error:${RESET} '$input' not found" >&2
        return 1
    fi

    # Confirm overwrite if output exists
    if [[ -f "$output" ]]; then
        printf "${YELLOW}'%s' exists. Overwrite? [y/N]:${RESET} " "$output"
        read -r confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && return 1
    fi

    echo
    openssl pkcs12 -in "$input" -out "$output" -nodes && \
        echo "${GREEN}✓ Created:${RESET} $output"
}

alias xc='certex'
