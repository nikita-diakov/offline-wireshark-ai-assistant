# Offline Wireshark → GPT4All LocalDocs Assistant (Ubuntu 24)

A small, **offline-first** lab/toolkit that turns Wireshark captures (`.pcap` / `.pcapng`) into **sanitized Markdown reports** using `tshark`, then lets you analyze those reports using **GPT4All Desktop + LocalDocs** — **without cloud calls** and **without exposing a web service**.

> ⚠️ Security note: No open-source stack can be guaranteed “zero vulnerabilities”. This project focuses on **risk reduction**:
> - no internet required after setup,
> - no server ports opened,
> - narrow filesystem access,
> - optional network sandboxing for GPT4All (Flatpak overrides),
> - deterministic report generation via `tshark`.

---

## What you get

- `pcap2md.sh` — generate a compact Markdown summary from a PCAP/PCAPNG
- `new_session.sh` — create a session folder containing capture + `report.md`
- `collect_reports.sh` — gather `report.md` files into a single `reports/` folder (best for LocalDocs)
- `diagnostics.sh` — quick checks for Wireshark capture permissions and interfaces
- `install_ubuntu24.sh` — installs required packages on Ubuntu 24

---

## Architecture

```text
+------------------+        save as .pcapng        +------------------------+
|   Wireshark GUI  | ---------------------------> |  captures/ (pcapng)    |
+------------------+                               +------------------------+
          |                                                      |
          |                                                      v
          |                                           +---------------------+
          |                                           | scripts/pcap2md.sh  |
          |                                           | scripts/new_session |
          |                                           +----------+----------+
          |                                                      |
          v                                                      v
+------------------+                                 +------------------------+
| tshark / capinfos| ----> Markdown report.md ---->  | reports/ (Markdown)   |
+------------------+                                 +------------------------+
                                                                  |
                                                                  v
                                                     +------------------------+
                                                     | GPT4All Desktop        |
                                                     | LocalDocs Collection   |
                                                     | (offline, no server)   |
                                                     +------------------------+
```

---

## Quickstart (Ubuntu 24)

### 1) Install tools
```bash
./scripts/install_ubuntu24.sh
```

### 2) Ensure you can capture packets without root (recommended)
```bash
sudo dpkg-reconfigure wireshark-common   # choose YES for non-root capture
sudo adduser "$USER" wireshark
# log out / log in (or reboot) to apply group membership
```

Test:
```bash
/usr/bin/dumpcap -D
```

### 3) Capture traffic in Wireshark
- Start Wireshark
- Select interface: `any` (easy) or your NIC (e.g., `enp0s3`, `wlp...`)
- Start capture → generate traffic → Stop
- Save as: `./captures/test.pcapng`

### 4) Create a session + report
```bash
./scripts/new_session.sh ./captures/test.pcapng test_capture
```

This creates:
```text
sessions/YYYYMMDD_HHMMSS_test_capture/
  test.pcapng
  report.md
```

### 5) Collect reports for LocalDocs
GPT4All LocalDocs works best with **text files** (Markdown). PCAP is binary.
```bash
./scripts/collect_reports.sh
```
Result: `./reports/*.md`

---

## GPT4All Desktop (recommended setup)

### Install (Flatpak)
```bash
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.gpt4all.gpt4all
```

### Download models while internet is available (one time)
- Open GPT4All → **Models** → download one local model (7–8B Instruct, Q4 is a good CPU baseline)
- Open **Settings → LocalDocs**
  - **Disable** any “Embed API”/cloud option if shown
  - Ensure an embeddings model is available locally
- Create a LocalDocs collection pointing to:
  - `.../offline-wireshark-ai-assistant/reports`

### Lock GPT4All to offline + minimal folder access (Flatpak hardening)
```bash
# deny all network for GPT4All
flatpak override --user --unshare=network io.gpt4all.gpt4all

# allow access only to this repo folder
flatpak override --user --nofilesystem=home io.gpt4all.gpt4all
flatpak override --user --filesystem="$PWD" io.gpt4all.gpt4all
```

Launch:
```bash
flatpak run io.gpt4all.gpt4all
```

---

## Suggested prompts (copy/paste)

Use after you select the LocalDocs collection containing `reports/*.md`.

- **High-level overview**
  > Summarize the traffic in the latest report: key endpoints, protocols, and anything unusual.

- **Suspicious indicators**
  > Identify suspicious DNS/HTTP/TLS SNI patterns, rare ports, and unusual endpoints. Provide potential IOCs and explain why.

- **Actionable Wireshark filters**
  > Suggest Wireshark display filters to validate the top suspicious findings (DNS, HTTP, TLS, beaconing).

- **Investigation plan**
  > Provide a step-by-step investigation checklist based on this report.

---

## Troubleshooting

### Wireshark shows only extcap (ciscodump/sshdump/udpdump) and no local interfaces
Run:
```bash
./scripts/diagnostics.sh
```
Common fix:
```bash
sudo dpkg-reconfigure wireshark-common   # YES
sudo adduser "$USER" wireshark
# log out / log in (or reboot)
```

### `dumpcap: Permission denied`
Make sure you’re in the `wireshark` group and re-login:
```bash
groups | tr ' ' '\n' | grep wireshark
```

If needed:
```bash
sudo chown root:wireshark /usr/bin/dumpcap
sudo chmod 750 /usr/bin/dumpcap
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
```

### LocalDocs shows “0 words”
You likely indexed binary files (`.pcapng`). Index `./reports/*.md` instead.
```bash
./scripts/collect_reports.sh
```

---

## License
MIT. See `LICENSE`.
