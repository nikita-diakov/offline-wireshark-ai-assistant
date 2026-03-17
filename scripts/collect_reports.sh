#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT_DIR/reports"
mkdir -p "$OUT"

count=0
while IFS= read -r -d '' f; do
  sess="$(basename "$(dirname "$f")")"
  cp -a "$f" "$OUT/${sess}.md"
  count=$((count+1))
done < <(find "$ROOT_DIR/sessions" -maxdepth 3 -name report.md -print0 2>/dev/null || true)

echo "Collected $count report(s) into: $OUT"
ls -lah "$OUT" | head
echo
echo "Tip: point GPT4All LocalDocs to this folder:"
echo "  $OUT"
