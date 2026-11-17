#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ask_or_use_target
need dig
WORDLIST="${WORDLIST:-$BASE_DIR/wordlists/subdomains.txt}"; [[ -f "$WORDLIST" ]] || die "Wordlist bulunamadı: $WORDLIST"
OUT="$RUN_DIR/subdomains-active.txt"; : > "$OUT"
MAX_WORDS="${MAX_WORDS:-5000}"
log "DNS wordlist keşfi başlıyor. Kelime sınırı: $MAX_WORDS"
count=0
while IFS= read -r label || [[ -n "$label" ]]; do
 label="${label%%#*}"; label="${label//[[:space:]]/}"; [[ -z "$label" ]] && continue
 [[ "$label" =~ ^[A-Za-z0-9*-]+$ ]] || continue
 if dig +time=2 +tries=1 +short "$label.$TARGET" A | grep -Eq '^[0-9.]+$'; then printf '%s.%s\n' "$label" "$TARGET" >>"$OUT"; fi
 ((count+=1)); (( count >= MAX_WORDS )) && break
done < "$WORDLIST"
dedupe_file "$OUT"; ok "Aktif DNS keşfi: $(wc -l < "$OUT") kayıt / $count sorgu"
