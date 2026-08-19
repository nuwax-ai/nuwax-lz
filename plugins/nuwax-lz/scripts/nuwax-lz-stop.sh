#!/usr/bin/env bash
# nuwax-lz: Codex 任务完成（Stop hook）→ 播报「Codex 已完成 xx 任务」
INPUT="$(cat 2>/dev/null)"
[ -n "$INPUT" ] || exit 0
TOKEN="$(cat "$HOME/.codex/nuwax-lz-token" 2>/dev/null | tr -d '[:space:]')"
[ -n "$TOKEN" ] || exit 0
if command -v jq >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | jq -c '{type:"agent-turn-complete",session_id:(.session_id // ""),cwd:(.cwd // "")}' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(json.dumps({"type":"agent-turn-complete","session_id":d.get("session_id") or "","cwd":d.get("cwd") or ""}))
except Exception:
    pass' 2>/dev/null)
else
  SID=$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  CWD=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  BODY="{\"type\":\"agent-turn-complete\",\"session_id\":\"$SID\",\"cwd\":\"$CWD\"}"
fi
[ -n "$BODY" ] || exit 0
HOST="$(cat "$HOME/.codex/nuwax-lz-host" 2>/dev/null | tr -d '[:space:]')"
[ -n "$HOST" ] || HOST="https://desk-buddy.nuwao.com"
curl -sL --max-time 3 -X POST "$HOST/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "$BODY" </dev/null >/dev/null 2>&1 &
exit 0
