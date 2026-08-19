#!/usr/bin/env bash
# nuwax-lz: Codex 需要审批（PermissionRequest hook）→ 播报固定文案；异步执行，不干预审批决策
INPUT="$(cat 2>/dev/null)"
[ -n "$INPUT" ] || exit 0
TOKEN="$(cat "$HOME/.codex/nuwax-lz-token" 2>/dev/null | tr -d '[:space:]')"
[ -n "$TOKEN" ] || exit 0
if command -v jq >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | jq -c '{type:"approval-requested",session_id:(.session_id // ""),cwd:(.cwd // "")}' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(json.dumps({"type":"approval-requested","session_id":d.get("session_id") or "","cwd":d.get("cwd") or ""}))
except Exception:
    pass' 2>/dev/null)
else
  SID=$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  CWD=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  BODY="{\"type\":\"approval-requested\",\"session_id\":\"$SID\",\"cwd\":\"$CWD\"}"
fi
[ -n "$BODY" ] || exit 0
HOST="$(cat "$HOME/.codex/nuwax-lz-host" 2>/dev/null | tr -d '[:space:]')"
[ -n "$HOST" ] || HOST="https://desk-buddy.nuwao.com"
curl -sL --max-time 5 -X POST "$HOST/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "$BODY" </dev/null >/dev/null 2>&1 &
exit 0
