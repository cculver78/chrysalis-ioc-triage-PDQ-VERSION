# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [2.0.0] -- 2026-02-06

### Changed

- **Script:** Restructured for PDQ Connect deployment. Script body wrapped in `function Main` to avoid PowerShell parser issues in non-file execution contexts.
- **IoCs:** All indicators (hashes, paths, mutexes, registry keys) are now embedded directly in the script. No external `iocs.json` dependency.
- **Report location:** JSON reports now saved to `C:\ProgramData\ChrysalisScan\` instead of next to the IoC file.
- **Documentation:** Updated README, AGENTS.md, CONTRIBUTING.md, and CHANGELOG to reflect fork changes.

### Removed

- **Parameters:** `-ScanPaths`, `-NoRegistry`, `-NoMutex`, `-IocFile` removed. Script runs all default checks.
- **External IoC file:** `iocs.json` removed from the repo. All IoCs are embedded in the script. Human-readable reference remains in `docs/chrysalis-iocs.md`.

### Credit

- Forked from [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage). Original script and IoC data by **CreamyG31337**.

## [1.0.0] -- 2026-02-02

### Added

- **Script:** `Check-ChrysalisIoC.ps1` -- Checks paths, file hashes, mutex `Global\Jdhfv_1.0.1`, Run keys, and services.
- **IoC data:** `iocs.json` -- 16 file hashes, paths, mutex, registry Run paths, network (IPs/domains).
- **Docs:** `docs/chrysalis-iocs.md` -- Human-readable IoC reference and MITRE mapping.
- **Docs:** `docs/script-reference.md` -- Script parameters, exit codes, report format.
- **Docs:** README, AGENTS.md, CONTRIBUTING.md, LICENSE (MIT), CHANGELOG.
- **Options:** `-ScanPaths`, `-NoRegistry`, `-NoMutex`, `-IocFile`.
- **Report:** JSON report `chrysalis-scan-<timestamp>.json` with category, detail, severity, time.

### Notes

- IoCs sourced from [Rapid7 -- The Chrysalis Backdoor: A Deep Dive into Lotus Blossom's toolkit](https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/).
- Script is read-only; no files or registry are modified.
