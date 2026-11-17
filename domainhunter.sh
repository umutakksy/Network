#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/config/settings.conf"
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'
pause(){ echo; read -r -p "Devam etmek için ENTER..." _; }
run_module(){ local file="$BASE_DIR/modules/$1.sh"; [[ -f "$file" ]] || { echo "Modül bulunamadı: $1" >&2; return 1; }; bash "$file"; }
full_scan(){
 local target answer
 read -r -p "Yetkili olduğunuz hedef domain: " target
 target="${target,,}"; target="${target#http://}"; target="${target#https://}"; target="${target%%/*}"; target="${target%%:*}"
 [[ "$target" =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$ ]] || { echo "Geçersiz domain."; return 1; }
 echo "Yalnızca sahip olduğunuz veya yazılı izin aldığınız hedeflerde çalıştırın."
 read -r -p "$target için pasif + aktif keşif ve servis kontrollerini onaylıyor musunuz? [y/N] " answer
 [[ "$answer" == "y" || "$answer" == "Y" ]] || return 1
 export DOMAINHUNTER_TARGET="$target" DOMAINHUNTER_AUTHORIZED=yes
 export RUN_DIR="$BASE_DIR/results/${target}_$(date +%Y%m%d_%H%M%S)"
 mkdir -p "$RUN_DIR"; printf '%s\n' "$RUN_DIR" > "$BASE_DIR/results/latest.txt"
 for module in passive active; do echo "[*] $module"; bash "$BASE_DIR/modules/$module.sh" || echo "[!] $module modülü hata verdi."; done
 cat "$RUN_DIR"/subdomains-{passive,active}.txt 2>/dev/null | sort -fu > "$RUN_DIR/subdomains-all.txt" || true
 [[ -s "$RUN_DIR/subdomains-all.txt" ]] || printf '%s\n' "$target" > "$RUN_DIR/subdomains-all.txt"
 for module in dns http; do echo "[*] $module"; bash "$BASE_DIR/modules/$module.sh" || echo "[!] $module modülü hata verdi."; done
 echo "[+] Tam tarama tamamlandı. Sonuçlar: $RUN_DIR"
}
banner(){
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
 echo -e "${GREEN}       CachyOS / Arch Linux edition${RESET}\n"
}
while true; do
 banner
 cat <<'MENU'
 [1] Passive subdomain discovery
 [2] Active DNS wordlist discovery
 [3] DNS record analysis
 [4] HTTP/HTTPS live detection
 [5] TCP service discovery (Nmap)
 [6] Full reconnaissance
 [7] View latest results
 [8] Install / update tools
 [9] Generate report
 [0] Exit
MENU
 echo; read -r -p "DomainHunter > " choice
 case "$choice" in
  1) run_module passive; pause ;;
  2) run_module active; pause ;;
  3) run_module dns; pause ;;
  4) run_module http; pause ;;
  5) run_module ports; pause ;;
  6) full_scan; pause ;;
  7) if [[ -f "$BASE_DIR/results/latest.txt" ]]; then d="$(<"$BASE_DIR/results/latest.txt")"; find "$d" -maxdepth 1 -type f -printf '%f\n' | sort; else echo "Henüz sonuç yok."; fi; pause ;;
  8) bash "$BASE_DIR/install.sh"; pause ;;
  9) run_module report; pause ;;
  0) echo "DomainHunter kapatıldı."; exit 0 ;;
  *) echo -e "${RED}Geçersiz seçim.${RESET}"; pause ;;
 esac
done
