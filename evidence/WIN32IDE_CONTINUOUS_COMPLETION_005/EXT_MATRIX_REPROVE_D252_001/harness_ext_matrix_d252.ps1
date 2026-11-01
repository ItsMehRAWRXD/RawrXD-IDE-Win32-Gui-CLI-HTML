# EXTENSION_RUNTIME_MATRIX_002 - candidate post-73368 repair. Tip 748B untouched.
# Cells: discovery | manifest_load | activation | commands | toggles | failure_isolation
# NOT_RUN != PASS. SOURCE_WIRE != PASS. No invent host_pid. PROMOTE=0.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_005\EXT_MATRIX_REPROVE_D252_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$HostExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-ExtensionHost.exe"
$ExpectCand = "D252A344B5D9ABECF402E2E927A18F2DB06909CE773B587F6B5AABD61BAD25E2"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$CandBeforeRepair = "73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738"
$FixtureDir = "G:\~dev\rawrxd\evidence\EXTENSION_RUNTIME_MATRIX_002\fixtures\extensions\rawrxd.test.extension"
$BadFixture = "G:\~dev\rawrxd\evidence\EXTENSION_RUNTIME_MATRIX_002\fixtures\extensions\rawrxd.bad.extension"
# Prefer empty read_motd (resolve under --dir) — absolute g:\~dev\.cursor is outside workspace.
$MotdPath = ""
$Port = 19155
$RunLog = Join-Path $Logs "RUNLOG.txt"
Set-Content $RunLog ""

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $RunLog $line
  Write-Output $line
}

function AdjudicateBody([string]$body, [string]$http) {
  $thin = [bool]($body -match 'product_thin')
  $okHttp = [bool]($http -match '^2')
  return @{ thin = $thin; okHttp = $okHttp }
}

