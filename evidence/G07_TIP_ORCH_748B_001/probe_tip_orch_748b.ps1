# G07_TIP_ORCH_748B_001 — tip 748B orch probe (headless PathA; GUI PathB cite-only if unsafe)
# AUTHORITY: TIP_FREEZE_001\bin ONLY. REBUILD=0. ABSORB=NOT_AUTHORIZED. PROMOTE=0.
# N2 PASS on 7BB71 ≠ tip G07. Do not invent PASS. Do not cite candidate as tip proof.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\G07_TIP_ORCH_748B_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectSha = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Port = 18971
$Model = "G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
$Log = Join-Path $OutDir "RUNLOG.txt"
Set-Content $Log ""

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}

$sha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$sha | Set-Content (Join-Path $Logs "tip_sha_pre.txt")
WLog "START G07_TIP_ORCH_748B_001 TIP_SHA=$sha MATCH=$([int]($sha -eq $ExpectSha))"
if ($sha -ne $ExpectSha) {
  @"
GATE=G07_TIP_ORCH_748B_001
DISPOSITION=FAIL_CLOSED
REASON=TIP_SHA_MISMATCH
TIP_SHA=$sha
EXPECTED=$ExpectSha
G07_MET=0
PROMOTE=0
ABSORB=NOT_AUTHORIZED
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
  exit 2
}

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"; Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$key = "g07-tip748b-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_WEIGHT_BUDGET_MIB = "E8B0M"
Remove-Item Env:RAWRXD_SWARM_SEQUENTIAL -ErrorAction SilentlyContinue

