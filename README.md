# Chrysalis IoC Triage (PDQ Connect Edition)

A self-contained, read-only host-based checker for **Indicators of Compromise (IoC)** associated with the **Chrysalis** backdoor and **Lotus Blossom (Billbug)** campaign. Designed for deployment via **PDQ Connect** across Windows endpoints.

## Credit

Forked from [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage). Original script and IoC data by **CreamyG31337**. This fork restructures the script for mass deployment via PDQ Connect.

## Source

All IoCs are derived from the following publication:

**Rapid7 -- *The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit***
<https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/>

| | |
|--|--|
| **Threat** | Chrysalis backdoor, Lotus Blossom (Billbug) APT |
| **Platform** | Windows (PowerShell 5.1+) |

---

## Quick start

**Requirements:** Windows, PowerShell 5.1 or later. Run as Administrator for full registry and service checks.

The script is fully self-contained with all IoCs embedded. No external `iocs.json` file is needed.

### PDQ Connect deployment

1. Add `Check-ChrysalisIoC.ps1` as a PowerShell script step in a PDQ Connect package.
2. Deploy to target endpoints.
3. Exit code 0 = clean. Exit code 1 = findings detected.
4. JSON reports are saved to `C:\ProgramData\ChrysalisScan\` on each endpoint.

### Manual execution

```powershell
.\Check-ChrysalisIoC.ps1
```

---

## What is checked

| Check | Description |
|-------|-------------|
| **Paths** | `%AppData%\Bluetooth` (including hidden attribute check); files under that folder and `%ProgramData%\USOShared` |
| **File hashes** | SHA-256 of files in known directories compared against 16 known malicious hashes |
| **Mutex** | `Global\Jdhfv_1.0.1` (Chrysalis single-instance; presence suggests possible live implant) |
| **Registry** | HKCU/HKLM Run keys for Chrysalis-like values (e.g. `BluetoothService.exe` in `AppData\Bluetooth` with `-i`/`-k`) |
| **Services** | Services named `BluetoothService` or with path under `AppData\...\Bluetooth\BluetoothService.exe` |

The script is read-only and does not modify files, registry, or services.

---

## Changes from upstream

| Upstream (CreamyG31337) | This fork |
|--------------------------|-----------|
| IoCs loaded from external `iocs.json` | IoCs embedded directly in the script; `iocs.json` removed from repo |
| Parameters: `-ScanPaths`, `-NoRegistry`, `-NoMutex`, `-IocFile` | No parameters; runs all default checks |
| Top-level `[CmdletBinding()]` / `param()` block | Wrapped in `function Main` for PDQ Connect compatibility |
| Report saved next to `iocs.json` | Report saved to `C:\ProgramData\ChrysalisScan\` |

---

## Project layout

```
chrysalis-ioc-triage/
+-- README.md
+-- AGENTS.md
+-- CONTRIBUTING.md
+-- LICENSE
+-- CHANGELOG.md
+-- docs/
|   +-- README.md
|   +-- chrysalis-iocs.md
|   +-- script-reference.md
+-- scripts/
    +-- Check-ChrysalisIoC.ps1
```

---

## Report output

Reports are saved as JSON to `C:\ProgramData\ChrysalisScan\chrysalis-scan-<timestamp>.json` on each endpoint. Each finding includes a category, detail, severity, and timestamp.

## Interpretation

- **Critical** -- Known malicious file hash match or Chrysalis mutex present. Treat as compromise until proven otherwise.
- **High** -- Suspicious path, Run key, or service. Investigate further (may overlap with legitimate software).

`C:\ProgramData\USOShared` is a legitimate Windows path; the script does not flag its existence, only known malicious hashes within it. Registry and service checks use Chrysalis-specific patterns to limit false positives.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
