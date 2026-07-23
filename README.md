# Codex Safe Check

[简体中文](#简体中文) | [English](#english)

## 简体中文

一个面向 Codex CLI 安装与网络问题的只读环境采集器。

下载稳定版本：
<https://github.com/yaoguai-xh/codex-safe-check/releases/tag/v1.0.1>

它只报告：

- 操作系统家族与架构；
- Codex CLI、Node.js、npm、Git、curl 和 Python 是否存在及版本行；
- 代理、自定义 CA、`CODEX_HOME` 是否设置，不读取值；
- Codex 官方安装地址与 OpenAI API 主机是否可达；
- 当前 Codex 版本是否提供 `codex doctor`。

它不会读取密码、API Key、令牌、Cookie、认证文件、完整配置、项目代码、日志、
用户名、主机名、工作目录或代理地址，也不会安装或修改系统软件。

### 运行

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\collect-diagnostics.ps1
```

macOS、Linux 或 WSL2：

```bash
bash collect-diagnostics.sh
```

脚本会在当前目录创建 `codex-safe-report.txt`。发送给任何人之前，必须先人工打开
并删除不想分享的内容。详细步骤见 [`开始这里.md`](开始这里.md)，隐私边界见
[`隐私与服务边界.md`](隐私与服务边界.md)。如果你想先判断问题类型，见
[`codex-cli-troubleshooting.md`](codex-cli-troubleshooting.md)。

### 适合排查的问题

- `codex` 命令不存在、版本异常或多个 Codex 客户端版本不一致；
- `codex login` 浏览器回跳失败、远程机器无法登录或需要 device auth；
- ChatGPT 登录、API Key 登录、工作区权限或本地凭据缓存混淆；
- 企业网络、自定义 CA、代理、网络沙箱或官方端点不可达；
- `CODEX_HOME`、安装目录、Node.js、npm、Git、curl 等基础环境问题。

### 免费脚本与付费服务

脚本永久免费且采用 MIT License。收费项目不是脚本下载，而是一份针对客户脱敏
报告的人工诊断、按顺序执行的修复步骤和一次补充判断。付费服务链接会在商品正式
发布后补充；在此之前，本仓库不通过私信收款，也不接收凭据。

## English

Codex Safe Check is a read-only environment collector for Codex CLI installation
and connectivity problems.

Stable release download:
<https://github.com/yaoguai-xh/codex-safe-check/releases/tag/v1.0.1>

It reports only the OS family and architecture, selected tool version lines,
whether proxy/CA/Codex-home overrides are present, reachability of two official
hosts, and whether `codex doctor` is available. It does not read secret values,
credentials, auth files, full configuration, source code, logs, usernames,
hostnames, working directories, or proxy addresses. It does not install or
modify system software.

Run on Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\collect-diagnostics.ps1
```

Run on macOS, Linux, or WSL2:

```bash
bash collect-diagnostics.sh
```

Review `codex-safe-report.txt` manually before sharing it. The collector is free
and MIT licensed. Any later paid offer is for human analysis and one follow-up,
not for access to this script and not a guaranteed fix.

For a symptom map before running the collector, see
[`codex-cli-troubleshooting.md`](codex-cli-troubleshooting.md).

## Security

Do not submit secrets in a public issue. If the collector ever emits a secret or
private path, stop sharing the report and open an issue that describes the field
type without including the value. Rotate any credential already disclosed.
