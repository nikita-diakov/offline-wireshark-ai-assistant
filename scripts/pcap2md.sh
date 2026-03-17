#!/usr/bin/env bash
set -euo pipefail

PCAP="${1:-}"
OUT="${2:-}"

if [[ -z "$PCAP" ]]; then
  echo "Usage: $0 /path/to/capture.pcapng [/path/to/report.md]" >&2
  exit 1
fi

if [[ ! -f "$PCAP" ]]; then
  echo "ERROR: file not found: $PCAP" >&2
  exit 1
fi

if [[ -z "$OUT" ]]; then
  OUT="$(dirname "$PCAP")/$(basename "$PCAP").report.md"
fi

{
  echo "# PCAP report: $(basename "$PCAP")"
  echo
  echo "## Capture metadata"
  capinfos "$PCAP" 2>/dev/null || true
  echo
  echo "## Protocol hierarchy"
  tshark -r "$PCAP" -q -z io,phs 2>/dev/null || true
  echo
  echo "## Top IPv4 endpoints (first ~80 lines)"
  tshark -r "$PCAP" -q -z endpoints,ip 2>/dev/null | head -n 80 || true
  echo
  echo "## Top TCP conversations (first ~80 lines)"
  tshark -r "$PCAP" -q -z conv,tcp 2>/dev/null | head -n 80 || true
  echo
  echo "## Top UDP conversations (first ~80 lines)"
  tshark -r "$PCAP" -q -z conv,udp 2>/dev/null | head -n 80 || true
  echo
  echo "## DNS queries (first 200)"
  tshark -r "$PCAP" -Y "dns.flags.response==0" -T fields     -e frame.time -e ip.src -e dns.qry.name -e dns.qry.type 2>/dev/null     | head -n 200 || true
  echo
  echo "## HTTP requests (first 200)"
  tshark -r "$PCAP" -Y "http.request" -T fields     -e frame.time -e ip.src -e ip.dst -e http.host -e http.request.method -e http.request.uri 2>/dev/null     | head -n 200 || true
  echo
  echo "## TLS SNI (ClientHello, first 200)"
  tshark -r "$PCAP" -Y "tls.handshake.type==1" -T fields     -e frame.time -e ip.src -e ip.dst -e tls.handshake.extensions_server_name 2>/dev/null     | head -n 200 || true

} > "$OUT"

echo "Wrote: $OUT"
