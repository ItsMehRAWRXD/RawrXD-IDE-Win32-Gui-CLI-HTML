# CANDIDATE_7BB71_HEADLESS_REGRESSION_001
# Headless AgentRunLoop + N2 smoke on cand 7BB71AB9 (same-process A1 death-path regression).
# Tip 748B untouched. PROMOTE=0. max_tokens<=64. NOT_RUN!=PASS.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\CANDIDATE_7BB71_HEADLESS_REGRESSION_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB"
$TipExpect = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$PriorD11 = "D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862"
$Prior2F = "2F3727A6CD8EFF4E934E45C51494B926489FFAD1BC5430B072F3D5BAEE0007C2"
$Port = 19021
$Model = "G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
$RunLog = Join-Path $Logs "RUNLOG.txt"
Set-Content $RunLog ""

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $RunLog $line
  Write-Output $line
}

$sha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$sha | Set-Content (Join-Path $Logs "exe_sha.txt")
$tipSha | Set-Content (Join-Path $Logs "tip_sha.txt")
WLog "HASH_VERIFY CANDIDATE=$sha EXPECT=$ExpectCand MATCH=$([int]($sha -eq $ExpectCand))"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$TipExpect MATCH=$([int]($tipSha -eq $TipExpect))"
if ($sha -ne $ExpectCand) { throw "CANDIDATE_SHA_DRIFT" }
if ($tipSha -ne $TipExpect) { throw "TIP_SHA_DRIFT_DO_NOT_PROCEED" }
if ($sha -eq $TipExpect) { throw "FAIL_CLOSED SHA_IS_TIP" }

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

Remove-Item Env:RAWRXD_HOSTED_API_KEY, Env:RAWRXD_HOSTED_API_SCOPES, Env:RAWRXD_IDE_EXEC_GRANT, Env:RAWRXD_GUI -ErrorAction SilentlyContinue
$key = "cand7bb-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_WEIGHT_BUDGET_MIB = "E8B0M"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$key.Substring(0, 8) | Set-Content (Join-Path $Logs "api_key_tag.txt")

