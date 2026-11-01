# TIP_FREEZE_748B_HEADLESS_SURFACE_002 — G16 tip /api/tool via .NET HttpClient
# AUTHORITY: TIP_FREEZE_001\bin SHA 748B… · REBUILD=0 · ABSORB NOT_AUTHORIZED · PROMOTE=0
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\TIP_FREEZE_748B_HEADLESS_SURFACE_002"
$Logs = Join-Path $OutDir "logs"
$Sandbox = Join-Path $OutDir "sandbox"
New-Item -ItemType Directory -Force -Path $Logs, $Sandbox | Out-Null
if (-not (Test-Path (Join-Path $Sandbox "seed.txt"))) {
  [System.IO.File]::WriteAllText((Join-Path $Sandbox "seed.txt"), "seed-748b-g16")
}
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectSha = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Port = 18983
$MotdPath = "G:\~dev\rawrxd\.cursor\rules\PassiveRoleNotRoleplay.mdc"
$Sha = (Get-FileHash $TipExe -Algorithm SHA256).Hash
$ShaMatch = [int]($Sha -eq $ExpectSha)
[System.IO.File]::WriteAllText((Join-Path $Logs "exe_sha.txt"), $Sha)
[System.IO.File]::WriteAllText((Join-Path $Logs "sha_match.txt"), "SHA_MATCH=$ShaMatch`r`nSHA=$Sha")
if ($ShaMatch -ne 1) { throw "TIP SHA mismatch" }

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

Add-Type -AssemblyName System.Net.Http
function Invoke-ApiTool {
  param([string]$Tag, [string]$Json, [hashtable]$Headers)
  $uri = "http://127.0.0.1:$Port/api/tool"
  $reqPath = Join-Path $Logs ("H_" + $Tag + ".req.json")
  [System.IO.File]::WriteAllText($reqPath, $Json, [System.Text.UTF8Encoding]::new($false))
  $code = -1
  $body = ""
  try {
    $handler = New-Object System.Net.Http.HttpClientHandler
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(45)
    $content = New-Object System.Net.Http.StringContent($Json, [System.Text.Encoding]::UTF8, "application/json")
    $req = New-Object System.Net.Http.HttpRequestMessage([System.Net.Http.HttpMethod]::Post, $uri)
    $req.Content = $content
    if ($Headers) {
      foreach ($k in $Headers.Keys) {
        [void]$req.Headers.TryAddWithoutValidation($k, [string]$Headers[$k])
      }
    }
    $resp = $client.SendAsync($req).Result
    $code = [int]$resp.StatusCode
    $body = $resp.Content.ReadAsStringAsync().Result
    $client.Dispose()
  } catch {
    $code = -1
    $body = $_.Exception.ToString()
    if ($_.Exception.InnerException) { $body = $_.Exception.InnerException.ToString() }
  }
  [System.IO.File]::WriteAllText((Join-Path $Logs ("H_" + $Tag + ".code.txt")), "$code")
  [System.IO.File]::WriteAllText((Join-Path $Logs ("H_" + $Tag + ".body.txt")), $body)
  [System.IO.File]::WriteAllText((Join-Path $Logs ("H_" + $Tag + ".txt")), "$Tag|$code|$body")
  return @{ code = $code; body = $body }
}

function Wait-Port([int]$Seconds = 90) {
  $deadline = (Get-Date).AddSeconds($Seconds)
  while ((Get-Date) -lt $deadline) {
    if (netstat -ano | Select-String ":$Port\s+.*LISTENING") { return $true }
    Start-Sleep -Milliseconds 400
  }
  return $false
}

function Json-Tool([string]$Tool, [hashtable]$ArgsMap) {
  $argsJson = ($ArgsMap | ConvertTo-Json -Compress -Depth 6)
  return "{`"tool`":`"$Tool`",`"args`":$argsJson}"
}

# --- Phase A: bare ---
Remove-Item Env:RAWRXD_HOSTED_API_KEY -ErrorAction SilentlyContinue
Remove-Item Env:RAWRXD_HOSTED_API_SCOPES -ErrorAction SilentlyContinue
Remove-Item Env:RAWRXD_IDE_EXEC_GRANT -ErrorAction SilentlyContinue
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$motdJson = Json-Tool "read_motd" @{ path = $MotdPath }

