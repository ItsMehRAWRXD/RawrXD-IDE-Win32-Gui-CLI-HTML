# AGENT_RUN_LOOP_TIP_004 — prove /api/agent/run on FROZEN 748B only
# PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 NO_INVENT_PASS=1 REBUILD=0
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\AGENT_RUN_LOOP_TIP_004"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$Expected = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Port = 18992
$Model = "G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
$Sha = (Get-FileHash $TipExe -Algorithm SHA256).Hash
$Sha | Set-Content (Join-Path $Logs "exe_sha.txt")
if ($Sha -ne $Expected) { throw "TIP_SHA_DRIFT actual=$Sha" }

Get-Process RawrXD-Win32IDE -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
Remove-Item Env:RAWRXD_HOSTED_API_KEY, Env:RAWRXD_HOSTED_API_SCOPES, Env:RAWRXD_IDE_EXEC_GRANT, Env:RAWRXD_GUI -ErrorAction SilentlyContinue
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_WEIGHT_BUDGET_MIB = "E8B0M"

$stdout = Join-Path $Logs "srv2_out.txt"
$stderr = Join-Path $Logs "srv2_err.txt"
$p = Start-Process -FilePath $TipExe -WorkingDirectory (Split-Path $TipExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  if (netstat -ano | Select-String ":$Port\s+.*LISTENING") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
"PID=$($p.Id) READY=$ready EXITED=$($p.HasExited) SHA=$Sha PORT=$Port" |
  Set-Content (Join-Path $Logs "srv_meta_headless.txt")
if (-not $ready) { throw "NOT_READY" }

$loadReq = Join-Path $Logs "req_model_load.json"
(@{ modelPath = $Model } | ConvertTo-Json -Compress) | Set-Content $loadReq -NoNewline
$cLoad = & curl.exe -sS -o (Join-Path $Logs "R2_load.body.txt") -w "%{http_code}" `
  -X POST "http://127.0.0.1:$Port/api/model/load" `
  -H "Content-Type: application/json" -H "Origin: http://127.0.0.1:$Port" `
  --data-binary "@$loadReq" --max-time 300
"LOAD_HTTP=$cLoad" | Set-Content (Join-Path $Logs "R2_load.meta.txt")

$req = Join-Path $Logs "req_agent_run.json"
'{"prompt":"hi","cancel":false,"max_tokens":16,"max_iter":1}' | Set-Content $req -NoNewline
$cRun = & curl.exe -sS -D (Join-Path $Logs "R2_run.hdr.txt") -o (Join-Path $Logs "R2_run.body.txt") -w "%{http_code}" `
  -X POST "http://127.0.0.1:$Port/api/agent/run" `
  -H "Content-Type: application/json" -H "Origin: http://127.0.0.1:$Port" `
  --data-binary "@$req" --max-time 180
$alive = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
"RUN_HTTP=$cRun ALIVE=$alive EXITED=$($p.HasExited)" | Set-Content (Join-Path $Logs "R2_run.meta.txt")
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
Write-Output "SHA=$Sha LOAD=$cLoad RUN=$cRun ALIVE=$alive"
