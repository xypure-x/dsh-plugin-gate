# Design: Hardened Runtime

## Scope

This project is a security-hardened runtime gate for DSH plugins, optimized first for Linux. It keeps the trusted local-development workflow but does not treat arbitrary plugin directories or agent-generated code as trusted by default.

## Architecture

- **Configuration layer:** explicit trusted roots, profile directory, auto-restore policy, unsafe feature flags, and API token.
- **Security layer:** canonical path validation, package layout validation, content fingerprinting, request authentication, and restrictive persistence.
- **Runtime layer:** existing loader/fiber lifecycle operations, used only after security checks pass.
- **Capability boundary:** high-risk tools return a confirmation-required result unless the operation has an explicit trusted policy.
- **Linux baseline:** POSIX symlinks, Bash build support, `os.tmpdir()`, and DSH checkout detection are first-class.

## Trust model

The following are untrusted by default:

- Agent-provided paths.
- Plugin source and generated files.
- README files, comments, tool results, and ingest input.
- Plugin build scripts and npm lifecycle scripts.
- Existing registry entries whose fingerprint no longer matches.

The host process remains a high-value trust boundary. In-process JavaScript plugins cannot be safely sandboxed with ordinary `new Function` or VM APIs; durable isolation requires a worker or separate process with a reduced capability protocol.

## Data flow

1. Tool receives a path or operation request.
2. Input is normalized and canonicalized.
3. Security policy validates the operation, path, package layout, and approval state.
4. The operation is either rejected, returned as confirmation-required, or executed.
5. Successful persistent operations store an atomic record containing path, package name, fingerprint, and timestamp.
6. Restore revalidates all stored fields before runtime loading.

## Correctness Properties

### Property 1: Path containment

Every injected or built directory SHALL be a canonical descendant of a configured trusted root.

**Validates: Requirements 3.1, 3.2, 5.4**

### Property 2: No default dynamic evaluation

The default runtime SHALL contain no active path that evaluates agent-supplied JavaScript source or executes an arbitrary plugin build script.

**Validates: Requirements 2.1, 2.2, 2.3, 5.4**

### Property 3: Restore integrity

An auto-restore operation SHALL load a plugin only when its canonical path, package layout, and stored fingerprint remain valid.

**Validates: Requirements 3.3, 3.4, 5.2**

### Property 4: Fail closed

Missing prerequisites, invalid policy, invalid state, and unsupported private APIs SHALL produce an actionable error without modifying profile state.

**Validates: Requirements 1.4, 4.1, 5.3**

## Error handling

- Security errors are explicit and do not fall back to execution.
- Build and release failures do not write profile configuration.
- Restore skips invalid entries and records an audit event.
- API errors return a generic client-safe message; detailed diagnostics remain server-side.
