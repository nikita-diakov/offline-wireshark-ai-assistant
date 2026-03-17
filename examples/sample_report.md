# PCAP report: sample_capture.pcapng

## Capture metadata
File name: sample_capture.pcapng
File type: pcapng
Packet count: 12345
Capture duration: 120.0 seconds
Data size: 9 MB

## Protocol hierarchy
- Ethernet
  - IPv4
    - TCP (TLS, HTTP)
    - UDP (DNS)

## Top IPv4 endpoints
- 192.168.1.10 (client) → 192.168.1.1 (gateway)
- 192.168.1.10 → 93.184.216.34 (example.org)

## DNS queries (first 10)
2026-03-18 12:00:01  192.168.1.10  example.org  A
2026-03-18 12:00:05  192.168.1.10  api.example.org  A

## HTTP requests (first 5)
2026-03-18 12:00:10  192.168.1.10  93.184.216.34  example.org  GET  /
2026-03-18 12:00:12  192.168.1.10  93.184.216.34  example.org  GET  /robots.txt

## TLS SNI (first 5)
2026-03-18 12:00:20  192.168.1.10  93.184.216.34  example.org

---
This is a **synthetic** example report. Do not commit real customer or production traffic to GitHub.
