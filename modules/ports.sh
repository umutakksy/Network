#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ask_or_use_target
need nmap
OUT="$RUN_DIR/ports-nmap.txt"
warn "Nmap profili: TCP top 1000 port, servis/sürüm tespiti, T3. Yalnızca yetkili hedef."
nmap -Pn -n -sV --version-light --top-ports 1000 -T3 --max-retries 2 --host-timeout 20m -oN "$OUT" "$TARGET"
ok "Port keşfi tamamlandı: $OUT"