$pA = Start-Process -FilePath $TipExe -WorkingDirectory (Split-Path $TipExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir",$Sandbox) `
  -RedirectStandardOutput (Join-Path $Logs "h_srv_bare_out.txt") `
  -RedirectStandardError (Join-Path $Logs "h_srv_bare_err.txt") `
  -PassThru -WindowStyle Hidden
$readyA = Wait-Port
[System.IO.File]::WriteAllText((Join-Path $Logs "h_srv_bare_meta.txt"), "PHASE=bare PID=$($pA.Id) READY=$readyA EXITED=$($pA.HasExited)")
$bare = Invoke-ApiTool -Tag "bare_motd" -Json $motdJson -Headers @{}
if (-not $pA.HasExited) { Stop-Process -Id $pA.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep 2

# --- Phase B: auth ---
$key = "tip748b-g16h-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
Remove-Item Env:RAWRXD_IDE_EXEC_GRANT -ErrorAction SilentlyContinue

$pB = Start-Process -FilePath $TipExe -WorkingDirectory (Split-Path $TipExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir",$Sandbox) `
  -RedirectStandardOutput (Join-Path $Logs "h_srv_auth_out.txt") `
  -RedirectStandardError (Join-Path $Logs "h_srv_auth_err.txt") `
  -PassThru -WindowStyle Hidden
$readyB = Wait-Port
[System.IO.File]::WriteAllText((Join-Path $Logs "h_srv_auth_meta.txt"), "PHASE=auth PID=$($pB.Id) READY=$readyB EXITED=$($pB.HasExited) KEY_LEN=$($key.Length)")

$auth = @{ "X-Api-Key" = $key; "Origin" = "http://127.0.0.1:$Port" }
$evil = @{ "X-Api-Key" = $key; "Origin" = "https://evil.example" }
$nokey = @{ "Origin" = "http://127.0.0.1:$Port" }
$nullo = @{ "X-Api-Key" = $key; "Origin" = "null" }

$rEvil = Invoke-ApiTool -Tag "evil" -Json $motdJson -Headers $evil
$rNokey = Invoke-ApiTool -Tag "nokey_auth" -Json $motdJson -Headers $nokey
$rNull = Invoke-ApiTool -Tag "nullorig" -Json $motdJson -Headers $nullo
$rMotd = Invoke-ApiTool -Tag "motd" -Json $motdJson -Headers $auth
$rList = Invoke-ApiTool -Tag "list" -Json (Json-Tool "list_directory" @{ path = "." }) -Headers $auth
$rRead = Invoke-ApiTool -Tag "read_file" -Json (Json-Tool "read_file" @{ path = "seed.txt" }) -Headers $auth
$rWrite = Invoke-ApiTool -Tag "write_inside" -Json (Json-Tool "write_file" @{ path = "inside_ok.txt"; content = "ok748b" }) -Headers $auth
$rAbs = Invoke-ApiTool -Tag "deny_abs" -Json (Json-Tool "write_file" @{ path = "C:\Windows\Temp\rawrxd_deny_748b_g16h.txt"; content = "deny" }) -Headers $auth
$rDot = Invoke-ApiTool -Tag "deny_dotdot" -Json (Json-Tool "write_file" @{ path = "..\..\..\Windows\Temp\rawrxd_trav_748b_g16h.txt"; content = "deny" }) -Headers $auth
$rExecNo = Invoke-ApiTool -Tag "exec_nogrant" -Json (Json-Tool "execute_command" @{ command = "cmd /c echo exec_nogrant" }) -Headers $auth

$insideFs = Test-Path (Join-Path $Sandbox "inside_ok.txt")
$absFs = Test-Path "C:\Windows\Temp\rawrxd_deny_748b_g16h.txt"
$travFs = Test-Path "C:\Windows\Temp\rawrxd_trav_748b_g16h.txt"
if (-not $pB.HasExited) { Stop-Process -Id $pB.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep 2

# --- Phase C: grant ---
$env:RAWRXD_IDE_EXEC_GRANT = "1"
$pC = Start-Process -FilePath $TipExe -WorkingDirectory (Split-Path $TipExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir",$Sandbox) `
  -RedirectStandardOutput (Join-Path $Logs "h_srv_grant_out.txt") `
  -RedirectStandardError (Join-Path $Logs "h_srv_grant_err.txt") `
  -PassThru -WindowStyle Hidden
$readyC = Wait-Port
[System.IO.File]::WriteAllText((Join-Path $Logs "h_srv_grant_meta.txt"), "PHASE=grant PID=$($pC.Id) READY=$readyC EXITED=$($pC.HasExited)")
[void](Invoke-ApiTool -Tag "grant_motd" -Json $motdJson -Headers $auth)
$rExecYes = Invoke-ApiTool -Tag "exec_grant" -Json (Json-Tool "execute_command" @{ command = "cmd /c echo exec_ok_748b" }) -Headers $auth
if (-not $pC.HasExited) { Stop-Process -Id $pC.Id -Force -ErrorAction SilentlyContinue }

$g16_motd = [int]($rMotd.code -eq 200)
$g16_list = [int]($rList.code -eq 200)
$g16_evil = [int]($rEvil.code -eq 403)
$G16 = [int]($ShaMatch -eq 1 -and $g16_motd -eq 1 -and $g16_list -eq 1 -and $g16_evil -eq 1)
$execGrantPass = [int](($rExecYes.code -eq 200) -and ($rExecYes.body -match "exec_ok_748b|`"exitCode`":0"))

$tsv = @(
  "tag|http",
  "bare_motd|$($bare.code)",
  "evil|$($rEvil.code)",
  "nokey_auth|$($rNokey.code)",
  "nullorig|$($rNull.code)",
  "motd|$($rMotd.code)",
  "list|$($rList.code)",
  "read_file|$($rRead.code)",
  "write_inside|$($rWrite.code)",
  "deny_abs|$($rAbs.code)",
  "deny_dotdot|$($rDot.code)",
  "exec_nogrant|$($rExecNo.code)",
  "exec_grant|$($rExecYes.code)"
) -join "`r`n"
[System.IO.File]::WriteAllText((Join-Path $Logs "score_h.tsv"), $tsv)

$summary = @"
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('o'))
EVIDENCE=TIP_FREEZE_748B_HEADLESS_SURFACE_002
WORKSTREAM=TOP10_4_G16_HEADLESS_TOOL_SURFACE_TIP_748B
TIP_EXE=$TipExe
TIP_SHA=$Sha
SHA_MATCH=$ShaMatch
PORT=$Port
MOTD_PATH=$MotdPath
BIND=127.0.0.1
LOCAL_ONLY=1
G16_MOTD_200=$g16_motd
G16_LIST_200=$g16_list
G16_EVIL_403=$g16_evil
G16_MET=$G16
BARE_MOTD_HTTP=$($bare.code)
NOKEY_AUTH_HTTP=$($rNokey.code)
NULL_ORIG_HTTP=$($rNull.code)
READ_FILE_HTTP=$($rRead.code)
WRITE_INSIDE_HTTP=$($rWrite.code)
DENY_ABS_HTTP=$($rAbs.code)
DENY_DOTDOT_HTTP=$($rDot.code)
EXEC_NOGRANT_HTTP=$($rExecNo.code)
EXEC_GRANT_HTTP=$($rExecYes.code)
EXEC_GRANT_PASS=$execGrantPass
FS_INSIDE=$insideFs
FS_ABS_LEAK=$absFs
FS_TRAV_LEAK=$travFs
HEADLESS_EXECUTE_COMMAND_003=CITE_ONLY_NOT_TRANSFER
PRIOR_SURFACE_001_G16_MET=0
REBUILD_THIS_DISPATCH=0
ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
NO_INVENT_PASS=1
NO_BUILD_TREE_SUBSTITUTION=1
HARNESS=dotnet_httpclient
"@
[System.IO.File]::WriteAllText((Join-Path $OutDir "SUMMARY.txt"), $summary)
[System.IO.File]::WriteAllText((Join-Path $Logs "scoreboard.txt"), $summary)
Write-Output $summary
