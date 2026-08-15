# dsh-plugin-gate

Linux-first security-hardened runtime injector for DeepSeek Harness plugins.

This project intentionally differs from the original injector:

- `trustedRoots` is required for external plugin injection.
- Arbitrary JavaScript staging is disabled.
- Plugin-directory build scripts are disabled by default.
- GitHub release automation is disabled by default.
- Auto-restore revalidates plugin paths and package layout.
- HTTP state-changing endpoints require `x-dsh-plugin-gate-token`.
- Ingest automation is disabled until a confirmation workflow is implemented.

## Installation

All installation methods require a Linux DSH web profile. After installation, restart the DSH web process and verify with `dev_plugin_status`.

### Option 1: GitHub repository

Use the DSH plugin manager to install from the `xypure-x` organization:

```bash
dsh plugin --profile web add github:xypure-x/dsh-plugin-gate
```

Restart the DSH web process, then run:

```text
dev_plugin_status
```

### Option 2: Release tarball

Download a release tarball from the project releases page, then extract it:

```bash
mkdir -p ~/dsh-plugin-gate
tar -xzf xypure-x-dsh-plugin-gate-<version>.tgz \
  -C ~/dsh-plugin-gate --strip-components=1
dsh plugin --profile web add ~/dsh-plugin-gate
```

This method does not require a local checkout of the project, but the tarball must contain `lib/` and `cordis.patch.yml`.

### Option 3: npm registry package

After the package has been published to the configured npm registry, install it through the DSH plugin manager:

```bash
dsh plugin --profile web add @xypure-x/dsh-plugin-gate
```

For a private registry, configure npm authentication first:

```bash
npm login --registry=https://registry.example.com
dsh plugin --profile web add @xypure-x/dsh-plugin-gate
```

The repository currently uses `private: true`, so it is not publishable to the public npm registry until the release policy is changed. `npm pack` can still be used to produce a local tarball.

### Option 4: Build from source

```bash
git clone https://github.com/xypure-x/dsh-plugin-gate.git
cd dsh-plugin-gate
export DSH_CHECKOUT=/path/to/deepseek-harness
npm run build
npm run build:client
dsh plugin --profile web add "$PWD"
```

### Option 5: Manual profile patch

Add the plugin to `~/.dsh/profiles/web/cordis.patch.yml`:

```yaml
- insert:
    - id: dsh-plugin-gate
      name: '@xypure-x/dsh-plugin-gate'
      config: {}
```

The package must also be resolvable from the profile's `node_modules`. Manual patching is intended as a fallback; prefer the DSH plugin manager when available.

### Configure trusted plugin roots

Before injecting external plugins, configure an explicit trusted root:

```yaml
config:
  trustedRoots:
    - /home/user/dsh-plugins
```

An empty `trustedRoots` list fails closed and rejects external plugin injection.

## Linux Requirements

- Linux
- Node.js from the DSH installation, preferably the same major version as the running Harness
- Bash and npm
- A DSH source checkout with `packages/` and `node_modules/.bin/tsc`
- `DSH_CHECKOUT` pointing to that checkout

## Build

```bash
export DSH_CHECKOUT=/path/to/deepseek-harness
bash scripts/build.sh
```

The build script links compile-time dependencies from the DSH checkout and writes `lib/`.

## Configuration

Configure the plugin with an explicit trusted root, for example:

```yaml
- insert:
    - id: dsh-plugin-gate
      name: '@xypure-x/dsh-plugin-gate'
      config:
        trustedRoots:
          - /home/user/dsh-plugins
        autoRestore: false
        allowUnsafeBuildScripts: false
        allowRelease: false
        apiToken: ''
```

An empty `trustedRoots` list fails closed and rejects external plugin injection.

## Security Boundary

This is a high-privilege development tool, not a sandbox. A plugin that is explicitly injected still runs in the Harness process. Do not add untrusted directories to `trustedRoots`, and do not enable unsafe build or release features for unreviewed code.

See [SECURITY-HARDENING-PLAN.md](./SECURITY-HARDENING-PLAN.md) for the implementation roadmap.

Reference project: [dsh-router-standard](https://github.com/yjh051108/dsh-router-standard).
