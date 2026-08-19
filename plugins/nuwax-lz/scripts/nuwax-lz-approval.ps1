$ErrorActionPreference = 'SilentlyContinue'
$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
$tokenFile = Join-Path $env:USERPROFILE '.codex\nuwax-lz-token'
if (-not (Test-Path $tokenFile)) { exit 0 }
$token = (Get-Content -Raw -Encoding UTF8 $tokenFile).Trim()
if ([string]::IsNullOrEmpty($token)) { exit 0 }
try { $p = $raw | ConvertFrom-Json } catch { exit 0 }
$ti = $p.tool_input
$cmd = $null
if ($ti -is [System.Management.Automation.PSCustomObject]) {
  $cmd = [string]$ti.command
  if ([string]::IsNullOrEmpty($cmd)) { $cmd = [string]$ti.shell }
}
if (-not [string]::IsNullOrEmpty($cmd)) {
  $cmd = ($cmd -replace '\s+', ' ').Trim()
  if ($cmd.Length -gt 60) { $cmd = $cmd.Substring(0, 60) }
  $text = 'Codex 需要你审批：执行命令 ' + $cmd
} else {
  $toolName = [string]$p.tool_name
  if ([string]::IsNullOrWhiteSpace($toolName)) { $toolName = '执行操作' }
  if ($toolName -eq 'apply_patch') { $text = 'Codex 需要你审批：修改代码' }
  else { $text = 'Codex 需要你审批：' + $toolName }
}
$body = @{ type = 'approval-requested'; session_id = [string]$p.session_id; cwd = [string]$p.cwd; text = $text } | ConvertTo-Json -Compress
$hostUrl = 'https://desk-buddy.nuwao.com'
$hostFile = Join-Path $env:USERPROFILE '.codex\nuwax-lz-host'
if (Test-Path $hostFile) {
  $h = (Get-Content -Raw -Encoding UTF8 $hostFile).Trim()
  if ($h) { $hostUrl = $h }
}
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
try {
  $req = [System.Net.HttpWebRequest]::Create($hostUrl + '/api/agent-cli/v1/hooks')
  $req.Method = 'POST'
  $req.ContentType = 'application/json'
  $req.Headers['Authorization'] = 'Bearer ' + $token
  $req.Timeout = 5000
  $req.ReadWriteTimeout = 5000
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
  $req.ContentLength = $bytes.Length
  $stream = $req.GetRequestStream()
  $stream.Write($bytes, 0, $bytes.Length)
  $stream.Close()
  $resp = $req.GetResponse()
  $resp.Close()
} catch {}
exit 0
