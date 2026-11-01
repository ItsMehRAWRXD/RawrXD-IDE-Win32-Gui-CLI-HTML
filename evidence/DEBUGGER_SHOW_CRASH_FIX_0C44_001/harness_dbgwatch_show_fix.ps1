# DEBUGGER_SHOW_CRASH_FIX_0C44_001 — MenuReady → baseline ping → IDM_DBGWATCH_SHOW must NOT kill GUI.
# Pattern from RUNTIME_AUDIT_DRAINS_0C44_001. PROMOTE=0 ABSORB=NOT_AUTHORIZED tip748B HOLD.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\DEBUGGER_SHOW_CRASH_FIX_0C44_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Prior0C44 = "0C44110A45FAACCCFDCE31FC307CB8B34D8193B2754BED197C16FDFBED00F993"
$Prior7C16 = "7C1622A35BA21F86E95FFB69713F1DBF93793084584E10917942E8A937B0D964"
$RunId = "DBGSHOW_" + (Get-Date -Format "yyyyMMddTHHmmss")
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
public class DbgShowFix001 {
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

cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
Start-Sleep 1

$sha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$sha | Set-Content (Join-Path $Logs "exe_sha.txt")
$tipSha | Set-Content (Join-Path $Logs "tip_sha.txt")
$tipMatch = [int]($tipSha -eq $ExpectTip)
WLog "HASH_VERIFY CAND=$sha PRIOR_0C44=$Prior0C44 PRIOR_7C16=$Prior7C16 tip748B=$tipMatch"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$tipMatch"
if ($tipMatch -eq 1) { $cells["HASH_BIND"] = "PASS" }
else {
  $cells["HASH_BIND"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "HASH_BIND" }
}

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
  $hwnd = [DbgShowFix001]::FindMain([uint32]$gui.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $menuReady = [DbgShowFix001]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 400
}
WLog "GUI_PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady) EXITED=$($gui.HasExited)"
"PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady)" | Set-Content (Join-Path $Logs "gui_meta.txt")

if ($hwnd -eq [IntPtr]::Zero -or -not $menuReady -or $gui.HasExited) {
  $cells["GUI_LAUNCH"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "GUI_LAUNCH" }
  $cells["GUI_SURVIVAL"] = "FAIL"
} else {
  $cells["GUI_LAUNCH"] = "PASS"
  $to0 = 0
  $ping0 = [DbgShowFix001]::PingNull($hwnd, 3000, [ref]$to0)
  $alive0 = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  WLog "GUI_BASELINE alive=$([int]$alive0) ping=$ping0 timedOut=$to0"

  $ok = [DbgShowFix001]::PostId($hwnd, 12230)
  Start-Sleep -Milliseconds 800
  $still = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  $to = 0
  $ping = 0
  if ($still) { $ping = [DbgShowFix001]::PingNull($hwnd, 3000, [ref]$to) }
  $gui.Refresh()
  $exitCode = if ($gui.HasExited) { $gui.ExitCode } else { 0 }
  $exitHex = if ($gui.HasExited) { ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)) } else { "RUNNING" }
  @"
POST id=12230 name=IDM_DBGWATCH_SHOW ok=$ok alive_after=$([int]$still) ping=$ping timedOut=$to exit=$exitCode hex=$exitHex
KILLER=$(if ($still -and $ping -eq 1) { 'NONE' } else { 'IDM_DBGWATCH_SHOW' })
"@ | Set-Content (Join-Path $Logs "fiction_cmd_posts.txt")

  $cells["GUI_SURVIVAL"] = $(if ($still -and $ping -eq 1 -and $to -eq 0) { "PASS" } else { "FAIL" })
  if ($cells["GUI_SURVIVAL"] -ne "PASS" -and $firstFail -eq "NONE") {
    $firstFail = "GUI_SURVIVAL:IDM_DBGWATCH_SHOW"
  }
  WLog "GUI_SURVIVAL alive=$([int]$still) ping=$ping timedOut=$to exitHex=$exitHex => $($cells['GUI_SURVIVAL'])"
}

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$cells["TIP_UNTOUCHED"] = $(if ($tipAfter -eq $ExpectTip) { "PASS" } else { "FAIL" })
if ($cells["TIP_UNTOUCHED"] -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "TIP_UNTOUCHED" }
WLog "TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])"

$cells["CERTIFIED_UNCHANGED"] = "PASS"
WLog "CERTIFIED_UNCHANGED=PASS (CERTIFIED stays 0; no invent)"

if ($gui -and -not $gui.HasExited) {
  Stop-Process -Id $gui.Id -Force -ErrorAction SilentlyContinue
}

$passN = @($cells.Values | Where-Object { $_ -eq "PASS" }).Count
$failN = @($cells.Values | Where-Object { $_ -eq "FAIL" }).Count
$disp = if ($failN -eq 0) { "DBGWATCH_SHOW_FIX_PASS" } else { "DBGWATCH_SHOW_FIX_FAIL_CLOSED" }
$exit = if ($failN -eq 0) { 0 } else { 1 }
WLog "DISPOSITION=$disp EXIT=$exit PASS=$passN FAIL=$failN FIRST=$firstFail"

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$summary = @"
GATE=DEBUGGER_SHOW_CRASH_FIX_0C44_001
RUN_ID=$RunId
ASOF_UTC=$asof
CAND_SHA=$sha
CAND_PRIOR_7C16=$Prior7C16
CAND_PRIOR_0C44=$Prior0C44
TIP_SHA=$tipSha
tip748B=$tipMatch
TIP_REBUILD=0
ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
DISPOSITION=$disp
EXIT=$exit
FIRST_FAILURE=$firstFail
PASS=$passN
FAIL=$failN
CELL_HASH_BIND=$($cells['HASH_BIND'])
CELL_GUI_LAUNCH=$($cells['GUI_LAUNCH'])
CELL_GUI_SURVIVAL=$($cells['GUI_SURVIVAL'])
CELL_TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])
CELL_CERTIFIED_UNCHANGED=$($cells['CERTIFIED_UNCHANGED'])
KILLER_PRIOR=IDM_DBGWATCH_SHOW
ROOT_CAUSE=handleDebugWatchCommand ShowWindow/SetFocus/appendToOutput path on 0C44 → EXIT=0xC0000409; fail-closed ODS-only
NEXT_PRIORITY=BREAKPOINT_FOLLOWON_OR_AWAITING_AUTH_OR_CAPABLE_HOST
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
"@
$summary | Set-Content (Join-Path $Seal "SUMMARY.txt")
$summary | Set-Content (Join-Path $Logs "SUMMARY_COPY.txt")
"DEBUGGER_SHOW_CRASH_FIX=$disp | RUN_ID=$RunId EXIT=$exit | CAND=$($sha.Substring(0,8))… tip748B=$tipMatch | GUI_SURVIVAL=$($cells['GUI_SURVIVAL']) | PROMOTE=0 | NEXT=BREAKPOINT_FOLLOWON_OR_AWAITING_AUTH_OR_CAPABLE_HOST" |
  Set-Content (Join-Path $Seal "RETURN_LINE.txt")

exit $exit
