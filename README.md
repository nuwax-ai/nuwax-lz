# nuwax-lz · 女娲灵珠播报

Claude Code / Codex 任务完成、需要授权时，推送到你的女娲灵珠设备语音播报，也可以主动让设备念一段话。

## 安装

安装命令都在女娲灵珠 App → 设备详情 →「Agent 接入」页生成（令牌已内置），按你的 CLI 选择对应命令。国内网络建议选择 Gitee 仓库。

### Claude Code

App 页复制命令，或手动执行：

```bash
# 第一步：添加 marketplace（二选一）
claude plugin marketplace add https://gitee.com/nuwax/nuwax-lz.git
claude plugin marketplace add https://github.com/nuwax-ai/nuwax-lz.git

# 第二步：安装插件
claude plugin install nuwax-lz@nuwax --config nuwax_lz_token=lz_你的令牌
```

装完即生效（令牌经 `--config` 写入本机 `~/.claude/settings.json`）。Windows 需先安装 Git for Windows（Claude Code 的 Bash 环境由它提供）。

### Codex

App 页复制对应平台的一键安装命令：

| 平台 | 方式 |
|---|---|
| macOS / Linux | `curl -fsSL <host>/install-codex.sh | bash -s -- <令牌> <host> [marketplace]` |
| Windows PowerShell | App 页 PowerShell 命令，无需 bash（需已安装 Git） |
| Windows Git Bash / WSL | 同 macOS/Linux 命令：Git Bash 装给 Windows 原生 Codex，WSL 装给 WSL 内的 Linux Codex |

安装脚本会：校验令牌 → 写入 `~/.codex/nuwax-lz-token` 与 `~/.codex/nuwax-lz-host` → 添加 marketplace 并安装 `nuwax-lz@nuwax` 插件（hooks + skill）。重启 Codex 生效，首次会提示审查新钩子，确认即可。默认 marketplace 为 Gitee，App 生成的命令会自动带上仓库地址。

## 播报场景

| 场景 | 设备播报 |
|---|---|
| Claude Code 任务完成 | "Claude 已完成 xx 项目的任务" |
| Claude Code 等待授权确认 | "Claude 在 xx 项目等你确认授权" |
| Claude Code 等待输入 | "Claude 在等你的下一步指令" |
| Codex 任务完成 | "Codex 已完成 xx 项目的任务" |
| Codex 需要你审批 | "Codex 需要你审批：执行命令 xxx" |
| 主动播报（两者通用） | 播报你指定的内容（≤100 字） |

## 主动播报

- 直接说：在 Claude Code / Codex 会话里说「播报 xxx」「念一下 xxx」「朗读 xxx」「让设备说 xxx」「通知到设备 xxx」
- Claude Code 斜杠命令：`/nuwax-lz:say 改完了，过来 review`
- Codex 显式调用：`$nuwax-lz-say 改完了，过来 review`
- 建议一句话说清，超过 100 字自动截断

## 令牌更新

- **Claude Code**：App 重置后复制新令牌，会话内运行 `/plugin configure nuwax-lz@nuwax` 粘贴新令牌
- **Codex**：App 页重新复制安装命令执行一次即可（幂等，刷新令牌与服务地址文件，插件无需重装）

## 卸载

- **Claude Code**：会话内 `/plugin uninstall nuwax-lz`；不再使用可顺带 `/plugin marketplace remove nuwax`
- **Codex**：App 页卸载命令（`curl -fsSL <host>/install-codex.sh | bash -s -- uninstall` 或 PowerShell 版），自动移除插件与令牌、服务地址文件

## 更新

- **Claude Code 插件**：`claude plugin update nuwax-lz@nuwax`，然后 `/reload-plugins`（或重启 Claude Code）。令牌保存在 `~/.claude/settings.json`，无需重新填写
- **Codex 插件**：`codex plugin update nuwax-lz@nuwax`；令牌 / 服务地址更新只需重跑 App 页安装命令
- 仅服务端调整（播报文案、频率限制等）时自动生效，无需任何操作

## 说明

- 同一任务 1 分钟窗口内不重复播报；每台设备每分钟最多 6 条
- 设备会议 / 监控中、语音播报关闭、设备离线时静默跳过，不影响 CLI 使用
- 令牌在 App「Agent 接入」页可随时重置，旧令牌立即失效

## 故障排查

安装后无播报：

1. Claude：`claude plugin list` 确认 nuwax-lz 已启用；令牌填错或已重置时 `/plugin configure nuwax-lz@nuwax` 更新后 `/reload-plugins`
2. Codex：`codex plugin list` 确认 nuwax-lz@nuwax 已启用，且 `~/.codex/nuwax-lz-token`、`~/.codex/nuwax-lz-host` 存在；令牌重置后重新执行 App 页安装命令
3. 设备须在线且 App 内语音播报开启
4. hook 请求失败不提示，可在会话里直接说「播报测试」验证连通性
