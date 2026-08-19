---
name: say
description: 把一段话通过女娲灵珠设备语音播报（主动播报）。当用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备 xxx"等把内容发到设备时使用。
allowed-tools: Bash
---

把用户给的内容压缩成一句话（不超过 100 字），替换下方 TEXT 后用 Bash 执行：

```bash
TEXT="要播报的内容"
curl -s --max-time 5 -X POST "https://desk-buddy.nuwao.com/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $CLAUDE_PLUGIN_OPTION_NUWAX_LZ_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TEXT" --arg s "say-$(date +%s)" --arg c "$PWD" \
    '{hook_event_name:"Notification", notification_type:"say", session_id:$s, cwd:$c, text:$t}')"
```

说明：
- 令牌来自插件配置的 nuwax_lz_token（环境变量 CLAUDE_PLUGIN_OPTION_NUWAX_LZ_TOKEN），不要向用户询问令牌内容
- 服务端会截断到 100 字；设备离线/播报关闭时静默成功，无需重试
- 返回 `accepted=true` 表示已受理；告知用户"设备正在播报"即可
