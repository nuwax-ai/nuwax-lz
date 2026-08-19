#!/usr/bin/env bash
# nuwax-lz: Codex 需要审批（PermissionRequest hook）→ 播报；异步执行，不干预审批决策
INPUT="$(cat 2>/dev/null)"
[ -n "$INPUT" ] || exit 0
TOKEN="$(cat "$HOME/.codex/nuwax-lz-token" 2>/dev/null | tr -d '[:space:]')"
[ -n "$TOKEN" ] || exit 0
if command -v jq >/dev/null 2>&1; then
  TEXT=$(printf '%s' "$INPUT" | jq -r '
    (.tool_input.command // .tool_input.shell // "") as $cmd |
    (($cmd | gsub("\\s+"; " ") | gsub("^\\s+|\\s+$"; ""))) as $norm |
    if $cmd != "" and $norm != "" then
      ($norm / " ") as $parts |
      if (["git","npm","npx","yarn","pnpm","cargo","go","python","python3","pip","pip3","docker","kubectl","brew","apt","apt-get","codex"] | index($parts[0])) != null and $parts[1] != null
      then "Codex 需要你审批：" + $parts[0] + " " + $parts[1]
      else "Codex 需要你审批：" + $parts[0]
      end
    elif .tool_name == "apply_patch" then "Codex 需要你审批：修改代码"
    else "Codex 需要你审批：" + (.tool_name // "执行操作")
    end' 2>/dev/null)
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
  CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  TEXT=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
KNOWN = {"git","npm","npx","yarn","pnpm","cargo","go","python","python3","pip","pip3","docker","kubectl","brew","apt","apt-get","codex"}
try:
    d = json.load(sys.stdin)
    ti = d.get("tool_input") or {}
    if not isinstance(ti, dict):
        ti = {}
    cmd = ti.get("command") or ti.get("shell") or ""
    if cmd:
        parts = cmd.split()
        prog = parts[0]
        if prog in KNOWN and len(parts) > 1:
            prog += " " + parts[1]
        text = "Codex 需要你审批：" + prog
    elif d.get("tool_name") == "apply_patch":
        text = "Codex 需要你审批：修改代码"
    else:
        text = "Codex 需要你审批：" + str(d.get("tool_name") or "执行操作")
    print(text)
except Exception:
    pass' 2>/dev/null)
  SID=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("session_id") or "")
except Exception:
    pass' 2>/dev/null)
  CWD=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("cwd") or "")
except Exception:
    pass' 2>/dev/null)
fi
[ -n "$TEXT" ] || exit 0
TEXT=$(printf '%s' "$TEXT" | tr -s ' ' | cut -c1-100)
if command -v jq >/dev/null 2>&1; then
  BODY=$(jq -n --arg t "$TEXT" --arg s "$SID" --arg c "$CWD" '{type:"approval-requested",session_id:$s,cwd:$c,text:$t}')
elif command -v python3 >/dev/null 2>&1; then
  BODY=$(python3 -c 'import json,sys;print(json.dumps({"type":"approval-requested","session_id":sys.argv[1],"cwd":sys.argv[2],"text":sys.argv[3]}))' "$SID" "$CWD" "$TEXT")
else
  ESCAPED=$(printf '%s' "$TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g')
  BODY="{\"type\":\"approval-requested\",\"session_id\":\"$SID\",\"cwd\":\"$CWD\",\"text\":\"$ESCAPED\"}"
fi
HOST="$(cat "$HOME/.codex/nuwax-lz-host" 2>/dev/null | tr -d '[:space:]')"
[ -n "$HOST" ] || HOST="https://desk-buddy.nuwao.com"
curl -sL --max-time 5 -X POST "$HOST/api/agent-cli/v1/hooks" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "$BODY" </dev/null >/dev/null 2>&1 &
exit 0
