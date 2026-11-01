# SWARM_ORCH_N2_RESET_001 — relink build_win32ide_link001 → candidate freeze → n=2 prove
# PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED REBUILD_TIP=0 NEVER overwrite TIP_FREEZE_001\bin
$ErrorActionPreference = "Stop"
$Root = "G:\~dev\rawrxd"
$Build = Join-Path $Root "build_win32ide_link001"
$Cand = Join-Path $Root "evidence\TIP_CANDIDATE_AGENT_RUN_005"
$SealDir = Join-Path $Root "evidence\SWARM_ORCH_N2_RESET_001"
$Logs = Join-Path $SealDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$TipExpect = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$B421 = "B4212E46598F6490241A531C88C8D9A8DA37532B8C940A2C38BB35226C5D869F"
$Port = 18997
$Model = "G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"

# 1) compile TUs
cmd /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat`" -arch=amd64 >nul && cd /d `"$Build`" && ninja -j1 CMakeFiles/RawrXD-Win32IDE.dir/src/subagent_core.cpp.obj CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/HeadlessIDE_SwarmOrch.cpp.obj"
if ($LASTEXITCODE -ne 0) { throw "COMPILE_FAIL" }

# 2) link via ninja (prefer over missing rsp)
cmd /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat`" -arch=amd64 >nul && cd /d `"$Build`" && ninja -j1 bin/RawrXD-Win32IDE.exe"
$exe = Join-Path $Build "bin\RawrXD-Win32IDE.exe"
if (-not (Test-Path $exe)) { throw "EXE_MISSING_AFTER_LINK" }

$sha = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
"NEW_SHA=$sha" | Set-Content (Join-Path $Logs "link_sha.txt")
if ($sha -eq $TipExpect -or $sha -eq $B421) { throw "FAIL_CLOSED SHA_IS_TIP_OR_B421" }

# 3) freeze candidate only (never tip)
$candExe = Join-Path $Cand "bin\RawrXD-Win32IDE.exe"
Copy-Item -LiteralPath $exe -Destination $candExe -Force
Copy-Item -LiteralPath (Join-Path $Build "bin\RawrXD-Win32IDE.pdb") -Destination (Join-Path $Cand "bin\RawrXD-Win32IDE.pdb") -Force -ErrorAction SilentlyContinue
$sha | Set-Content (Join-Path $Cand "bin\CANDIDATE_SHA256.txt")
$sha | Set-Content (Join-Path $Cand "FROZEN_CANDIDATE_SHA.txt")

# 4) tip intact check
$tipSha = (Get-FileHash -LiteralPath (Join-Path $Root "evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe") -Algorithm SHA256).Hash
if ($tipSha -ne $TipExpect) { throw "TIP_SHA_DRIFT" }

# 5) prove n=2
Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
$key = "n2fix-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_WEIGHT_BUDGET_MIB = "E8B0M"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$out = Join-Path $Logs "srv_out.txt"
$err = Join-Path $Logs "srv_err.txt"
$p = Start-Process -FilePath $candExe -WorkingDirectory (Split-Path $candExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden
$ready = $false
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  if (netstat -ano | Select-String ":$Port\s+.*LISTENING") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
if (-not $ready) { throw "NOT_READY" }
$auth = "http://127.0.0.1:$Port"
(@{ modelPath = $Model } | ConvertTo-Json -Compress) | Set-Content (Join-Path $Logs "req_load.json") -NoNewline
$cLoad = & curl.exe -sS -o (Join-Path $Logs "load.body.txt") -w "%{http_code}" `
  -X POST "$auth/api/model/load" -H "Content-Type: application/json" -H "Origin: $auth" -H "X-Api-Key: $key" `
  --data-binary "@$(Join-Path $Logs 'req_load.json')" --max-time 300
Start-Sleep 3
'{"n":2,"input":"int main(){return 0;}"}' | Set-Content (Join-Path $Logs "req_n2.json") -NoNewline
$cN2 = & curl.exe -sS -o (Join-Path $Logs "n2.body.txt") -w "%{http_code}" `
  -X POST "$auth/api/swarm/orch" -H "Content-Type: application/json" -H "Origin: $auth" -H "X-Api-Key: $key" `
  --data-binary "@$(Join-Path $Logs 'req_n2.json')" --max-time 300
$alive = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
$body = Get-Content (Join-Path $Logs "n2.body.txt") -Raw -ErrorAction SilentlyContinue
$noModel = [int]($body -match "No model loaded")
$noEng = [int]($body -match "No Inference Engine")
@"
CANDIDATE_SHA=$sha
TIP_SHA=$tipSha
LOAD_HTTP=$cLoad
N2_HTTP=$cN2
ALIVE=$([int]$alive)
NO_MODEL_LOADED_STRING=$noModel
NO_INFERENCE_ENGINE_STRING=$noEng
WORKER_MODEL_LOADED=SEE_BODY
PROMOTE=0
"@ | Set-Content (Join-Path $Logs "prove_meta.txt")
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Write-Output "DONE N2_HTTP=$cN2 SHA=$sha"
