#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ask_or_use_target
need dig
HOSTS="$RUN_DIR/subdomains-all.txt"; [[ -s "$HOSTS" ]] || printf '%s\n' "$TARGET" > "$HOSTS"
OUT="$RUN_DIR/dns-records.txt"; : > "$OUT"
while IFS= read -r host; do
 [[ -z "$host" ]] && continue
 { printf '\n===== %s =====\n' "$host"; for type in A AAAA CNAME MX NS TXT SOA CAA; do printf -- '-- %s --\n' "$type"; dig +time=3 +tries=1 +noall +answer "$host" "$type"; done; } >>"$OUT"
done < "$HOSTS"
ok "DNS kayıt analizi tamamlandı: $OUT"
