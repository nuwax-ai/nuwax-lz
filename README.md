# nuwax-lz · 女娲灵珠播报

Claude Code 任务完成 / 需要授权时，推送到你的女娲灵珠设备语音播报。

## 安装

1. 女娲灵珠 App → 设备详情 →「Agent 接入」页，复制安装命令（已内置设备令牌）
2. 终端中执行：

   ```
   claude plugin marketplace add https://github.com/nuwax-ai/nuwax-lz
   claude plugin install nuwax-lz@nuwax --config nuwax_lz_token=lz_你的令牌
   ```

装完即生效（令牌经 `--config` 写入本机 Keychain）。此后：

| 场景 | 设备播报 |
|---|---|
| 任务完成（Stop） | "Claude 已完成 xx 项目的任务" |
| 等待授权确认 | "Claude 在 xx 项目等你确认授权" |
| 等待输入 | "Claude 在等你的下一步指令" |
| 说「播报 / 念一下 / 让设备说 xxx」（Claude Code、Codex 通用） | 播报你指定的内容（≤100 字） |
| `/nuwax-lz:say 内容`（仅 Claude Code） | 同上，斜杠命令形式 |
| `$nuwax-lz-say`（仅 Codex） | 同上，显式调用形式 |

## Codex 用户

App「Agent 接入」页复制一键安装命令（内置令牌）：

```bash
curl -fsSL https://desk-buddy.nuwao.com/install-codex.sh | bash -s -- <lz_令牌> https://desk-buddy.nuwao.com
```

Codex 官方 notify 目前仅支持任务完成事件（无授权提醒）。

主动播报：安装后对 Codex 说「播报 xxx / 念一下 xxx」即可（skill 写入 `~/.agents/skills/nuwax-lz-say/`，支持 `$nuwax-lz-say` 显式调用与语义匹配；旧版 Codex 由 `~/.codex/AGENTS.md` 指引兜底，实际由 `~/.codex/nuwax-lz-say.sh` 发送）。

## 说明

- 同一任务 1 分钟窗口内不重复播报；每台设备每分钟最多 6 条
- 设备会议 / 监控中、语音播报关闭、设备离线时静默跳过，不影响 CLI 使用
- 令牌在 App「Agent 接入」页可随时重置，旧令牌立即失效
- 卸载：`/plugin uninstall nuwax-lz`；Codex 删除 `~/.codex/config.toml` 的 notify 行、`~/.codex/AGENTS.md` 的 nuwax-lz 块、`~/.agents/skills/nuwax-lz-say/`，以及 `~/.codex/nuwax-lz-notify.sh`、`~/.codex/nuwax-lz-say.sh`

## 更新

- **Claude Code 插件**：执行 `claude plugin update nuwax-lz@nuwax`，然后 `/reload-plugins`（或重启 Claude Code）使新 hooks 生效。令牌保存在你自己的 Keychain 中，更新后无需重新填写。
- **Codex 脚本**：从 App「Agent 接入」页重新复制一键安装命令再执行一次即可（幂等，会覆盖脚本并刷新 AGENTS.md 指引与 skill，不影响现有配置）。
- 仅服务端调整（播报文案、频率限制等）时无需任何操作，自动生效。

## 故障排查

安装后无播报：

1. `claude plugin list` 检查 nuwax-lz 已启用；令牌填错或已重置时，重新执行安装命令（`--config` 会覆盖更新），然后 `/reload-plugins`
2. 设备须在线且 App 内语音播报开启
3. hook 请求失败不提示，可在本会话直接执行 skill 中的 curl 命令验证连通性
