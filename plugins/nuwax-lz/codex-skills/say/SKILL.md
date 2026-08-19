---
name: say
description: 把一段话通过女娲灵珠设备语音播报（主动播报）。当用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备"某段内容时使用。
---

用户要求"播报 / 念一下 / 朗读 / 让设备（灵珠）说 / 通知到设备"某段内容时：

1. 把内容压缩成一句话（不超过 100 字）
2. 执行播报（macOS/Linux 用 Bash，Windows 用 PowerShell）

macOS / Linux（Bash）：

```bash
"$HOME/.codex/nuwax-lz-say.sh" "要播报的文案"
```

Windows（PowerShell）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\nuuwax-lz-say.ps1" -Text '要播报的文案'
```

- 该命令静默成功（设备离线、播报关闭也视为成功）
- 若提示脚本不存在（no such file），请先重新执行 App「Agent 接入」页的安装命令
- 执行后回复用户：设备正在播报：<要播报的文案>（原样带上，让用户知道设备念的是什么）
- 仅在用户明确要求播报时使用，其余情况不要调用