$cs = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class ExtMtxD252 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  public static IntPtr FindMain(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      GetClassNameW(h, cls, 256);
      if (cls.ToString() == "RawrXD_IDE_MainWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static bool MenuReady(IntPtr main) { return GetPropW(main, "RawrXD.MainMenuReady") != IntPtr.Zero; }
  public static int PostId(IntPtr h, int id) { return PostMessageW(h, 0x0111, (IntPtr)id, IntPtr.Zero) ? 1 : 0; }
  public static int PingNull(IntPtr h, uint timeoutMs, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, timeoutMs, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
"@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$sha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$hostPresent = [int](Test-Path -LiteralPath $HostExe)
$hostSha = if ($hostPresent) { (Get-FileHash -LiteralPath $HostExe -Algorithm SHA256).Hash } else { "ABSENT" }
$sha | Set-Content (Join-Path $Logs "exe_sha.txt")
$tipSha | Set-Content (Join-Path $Logs "tip_sha.txt")
$hostSha | Set-Content (Join-Path $Logs "host_sha.txt")
WLog "HASH_VERIFY CAND=$sha EXPECT=$ExpectCand MATCH=$([int]($sha -eq $ExpectCand))"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$([int]($tipSha -eq $ExpectTip))"
WLog "HOST_PRESENT=$hostPresent HOST_SHA=$hostSha CAND_BEFORE_REPAIR=$CandBeforeRepair"
if ($sha -ne $ExpectCand) { throw "CANDIDATE_SHA_DRIFT" }
if ($tipSha -ne $ExpectTip) { throw "TIP_SHA_DRIFT_DO_NOT_PROCEED" }
if ($sha -eq $ExpectTip) { throw "FAIL_CLOSED SHA_IS_TIP" }

Get-Process -Name "RawrXD-Win32IDE","RawrXD-ExtensionHost" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR name=$($_.Name) pid=$($_.Id)"
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

Remove-Item Env:RAWRXD_HOSTED_API_KEY, Env:RAWRXD_HOSTED_API_SCOPES, Env:RAWRXD_IDE_EXEC_GRANT, Env:RAWRXD_GUI -ErrorAction SilentlyContinue
$key = "ExtMtxD252-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$key.Substring(0, 8) | Set-Content (Join-Path $Logs "api_key_tag.txt")

$stdout = Join-Path $Logs "headless_out.txt"
$stderr = Join-Path $Logs "headless_err.txt"
$p = Start-Process -FilePath $CandExe -WorkingDirectory (Split-Path $CandExe) `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if ($conn) { $ready = $true; break }
  $probe = & curl.exe -sS -o NUL -w "%{http_code}" "http://127.0.0.1:$Port/" --max-time 2 2>$null
  if ($probe -and $probe -ne "000") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
WLog "HEADLESS_PID=$($p.Id) PORT_READY=$ready EXITED=$($p.HasExited) PORT=$Port"
"PID=$($p.Id) READY=$ready EXITED=$($p.HasExited) SHA=$sha PORT=$Port" | Set-Content (Join-Path $Logs "headless_meta.txt")

$cells = [ordered]@{}
$authOrigin = "http://127.0.0.1:$Port"
$cmdHeadless = "BLOCKED"
$hostPidReal = $false
$firstFail = "NONE"

function Hit([string]$method, [string]$path, [string]$bodyFile, [string]$outBase) {
  $hdr = Join-Path $Logs ($outBase + ".hdr.txt")
  $bodyOut = Join-Path $Logs ($outBase + ".body.txt")
  $curlArgs = [System.Collections.Generic.List[string]]::new()
  $curlArgs.AddRange([string[]]@("-sS","-D",$hdr,"-o",$bodyOut,"-w","%{http_code}","-X",$method,"$authOrigin$path",
    "-H","Origin: $authOrigin","-H","X-Api-Key: $key","--max-time","30"))
  if ($method -eq "POST" -or $method -eq "PUT") {
    $curlArgs.Add("-H"); $curlArgs.Add("Content-Type: application/json")
    if ($bodyFile) { $curlArgs.Add("--data-binary"); $curlArgs.Add("@$bodyFile") }
    else { $curlArgs.Add("--data-binary"); $curlArgs.Add("{}") }
  }
  $code = & curl.exe @($curlArgs.ToArray())
  $body = ""
  if (Test-Path $bodyOut) { $body = Get-Content $bodyOut -Raw -ErrorAction SilentlyContinue }
  return @{ code = "$code"; body = "$body" }
}

if (-not $ready) {
  WLog "HEADLESS_NOT_READY - cells that need HTTP = BLOCKED"
  $firstFail = "HEADLESS_PORT_NOT_READY"
  foreach ($c in @("DISCOVERY","MANIFEST_LOAD","ACTIVATION","COMMANDS","TOGGLES","FAILURE_ISOLATION")) {
    $cells[$c] = "BLOCKED"
  }
  @(
    "BLOCK_REASON=HEADLESS_PORT_NOT_READY",
    "MISSING_DEPENDENCY=headless LocalServer listen on port $Port for EXE_SHA=$sha"
  ) | Set-Content (Join-Path $Logs "blocked_reason.txt")
} else {
  $rScan = Hit "GET" "/api/extensions/scan" $null "cell_discovery_scan"
  $rList = Hit "GET" "/api/extensions/list" $null "cell_discovery_list"
  $rInst = Hit "GET" "/api/extensions/installed" $null "cell_discovery_installed"
  $adj = AdjudicateBody $rScan.body $rScan.code
  $realAdapter = [bool]($rScan.body -match 'product_extension_runtime')
  if (($adj.okHttp) -and (-not $adj.thin) -and $realAdapter -and ($rScan.body -match '"total"\s*:\s*[1-9]')) {
    $cells["DISCOVERY"] = "PASS"
  } else {
    $cells["DISCOVERY"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "DISCOVERY" }
  }
  WLog "DISCOVERY scan=$($rScan.code) thin=$([int]$adj.thin) real=$([int]$realAdapter) => $($cells['DISCOVERY'])"
  @(
    "SCAN_HTTP=$($rScan.code)",
    "LIST_HTTP=$($rList.code)",
    "INSTALLED_HTTP=$($rInst.code)",
    "PRODUCT_THIN=$([int]$adj.thin)",
    "REAL_ADAPTER=$([int]$realAdapter)",
    "DISPOSITION=$($cells['DISCOVERY'])"
  ) | Set-Content (Join-Path $Logs "cell_discovery.meta.txt")

  $goodBody = Join-Path $Logs "req_load_good.json"
  $badBody = Join-Path $Logs "req_load_bad.json"
  $missBody = Join-Path $Logs "req_load_missing.json"
  ("{`"path`":`"" + ($FixtureDir -replace '\\','\\') + "`"}") | Set-Content $goodBody -NoNewline
  ("{`"path`":`"" + ($BadFixture -replace '\\','\\') + "`"}") | Set-Content $badBody -NoNewline
  '{"path":"G:\\~dev\\rawrxd\\evidence\\EXTENSION_RUNTIME_MATRIX_002\\fixtures\\missing.vsix"}' | Set-Content $missBody -NoNewline
  $rGood = Hit "POST" "/api/extensions/load-vsix" $goodBody "cell_manifest_load_good"
  $rBad = Hit "POST" "/api/extensions/load-vsix" $badBody "cell_manifest_load_bad"
  $rMiss = Hit "POST" "/api/extensions/load-vsix" $missBody "cell_manifest_load_missing"
  $adjM = AdjudicateBody $rGood.body $rGood.code
  $goodOk = [bool](($adjM.okHttp) -and (-not $adjM.thin) -and ($rGood.body -match '"success"\s*:\s*true') -and ($rGood.body -match '"manifest"'))
  $badClosed = [bool](($rBad.body -match '"success"\s*:\s*false') -and ($rBad.body -notmatch 'product_thin'))
  $missClosed = [bool](($rMiss.body -match '"success"\s*:\s*false') -and ($rMiss.body -notmatch 'product_thin'))
  $aliveAfterBad = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
  if ($goodOk -and $badClosed -and $missClosed -and $aliveAfterBad) { $cells["MANIFEST_LOAD"] = "PASS" }
  else {
    $cells["MANIFEST_LOAD"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "MANIFEST_LOAD" }
  }
  WLog "MANIFEST_LOAD good=$($rGood.code) badClosed=$([int]$badClosed) missClosed=$([int]$missClosed) alive=$([int]$aliveAfterBad) => $($cells['MANIFEST_LOAD'])"
  @(
    "GOOD_HTTP=$($rGood.code)",
    "BAD_HTTP=$($rBad.code)",
    "MISS_HTTP=$($rMiss.code)",
    "GOOD_OK=$([int]$goodOk)",
    "BAD_FAIL_CLOSED=$([int]$badClosed)",
    "MISS_FAIL_CLOSED=$([int]$missClosed)",
    "IDE_ALIVE_AFTER_BAD=$([int]$aliveAfterBad)",
    "DISPOSITION=$($cells['MANIFEST_LOAD'])"
  ) | Set-Content (Join-Path $Logs "cell_manifest_load.meta.txt")

  $actBody = Join-Path $Logs "req_activate.json"
  '{"id":"rawrxd.test.extension"}' | Set-Content $actBody -NoNewline
  $rAct = Hit "POST" "/api/extensions/activate" $actBody "cell_activation"
  $rHost = Hit "GET" "/api/extensions/host/status" $null "cell_activation_host"
  $adjA = AdjudicateBody $rAct.body $rAct.code
  $hostPidReal = [bool]($rHost.body -match '"host_pid"\s*:\s*[1-9]')
  $actOk = [bool](($rAct.body -match '"success"\s*:\s*true') -and ($rAct.body -match 'product_extension_runtime') -and (-not $adjA.thin))
  if ($adjA.okHttp -and $actOk -and $hostPidReal) { $cells["ACTIVATION"] = "PASS" }
  else {
    $cells["ACTIVATION"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "ACTIVATION" }
  }
  WLog "ACTIVATION act=$($rAct.code) hostPidReal=$([int]$hostPidReal) => $($cells['ACTIVATION'])"
  @(
    "ACTIVATE_HTTP=$($rAct.code)",
    "HOST_STATUS_HTTP=$($rHost.code)",
    "HOST_PID_REAL=$([int]$hostPidReal)",
    "PRODUCT_THIN=$([int]$adjA.thin)",
    "DISPOSITION=$($cells['ACTIVATION'])"
  ) | Set-Content (Join-Path $Logs "cell_activation.meta.txt")

  $togBody = Join-Path $Logs "req_toggle.json"
  '{"id":"rawrxd.test.extension","enabled":true}' | Set-Content $togBody -NoNewline
  $rEn = Hit "POST" "/api/extensions/enable" $togBody "cell_toggles_enable"
  $rDis = Hit "POST" "/api/extensions/disable" $togBody "cell_toggles_disable"
  $rEn2 = Hit "POST" "/api/extensions/enable" $togBody "cell_toggles_enable2"
  $adjT = AdjudicateBody $rEn.body $rEn.code
  if ($adjT.okHttp -and (-not $adjT.thin) -and ($rEn.body -match '"persisted"\s*:\s*true') -and ($rEn.body -match 'product_extension_runtime')) {
    $cells["TOGGLES"] = "PASS"
  } else {
    $cells["TOGGLES"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "TOGGLES" }
  }
  WLog "TOGGLES enable=$($rEn.code) => $($cells['TOGGLES'])"
  @(
    "ENABLE_HTTP=$($rEn.code)",
    "DISABLE_HTTP=$($rDis.code)",
    "ENABLE2_HTTP=$($rEn2.code)",
    "PRODUCT_THIN=$([int]$adjT.thin)",
    "DISPOSITION=$($cells['TOGGLES'])"
  ) | Set-Content (Join-Path $Logs "cell_toggles.meta.txt")

  $motdReq = Join-Path $Logs "req_motd.json"
  '{"tool":"read_motd","args":{}}' | Set-Content $motdReq -NoNewline
  $rMotd = Hit "POST" "/api/tool" $motdReq "cell_commands_motd"
  WLog "MOTD_TOOL http=$($rMotd.code)"

  $cmdProbe = Join-Path $Logs "req_tool_ext.json"
  '{"tool":"extension.activate","name":"extension.activate","args":{"id":"rawrxd.test.extension"}}' | Set-Content $cmdProbe -NoNewline
  $rTool = Hit "POST" "/api/tool" $cmdProbe "cell_commands_tool"
  $rCmd = Hit "POST" "/api/command" $cmdProbe "cell_commands_command"
  $toolBody = $rTool.body
  $hasExtTool = [bool](($toolBody -match 'extension') -and ($toolBody -match 'product_extension_runtime|success') -and ($toolBody -notmatch 'unknown_tool|not found|unsupported') -and ($rTool.code -match '^2') -and ($toolBody -notmatch 'product_thin'))
  if ($hasExtTool) { $cmdHeadless = "PASS" }
  elseif ($rTool.code -match '^2' -or $rCmd.code -match '^2') { $cmdHeadless = "FAIL" }
  else { $cmdHeadless = "BLOCKED" }
  WLog "COMMANDS_HEADLESS tool=$($rTool.code) hasExtTool=$([int]$hasExtTool) provisional=$cmdHeadless"
  @(
    "MOTD_HTTP=$($rMotd.code)",
    "TOOL_HTTP=$($rTool.code)",
    "COMMAND_HTTP=$($rCmd.code)",
    "HAS_EXT_TOOL=$([int]$hasExtTool)",
    "PROVISIONAL=$cmdHeadless"
  ) | Set-Content (Join-Path $Logs "cell_commands_headless.meta.txt")

  $rKill = Hit "POST" "/api/extensions/host/kill" $null "cell_failiso_kill"
  Start-Sleep -Milliseconds 300
  $rBadAct = Hit "POST" "/api/extensions/activate" $actBody "cell_failiso_bad_act"
  Start-Sleep -Milliseconds 500
  $aliveHttp = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
  $rPing = Hit "GET" "/api/extensions/host/status" $null "cell_failiso_ping"
  $pingOk = [bool]($rPing.code -match '^2')
  # Lifecycle cleanup + failure isolation: IDE survives kill/reactivate; host_pid real at least once.
  if ($aliveHttp -and $pingOk -and $hostPidReal -and ($rKill.body -match 'product_extension_runtime')) {
    $cells["FAILURE_ISOLATION"] = "PASS"
  } elseif ($aliveHttp -and $pingOk -and -not $hostPidReal) {
    $cells["FAILURE_ISOLATION"] = "BLOCKED"
    if ($firstFail -eq "NONE") { $firstFail = "FAILURE_ISOLATION_BLOCKED_NO_HOST_PID" }
  } else {
    $cells["FAILURE_ISOLATION"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "FAILURE_ISOLATION" }
  }
  WLog "FAILURE_ISOLATION alive=$([int]$aliveHttp) ping=$($rPing.code) hostPidReal=$([int]$hostPidReal) => $($cells['FAILURE_ISOLATION'])"
  @(
    "KILL_HTTP=$($rKill.code)",
    "BAD_ACT_HTTP=$($rBadAct.code)",
    "ALIVE=$([int]$aliveHttp)",
    "PING_HTTP=$($rPing.code)",
    "HOST_PID_REAL=$([int]$hostPidReal)",
    "DISPOSITION=$($cells['FAILURE_ISOLATION'])"
  ) | Set-Content (Join-Path $Logs "cell_failure_isolation.meta.txt")

  if (-not $p.HasExited) {
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
  }
  Get-Process -Name "RawrXD-ExtensionHost" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  WLog "HEADLESS_STOPPED"

  # COMMANDS: prefer headless real tool dispatch; GUI IDM fiction is not invent-PASS.
  $cells["COMMANDS"] = $cmdHeadless
  if ($cells["COMMANDS"] -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "COMMANDS" }
  @(
    "HEADLESS_PROVISIONAL=$cmdHeadless",
    "DISPOSITION=$($cells['COMMANDS'])",
    "NOTE=COMMANDS adjudicated on /api/tool extension.activate after MOTD (not GUI IDM invent)"
  ) | Set-Content (Join-Path $Logs "cell_commands.meta.txt")
}

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipOk = [int]($tipAfter -eq $ExpectTip)
$candOk = [int]($candAfter -eq $ExpectCand)
WLog "POST_HASH tip748B=$tipOk candMatch=$candOk"

$passN = 0; $failN = 0; $nrN = 0; $blkN = 0
foreach ($k in @("DISCOVERY","MANIFEST_LOAD","ACTIVATION","COMMANDS","TOGGLES","FAILURE_ISOLATION")) {
  if (-not $cells.Contains($k)) { $cells[$k] = "NOT_RUN" }
  switch ($cells[$k]) {
    "PASS" { $passN++ }
    "FAIL" { $failN++ }
    "NOT_RUN" { $nrN++ }
    "BLOCKED" { $blkN++ }
  }
}

$extRuntime = "NOT_RUN"
if ($passN -eq 6) { $extRuntime = "PASS" }
elseif ($passN -gt 0 -and ($failN + $blkN + $nrN) -gt 0) { $extRuntime = "PARTIAL_FAIL_CLOSED" }
elseif ($failN -gt 0 -and $passN -eq 0) { $extRuntime = "FAIL" }
elseif ($blkN -gt 0 -and $passN -eq 0 -and $failN -eq 0) { $extRuntime = "BLOCKED" }
elseif ($nrN -eq 6) { $extRuntime = "NOT_RUN" }
else { $extRuntime = "FAIL_CLOSED" }

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
@(
  "GATE=EXTENSION_RUNTIME_MATRIX_002",
  "ASOF_UTC=$asof",
  "EXE_SHA=$sha",
  "CAND_SHA_BEFORE_REPAIR=$CandBeforeRepair",
  "TIP_SHA=$tipAfter",
  "tip748B=$tipOk",
  "HOST_SHA=$hostSha",
  "TIP_REBUILD=0",
  "ABSORB=NOT_AUTHORIZED",
  "PROMOTE=0",
  "CERTIFIED=0",
  "FIRST_FAILURE_BOUNDARY=$firstFail",
  "DISCOVERY=$($cells['DISCOVERY'])",
  "MANIFEST_LOAD=$($cells['MANIFEST_LOAD'])",
  "ACTIVATION=$($cells['ACTIVATION'])",
  "COMMANDS=$($cells['COMMANDS'])",
  "TOGGLES=$($cells['TOGGLES'])",
  "FAILURE_ISOLATION=$($cells['FAILURE_ISOLATION'])",
  "PASS=$passN",
  "FAIL=$failN",
  "NOT_RUN=$nrN",
  "BLOCKED=$blkN",
  "EXTENSION_RUNTIME=$extRuntime",
  "NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS"
) | Set-Content (Join-Path $Logs "COUNTS_RUNTIME.txt")

WLog "COUNTS PASS=$passN FAIL=$failN NOT_RUN=$nrN BLOCKED=$blkN EXTENSION_RUNTIME=$extRuntime FIRST_FAIL=$firstFail"
Copy-Item (Join-Path $Logs "COUNTS_RUNTIME.txt") (Join-Path $Seal "SUMMARY.txt") -Force