WLog "LAUNCH tip headless port=$Port"
$p = Start-Process -FilePath $TipExe -WorkingDirectory (Split-Path $TipExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput (Join-Path $Logs "srv_out.txt") `
  -RedirectStandardError (Join-Path $Logs "srv_err.txt") `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  if (netstat -ano | Select-String ":$Port\s+.*LISTENING") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
"PID=$($p.Id) READY=$ready EXITED=$($p.HasExited) PORT=$Port SHA=$sha" |
  Set-Content (Join-Path $Logs "srv_meta.txt")
WLog "READY=$ready PID=$($p.Id) EXITED=$($p.HasExited)"

$loadHttp = -1
$orchHttp = -1
$orchBody = ""
$orchBytes = 0
$aliveAfter = 0
$productJsonPass = 0
$productReached = 0
$completed = -1
$timedOut = -1
$failed = -1
$tokensSum = 0
$disp = "NOT_RUN"
$engineMissing = 0
$mergedPreview = ""

if ($ready) {
  if (Test-Path -LiteralPath $Model) {
    $loadReq = Join-Path $Logs "req_load.json"
    (@{ modelPath = $Model } | ConvertTo-Json -Compress) | Set-Content $loadReq -NoNewline
    WLog "POST /api/model/load"
    $loadHttp = [int](& curl.exe -sS -o (Join-Path $Logs "load.body.txt") -w "%{http_code}" `
      -X POST "http://127.0.0.1:$Port/api/model/load" `
      -H "Content-Type: application/json" -H "Origin: http://127.0.0.1:$Port" `
      -H "X-Api-Key: $key" --data-binary "@$loadReq" --max-time 300)
    WLog "LOAD_HTTP=$loadHttp"
  } else {
    WLog "MODEL_ABSENT path=$Model"
    "MODEL_ABSENT" | Set-Content (Join-Path $Logs "load.body.txt")
  }

  $req = Join-Path $Logs "req_n2.json"
  '{"n":2,"input":"int main(){ return 0; }\n","cleanup":true}' | Set-Content $req -NoNewline
  WLog "POST /api/swarm/orch n=2 (tip 748B)"
  $orchHttp = [int](& curl.exe -sS -o (Join-Path $Logs "orch_n2.body.json") -w "%{http_code}" `
    -X POST "http://127.0.0.1:$Port/api/swarm/orch" `
    -H "Content-Type: application/json" -H "Origin: http://127.0.0.1:$Port" `
    -H "X-Api-Key: $key" --data-binary "@$req" --max-time 180)
  if (Test-Path (Join-Path $Logs "orch_n2.body.json")) {
    $orchBody = Get-Content -Raw (Join-Path $Logs "orch_n2.body.json")
    $orchBytes = $orchBody.Length
  }
  $aliveAfter = [int][bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
  "$orchHttp" | Set-Content (Join-Path $Logs "orch_n2.code.txt")
  WLog "ORCH_HTTP=$orchHttp BYTES=$orchBytes ALIVE_AFTER=$aliveAfter"

  try {
    $j = $orchBody | ConvertFrom-Json
    if ($j.RUNTIME_PASS -eq $true) { $productJsonPass = 1 }
    if ($j.RUNTIME_REACHED -eq $true) { $productReached = 1 }
    if ($null -ne $j.completed) { $completed = [int]$j.completed }
    if ($null -ne $j.timed_out) { $timedOut = [int]$j.timed_out }
    if ($null -ne $j.failed) { $failed = [int]$j.failed }
    if ($j.disposition) { $disp = [string]$j.disposition }
    if ($j.mergedPreview) { $mergedPreview = [string]$j.mergedPreview }
    if ($mergedPreview -match "No Inference Engine") { $engineMissing = 1 }
    if ($j.workers) {
      foreach ($w in @($j.workers)) {
        if ($null -ne $w.tokensGenerated) { $tokensSum += [int]$w.tokensGenerated }
        if ([string]$w.resultPreview -match "No Inference Engine") { $engineMissing = 1 }
      }
    }
  } catch {
    $disp = "PARSE_FAIL_OR_EMPTY"
  }
} else {
  WLog "FAIL_CLOSED: tip headless port not ready"
  $disp = "NOT_READY"
}

if ($null -ne $p -and -not $p.HasExited) {
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$shaPost = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$shaPost | Set-Content (Join-Path $Logs "tip_sha_post.txt")
$tipUntouched = [int]($shaPost -eq $ExpectSha)

# Honest G07 tip disposition:
# Product JSON RUNTIME_PASS with No Inference Engine / tokens that are error stubs ≠ G07 MET.
# Candidate N2 PASS (7BB71) must not transfer.
$tokenSurvived = 0
if ($tokensSum -gt 0 -and $engineMissing -eq 0 -and $orchHttp -eq 200 -and $orchBytes -gt 0) {
  $tokenSurvived = 1
}
$g07Met = 0
$disposition = "NOT_OBSERVED"
$reason = "TIP_ORCH_NO_HONEST_ENSEMBLE_MET"

if (-not $ready) {
  $disposition = "FAIL_CLOSED"
  $reason = "HEADLESS_NOT_READY"
} elseif ($orchHttp -le 0 -or $orchBytes -eq 0) {
  $disposition = "FAIL_CLOSED"
  $reason = "ORCH_HTTP_OR_BODY_MISSING"
} elseif ($engineMissing -eq 1 -or $tokenSurvived -eq 0) {
  # Structural orch may have fired; ensemble inference on tip not observed as honest PASS
  $disposition = "NOT_OBSERVED"
  $reason = "TIP_ORCH_INFERENCE_ENGINE_OR_TOKEN_SURVIVED_ABSENT"
} elseif ($productJsonPass -eq 1 -and $tokenSurvived -eq 1) {
  # Still not invent G07 MET for n=2 only / without tip GUI PathB
  $disposition = "RUNTIME_PARTIAL"
  $reason = "TIP_HEADLESS_N2_STRUCTURAL_ONLY_NE_G07_MET_1_16"
  $g07Met = 0
}

@"
GATE=G07_TIP_ORCH_748B_001
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
AUTHORITY_EXE=$TipExe
TIP_SHA=$ExpectSha
TIP_LIVE_HASH_REVERIFY=$(if ($sha -eq $ExpectSha) {"MATCH"} else {"MISMATCH"})
TIP_POST_HASH_REVERIFY=$(if ($shaPost -eq $ExpectSha) {"MATCH"} else {"MISMATCH"})
TIP_BIN_UNTOUCHED=$tipUntouched
REBUILD_TIP=0
ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
NO_INVENT_PASS=1
CANDIDATE_7BB71_AS_TIP_PROOF=0
N2_HEADLESS_PASS_7BB71_NE_TIP_G07=1
PATH=HEADLESS_A
PORT=$Port
READY=$([int]$ready)
LOAD_HTTP=$loadHttp
ORCH_HTTP=$orchHttp
ORCH_BYTES=$orchBytes
ALIVE_AFTER=$aliveAfter
PRODUCT_JSON_RUNTIME_PASS=$productJsonPass
PRODUCT_JSON_RUNTIME_REACHED=$productReached
completed=$completed
timed_out=$timedOut
failed=$failed
tokensSum=$tokensSum
engineMissing=$engineMissing
TOKEN_SURVIVED=$tokenSurvived
product_disposition=$disp
G07_MET=$g07Met
DISPOSITION=$disposition
REASON=$reason
GUI_PATHB_THIS_PROBE=NOT_RERUN_UNSAFE
GUI_PATHB_PRIOR=FAIL_CLOSED_ORCH_NOT_OBSERVED cite SWARM_16_RUNTIME_004_PATH_B
"@ | Set-Content (Join-Path $Logs "probe_summary.txt")

WLog "DISPOSITION=$disposition G07_MET=$g07Met REASON=$reason TIP_UNTOUCHED=$tipUntouched"
Write-Output "DONE disposition=$disposition g07_met=$g07Met"
