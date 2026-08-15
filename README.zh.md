# dsh-plugin-gate

面向 Linux 的 DeepSeek Harness 安全加固运行时插件注入器。

本项目是原始注入器的独立加固版本，重点是限制 AI agent 对本地代码、构建脚本和持久化配置的直接控制。

## 与原版的区别

- 外部插件注入必须位于显式配置的 `trustedRoots` 目录下。
- 默认禁用任意 JavaScript staging，不执行 `new Function`。
- 默认禁止执行插件目录中的 `build.sh` 和 npm 构建脚本。
- 默认禁用 GitHub Release 发布能力。
- 自动恢复默认关闭；启用后会重新校验插件路径、包结构和指纹。
- HTTP 状态修改接口要求 `x-dsh-plugin-gate-token` 认证。
- 自动 ingest 默认关闭，未经人工审查不会创建插件会话。

## 安装方式

以下方式均以 Linux DSH web profile 为目标。安装后需要重启 DSH web 进程，并使用 `dev_plugin_status` 验证插件状态。

### 方式一：GitHub 仓库安装

通过 DSH 插件管理器从 `xypure-x` 组织安装：

```bash
dsh plugin --profile web add github:xypure-x/dsh-plugin-gate
```

重启 DSH web 进程后执行：

```text
dev_plugin_status
```

### 方式二：Release tarball 安装

从项目 Release 页面下载 tarball，然后解压并装配：

```bash
mkdir -p ~/dsh-plugin-gate
tar -xzf xypure-x-dsh-plugin-gate-<version>.tgz \
  -C ~/dsh-plugin-gate --strip-components=1
dsh plugin --profile web add ~/dsh-plugin-gate
```

该方式不要求本地存在项目源码，但 tarball 必须包含 `lib/` 和 `cordis.patch.yml`。

### 方式三：npm registry 包安装

当包已经发布到所使用的 npm registry 后，可以通过 DSH 插件管理器安装：

```bash
dsh plugin --profile web add @xypure-x/dsh-plugin-gate
```

如果使用私有 registry，先完成 npm 登录：

```bash
npm login --registry=https://registry.example.com
dsh plugin --profile web add @xypure-x/dsh-plugin-gate
```

当前仓库的 `package.json` 使用 `private: true`，因此暂时不能发布到公共 npm registry。发布前需要先调整发布策略；本地仍可使用 `npm pack` 生成 tarball。

### 方式四：从源码构建安装

```bash
git clone https://github.com/xypure-x/dsh-plugin-gate.git
cd dsh-plugin-gate
export DSH_CHECKOUT=/path/to/deepseek-harness
npm run build
npm run build:client
dsh plugin --profile web add "$PWD"
```

### 方式五：手动 profile patch

编辑 `~/.dsh/profiles/web/cordis.patch.yml`，加入：

```yaml
- insert:
    - id: dsh-plugin-gate
      name: '@xypure-x/dsh-plugin-gate'
      config: {}
```

同时确保插件可以从 profile 的 `node_modules` 解析。手动 patch 仅作为兜底方式，优先使用 DSH 插件管理器。

### 配置可信插件目录

在注入外部插件前，必须配置明确的可信根目录：

```yaml
config:
  trustedRoots:
    - /home/user/dsh-plugins
```

`trustedRoots` 为空时会安全失败，拒绝注入外部插件。

## Linux 环境要求

- Linux
- DSH 安装自带的 Node.js，建议与当前 Harness 使用相同的大版本
- Bash 和 npm
- DSH 源码 checkout，且包含：
  - `packages/`
  - `node_modules/.bin/tsc`
  - `node_modules/.bin/tsdown`（构建 client 时需要）
- `DSH_CHECKOUT` 环境变量指向 DSH 源码 checkout

检查 checkout：

```bash
export DSH_CHECKOUT=/path/to/deepseek-harness
test -d "$DSH_CHECKOUT/packages"
test -x "$DSH_CHECKOUT/node_modules/.bin/tsc"
```

## 构建

构建 host 侧代码：

```bash
export DSH_CHECKOUT=/path/to/deepseek-harness
npm run build
```

构建 client UI：

```bash
npm run build:client
```

类型检查：

```bash
npm run typecheck
```

安全静态检查：

```bash
npm run security:check
```

构建脚本会从 DSH checkout 链接编译依赖，并将 host 产物写入 `lib/`。client 构建产物为 `lib/client.js`。

## 安装配置

在 DSH profile 的 `cordis.patch.yml` 中配置插件。必须显式指定可信插件目录：

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

`trustedRoots` 为空时会安全失败，拒绝注入外部插件。目录会先经过真实路径解析，再检查是否位于可信根目录下。

## 配置项

| 配置项 | 默认值 | 说明 |
|---|---:|---|
| `trustedRoots` | `[]` | 允许注入和安装插件的 canonical 根目录 |
| `autoRestore` | `false` | 是否在启动时自动恢复 registry 中的插件 |
| `allowUnsafeBuildScripts` | `false` | 是否允许执行插件目录中的构建脚本 |
| `allowRelease` | `false` | 是否允许调用 `gh` 发布 GitHub Release |
| `apiToken` | `''` | HTTP 状态修改接口认证 token |

除非在受控开发环境中经过人工审核，否则不要启用 `allowUnsafeBuildScripts` 或 `allowRelease`。

## HTTP 管理接口

状态修改接口默认拒绝请求。启用 `apiToken` 后，客户端必须携带：

```http
x-dsh-plugin-gate-token: <configured-token>
```

支持的状态修改操作包括插件注入、卸载和 ingest 请求。请求体限制为 64 KiB，并检查浏览器 Origin。

## 安全边界

本项目是高权限开发工具，不是沙箱。

即使通过 `trustedRoots` 明确允许，插件仍会在 Harness 宿主进程中运行。因此：

- 不要将不可信目录加入 `trustedRoots`。
- 不要直接注入未经审查的第三方插件。
- 不要对未审核代码开启构建脚本或发布能力。
- 不要把 API token 暴露给浏览器脚本、日志或模型上下文。

如果需要真正隔离不可信插件，应将插件迁移到独立 worker 或独立进程，并通过受限 capability 协议通信。

## 相关文档

- [安全加固计划](./SECURITY-HARDENING-PLAN.md)
- [本次调整记录](./ADJUSTMENT-RECORD.md)
- [规格索引](./.specs/index.md)
