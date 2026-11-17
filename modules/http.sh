#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ask_or_use_target
HOSTS="$RUN_DIR/subdomains-all.txt"; [[ -s "$HOSTS" ]] || printf '%s\n' "$TARGET" > "$HOSTS"
OUT="$RUN_DIR/http-live.txt"
if command -v httpx >/dev/null 2>&1; then
 httpx -l "$HOSTS" -silent -status-code -title -tech-detect -follow-redirects -timeout "$TIMEOUT" -threads "$THREADS" -no-color -o "$OUT"
else
 warn "ProjectDiscovery httpx bulunamadı; curl fallback kullanılıyor."; : >"$OUT"
 while IFS= read -r host; do
  for scheme in https http; do
   line="$(curl -kIsS --max-time "$TIMEOUT" "$scheme://$host" 2>/dev/null | head -n 1 || true)"
   [[ -n "$line" ]] && printf '%s://%s %s\n' "$scheme" "$host" "$line" >>"$OUT"
  done
 done <"$HOSTS"
fi
ok "HTTP/HTTPS kontrolü tamamlandı: $OUT"
