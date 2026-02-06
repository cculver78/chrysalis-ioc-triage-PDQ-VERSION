# Contributing to Chrysalis IoC Triage (PDQ Connect Edition)

Contributions are welcome: new IoCs, script improvements, or documentation fixes.

This is a fork of [CreamyG31337/chrysalis-ioc-triage](https://github.com/CreamyG31337/chrysalis-ioc-triage), restructured for PDQ Connect deployment.

## Adding or updating IoCs

1. **Source** -- Only add IoCs from reliable, public sources (e.g. vendor blogs, CERTs). Include the URL in your PR.
2. **Keep in sync** -- Because IoCs are embedded in the script, you need to update two places:
   - **`scripts/Check-ChrysalisIoC.ps1`** -- The embedded arrays (`$fileHashes`, `$knownPaths`, `$hashOnlyPaths`, `$mutexes`, `$registryRunPaths`) inside the `Main` function.
   - **`docs/chrysalis-iocs.md`** -- Human-readable reference table and notes.

## Script changes

- The script is **read-only**: it must not delete, move, or modify files or registry.
- The script must remain **self-contained** with no external file dependencies, since it's deployed via PDQ Connect.
- Preserve the `function Main { ... }; Main` wrapper. This is required for PDQ Connect compatibility.
- Prefer existing categories: `Path`, `FileHash`, `Mutex`, `Registry`, `Service`. Add new categories only when necessary.
- Preserve PowerShell 5.1 compatibility (no `??`, `?.`, ternary operators, etc.).
- Document new checks and behavior in `docs/script-reference.md` and the script's comment-based help.

## Documentation

- **README.md** -- User-facing: quick start, deployment instructions, layout, links.
- **AGENTS.md** -- Context for AI/agents: purpose, layout, how to run, conventions.
- **docs/** -- Detailed IoC list and script reference.

## Submitting changes

1. Fork the repo and create a branch.
2. Make your changes; keep the script's embedded IoCs and `docs/chrysalis-iocs.md` in sync when touching IoCs.
3. Run the script locally to confirm it still runs and reports as expected.
4. Open a pull request with a short description and, if adding IoCs, the source URL.

## Code of conduct

Be respectful and constructive. This project is for defensive security use only.
