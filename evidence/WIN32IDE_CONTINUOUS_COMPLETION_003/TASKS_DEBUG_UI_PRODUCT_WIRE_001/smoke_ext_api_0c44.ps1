# Smoke ProductExtensionRuntime on NEW cand SHA after Sidebar wire.
# MATRIX_002_TRANSFER=0 PATHB_TRANSFER=0 N2_TRANSFER=0 PROMOTE=0 tip748B=1
$ErrorActionPreference = 'Continue'
$Seal = 'G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_003\TASKS_DEBUG_UI_PRODUCT_WIRE_001'
$Logs = Join-Path $Seal 'logs'
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe'
$TipExe = 'G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$ExpectNew = ((Get-Content (Join-Path $Seal 'NEW_CAND_SHA.txt') | Where-Object { $_ -match '^CAND_SHA_AFTER=' }) -replace 'CAND_SHA_AFTER=','').Trim()
$ExpectTip = '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'
$Port = 19160
$RunLog = Join-Path $Logs 'smoke_ext_api_RUNLOG.txt'
Set-Content $RunLog ''
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format 'o'), $m
  Add-Content $RunLog $line
  Write-Output $line
}

$sha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "CAND=$sha EXPECT_NEW=$ExpectNew MATCH=$([int]($sha -eq $ExpectNew))"
WLog "TIP=$tipSha tip748B=$([int]($tipSha -eq $ExpectTip))"
if ($sha -ne $ExpectNew) { throw "CAND_SHA_MISMATCH" }
if ($tipSha -ne $ExpectTip) { throw "TIP_DRIFT" }

Get-Process -Name 'RawrXD-Win32IDE','RawrXD-ExtensionHost' -ErrorAction SilentlyContinue |
  ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep 2

$key = 'sidebar-ext-' + [guid]::NewGuid().ToString('N').Substring(0, 10)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = 'read,inference,models,github,admin,*'
$env:RAWRXD_HEADLESS = '1'
$env:LOCAL_ONLY = '1'

$stdout = Join-Path $Logs 'smoke_out.txt'
$stderr = Join-Path $Logs 'smoke_err.txt'
$p = Start-Process -FilePath $CandExe -WorkingDirectory (Split-Path $CandExe) `
  -ArgumentList @('--headless','--local','--port',"$Port",'--bind','127.0.0.1','--dir','G:\~dev\rawrxd') `
  -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  $probe = & curl.exe -sS -o NUL -w '%{http_code}' "http://127.0.0.1:$Port/" --max-time 2 2>$null
  if ($probe -and $probe -ne '000') { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
WLog "HEADLESS_PID=$($p.Id) READY=$ready EXITED=$($p.HasExited)"

$authOrigin = "http://127.0.0.1:$Port"
function Hit([string]$method, [string]$path, [string]$bodyFile, [string]$outBase) {
  $hdr = Join-Path $Logs ($outBase + '.hdr.txt')
  $bodyOut = Join-Path $Logs ($outBase + '.body.txt')
  $curlArgs = [System.Collections.Generic.List[string]]::new()
  $curlArgs.AddRange([string[]]@('-sS','-D',$hdr,'-o',$bodyOut,'-w','%{http_code}','-X',$method,"$authOrigin$path",
    '-H',"Origin: $authOrigin",'-H',"X-Api-Key: $key",'--max-time','30'))
  if ($method -eq 'POST') {
    $curlArgs.Add('-H'); $curlArgs.Add('Content-Type: application/json')
    if ($bodyFile) { $curlArgs.Add('--data-binary'); $curlArgs.Add("@$bodyFile") }
    else { $curlArgs.Add('--data-binary'); $curlArgs.Add('{}') }
  }
  $code = & curl.exe @($curlArgs.ToArray())
  $body = ''
  if (Test-Path $bodyOut) { $body = Get-Content $bodyOut -Raw -ErrorAction SilentlyContinue }
  return @{ code = "$code"; body = "$body" }
}

$adapterOk = 0; $thin = 1; $enOk = 0; $actOk = 0; $scanCode = '000'
if ($ready) {
  $rScan = Hit 'GET' '/api/extensions/scan' $null 'smoke_scan'
  $scanCode = $rScan.code
  $adapterOk = [int]($rScan.body -match 'product_extension_runtime')
  $thin = [int]($rScan.body -match 'product_thin')
  WLog "SCAN_HTTP=$scanCode ADAPTER=$adapterOk THIN=$thin"
  $togBody = Join-Path $Logs 'req_enable.json'
  '{"id":"rawrxd.test.extension","enabled":true}' | Set-Content $togBody -NoNewline
  $rEn = Hit 'POST' '/api/extensions/enable' $togBody 'smoke_enable'
  $rDis = Hit 'POST' '/api/extensions/disable' $togBody 'smoke_disable'
  # Leave enabled=true — disable-last poisons EXT matrix ACTIVATION (extension_disabled).
  $rEn2 = Hit 'POST' '/api/extensions/enable' $togBody 'smoke_enable_restore'
  $enOk = [int](($rEn.body -match 'product_extension_runtime') -and ($rEn.code -match '^2') -and ($rEn2.code -match '^2'))
  WLog "ENABLE_HTTP=$($rEn.code) DISABLE_HTTP=$($rDis.code) ENABLE_RESTORE=$($rEn2.code) ENABLE_OK=$enOk"
  $actBody = Join-Path $Logs 'req_activate.json'
  '{"id":"rawrxd.test.extension"}' | Set-Content $actBody -NoNewline
  $rAct = Hit 'POST' '/api/extensions/activate' $actBody 'smoke_activate'
  $actOk = [int](($rAct.code -match '^2') -and ($rAct.body -match 'product_extension_runtime'))
  WLog "ACTIVATE_HTTP=$($rAct.code) ACTIVATE_OK=$actOk"
}

try { if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force } } catch {}
$pass = [int]($ready -and $adapterOk -eq 1 -and $thin -eq 0 -and $scanCode -match '^2')
@"
SMOKE_PASS=$pass
CAND_SHA=$sha
CAND_SHA_BEFORE=D41BB1DBAAFC7B6AC9135EEA848F757EB0E3474B479DABED832296F69DE19F98
tip748B=1
ADAPTER_PRODUCT_EXT=$adapterOk
PRODUCT_THIN=$thin
SCAN_HTTP=$scanCode
ENABLE_API_OK=$enOk
ACTIVATE_API_OK=$actOk
PROMOTE=0
ABSORB=NOT_AUTHORIZED
MATRIX_002_TRANSFER=0
PATHB_TRANSFER=0
N2_TRANSFER=0
SIDEBAR_WIRE=Activate/Enable/Disable->ProductExtensionRuntime
"@ | Set-Content (Join-Path $Seal 'SMOKE_RECEIPT.txt')
WLog "SMOKE_PASS=$pass"
exit (1 - $pass)


