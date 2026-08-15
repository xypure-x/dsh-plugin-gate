# Changelog: Hardened Runtime

## 2026-08-15

- Created the initial Linux-first security hardening specification.
- Defined fail-closed behavior for arbitrary JavaScript, shell execution, plugin injection, restore, and HTTP management operations.
- Implemented the initial hardened runtime: trusted roots, package validation, fingerprints, token-protected state changes, disabled dynamic staging/ingest/build/release defaults, Linux checkout-aware build scripts, and static security checks.
- Removed personal usernames, names, and machine-specific paths from project documentation and source examples.
- Renamed the project to `dsh-plugin-gate`, moved the package scope to `@xypure-x`, and updated runtime, API, client, storage, and repository identifiers.
