# 本次调整记录

## 调整日期

2026-08-15

## 调整范围

本次调整仅针对新项目：

```text
/home/lenny/dev/tools/dsh-plugin-gate
```

原项目不在本次调整范围内。

## 调整内容

- 项目目录由 `dsh-super-injector-hardened` 重命名为 `dsh-plugin-gate`。
- npm 包名由 `@dsh-external/dsh-super-injector-hardened` 改为 `@xypure-x/dsh-plugin-gate`。
- 插件 ID、client bundle ID 和内部自重载匹配名统一为 `dsh-plugin-gate`。
- 仓库元数据统一指向 `xypure-x/dsh-plugin-gate`。
- API 路径统一为 `/plugin-gate/api`，认证 Header 统一为 `x-dsh-plugin-gate-token`。
- 运行时状态目录由 `~/.dsh/super-injector` 改为 `~/.dsh/plugin-gate`。
- 删除项目文档中的个人姓名和个人账号。
- 删除个人仓库地址及个人发布页地址。
- 将个人仓库引用替换为通用的 `<repository-url>` 或部署说明。
- 删除自检代码中的个人机器绝对路径。
- 将临时目录改为基于系统 `os.tmpdir()` 的随机目录。
- 删除 Windows 专用个人环境路径探测逻辑。
- 将示例路径统一为通用路径，例如 `/path/to/folder`。
- 修正新项目内部的包名、插件 ID 和 client bundle ID，使其统一为：

```text
@xypure-x/dsh-plugin-gate
```

## 未调整内容

- 未修改原项目源码、文档或配置。
- 未删除依赖锁文件中的第三方依赖元数据。
- 未改变插件的安全策略：动态 JavaScript、自动 ingest、默认构建脚本和发布能力仍保持关闭。

## 验证结果

已在新项目中通过：

```bash
DSH_CHECKOUT=/path/to/deepseek-harness npm run typecheck
npm run security:check
```

安全检查确认项目中不存在个人姓名、个人账号和个人机器路径。
