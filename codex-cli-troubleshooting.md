# Codex CLI Troubleshooting Map

This page helps you decide whether Codex Safe Check is relevant before you run
the collector. It is based on public OpenAI Codex documentation for CLI setup,
authentication, configuration, local state, custom CA bundles, and logs.

Official references:

- Codex CLI entry point: <https://learn.chatgpt.com/docs/codex/cli>
- Authentication: <https://learn.chatgpt.com/docs/auth>
- Environment variables: <https://learn.chatgpt.com/docs/config-file/environment-variables>
- Config and state locations: <https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations>
- Permissions and sandboxing: <https://learn.chatgpt.com/docs/permissions>

## Good Fits

Use the collector when you are stuck on one of these symptoms:

- `codex` is not found, or the version line is surprising.
- `codex login` opens a browser but the CLI never becomes authenticated.
- You are on SSH, a remote VM, WSL2, or a headless machine and browser login is
  awkward.
- API key login and ChatGPT login appear to be mixed up.
- A corporate proxy, custom CA, or TLS interception may be blocking login or
  requests.
- Network access works in the browser but not inside the Codex CLI session.
- You changed `CODEX_HOME`, install location, or shell startup files and Codex
  started behaving differently.
- You need a privacy-preserving summary before asking another person for help.

## Not a Good Fit

Do not use this collector as evidence for:

- account eligibility, billing disputes, workspace seat assignment, or regional
  availability;
- bypassing employer, school, platform, or network administrator restrictions;
- recovering deleted sessions, credentials, API keys, or private project files;
- proving that a model or product feature is available to a specific account.

## What the Collector Checks

The scripts report only:

- operating system family and CPU architecture;
- version lines for Codex CLI, Node.js, npm, Git, curl, and Python when present;
- whether proxy, custom CA, and `CODEX_HOME` settings are present, without
  printing their values;
- whether selected official hosts are reachable;
- whether the installed Codex command exposes `codex doctor`.

The scripts do not read secret values, `auth.json`, full `config.toml`, source
code, logs, usernames, hostnames, working directories, or proxy addresses.

## What to Send for Paid Diagnosis

Send only:

- your main symptom in one sentence;
- the full text of `codex-safe-report.txt` after manual review;
- one redacted error line if it is necessary.

Do not send passwords, one-time codes, API keys, access tokens, identity
documents, complete logs, screenshots containing account details, source code,
or full configuration files.

## 中文速览

这个采集器适合排查 Codex CLI 安装、登录、本地环境、企业网络、自定义 CA、代理和
基础连通性问题。它不解决账号资格、计费、地区、组织权限或受管设备策略问题。

发送报告前必须人工检查。不要发送密码、验证码、API Key、访问令牌、身份证件、
完整日志、源码、完整配置文件或含账号信息的截图。
