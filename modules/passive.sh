#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ask_or_use_target
OUT="$RUN_DIR/subdomains-passive.txt"; TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
log "Pasif kaynaklardan alt alan adları toplanıyor: $TARGET"
if command -v subfinder >/dev/null 2>&1; then subfinder -d "$TARGET" -silent -all 2>>"$BASE_DIR/logs/subfinder.log" >>"$TMP" || warn "Subfinder bazı kaynaklarda hata verdi."; else warn "Subfinder kurulu değil."; fi
if command -v amass >/dev/null 2>&1; then amass enum -passive -d "$TARGET" 2>>"$BASE_DIR/logs/amass.log" >>"$TMP" || warn "Amass bazı kaynaklarda hata verdi."; fi
if command -v assetfinder >/dev/null 2>&1; then assetfinder --subs-only "$TARGET" 2>>"$BASE_DIR/logs/assetfinder.log" >>"$TMP" || true; fi
need curl
log "Certificate Transparency (crt.sh) sorgulanıyor..."
curl -fsSL --max-time 45 "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value? // empty' 2>/dev/null | tr '\r' '\n' | sed 's/^\*\.//' >>"$TMP" || warn "crt.sh sorgusu başarısız."
grep -E '^[A-Za-z0-9.-]+$' "$TMP" | grep -E "(^|\.)${TARGET//./\\.}$" > "$OUT" || true
dedupe_file "$OUT"
ok "Pasif keşif: $(wc -l < "$OUT") kayıt"
