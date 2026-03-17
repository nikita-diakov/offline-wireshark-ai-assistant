#!/usr/bin/env bash
set -euo pipefail

echo "== User/group checks =="
echo "User: $(whoami)"
echo "Groups: $(groups)"
if groups | tr ' ' '\n' | grep -q '^wireshark$'; then
  echo "[OK] user is in 'wireshark' group"
else
  echo "[WARN] user is NOT in 'wireshark' group"
  echo "Fix:"
  echo "  sudo dpkg-reconfigure wireshark-common   # choose YES"
  echo "  sudo adduser "$USER" wireshark"
  echo "  # log out / log in (or reboot)"
fi
echo

echo "== dumpcap permissions =="
if command -v dumpcap >/dev/null 2>&1; then
  echo "dumpcap: $(command -v dumpcap)"
  ls -l /usr/bin/dumpcap || true
  getcap /usr/bin/dumpcap || true
  echo
  echo "== dumpcap interfaces =="
  /usr/bin/dumpcap -D || true
else
  echo "[ERR] dumpcap not found. Install wireshark/tshark first."
fi
echo

echo "== Network interfaces =="
ip -br link || true
ip -br addr || true
echo

echo "== Quick packet visibility test (needs sudo if not configured) =="
echo "Try:"
echo "  sudo tshark -i any -c 10"
