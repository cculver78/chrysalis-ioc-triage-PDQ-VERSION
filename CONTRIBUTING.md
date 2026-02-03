# Contributing to Chrysalis IoC Triage

Contributions are welcome: new IoCs, script improvements, or documentation fixes.

## Adding or updating IoCs

1. **Source** – Only add IoCs from reliable, public sources (e.g. vendor blogs, CERTs). Include the URL in your PR.
2. **Keep in sync** – Update both:
   - **`iocs.json`** – Machine-readable data for the script (`fileHashes`, `paths`, `mutexes`, `registryRunPaths`, `network`).
   - **`docs/chrysalis-iocs.md`** – Human-readable reference table and notes.
3. **Script behavior** – If you add new check types (e.g. new registry paths), extend `scripts/Check-ChrysalisIoC.ps1` and document in `docs/script-reference.md`.

## Script changes

- The script is **read-only**: it must not delete, move, or modify files or registry.
- Prefer existing categories: `Path`, `FileHash`, `Mutex`, `Registry`, `Service`. Add new categories only when necessary.
- Preserve PowerShell 5.1 compatibility (no `??`, etc.).
- Document new parameters and behavior in `docs/script-reference.md` and the script’s comment-based help.

## Documentation

- **README.md** – User-facing: quick start, options, layout, links.
- **AGENTS.md** – Context for AI/agents: purpose, layout, how to run, conventions.
- **docs/** – Detailed IoC list and script reference.

## Submitting changes

1. Fork the repo and create a branch.
2. Make your changes; keep `iocs.json` and `docs/chrysalis-iocs.md` in sync when touching IoCs.
3. Run the script locally to confirm it still runs and reports as expected.
4. Open a pull request with a short description and, if adding IoCs, the source URL.

## Code of conduct

Be respectful and constructive. This project is for defensive security use only.
