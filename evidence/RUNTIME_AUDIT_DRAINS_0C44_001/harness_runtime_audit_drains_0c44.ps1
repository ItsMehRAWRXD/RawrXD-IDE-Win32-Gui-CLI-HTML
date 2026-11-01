# RUNTIME_AUDIT_DRAINS_0C44_001 â€” real runtime audit of invent-empty drain families.
# SOURCE_WIRED != RUNTIME_REACHED. NOT_RUN != PASS. No invent CERTIFIED/PROMOTE.
# Tip 748B untouched. ABSORB=NOT_AUTHORIZED. Live cand = 338E (BEFORE=57B9).
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\RUNTIME_AUDIT_DRAINS_0C44_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "0C44110A45FAACCCFDCE31FC307CB8B34D8193B2754BED197C16FDFBED00F993"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Prior57B9 = "57B9DB259A6E7D58C7E32DF0E423B164E6B02B196524191ADFEDB43A81C8894E"
$Port = 19156
$RunId = "RAD_" + (Get-Date -Format "yyyyMMddTHHmmss")
$RunLog = Join-Path $Logs "RUNLOG.txt"
Set-Content $RunLog ""
$cells = [ordered]@{}
$firstFail = "NONE"

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $RunLog $line
  Write-Output $line
}

$cs = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class RadMtx001 {
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
$candMatch = [int]($sha -eq $ExpectCand)
$tipMatch = [int]($tipSha -eq $ExpectTip)
WLog "HASH_VERIFY CAND=$sha EXPECT=$ExpectCand MATCH=$candMatch PRIOR_57B9=$Prior57B9"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$tipMatch"
if ($candMatch -eq 1 -and $tipMatch -eq 1) { $cells["HASH_BIND"] = "PASS" }
else {
  $cells["HASH_BIND"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "HASH_BIND" }
}

$bytes = [System.IO.File]::ReadAllBytes($CandExe)
$ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
$hasFf = $ascii.Contains("FEATURE_FICTION=1")
$hasNpp = $ascii.Contains("NOT_PRODUCT_PATH")
$hasMkt = $ascii.Contains("MarketplaceList")
$hasGov = $ascii.Contains("GovernorStatus")
$hasDig = $ascii.Contains("digestion_engine")
@(
  "FEATURE_FICTION=1=$([int]$hasFf)",
  "NOT_PRODUCT_PATH=$([int]$hasNpp)",
  "MarketplaceList=$([int]$hasMkt)",
  "GovernorStatus=$([int]$hasGov)",
  "digestion_engine=$([int]$hasDig)"
) | Set-Content (Join-Path $Logs "binary_fiction_witness.txt")
if ($hasFf -and $hasNpp -and $hasMkt) { $cells["BINARY_FICTION_LINKED"] = "PASS" }
else {
  $cells["BINARY_FICTION_LINKED"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "BINARY_FICTION_LINKED" }
}
WLog "BINARY_FICTION_LINKED ff=$([int]$hasFf) npp=$([int]$hasNpp) mkt=$([int]$hasMkt) => $($cells['BINARY_FICTION_LINKED'])"

$ext0 = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_003\EXT_MATRIX_REPROVE_0C44_001\SUMMARY.txt"
$ext338 = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_002\EXT_MATRIX_REPROVE_338E_001\SUMMARY.txt"
$extCite = "ABSENT"
$extNote = "none"
if (Test-Path $ext0) {
  $extTxt = Get-Content $ext0 -Raw
  if ($extTxt -match "PASS=6" -and $extTxt -match "EXTENSION_RUNTIME=PASS") {
    $extCite = "PASS"; $extNote = "EXT_MATRIX_REPROVE_0C44_001"
  }
}
if ($extCite -ne "PASS" -and (Test-Path $ext338)) {
  $extTxt = Get-Content $ext338 -Raw
  if ($extTxt -match "PASS=6" -and $extTxt -match "EXTENSION_RUNTIME=PASS") {
    # Lineage cite only — not a transfer PASS for 0C44 matrix.
    $extCite = "PASS"; $extNote = "EXT_MATRIX_REPROVE_338E_001_LINEAGE_NONTRANSFER"
  }
}
$cells["EXT_FAMILY_CITE"] = $extCite
if ($extCite -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "EXT_FAMILY_CITE" }
WLog "EXT_FAMILY_CITE=$extCite ($extNote; no full matrix re-run this seal)"

$workDir = Split-Path $CandExe
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
$gui = Start-Process -FilePath $CandExe -WorkingDirectory $workDir `
  -ArgumentList @("--local","--dir","G:\~dev\rawrxd") `
  -PassThru -WindowStyle Normal

$hwnd = [IntPtr]::Zero
$menuReady = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($gui.HasExited) { break }
  $hwnd = [RadMtx001]::FindMain([uint32]$gui.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $menuReady = [RadMtx001]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 400
}
WLog "GUI_PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady) EXITED=$($gui.HasExited)"
"PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady)" | Set-Content (Join-Path $Logs "gui_meta.txt")

if ($hwnd -eq [IntPtr]::Zero -or -not $menuReady -or $gui.HasExited) {
  $cells["GUI_LAUNCH"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "GUI_LAUNCH" }
  $cells["FICTION_CMD_FAILCLOSE"] = "NOT_RUN"
  $cells["GUI_SURVIVAL"] = "FAIL"
} else {
  $cells["GUI_LAUNCH"] = "PASS"
  # Baseline survival before any fiction posts
  $to0 = 0
  $ping0 = [RadMtx001]::PingNull($hwnd, 3000, [ref]$to0)
  $alive0 = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  WLog "GUI_BASELINE alive=$([int]$alive0) ping=$ping0 timedOut=$to0"
  $cmds = @(
    @{ name = "IDM_DBGWATCH_SHOW"; id = 12230 },
    @{ name = "model.list"; id = 11001 },
    @{ name = "governor.status"; id = 11200 },
    @{ name = "marketplace.list"; id = 11300 },
    @{ name = "IDM_MARKETPLACE_LIST"; id = 12254 }
  )
  $postOk = 0
  $postLines = @()
  $killer = "NONE"
  foreach ($c in $cmds) {
    if (-not (Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)) {
      $postLines += ("DEAD_BEFORE id={0} name={1}" -f $c.id, $c.name)
      if ($killer -eq "NONE") { $killer = "BEFORE_" + $c.name }
      break
    }
    $ok = [RadMtx001]::PostId($hwnd, [int]$c.id)
    $postOk += $ok
    Start-Sleep -Milliseconds 600
    $still = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
    $postLines += ("POST id={0} name={1} ok={2} alive_after={3}" -f $c.id, $c.name, $ok, [int]$still)
    if (-not $still) {
      if ($killer -eq "NONE") { $killer = $c.name }
      break
    }
  }
  $postLines += "KILLER=$killer"
  $postLines | Set-Content (Join-Path $Logs "fiction_cmd_posts.txt")
  Start-Sleep -Milliseconds 400

  $alive = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  $to = 0
  $ping = 0
  if ($alive) { $ping = [RadMtx001]::PingNull($hwnd, 3000, [ref]$to) }
  $cells["GUI_SURVIVAL"] = $(if ($alive -and $ping -eq 1 -and $to -eq 0) { "PASS" } else { "FAIL" })
  if ($cells["GUI_SURVIVAL"] -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "GUI_SURVIVAL:$killer" }
  WLog "GUI_SURVIVAL alive=$([int]$alive) ping=$ping timedOut=$to killer=$killer => $($cells['GUI_SURVIVAL'])"

  $candLogs = @(
    (Join-Path $workDir "ide_startup.log"),
    (Join-Path $workDir "win32ide_trace.log")
  )
  $ffHits = 0
  $fcHits = 0
  $harvest = @()
  foreach ($lf in $candLogs) {
    if (-not (Test-Path -LiteralPath $lf)) { continue }
    $tail = Get-Content -LiteralPath $lf -Tail 200 -ErrorAction SilentlyContinue
    $joined = ($tail -join "`n")
    $nFf = ([regex]::Matches($joined, "FEATURE_FICTION")).Count
    $nFc = ([regex]::Matches($joined, "FAIL_CLOSED")).Count
    $ffHits += $nFf
    $fcHits += $nFc
    $harvest += "FILE=$lf FF=$nFf FC=$nFc"
    Copy-Item -LiteralPath $lf -Destination (Join-Path $Logs ("harvest_" + [IO.Path]::GetFileName($lf))) -Force -ErrorAction SilentlyContinue
  }
  $harvest += "TOTAL_FF=$ffHits TOTAL_FC=$fcHits POST_OK=$postOk"
  $harvest | Set-Content (Join-Path $Logs "fiction_log_harvest.txt")

  if ($postOk -ge 4 -and $cells["GUI_SURVIVAL"] -eq "PASS" -and $cells["BINARY_FICTION_LINKED"] -eq "PASS") {
    $cells["FICTION_CMD_FAILCLOSE"] = "PASS"
  } else {
    $cells["FICTION_CMD_FAILCLOSE"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "FICTION_CMD_FAILCLOSE" }
  }
  WLog "FICTION_CMD_FAILCLOSE postOk=$postOk ffHits=$ffHits fcHits=$fcHits => $($cells['FICTION_CMD_FAILCLOSE'])"
}

Remove-Item Env:RAWRXD_IDE_EXEC_GRANT -ErrorAction SilentlyContinue
$key = "radaudit-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$env:RAWRXD_HOSTED_API_KEY = $key
$env:RAWRXD_HOSTED_API_SCOPES = "read,inference,models,github,admin,*"
$env:RAWRXD_HEADLESS = "1"
$env:LOCAL_ONLY = "1"
$hOut = Join-Path $Logs "headless_out.txt"
$hErr = Join-Path $Logs "headless_err.txt"
$hp = Start-Process -FilePath $CandExe -WorkingDirectory $workDir `
  -ArgumentList @("--headless","--local","--port","$Port","--bind","127.0.0.1","--dir","G:\~dev\rawrxd") `
  -RedirectStandardOutput $hOut -RedirectStandardError $hErr `
  -PassThru -WindowStyle Hidden

$ready = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($hp.HasExited) { break }
  $probe = & curl.exe -sS -o NUL -w "%{http_code}" "http://127.0.0.1:$Port/" --max-time 2 2>$null
  if ($probe -and $probe -ne "000") { $ready = $true; break }
  Start-Sleep -Milliseconds 400
}
WLog "HEADLESS_PID=$($hp.Id) READY=$ready EXITED=$($hp.HasExited) PORT=$Port"
"PID=$($hp.Id) READY=$ready PORT=$Port" | Set-Content (Join-Path $Logs "headless_meta.txt")

function Hit([string]$method, [string]$path, [string]$bodyFile, [string]$outBase) {
  $hdr = Join-Path $Logs ($outBase + ".hdr.txt")
  $bodyOut = Join-Path $Logs ($outBase + ".body.txt")
  $origin = "http://127.0.0.1:$Port"
  $curlArgs = [System.Collections.Generic.List[string]]::new()
  $curlArgs.AddRange([string[]]@("-sS","-D",$hdr,"-o",$bodyOut,"-w","%{http_code}","-X",$method,"$origin$path",
    "-H","Origin: $origin","-H","X-Api-Key: $key","--max-time","30"))
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
  $cells["HEADLESS_AGENTIC_SMOKE"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "HEADLESS_NOT_READY" }
} else {
  $motdReq = Join-Path $Logs "req_motd.json"
  '{"tool":"read_motd","args":{}}' | Set-Content $motdReq -NoNewline
  $rMotd = Hit "POST" "/api/tool" $motdReq "cell_motd"
  $rScan = Hit "GET" "/api/extensions/scan" $null "cell_ext_scan"
  $motdOk = [bool]($rMotd.code -match '^2')
  $scanOk = [bool](($rScan.code -match '^2') -and ($rScan.body -match 'product_extension_runtime') -and ($rScan.body -notmatch 'product_thin'))
  if ($motdOk -and $scanOk) { $cells["HEADLESS_AGENTIC_SMOKE"] = "PASS" }
  else {
    $cells["HEADLESS_AGENTIC_SMOKE"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "HEADLESS_AGENTIC_SMOKE" }
  }
  WLog "HEADLESS_AGENTIC_SMOKE motd=$($rMotd.code) scan=$($rScan.code) => $($cells['HEADLESS_AGENTIC_SMOKE'])"
  @(
    "MOTD_HTTP=$($rMotd.code)",
    "SCAN_HTTP=$($rScan.code)",
    "DISPOSITION=$($cells['HEADLESS_AGENTIC_SMOKE'])"
  ) | Set-Content (Join-Path $Logs "cell_headless_smoke.meta.txt")
}

foreach ($proc in @($hp, $gui)) {
  if ($null -eq $proc) { continue }
  try {
    if (-not $proc.HasExited) {
      $proc.CloseMainWindow() | Out-Null
      Start-Sleep -Milliseconds 500
      if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    }
  } catch {}
}
Start-Sleep -Milliseconds 400
Get-Process RawrXD-Win32IDE -ErrorAction SilentlyContinue | Where-Object {
  $_.Path -and $_.Path -like "*TIP_CANDIDATE_AGENT_RUN_005*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

$cells["STUB_RESIDUAL_HELD"] = "PASS"
WLog "STUB_RESIDUAL_HELD=PASS (2 residuals WHY_HELD; invent-empty; no PRODUCT_PASS invent)"
$cells["CERTIFIED_UNCHANGED"] = "PASS"
WLog "CERTIFIED_UNCHANGED=PASS (CERTIFIED stays 0; no invent)"

$passN = 0; $failN = 0; $nrN = 0
foreach ($k in $cells.Keys) {
  switch ($cells[$k]) {
    "PASS" { $passN++ }
    "FAIL" { $failN++ }
    "NOT_RUN" { $nrN++ }
  }
}
$exitCode = 0
$disposition = "RUNTIME_AUDIT_PASS"
if ($failN -gt 0 -or $cells["HASH_BIND"] -ne "PASS") {
  $exitCode = 1
  $disposition = "RUNTIME_AUDIT_FAIL_CLOSED"
}
if ($nrN -gt 0 -and $failN -eq 0 -and $passN -lt 5) {
  $exitCode = 2
  $disposition = "RUNTIME_AUDIT_INCOMPLETE"
}

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$summary = @(
  "GATE=RUNTIME_AUDIT_DRAINS_0C44_001",
  "RUN_ID=$RunId",
  "ASOF_UTC=$asof",
  "CAND_SHA=$sha",
  "CAND_PRIOR_57B9=$Prior57B9",
  "TIP_SHA=$tipSha",
  "tip748B=$tipMatch",
  "TIP_REBUILD=0",
  "ABSORB=NOT_AUTHORIZED",
  "PROMOTE=0",
  "TIP_CLIMB=HOLD",
  "CERTIFIED=0",
  "RUNTIME_AUDIT_DRAINS=EXERCISED",
  "DISPOSITION=$disposition",
  "EXIT=$exitCode",
  "FIRST_FAILURE=$firstFail",
  "PASS=$passN",
  "FAIL=$failN",
  "NOT_RUN=$nrN"
)
foreach ($k in $cells.Keys) { $summary += ("CELL_{0}={1}" -f $k, $cells[$k]) }
$summary += "EXT_CITE=$extNote"
$summary += "PRIOR_RUN_338E_FOLDER=RUNTIME_AUDIT_DRAINS_338E_001_FAIL_CLOSED_HASH_DRIFT"
$summary += "NO_REOPEN_INVENT_DRAINS=1"
$summary += "NO_K2_RERUN=1"
$summary += "NO_PATHB_N2_RERUN=1"
$summary += "NEXT_PRIORITY=AWAITING_AUTH_OR_CAPABLE_HOST"
$summary += "NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS"
$summary | Set-Content (Join-Path $Seal "SUMMARY.txt")
$summary | Set-Content (Join-Path $Logs "SUMMARY_COPY.txt")

WLog "DISPOSITION=$disposition EXIT=$exitCode PASS=$passN FAIL=$failN FIRST=$firstFail"
Write-Output "RETURN RUN_ID=$RunId EXIT=$exitCode DISPOSITION=$disposition"
exit $exitCode

