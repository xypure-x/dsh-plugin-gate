# Requirements: Hardened Runtime

## Requirement 1: Linux-first operation

As an operator, I want the plugin gate to work predictably on Linux with explicit prerequisites, so that platform assumptions are visible and failures are safe.

### Acceptance Criteria

- **1.1** The project SHALL document Node.js, Bash, npm, and `DSH_CHECKOUT` requirements.
- **1.2** The project SHALL use POSIX symlinks on Linux and SHALL reject unsupported platform-specific operations with an actionable error.
- **1.3** The project SHALL use `os.tmpdir()` for temporary files and SHALL not contain an author-specific absolute path.
- **1.4** If a required DSH checkout or compiler is unavailable, build operations SHALL fail before modifying profile state.

## Requirement 2: No unrestricted code execution by default

As a security-conscious operator, I want agent-facing tools not to evaluate arbitrary JavaScript or shell strings by default.

### Acceptance Criteria

- **2.1** `dev_stage_add` SHALL reject executable source strings unless an explicit disabled-by-default unsafe mode is configured.
- **2.2** Staging persistence SHALL NOT restore executable source automatically.
- **2.3** Build operations SHALL use an allowlisted command path and SHALL reject untrusted build scripts by default.
- **2.4** Release operations SHALL be disabled by default and SHALL require explicit configuration and user confirmation.

## Requirement 3: Trusted plugin injection

As an operator, I want injected plugins to come only from approved locations and verified package layouts.

### Acceptance Criteria

- **3.1** Injection SHALL canonicalize the requested directory before checking it.
- **3.2** Injection SHALL reject directories outside configured trusted roots.
- **3.3** Injection SHALL reject missing or malformed `package.json`, missing `lib/index.js`, and package entry points outside the package directory.
- **3.4** Auto-restore SHALL revalidate the path and package fingerprint before loading a plugin.

## Requirement 4: Protected management interface

As an operator, I want local management endpoints to be protected from browser-originated or unauthenticated high-risk actions.

### Acceptance Criteria

- **4.1** State-changing API requests SHALL require an authentication token.
- **4.2** The API SHALL enforce a request body size limit.
- **4.3** The API SHALL not expose internal stack traces or unrestricted local file details to the client.
- **4.4** Ingest SHALL perform read-only analysis by default and SHALL require confirmation before build or injection.

## Requirement 5: Safe persistence and degradation

As an operator, I want corrupted or modified state to fail closed without bricking the harness.

### Acceptance Criteria

- **5.1** Registry and security state writes SHALL be atomic and SHALL use restrictive file permissions where supported.
- **5.2** Modified plugin fingerprints SHALL invalidate automatic restore approval.
- **5.3** Missing or incompatible private DSH APIs SHALL disable the affected operation rather than silently mutate runtime state.
- **5.4** The project SHALL provide static tests covering path traversal, arbitrary code markers, hardcoded paths, and unsafe command execution.
