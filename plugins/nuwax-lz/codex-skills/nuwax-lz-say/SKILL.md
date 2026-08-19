---
name: nuwax-lz-say
description: 把一段话通过女娲灵珠设备语音播报（主动播报）。当用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备"某段内容时使用。
---

用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备"某段内容时：

1. 把内容压缩成一句话（不超过 100 字）
2. 执行播报（macOS/Linux 用 Bash，Windows 用 PowerShell）

macOS / Linux（Bash）：

```bash
TEXT="要播报的文案"
TOKEN="$(cat "$HOME/.codex/nuwax-lz-token" 2>/dev/null | tr -d '[:space:]')"
[ -n "$TOKEN" ] || { echo "未找到令牌：请重新执行 App「Agent 接入」页的安装命令"; exit 1; }
HOST="$(cat "$HOME/.codex/nuwax-lz-host" 2>/dev/null | tr -d '[:space:]')"
[ -n "$HOST" ] || HOST="https://desk-buddy.nuwao.com"
esc() { printf '%s' "$1" | tr '\n\r' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g'; }
curl -s --max-time 5 -X POST "$HOST/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "{\"hook_event_name\":\"Notification\",\"notification_type\":\"say\",\"session_id\":\"say-$(date +%s)\",\"cwd\":\"$(esc "$PWD")\",\"text\":\"$(esc "$TEXT")\"}"
```

Windows（PowerShell）：

```powershell
$TEXT = '要播报的文案'
$TOKEN = (Get-Content -Raw "$env:USERPROFILE\.codex\nuwax-lz-token" -ErrorAction SilentlyContinue).Trim()
if (-not $TOKEN) { Write-Host '未找到令牌：请重新执行 App「Agent 接入」页的安装命令'; exit 1 }
$HOST = 'https://desk-buddy.nuwao.com'
$hostFile = "$env:USERPROFILE\.codex\nuuwax-lz-host"
if (Test-Path $hostFile) {
  $h = (Get-Content -Raw $hostFile -ErrorAction SilentlyContinue).Trim()
  if ($h) { $HOST = $h }
}
$body = @{ hook_event_name = 'Notification'; notification_type = 'say'; session_id = ('say-' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()); cwd = (Get-Location).Path; text = $TEXT } | ConvertTo-Json
Invoke-RestMethod -Uri ($HOST + '/api/agent-cli/v1/hooks') -Method Post -Headers @{ Authorization = "Bearer $TOKEN" } -ContentType 'application/json' -Body $body | Out-Null
```

- 该命令静默成功（设备离线、播报关闭也视为成功）
- 执行后回复用户：设备正在播报：<要播报的文案>（原样带上，让用户知道设备念的是什么）
- 仅在用户明确要求播报时使用，其余情况不要调用
