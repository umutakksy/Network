#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config/settings.conf
source "$BASE_DIR/config/settings.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

pause() {
    echo
    read -r -p "Devam etmek için ENTER..." _
}

run_module() {
    local module="$1"
    local file="$BASE_DIR/modules/$module.sh"

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Modül bulunamadı: $module${RESET}"
        return 1
    fi

    bash "$file"
}

banner() {
    clear || true
    echo -e "${CYAN}"
    cat <<'ART'
 ____                        _       __  __
|  _ \  ___  _ __ ___   __ _(_)_ __ |  \/  | __ _ _ __
| | | |/ _ \| '_ ` _ \ / _` | | '_ \| |\/| |/ _` | '_ \
| |_| | (_) | | | | | | (_| | | | | | |  | | (_| | | | |
|____/ \___/|_| |_| |_|\__,_|_|_| |_|_|  |_|\__,_|_| |_|
ART
    echo -e "${RESET}${YELLOW}       DOMAIN DISCOVERY & RECONNAISSANCE${RESET}"
    echo -e "${GREEN}       CachyOS / Arch Linux edition${RESET}"
    echo
}

while true; do
    banner
    cat <<'MENU'
 [1] Passive subdomain discovery
 [2] Active DNS wordlist discovery
 [3] DNS record analysis
 [4] HTTP/HTTPS live detection
 [5] Port discovery (authorized targets only)
 [6] Full scan
 [7] View results
 [8] Install / update tools
 [0] Exit
MENU
    echo

    read -r -p "DomainHunter > " choice
    case "$choice" in
        1) run_module passive; pause ;;
        2) run_module active; pause ;;
        3) run_module dns; pause ;;
        4) run_module http; pause ;;
        5) run_module ports; pause ;;
        6) echo "Tam tarama akışı sonraki aşamada eklenecek."; pause ;;
        7) find "$BASE_DIR/results" -maxdepth 1 -type f -printf '%f\n' | sort; pause ;;
        8) bash "$BASE_DIR/install.sh"; pause ;;
        0) echo "DomainHunter kapatıldı."; exit 0 ;;
        *) echo -e "${RED}Geçersiz seçim.${RESET}"; pause ;;
    esac
done
