#!/usr/bin/env bash
# Shared helpers for DomainHunter modules.
set -Eeuo pipefail
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"
RESULT_DIR="$BASE_DIR/results"
mkdir -p "$RESULT_DIR" "$BASE_DIR/logs"

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Gerekli komut bulunamadı: $1. Önce ./install.sh çalıştırın."; }

valid_domain() {
    local d="${1,,}" label
    d="${d%.}"
    [[ -n "$d" && ${#d} -le 253 ]] || return 1
    [[ "$d" =~ ^[a-z0-9.-]+$ ]] || return 1
    [[ "$d" != .* && "$d" != *. && "$d" != *..* ]] || return 1

    local -a labels
    IFS='.' read -r -a labels <<< "$d"
    (("${#labels[@]}" >= 2)) || return 1

    for label in "${labels[@]}"; do
        (("${#label}" >= 1 && ${#label} <= 63)) || return 1
        [[ "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || return 1
    done

    # Require an alphabetic public suffix; supports multi-label suffixes such as .bel.tr.
    [[ "${labels[-1]}" =~ ^[a-z]{2,63}$ ]]
}

get_target() {
    local target="${DOMAINHUNTER_TARGET:-}"
    if [[ -z "$target" ]]; then read -r -p "Hedef domain (ör. example.com): " target; fi
    target="${target,,}"
    target="${target#http://}"
    target="${target#https://}"
    target="${target%%/*}"
    target="${target%%:*}"
    target="${target%.}"
    valid_domain "$target" || die "Geçerli bir domain girin."
    printf '%s' "$target"
}

confirm_authorized() {
    local target="$1"
    [[ "${DOMAINHUNTER_AUTHORIZED:-}" == "yes" ]] && return 0
    echo
    warn "Bu işlem hedef veya üçüncü taraf servislerle sorgu trafiği oluşturabilir."
    read -r -p "$target alan adını test etme yetkiniz olduğunu onaylıyor musunuz? [y/N] " answer
    [[ "$answer" == "y" || "$answer" == "Y" ]] || die "Yetkilendirme onayı verilmedi."
}

new_run_dir() {
    local target="$1"
    RUN_DIR="$RESULT_DIR/${target}_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$RUN_DIR"
    printf '%s\n' "$RUN_DIR" > "$RESULT_DIR/latest.txt"
    export RUN_DIR
}

ask_or_use_target() {
    TARGET="$(get_target)"
    confirm_authorized "$TARGET"
    if [[ -z "${RUN_DIR:-}" ]]; then
        local latest=""
        [[ -f "$RESULT_DIR/latest.txt" ]] && latest="$(<"$RESULT_DIR/latest.txt")"
        if [[ -n "$latest" && -d "$latest" && "$(basename "$latest")" == "$TARGET"_* ]]; then
            RUN_DIR="$latest"
            log "Mevcut tarama klasörü kullanılıyor: $RUN_DIR"
        else
            new_run_dir "$TARGET"
        fi
    fi
    export TARGET RUN_DIR
}

dedupe_file() {
    local file="$1"
    [[ -s "$file" ]] || return 0
    sort -fu "$file" -o "$file"
}
