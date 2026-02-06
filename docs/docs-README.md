# Documentation

Documentation for the Chrysalis IoC Triage project (PDQ Connect Edition).

Forked from [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage).

## Contents

| Document | Description |
|----------|-------------|
| [chrysalis-iocs.md](chrysalis-iocs.md) | **IoC reference** -- File hashes (SHA-256), paths, mutex, registry, network indicators, and MITRE ATT&CK mapping. Sourced from Rapid7's Chrysalis / Lotus Blossom write-up. |
| [script-reference.md](script-reference.md) | **Script reference** -- `Check-ChrysalisIoC.ps1` exit codes, report format, and usage. |

## Threat context

- **Campaign:** Chrysalis backdoor, Lotus Blossom (Billbug) APT.
- **Initial access:** Abuse of Notepad++ distribution (e.g. `update.exe` from 95.179.213.0).
- **Source:** [Rapid7 -- The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit](https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/).

## Project docs (root)

- [README.md](../README.md) -- Quick start, deployment instructions, and overview.
- [AGENTS.md](../AGENTS.md) -- Context for AI/agent use.
- [CONTRIBUTING.md](../CONTRIBUTING.md) -- How to contribute (IoC updates, script, docs).
