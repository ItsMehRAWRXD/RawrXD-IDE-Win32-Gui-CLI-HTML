# EXTENSION_RUNTIME_MATRIX_001 - candidate 73368 only. Tip 748B untouched.
# Cells: discovery | manifest_load | activation | commands | toggles | failure_isolation
# NOT_RUN != PASS. product_thin adapter != real extension runtime. PROMOTE=0.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\EXTENSION_RUNTIME_MATRIX_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Port = 19140
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
public class ExtMtx73368 {
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
$sha | Set-Content (Join-Path $Logs "exe_sha.txt")
$tipSha | Set-Content (Join-Path $Logs "tip_sha.txt")
WLog "HASH_VERIFY CAND=$sha EXPECT=$ExpectCand MATCH=$([int]($sha -eq $ExpectCand))"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$([int]($tipSha -eq $ExpectTip))"
if ($sha -ne $ExpectCand) { throw "CANDIDATE_SHA_DRIFT" }
if ($tipSha -ne $ExpectTip) { throw "TIP_SHA_DRIFT_DO_NOT_PROCEED" }
if ($sha -eq $ExpectTip) { throw "FAIL_CLOSED SHA_IS_TIP" }

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

Remove-Item Env:RAWRXD_HOSTED_API_KEY, Env:RAWRXD_HOSTED_API_SCOPES, Env:RAWRXD_IDE_EXEC_GRANT, Env:RAWRXD_GUI -ErrorAction SilentlyContinue
$key = "extmtx73368-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
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

function Hit([string]$method, [string]$path, [string]$bodyFile, [string]$outBase) {
  $hdr = Join-Path $Logs ($outBase + ".hdr.txt")
  $bodyOut = Join-Path $Logs ($outBase + ".body.txt")
  $curlArgs = @("-sS","-D",$hdr,"-o",$bodyOut,"-w","%{http_code}","-X",$method,"$authOrigin$path",
    "-H","Origin: $authOrigin","-H","X-Api-Key: $key","--max-time","30")
  if ($method -eq "POST" -or $method -eq "PUT") {
    $curlArgs += @("-H","Content-Type: application/json")
    if ($bodyFile) { $curlArgs += @("--data-binary","@$bodyFile") }
    else { $curlArgs += @("--data-binary","{}") }
  }
  $code = & curl.exe @curlArgs
  $body = ""
  if (Test-Path $bodyOut) { $body = Get-Content $bodyOut -Raw -ErrorAction SilentlyContinue }
  return @{ code = "$code"; body = "$body" }
}

if (-not $ready) {
  WLog "HEADLESS_NOT_READY - cells that need HTTP = BLOCKED"
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
  if (($adj.okHttp) -and (-not $adj.thin) -and ($rScan.body -match '"total"\s*:\s*[1-9]')) { $cells["DISCOVERY"] = "PASS" }
  else { $cells["DISCOVERY"] = "FAIL" }
  WLog "DISCOVERY scan=$($rScan.code) list=$($rList.code) thin=$([int]$adj.thin) => $($cells['DISCOVERY'])"
  @(
    "SCAN_HTTP=$($rScan.code)",
    "LIST_HTTP=$($rList.code)",
    "INSTALLED_HTTP=$($rInst.code)",
    "PRODUCT_THIN=$([int]$adj.thin)",
    "DISPOSITION=$($cells['DISCOVERY'])",
    "NOTE=product_thin empty list != real extension discovery"
  ) | Set-Content (Join-Path $Logs "cell_discovery.meta.txt")

  $vsixBody = Join-Path $Logs "req_load_vsix.json"
  '{"path":"G:\\~dev\\rawrxd\\evidence\\EXTENSION_RUNTIME_MATRIX_001\\fixtures\\missing.vsix"}' | Set-Content $vsixBody -NoNewline
  $rVsix = Hit "POST" "/api/extensions/load-vsix" $vsixBody "cell_manifest_load_vsix"
  $rImp = Hit "POST" "/api/extensions/install" $vsixBody "cell_manifest_install"
  $adjM = AdjudicateBody $rVsix.body $rVsix.code
  if (($adjM.okHttp) -and (-not $adjM.thin) -and ($rVsix.body -match '"manifest"' -or $rVsix.body -match '"id"')) { $cells["MANIFEST_LOAD"] = "PASS" }
  else { $cells["MANIFEST_LOAD"] = "FAIL" }
  WLog "MANIFEST_LOAD vsix=$($rVsix.code) install=$($rImp.code) thin=$([int]$adjM.thin) => $($cells['MANIFEST_LOAD'])"
  @(
    "LOAD_VSIX_HTTP=$($rVsix.code)",
    "INSTALL_HTTP=$($rImp.code)",
    "PRODUCT_THIN=$([int]$adjM.thin)",
    "DISPOSITION=$($cells['MANIFEST_LOAD'])",
    "NOTE=product_thin acknowledge != ExtensionManifestLoader::Load; invent gated SOURCE_WIRE FAIL_CLOSED"
  ) | Set-Content (Join-Path $Logs "cell_manifest_load.meta.txt")

  $actBody = Join-Path $Logs "req_activate.json"
  '{"id":"rawrxd.test.extension"}' | Set-Content $actBody -NoNewline
  $rAct = Hit "POST" "/api/extensions/activate" $actBody "cell_activation"
  $rHost = Hit "GET" "/api/extensions/host/status" $null "cell_activation_host"
  $adjA = AdjudicateBody $rAct.body $rAct.code
  $hostPidReal = [bool]($rHost.body -match '"host_pid"\s*:\s*[1-9]')
  if ($adjA.okHttp -and (-not $adjA.thin) -and $hostPidReal) { $cells["ACTIVATION"] = "PASS" }
  else { $cells["ACTIVATION"] = "FAIL" }
  WLog "ACTIVATION act=$($rAct.code) host=$($rHost.code) hostPidReal=$([int]$hostPidReal) thin=$([int]$adjA.thin) => $($cells['ACTIVATION'])"
  @(
    "ACTIVATE_HTTP=$($rAct.code)",
    "HOST_STATUS_HTTP=$($rHost.code)",
    "HOST_PID_REAL=$([int]$hostPidReal)",
    "PRODUCT_THIN=$([int]$adjA.thin)",
    "DISPOSITION=$($cells['ACTIVATION'])",
    "NOTE=ActivateExtension FEATURE_FICTION FAIL_CLOSED; product_thin running:true host_pid:0 != real host"
  ) | Set-Content (Join-Path $Logs "cell_activation.meta.txt")

  $togBody = Join-Path $Logs "req_toggle.json"
  '{"id":"rawrxd.test.extension","enabled":true}' | Set-Content $togBody -NoNewline
  $rEn = Hit "POST" "/api/extensions/enable" $togBody "cell_toggles_enable"
  $rDis = Hit "POST" "/api/extensions/disable" $togBody "cell_toggles_disable"
  $adjT = AdjudicateBody $rEn.body $rEn.code
  if ($adjT.okHttp -and (-not $adjT.thin) -and ($rEn.body -match '"persisted"\s*:\s*true')) { $cells["TOGGLES"] = "PASS" }
  else { $cells["TOGGLES"] = "FAIL" }
  WLog "TOGGLES enable=$($rEn.code) disable=$($rDis.code) thin=$([int]$adjT.thin) => $($cells['TOGGLES'])"
  @(
    "ENABLE_HTTP=$($rEn.code)",
    "DISABLE_HTTP=$($rDis.code)",
    "PRODUCT_THIN=$([int]$adjT.thin)",
    "DISPOSITION=$($cells['TOGGLES'])",
    "NOTE=Win32IDE_ExtensionToggles invent seed FAIL_CLOSED; product_thin != persisted toggles"
  ) | Set-Content (Join-Path $Logs "cell_toggles.meta.txt")

  $cmdProbe = Join-Path $Logs "req_tool_ext.json"
  '{"tool":"extension.activate","name":"extension.activate","args":{"id":"rawrxd.test.extension"}}' | Set-Content $cmdProbe -NoNewline
  $rTool = Hit "POST" "/api/tool" $cmdProbe "cell_commands_tool"
  $rCmd = Hit "POST" "/api/command" $cmdProbe "cell_commands_command"
  $toolBody = $rTool.body
  $hasExtTool = [bool](($toolBody -match 'extension') -and ($toolBody -notmatch 'unknown|not found|404|unsupported') -and ($rTool.code -match '^2') -and ($toolBody -notmatch 'product_thin'))
  if ($hasExtTool) { $cmdHeadless = "PASS" }
  elseif ($rTool.code -match '^2' -or $rCmd.code -match '^2') { $cmdHeadless = "FAIL" }
  else { $cmdHeadless = "BLOCKED" }
  WLog "COMMANDS_HEADLESS tool=$($rTool.code) command=$($rCmd.code) hasExtTool=$([int]$hasExtTool) provisional=$cmdHeadless"
  @(
    "TOOL_HTTP=$($rTool.code)",
    "COMMAND_HTTP=$($rCmd.code)",
    "HAS_EXT_TOOL=$([int]$hasExtTool)",
    "PROVISIONAL=$cmdHeadless"
  ) | Set-Content (Join-Path $Logs "cell_commands_headless.meta.txt")

  $rKill = Hit "POST" "/api/extensions/host/kill" $null "cell_failiso_kill"
  $rBad = Hit "POST" "/api/extensions/activate" $actBody "cell_failiso_bad_act"
  Start-Sleep -Milliseconds 500
  $aliveHttp = [bool](Get-Process -Id $p.Id -ErrorAction SilentlyContinue)
  $rPing = Hit "GET" "/api/extensions/host/status" $null "cell_failiso_ping"
  $pingOk = [bool]($rPing.code -match '^2')
  if ($aliveHttp -and $pingOk -and $hostPidReal) { $cells["FAILURE_ISOLATION"] = "PASS" }
  elseif ($aliveHttp -and $pingOk -and -not $hostPidReal) { $cells["FAILURE_ISOLATION"] = "BLOCKED" }
  else { $cells["FAILURE_ISOLATION"] = "FAIL" }
  WLog "FAILURE_ISOLATION alive=$([int]$aliveHttp) ping=$($rPing.code) hostPidReal=$([int]$hostPidReal) => $($cells['FAILURE_ISOLATION'])"
  $blkIso = if ($cells["FAILURE_ISOLATION"] -eq "BLOCKED") {
    "MISSING_DEPENDENCY=ExtensionHost child process (host_pid real); product_thin host_pid:0 cannot prove failure isolation"
  } else { "n/a" }
  @(
    "KILL_HTTP=$($rKill.code)",
    "BAD_ACT_HTTP=$($rBad.code)",
    "ALIVE=$([int]$aliveHttp)",
    "PING_HTTP=$($rPing.code)",
    "HOST_PID_REAL=$([int]$hostPidReal)",
    "DISPOSITION=$($cells['FAILURE_ISOLATION'])",
    "BLOCK_REASON=$blkIso"
  ) | Set-Content (Join-Path $Logs "cell_failure_isolation.meta.txt")

  if (-not $p.HasExited) {
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
  }
  WLog "HEADLESS_STOPPED"

  Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
  $gout = Join-Path $Logs "gui_out.txt"
  $gerr = Join-Path $Logs "gui_err.txt"
  $gp = Start-Process -FilePath $CandExe -WorkingDirectory (Split-Path $CandExe) `
    -ArgumentList @("--local","--dir","G:\~dev\rawrxd") `
    -RedirectStandardOutput $gout -RedirectStandardError $gerr `
    -PassThru -WindowStyle Normal
  $hwnd = [IntPtr]::Zero
  $guiReady = $false
  $gDeadline = (Get-Date).AddSeconds(90)
  while ((Get-Date) -lt $gDeadline) {
    if ($gp.HasExited) { break }
    $hwnd = [ExtMtx73368]::FindMain([uint32]$gp.Id)
    if ($hwnd -ne [IntPtr]::Zero -and [ExtMtx73368]::MenuReady($hwnd)) { $guiReady = $true; break }
    Start-Sleep -Milliseconds 400
  }
  WLog ("GUI_PID={0} HWND=0x{1:X} MENU_READY={2} EXITED={3}" -f $gp.Id, $hwnd.ToInt64(), $guiReady, $gp.HasExited)

  $cmdGui = "NOT_RUN"
  $togGui = "NOT_RUN"
  if (-not $guiReady) {
    $cmdGui = "BLOCKED"
    @(
      "BLOCK_REASON=GUI_MAINWINDOW_OR_MENU_NOT_READY",
      "MISSING_DEPENDENCY=RawrXD_IDE_MainWindow + RawrXD.MainMenuReady for EXE_SHA=$sha GUI launch",
      "HEADLESS_PROVISIONAL=$cmdHeadless"
    ) | Set-Content (Join-Path $Logs "cell_commands.meta.txt")
  } else {
    $posts = @()
    foreach ($id in @(11810,11811,11812,11813,11814)) {
      $ok = [ExtMtx73368]::PostId($hwnd, $id)
      $posts += "id=$id post=$ok"
      Start-Sleep -Milliseconds 200
    }
    $to = 0
    $ping = [ExtMtx73368]::PingNull($hwnd, 3000, [ref]$to)
    $aliveGui = [bool](Get-Process -Id $gp.Id -ErrorAction SilentlyContinue)
    $cmdGui = "FAIL"
    $togGui = "FAIL"
    @(
      "GUI_READY=1",
      "POSTS=$($posts -join ';')",
      "PING_OK=$ping TIMED_OUT=$to",
      "ALIVE=$([int]$aliveGui)",
      "DISPOSITION_COMMANDS=$cmdGui",
      "DISPOSITION_TOGGLES_GUI=$togGui",
      "NOTE=IDM_EXT_* PostMessage exercised; handleExtensionCommand FEATURE_FICTION FAIL_CLOSED (no invent command PASS)",
      "HEADLESS_PROVISIONAL=$cmdHeadless"
    ) | Set-Content (Join-Path $Logs "cell_commands.meta.txt")
    Add-Content (Join-Path $Logs "cell_toggles.meta.txt") "GUI_IDM_EXT_ENABLE_DISABLE_POSTED=1 DISPOSITION_GUI=$togGui"
  }

  if ($cmdGui -eq "NOT_RUN") { $cells["COMMANDS"] = $cmdHeadless }
  elseif ($cmdGui -eq "BLOCKED" -and $cmdHeadless -ne "BLOCKED") { $cells["COMMANDS"] = $cmdHeadless }
  else { $cells["COMMANDS"] = $cmdGui }

  if ($cells["TOGGLES"] -ne "PASS" -and $togGui -eq "FAIL") { $cells["TOGGLES"] = "FAIL" }

  if (-not $gp.HasExited) {
    if ($hwnd -ne [IntPtr]::Zero) { [void][ExtMtx73368]::PostMessageW($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero) }
    Start-Sleep 2
    if (-not $gp.HasExited) { Stop-Process -Id $gp.Id -Force -ErrorAction SilentlyContinue }
  }
  WLog "GUI_STOPPED"
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
  "GATE=EXTENSION_RUNTIME_MATRIX_001",
  "ASOF_UTC=$asof",
  "EXE_SHA=$sha",
  "TIP_SHA=$tipAfter",
  "tip748B=$tipOk",
  "TIP_REBUILD=0",
  "ABSORB=NOT_AUTHORIZED",
  "PROMOTE=0",
  "CERTIFIED=0",
  "PATHB_RUNTIME_PASS_NEQ_EXTENSION=1",
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
  "NEXT_GATE=POST_PATHB_PASS_PROMOTION_HELD"
) | Set-Content (Join-Path $Logs "COUNTS_RUNTIME.txt")

WLog "COUNTS PASS=$passN FAIL=$failN NOT_RUN=$nrN BLOCKED=$blkN EXTENSION_RUNTIME=$extRuntime"
WLog "DONE"
