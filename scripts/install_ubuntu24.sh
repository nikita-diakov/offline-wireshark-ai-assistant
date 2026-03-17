#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating apt cache..."
sudo apt update

echo "[*] Installing Wireshark/tshark + helpers..."
sudo apt install -y wireshark tshark

echo
echo "[*] (Optional) Install Flatpak for GPT4All Desktop (recommended sandbox)"
echo "    sudo apt install -y flatpak"
echo "    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
echo "    flatpak install -y flathub io.gpt4all.gpt4all"
echo
echo "[*] Done."
