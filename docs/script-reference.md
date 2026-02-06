# Script reference: Check-ChrysalisIoC.ps1

Reference for the Chrysalis IoC checker script (PDQ Connect Edition).

## Synopsis

```powershell
.\scripts\Check-ChrysalisIoC.ps1
```

The script is self-contained with all IoCs embedded. No parameters or external files are required.

## Checks performed

| Check | Description |
|-------|-------------|
| **Known paths** | Checks for existence of Chrysalis install paths (`%AppData%\Bluetooth` and contents). Detects hidden directory attribute. |
| **File hashes** | SHA-256 hashes files in `%AppData%\Bluetooth` and `%ProgramData%\USOShared`, compares against 16 known malicious hashes. |
| **Mutex** | Attempts to open `Global\Jdhfv_1.0.1` (Chrysalis single-instance mutex). Presence suggests a live implant. |
| **Registry Run keys** | Checks HKCU/HKLM Run keys for values matching Chrysalis patterns (e.g. `BluetoothService.exe` in `AppData\Bluetooth` with `-i`/`-k` flags). |
| **Services** | Checks for services named `BluetoothService` or with paths pointing to `AppData\...\Bluetooth\BluetoothService.exe`. |

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | No IoCs detected in checked locations. |
| `1` | One or more findings (path, hash, mutex, registry, or service). |

## Output

- **Console** -- Progress lines (`[*] Checking ...`) and findings (`[FOUND]`, `[MATCH]`, `[SUSPICIOUS]`). Summary at the end.
- **Report file** -- `C:\ProgramData\ChrysalisScan\chrysalis-scan-YYYYMMdd-HHmmss.json`. Contains an array of findings with:
  - `Category` -- Path, FileHash, Mutex, Registry, Service.
  - `Detail` -- Human-readable description.
  - `Severity` -- Critical or High.
  - `Time` -- ISO 8601 timestamp.

## Requirements

- **OS:** Windows.
- **PowerShell:** 5.1 or later.
- **Permissions:** Run as Administrator for full registry and service checks. Script is read-only.

## Deployment

### PDQ Connect

1. Add `Check-ChrysalisIoC.ps1` as a PowerShell script step in a PDQ Connect package.
2. Deploy to target endpoints.
3. Check exit codes: 0 = clean, 1 = findings detected.
4. Collect reports from `C:\ProgramData\ChrysalisScan\` on each endpoint.

### Manual

```powershell
.\scripts\Check-ChrysalisIoC.ps1
```

## Differences from upstream

This is a fork of [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage). The following changes were made for PDQ Connect compatibility:

| Feature | Upstream | This fork |
|---------|----------|-----------|
| IoC source | External `iocs.json` file | Embedded in script; `iocs.json` removed from repo |
| Parameters | `-ScanPaths`, `-IocFile`, `-NoRegistry`, `-NoMutex` | None (runs all default checks) |
| Script structure | Top-level `[CmdletBinding()]` / `param()` | Wrapped in `function Main` |
| Report location | Next to `iocs.json` | `C:\ProgramData\ChrysalisScan\` |

## Embedded IoCs

The script contains the following embedded IoC arrays. When adding new indicators, update these arrays in the script AND the corresponding entries in [chrysalis-iocs.md](chrysalis-iocs.md).

- `$fileHashes` -- 16 SHA-256 hashes (lowercase hex strings).
- `$knownPaths` -- Chrysalis install paths with `%AppData%` variables.
- `$hashOnlyPaths` -- Paths to hash-check only (e.g. `%ProgramData%\USOShared`).
- `$mutexes` -- Mutex names to check.
- `$registryRunPaths` -- Registry Run key paths to inspect.
