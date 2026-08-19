---
name: say
description: 把一段话通过女娲灵珠设备语音播报（主动播报）。当用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备 xxx"等把内容发到设备时使用。
allowed-tools: Bash
---

把用户给的内容压缩成一句话（不超过 100 字），替换下方 TEXT 后用 Bash 执行：

```bash
TEXT="要播报的内容"
# 令牌解析（零外部依赖）：优先环境变量；否则从 settings.json 的 pluginConfigs 提取
#（令牌统一存这里，格式固定 lz_+40hex，正则提取无歧义）
TOKEN="${CLAUDE_PLUGIN_OPTION_NUWAX_LZ_TOKEN:-$(grep -oE 'lz_[0-9a-f]{40}' ~/.claude/settings.json 2>/dev/null | head -1)}"
[ -n "$TOKEN" ] || { echo "未找到令牌：请运行 /plugin configure nuwax-lz@nuwax 配置设备令牌后重试"; exit 1; }
# JSON payload 构造（不依赖 jq）：转义反斜杠和双引号，去掉换行
esc() { printf '%s' "$1" | tr '\n\r' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g'; }
curl -s --max-time 5 -X POST "https://desk-buddy.nuwao.com/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"hook_event_name\":\"Notification\",\"notification_type\":\"say\",\"session_id\":\"say-$(date +%s)\",\"cwd\":\"$(esc "$PWD")\",\"text\":\"$(esc "$TEXT")\"}"
```

说明：
- 令牌来自插件配置的 nuwax_lz_token，不要向用户询问令牌内容；skill 的 Bash 拿不到 `CLAUDE_PLUGIN_OPTION_*` 环境变量是正常的（它只注入 hook 子进程），上面的命令会从配置文件自己取
- 服务端会截断到 100 字；设备离线/播报关闭时静默成功，无需重试
- 返回 `accepted=true` 表示已受理；告知用户"设备正在播报"即可
- 若输出「未找到令牌」，引导用户运行 `/plugin configure nuwax-lz@nuwax` 配置后再试
- 若服务端返回 `UNAUTHORIZED`（令牌已在 App 里重置或失效），引导用户运行 `/plugin configure nuwax-lz@nuwax` 更新令牌后重试
