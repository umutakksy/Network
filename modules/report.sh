#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
if [[ -z "${RUN_DIR:-}" ]]; then [[ -f "$RESULT_DIR/latest.txt" ]] || die "Henüz sonuç yok."; RUN_DIR="$(<"$RESULT_DIR/latest.txt")"; fi
[[ -d "$RUN_DIR" ]] || die "Sonuç dizini bulunamadı: $RUN_DIR"
need jq
JSON="$RUN_DIR/summary.json"
jq -n --arg directory "$RUN_DIR" --arg generated "$(date -Is)" --argjson files "$(find "$RUN_DIR" -maxdepth 1 -type f ! -name summary.json -printf '%f\n' | jq -R . | jq -s .)" '{generated_at:$generated,scan_directory:$directory,files:$files}' > "$JSON"
if command -v pandoc >/dev/null 2>&1; then
 { echo "# DomainHunter report"; echo; echo "- Generated: $(date -Is)"; for file in "$RUN_DIR"/*.txt; do [[ -f "$file" ]] || continue; echo; echo "## $(basename "$file")"; echo; cat "$file"; done; } | pandoc -f markdown -t html -s -o "$RUN_DIR/report.html"
fi
ok "Rapor özeti: $JSON"
