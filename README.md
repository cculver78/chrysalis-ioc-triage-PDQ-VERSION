# Chrysalis IoC Triage

Check a Windows system for **Indicators of Compromise (IoC)** from the **Chrysalis backdoor** and **Lotus Blossom** campaign (Rapid7, Feb 2026).

| | |
|--|--|
| **Threat** | Chrysalis backdoor, Lotus Blossom (Billbug) APT |
| **Source** | [Rapid7 – The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit](https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/) |
| **Platform** | Windows (PowerShell 5.1+) |

---

## Table of contents

- [Quick start](#quick-start)
- [What is checked](#what-is-checked)
- [Options](#options)
- [Project layout](#project-layout)
- [Documentation](#documentation)
- [Interpretation](#interpretation)
- [Contributing](#contributing)
- [License](#license)

---

## Quick start

**Requirements:** Windows, PowerShell 5.1+. Run as Administrator for full registry and service checks.

```powershell
# Clone the repo (or download and extract)
git clone https://github.com/YOUR_USERNAME/chrysalis-ioc-triage.git
cd chrysalis-ioc-triage

# Run the checker
.\scripts\Check-ChrysalisIoC.ps1
```

- **Exit code 0** – No IoCs detected in checked locations.
- **Exit code 1** – One or more findings; see console output and the generated `chrysalis-scan-<timestamp>.json` report.

---

## What is checked

| Check | Description |
|-------|-------------|
| **Paths** | `%AppData%\Bluetooth` (and if hidden); files under that folder and `%ProgramData%\USOShared` |
| **File hashes** | SHA-256 of files in those folders (and optional `-ScanPaths`); compared to 16 known malicious hashes |
| **Mutex** | `Global\Jdhfv_1.0.1` (Chrysalis single-instance; presence suggests possible live implant) |
| **Registry** | HKCU/HKLM Run keys for Chrysalis-like values (e.g. `BluetoothService.exe` in `AppData\Bluetooth` with `-i`/`-k`) |
| **Services** | Services named `BluetoothService` or path under `AppData\...\Bluetooth\BluetoothService.exe` |

The script is **read-only**: it does not delete or modify files or registry.

---

## Options

| Parameter | Description |
|-----------|-------------|
| `-ScanPaths 'C:\Users','C:\ProgramData'` | Also hash and compare files under these paths (can be slow) |
| `-NoRegistry` | Skip Run key checks |
| `-NoMutex` | Skip mutex check |
| `-IocFile <path>` | Use a custom IoC JSON file (default: `iocs.json` in repo root) |

**Example – broader scan:**

```powershell
.\scripts\Check-ChrysalisIoC.ps1 -ScanPaths 'C:\Users','C:\ProgramData'
```

---

## Project layout

```
chrysalis-ioc-triage/
├── README.md           # This file
├── AGENTS.md           # Context for AI/agent use
├── CONTRIBUTING.md     # How to contribute
├── LICENSE             # MIT
├── CHANGELOG.md        # Version history
├── iocs.json           # IoC data (hashes, paths, mutex, registry, network)
├── docs/
│   ├── README.md       # Documentation index
│   ├── chrysalis-iocs.md   # Human-readable IoC reference
│   └── script-reference.md # Script parameters and behavior
└── scripts/
    └── Check-ChrysalisIoC.ps1
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/README.md](docs/README.md) | Documentation index and links |
| [docs/chrysalis-iocs.md](docs/chrysalis-iocs.md) | Full IoC list (hashes, paths, mutex, registry, network, MITRE) |
| [docs/script-reference.md](docs/script-reference.md) | Script reference (parameters, exit codes, report format) |
| [AGENTS.md](AGENTS.md) | Project context and conventions for agents |

---

## Interpretation

- **Critical** – Known malicious file hash match or Chrysalis mutex present → treat as compromise until proven otherwise.
- **High** – Suspicious path, Run key, or service → investigate (possible naming overlap with legitimate software).

**Note:** `C:\ProgramData\USOShared` is a legitimate Windows path; the script does not flag its existence, only known malicious hashes there. Registry and service logic is tuned to Chrysalis patterns to reduce false positives.

---

## Upload to GitHub

First time pushing to a new repo? See **[docs/UPLOAD-TO-GITHUB.md](docs/UPLOAD-TO-GITHUB.md)** for step-by-step instructions.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add IoCs, report issues, or suggest changes.

---

## License

MIT. See [LICENSE](LICENSE).
