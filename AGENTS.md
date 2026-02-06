# Triage -- Chrysalis / Lotus Blossom IoC Investigation (PDQ Connect Edition)

## Purpose

This project checks a Windows host for **Indicators of Compromise (IoC)** related to the **Chrysalis backdoor** and **Lotus Blossom (Billbug)** campaign described in Rapid7's write-up:

- **Blog:** [The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit](https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/)
- **Threat:** Chinese APT Lotus Blossom; initial access via abused Notepad++ update (e.g. `update.exe` from 95.179.213.0).
- **Upstream:** Forked from [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage). Restructured for PDQ Connect deployment.

## What Gets Checked

- **Paths** -- Known install paths (e.g. `%AppData%\Bluetooth`, `C:\ProgramData\USOShared`).
- **File hashes** -- SHA-256 of known malicious files (installers, DLLs, loaders, shellcode) in those directories.
- **Mutex** -- `Global\Jdhfv_1.0.1` (Chrysalis single-instance).
- **Registry** -- Run keys (HKCU/HKLM) for values referencing BluetoothService or `-i`/`-k` style arguments.
- **Services** -- Services named or pointing to BluetoothService.

## Key Differences from Upstream

- **Self-contained:** All IoCs are embedded in the script. No external `iocs.json` dependency.
- **No parameters:** Runs all default checks. The `-ScanPaths`, `-NoRegistry`, `-NoMutex`, and `-IocFile` options from upstream are removed.
- **PDQ Connect compatible:** Script body is wrapped in `function Main { ... }; Main` to avoid parser issues with `[CmdletBinding()]`/`param()` in non-file execution contexts.
- **Report location:** `C:\ProgramData\ChrysalisScan\` instead of next to the IoC file.

## Project Layout

- **`docs/chrysalis-iocs.md`** -- Human-readable IoC reference and MITRE mapping.
- **`scripts/Check-ChrysalisIoC.ps1`** -- Self-contained PowerShell script with embedded IoCs.

## How to Run the Check

### Via PDQ Connect

Add `Check-ChrysalisIoC.ps1` as a script step in a PDQ Connect package and deploy. Exit code 0 = clean, exit code 1 = findings.

### Manual

```powershell
.\scripts\Check-ChrysalisIoC.ps1
```

Reports are saved to `C:\ProgramData\ChrysalisScan\chrysalis-scan-<timestamp>.json`. Exit code 1 if any finding, 0 if none.

## Agent / AI Guidelines

- When adding IoCs, update both the embedded arrays in the script AND `docs/chrysalis-iocs.md` to keep them in sync.
- Prefer the script's existing categories (Path, FileHash, Mutex, Registry, Service) for new findings; add new categories only when they don't fit.
- Do not modify live system state (e.g. delete files or change registry) from the script; keep it read-only.
- For network IoCs (IPs/domains), use external tools or manual review; the script focuses on host-based IoCs.