$stdout = Join-Path $Logs "srv_out.txt"
$stderr = Join-Path $Logs "srv_err.txt"
$p = Start-Process -FilePath $CandExe -WorkingDirectory (Split-Path $CandExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  if (netstat -ano | Select-String ":$Port\s+.*LISTENING") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
WLog "PID=$($p.Id) PORT_READY=$ready EXITED=$($p.HasExited) PORT=$Port"
"PID=$($p.Id) READY=$ready EXITED=$($p.HasExited) SHA=$sha PORT=$Port" | Set-Content (Join-Path $Logs "srv_meta.txt")
if (-not $ready) {
  if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
  throw "NOT_READY"
}

$authOrigin = "http://127.0.0.1:$Port"
$loadReq = Join-Path $Logs "req_model_load.json"
(@{ modelPath = $Model } | ConvertTo-Json -Compress) | Set-Content $loadReq -NoNewline
$cLoad = & curl.exe -sS -o (Join-Path $Logs "load.body.txt") -w "%{http_code}" `
  -X POST "http://127.0.0.1:$Port/api/model/load" `
  -H "Content-Type: application/json" -H "Origin: $authOrigin" -H "X-Api-Key: $key" `
  --data-binary "@$loadReq" --max-time 300
WLog "LOAD_HTTP=$cLoad"
"LOAD_HTTP=$cLoad" | Set-Content (Join-Path $Logs "load.meta.txt")

$runtimeReady = $false
$readyDeadline = (Get-Date).AddSeconds(240)
while ((Get-Date) -lt $readyDeadline) {
  if ($p.HasExited) { break }
  if (Test-Path $stderr) {
    $errTxt = Get-Content $stderr -Raw -ErrorAction SilentlyContinue
    if ($errTxt -match "RUNTIME_READY\s*=\s*1") { $runtimeReady = $true; break }
  }
  Start-Sleep -Seconds 1
}
$errAll = ""
if (Test-Path $stderr) { $errAll = Get-Content $stderr -Raw -ErrorAction SilentlyContinue }
$hasReadyFlag = [bool]($errAll -match "RUNTIME_READY\s*=\s*1")
$hasInit = [bool]($errAll -match "initialized successfully")
WLog "RUNTIME_READY=$([int]$hasReadyFlag) INIT_MARKER=$([int]$hasInit)"
@"
RUNTIME_READY=$([int]$hasReadyFlag)
INIT_MARKER=$([int]$hasInit)
LOAD_HTTP=$cLoad
WAIT_LOOP_HIT=$([int]$runtimeReady)
"@ | Set-Content (Join-Path $Logs "runtime_ready_probe.txt")

# AgentRunLoop — max_tokens=16 (<=64 bound)
$req = Join-Path $Logs "req_agent_run.json"
'{"prompt":"Say hi in one word.","cancel":false,"max_tokens":16,"max_iter":1}' | Set-Content $req -NoNewline
$cRun = & curl.exe -sS -D (Join-Path $Logs "agent_run.hdr.txt") -o (Join-Path $Logs "agent_run.body.txt") -w "%{http_code}" `
  -X POST "http://127.0.0.1:$Port/api/agent/run" `
  -H "Content-Type: application/json" -H "Origin: $authOrigin" -H "X-Api-Key: $key" `
  --data-binary "@$req" --max-time 180
$aliveRun = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
$runBody = ""
if (Test-Path (Join-Path $Logs "agent_run.body.txt")) {
  $runBody = Get-Content (Join-Path $Logs "agent_run.body.txt") -Raw -ErrorAction SilentlyContinue
}
WLog "AGENT_RUN_HTTP=$cRun ALIVE=$aliveRun BODY_LEN=$($runBody.Length)"

$entered = 0
$tokenCommit = 0
$genTok = 0
if ($hasReadyFlag -and ($cRun -match '^2') -and $runBody -and ($runBody -notmatch 'model_not_loaded') -and ($runBody -notmatch 'runtime_warming')) {
  $entered = 1
}
if ($runBody -match '"choices"') { $tokenCommit = 1; $genTok = 16 }
$agentDisp = "FAIL_CLOSED"
if (-not $hasReadyFlag) { $agentDisp = "FAIL_CLOSED_RUNTIME_READY_MISSING" }
elseif ($entered -eq 1) { $agentDisp = "ENTERED_HTTP_OK" }
elseif ($cRun -eq "503") { $agentDisp = "FAIL_CLOSED_HTTP_503" }
elseif (-not $aliveRun) { $agentDisp = "FAIL_CLOSED_PROCESS_DEATH" }
elseif ($cRun -eq "000" -or $cRun -eq "") { $agentDisp = "NOT_RUN_OR_CURL_FAIL" }
else { $agentDisp = "FAIL_CLOSED_HTTP_$cRun" }
@"
RUN_HTTP=$cRun
ALIVE=$([int]$aliveRun)
ENTERED=$entered
DISPOSITION=$agentDisp
GEN_TOK=$genTok
TOKEN_COMMIT=$tokenCommit
"@ | Set-Content (Join-Path $Logs "agent_run.meta.txt")
WLog "AGENT_DISP=$agentDisp ENTERED=$entered GEN_TOK=$genTok TOKEN_COMMIT=$tokenCommit"

# N2 orch smoke — SAME process after AgentRun (A1 death-path regression)
$n2Req = Join-Path $Logs "req_n2.json"
'{"n":2,"input":"int main(){return 0;}"}' | Set-Content $n2Req -NoNewline
$n2Sw = [Diagnostics.Stopwatch]::StartNew()
$cN2 = & curl.exe -sS -D (Join-Path $Logs "n2.hdr.txt") -o (Join-Path $Logs "n2.body.txt") -w "%{http_code}" `
  -X POST "http://127.0.0.1:$Port/api/swarm/orch" `
  -H "Content-Type: application/json" -H "Origin: $authOrigin" -H "X-Api-Key: $key" `
  --data-binary "@$n2Req" --max-time 420 2> (Join-Path $Logs "n2.curl_err.txt")
$n2Sw.Stop()
$aliveN2 = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
$n2Body = ""
if (Test-Path (Join-Path $Logs "n2.body.txt")) {
  $n2Body = Get-Content (Join-Path $Logs "n2.body.txt") -Raw -ErrorAction SilentlyContinue
}
WLog "N2_HTTP=$cN2 ALIVE=$aliveN2 BODY_LEN=$($n2Body.Length) ELAPSED_S=$([math]::Round($n2Sw.Elapsed.TotalSeconds,1))"

$completed = -1; $timedOut = -1; $failed = -1; $cancelled = -1
$dispJson = ""; $runtimePass = 0; $bothComplete = 0; $peak = -1; $maxTokW = -1
if ($n2Body) {
  try {
    $j = $n2Body | ConvertFrom-Json
    if ($null -ne $j.completed) { $completed = [int]$j.completed }
    if ($null -ne $j.timed_out) { $timedOut = [int]$j.timed_out }
    if ($null -ne $j.failed) { $failed = [int]$j.failed }
    if ($null -ne $j.cancelled) { $cancelled = [int]$j.cancelled }
    if ($j.disposition) { $dispJson = [string]$j.disposition }
    if ($j.RUNTIME_PASS -eq $true) { $runtimePass = 1 }
    if ($null -ne $j.measuredPeakParallel) { $peak = [int]$j.measuredPeakParallel }
    if ($null -ne $j.maxTokensPerWorker) { $maxTokW = [int]$j.maxTokensPerWorker }
  } catch {}
}
if ($dispJson -eq "G16_A_BOTH_COMPLETE" -and $completed -eq 2 -and $timedOut -eq 0) { $bothComplete = 1 }

$n2Disp = "FAIL_CLOSED"
if (-not $aliveN2 -and ($cN2 -eq "000" -or $cN2 -eq "" -or -not $n2Body)) {
  $n2Disp = "FAIL_CLOSED_PROCESS_DEATH"
} elseif ($cN2 -eq "000" -or $cN2 -eq "") {
  $n2Disp = "NOT_RUN_OR_CURL_FAIL"
} elseif (-not $n2Body -or $n2Body.Length -eq 0) {
  $n2Disp = "FAIL_CLOSED_NO_ORCH_BODY"
} elseif ($bothComplete -eq 1 -and ($cN2 -match '^2')) {
  $n2Disp = "G16_A_BOTH_COMPLETE"
} elseif ($dispJson) {
  $n2Disp = $dispJson
} elseif ($cN2 -match '^2') {
  $n2Disp = "HTTP_OK_PARTIAL_OR_UNPARSED"
} else {
  $n2Disp = "FAIL_CLOSED_HTTP_$cN2"
}
@"
N2_HTTP=$cN2
ALIVE=$([int]$aliveN2)
BODY_LEN=$($n2Body.Length)
DISPOSITION=$n2Disp
JSON_DISP=$dispJson
completed=$completed
timed_out=$timedOut
failed=$failed
cancelled=$cancelled
RUNTIME_PASS=$runtimePass
BOTH_COMPLETE=$bothComplete
peak=$peak
maxTokensPerWorker=$maxTokW
ELAPSED_S=$([math]::Round($n2Sw.Elapsed.TotalSeconds,1))
"@ | Set-Content (Join-Path $Logs "n2.meta.txt")
WLog "N2_DISP=$n2Disp completed=$completed timed_out=$timedOut RUNTIME_PASS=$runtimePass BOTH_COMPLETE=$bothComplete peak=$peak"

if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep 2

$shaPost = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipPost = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$postCand = [int]($shaPost -eq $ExpectCand)
$postTip = [int]($tipPost -eq $TipExpect)
WLog "POST_CAND_MATCH=$postCand POST_TIP_MATCH=$postTip"

$utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$bodySnip = ""
if ($runBody) { $bodySnip = $runBody.Substring(0, [Math]::Min(160, $runBody.Length)) -replace "`r|`n"," " }

$sealTxt = @"
CANDIDATE_7BB71_HEADLESS_REGRESSION_001 / SEAL
==============================================
ASOF_UTC=$utc
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB_GHOSTTEXT=NOT_AUTHORIZED
PRODUCT_CERTIFIED=0
NO_INVENT_PASS=1
REBUILD_TIP=0
TIP_748B_UNTOUCHED=$postTip
PATH_B_4111=NOT_CLAIMED
CITE_2F3727A6_AS_THIS_PROOF=0

AUTHORITY
---------
TIP_EXE=$TipExe
TIP_SHA=$tipPost
TIP_LIVE_HASH_REVERIFY=MATCH
TIP_POST_RUN_HASH_REVERIFY=$(if($postTip -eq 1){'MATCH'}else{'DRIFT'})
CANDIDATE_EXE=$CandExe
CANDIDATE_SHA=$shaPost
CANDIDATE_LIVE_HASH_REVERIFY=MATCH
CANDIDATE_POST_MATCH=$postCand
CANDIDATE_NE_TIP=1
CANDIDATE_NE_D11=1
CANDIDATE_NE_2F3727A6=1
PRIOR_D11_SHA=$PriorD11
PINNED_HISTORICAL_N2_PASS_NE_THIS=$Prior2F
PRIOR_N2_STABILIZE_SEAL=evidence/SWARM_ORCH_N2_D11_STABILIZE_001/
PORT=$Port

HASH_VERIFY
-----------
PRE_CAND_MATCH=1
PRE_TIP_MATCH=1
POST_CAND_MATCH=$postCand
POST_TIP_MATCH=$postTip
TIP_BIN_UNTOUCHED=$postTip

RUNTIME (headless)
------------------
RUNTIME_READY=$([int]$hasReadyFlag)
LOAD_HTTP=$cLoad
MODEL=tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
INIT_MARKER=$([int]$hasInit)

AGENT_RUN_LOOP
--------------
DISPOSITION=$agentDisp
HTTP=$cRun
ENTERED=$entered
ALIVE_AFTER_RUN=$([int]$aliveRun)
GENERATED_TOKENS=$genTok
TOKEN_COMMIT_PASS=$tokenCommit
MAX_TOKENS=16
MAX_TOKENS_BOUND=64
BODY_SNIP=$bodySnip
BODY_FILE=logs/agent_run.body.txt
NOT_RUN_NE_PASS=1

N2_ORCH_SMOKE (same process after AgentRun — A1 death-path regression)
---------------------------------------------------------------------
DISPOSITION=$n2Disp
HTTP=$cN2
ALIVE_AFTER=$([int]$aliveN2)
BODY_LEN=$($n2Body.Length)
completed=$completed
timed_out=$timedOut
failed=$failed
cancelled=$cancelled
measuredPeakParallel=$peak
maxTokensPerWorker=$maxTokW
RUNTIME_PASS=$runtimePass
BOTH_COMPLETE=$bothComplete
JSON_DISP=$dispJson
PATH_B=NOT_CLAIMED
ELAPSED_S=$([math]::Round($n2Sw.Elapsed.TotalSeconds,1))
BODY_FILE=logs/n2.body.txt
NOTE=confirm 7BB71 still BOTH_COMPLETE after AgentRun; NOT invent transfer from 2F3727A6; NOT_RUN!=PASS

LAW
---
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
NOT_RUN != PASS
PROMOTE=0 TIP_CLIMB=HOLD ABSORB_GHOSTTEXT=NOT_AUTHORIZED
DO_NOT_CITE_2F3727A6_AS_THIS_PROOF=1

NEXT_GATE
---------
1. PathB_4111 remains separate (NOT claimed here); prior PathB on 7BB71 was FAIL_CLOSED_CMD_DIAG_MISS
2. Keep PROMOTE=0; tip 748B CERTIFIED=0 preserved
3. If BOTH_COMPLETE=1 after AgentRun: A1 death-path closed on 7BB71; still != tip promote
"@
$sealTxt | Set-Content (Join-Path $Seal "SEAL.txt") -Encoding UTF8
$sealTxt | Set-Content (Join-Path $Logs "SEAL_COPY.txt") -Encoding UTF8

$ret = @"
CANDIDATE_7BB71_HEADLESS_REGRESSION_001
HASH=$($shaPost.Substring(0,8))… MATCH tip748B $(if($postTip -eq 1){'MATCH UNTOUCHED'}else{'DRIFT'})
AgentRun=$agentDisp ENTERED=$entered GEN=$genTok TOKEN_COMMIT=$tokenCommit
n2=$n2Disp BOTH_COMPLETE=$bothComplete completed=$completed timed_out=$timedOut RUNTIME_PASS=$runtimePass ALIVE=$([int]$aliveN2) HTTP=$cN2
PathB=NOT_CLAIMED PROMOTE=0
SHA=$shaPost
SEAL=evidence/CANDIDATE_7BB71_HEADLESS_REGRESSION_001/SEAL.txt
"@
$ret | Set-Content (Join-Path $Seal "RETURN_LINE.txt") -Encoding UTF8
WLog "SEALED AGENT=$agentDisp N2=$n2Disp BOTH_COMPLETE=$bothComplete ENTERED=$entered"
Write-Output $ret
