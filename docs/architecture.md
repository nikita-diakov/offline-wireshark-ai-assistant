# Architecture

This toolkit follows an offline-first, low-attack-surface design:

1. Capture traffic using Wireshark and save to `captures/`.
2. Convert binary capture files into **text-only** Markdown reports via `tshark`.
3. Point GPT4All LocalDocs to the `reports/` folder and analyze the textual summaries offline.

## Data flow

```text
Wireshark (.pcapng) → tshark/capinfos → report.md → GPT4All LocalDocs
```

## Security design choices

- No web service: reduces exposure to HTTP-layer vulnerabilities.
- Text-only reports: avoid indexing binary artifacts in LocalDocs.
- Optional Flatpak sandboxing: deny network and restrict filesystem to the repo folder.
- No capture data committed: `.gitignore` blocks PCAP/PCAPNG by default.
