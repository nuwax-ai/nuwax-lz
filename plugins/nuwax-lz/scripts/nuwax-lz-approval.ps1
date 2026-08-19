$ErrorActionPreference = 'SilentlyContinue'
$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
$tokenFile = Join-Path $env:USERPROFILE '.codex\nuwax-lz-token'
if (-not (Test-Path $tokenFile)) { exit 0 }
$token = (Get-Content -Raw -Encoding UTF8 $tokenFile).Trim()
if ([string]::IsNullOrEmpty($token)) { exit 0 }
try { $p = $raw | ConvertFrom-Json } catch { exit 0 }
$body = @{ type = 'approval-requested'; session_id = [string]$p.session_id; cwd = [string]$p.cwd } | ConvertTo-Json -Compress
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
