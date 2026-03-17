#!/usr/bin/env bash
set -euo pipefail

PCAP="${1:-}"
NAME="${2:-session}"

if [[ -z "$PCAP" || ! -f "$PCAP" ]]; then
  echo "Usage: $0 /path/to/capture.pcapng [name]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
DIR="$ROOT_DIR/sessions/${TS}_${NAME}"
mkdir -p "$DIR"

cp -a "$PCAP" "$DIR/"
"$ROOT_DIR/scripts/pcap2md.sh" "$DIR/$(basename "$PCAP")" "$DIR/report.md"

echo "Session created: $DIR"
echo "Files:"
ls -lah "$DIR"
