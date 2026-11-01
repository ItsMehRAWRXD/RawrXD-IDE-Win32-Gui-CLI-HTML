# BREAKPOINT_FOLLOWON_D252_001 — MenuReady → baseline ping → IDM_DBG_* BP cmds must NOT kill GUI.
# Follow-on after DEBUGGER_SHOW_CRASH_FIX_0C44_001. PROMOTE=0 ABSORB=NOT_AUTHORIZED tip748B HOLD.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\BREAKPOINT_FOLLOWON_D252_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$PriorD252 = "D252A344B5D9ABECF402E2E927A18F2DB06909CE773B587F6B5AABD61BAD25E2"
$Prior7C16 = "7C1622A35BA21F86E95FFB69713F1DBF93793084584E10917942E8A937B0D964"
$PriorShow = "D252A344B5D9ABECF402E2E927A18F2DB06909CE773B587F6B5AABD61BAD25E2"
$NewShaFile = Join-Path $Seal "NEW_CAND_SHA.txt"
$ExpectCand = $PriorD252
if (Test-Path -LiteralPath $NewShaFile) {
  $m = Select-String -LiteralPath $NewShaFile -Pattern '^CAND_SHA_AFTER=(.+)$' | Select-Object -First 1
  if ($m) { $ExpectCand = $m.Matches[0].Groups[1].Value.Trim() }
}
$RunId = "BPFOLLOW_" + (Get-Date -Format "yyyyMMddTHHmmss")
$RunLog = Join-Path $Logs "RUNLOG.txt"
Set-Content $RunLog ""
$cells = [ordered]@{}
$firstFail = "NONE"
$killer = "NONE"

# Product BP command surface (NativeDebugPanel + BreakpointManagerUI wire)
$cmds = @(
  @{ Id = 5170; Name = "IDM_DBG_LIST_BPS" },
  @{ Id = 5166; Name = "IDM_DBG_ADD_BP" },
  @{ Id = 5168; Name = "IDM_DBG_ENABLE_BP" },
  @{ Id = 5167; Name = "IDM_DBG_REMOVE_BP" },
  @{ Id = 5169; Name = "IDM_DBG_CLEAR_BPS" },
  @{ Id = 5170; Name = "IDM_DBG_LIST_BPS_REPOST" }
)

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $RunLog $line
  Write-Output $line
}

$cs = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class BpFollow001 {
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
$candMatch = [int]($sha -eq $ExpectCand)
WLog "HASH_VERIFY CAND=$sha EXPECT_CAND=$ExpectCand MATCH=$candMatch tip748B=$tipMatch"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$tipMatch"
WLog "HASH_VERIFY PRIOR_D252=$PriorD252 PRIOR_SHOW=$PriorShow PRIOR_7C16=$Prior7C16"
if ($tipMatch -eq 1 -and $candMatch -eq 1) { $cells["HASH_BIND"] = "PASS" }
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
  $hwnd = [BpFollow001]::FindMain([uint32]$gui.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $menuReady = [BpFollow001]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 400
}
WLog "GUI_PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady) EXITED=$($gui.HasExited)"
"PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady)" | Set-Content (Join-Path $Logs "gui_meta.txt")

$postLines = New-Object System.Collections.Generic.List[string]

if ($hwnd -eq [IntPtr]::Zero -or -not $menuReady -or $gui.HasExited) {
  $cells["GUI_LAUNCH"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "GUI_LAUNCH" }
  $cells["GUI_SURVIVAL"] = "FAIL"
  $cells["BP_CMDS"] = "FAIL"
} else {
  $cells["GUI_LAUNCH"] = "PASS"
  Start-Sleep -Seconds 2
  $to0 = 0
  $ping0 = [BpFollow001]::PingNull($hwnd, 5000, [ref]$to0)
  if ($ping0 -ne 1) {
    Start-Sleep -Seconds 2
    $to0 = 0
    $ping0 = [BpFollow001]::PingNull($hwnd, 5000, [ref]$to0)
  }
  $alive0 = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  WLog "GUI_BASELINE alive=$([int]$alive0) ping=$ping0 timedOut=$to0"
  if ($ping0 -ne 1) {
    $cells["GUI_BASELINE"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "GUI_BASELINE" }
  } else {
    $cells["GUI_BASELINE"] = "PASS"
  }

  $bpAllOk = $true
  foreach ($c in $cmds) {
    $aliveBefore = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
    if (-not $aliveBefore) {
      $gui.Refresh()
      $exitCode = 0
      try { $exitCode = $gui.ExitCode } catch {}
      $exitHex = ('{0:X8}' -f ([int64]$exitCode -band 0xFFFFFFFF))
      $bpAllOk = $false
      $killer = $c.Name
      if ($firstFail -eq "NONE") { $firstFail = "PRE_POST_DEAD:$($c.Name)" }
      $line = "POST id=$($c.Id) name=$($c.Name) SKIPPED_DEAD exit=$exitCode hex=$exitHex"
      $postLines.Add($line)
      WLog $line
      break
    }
    $ok = [BpFollow001]::PostId($hwnd, $c.Id)
    Start-Sleep -Milliseconds 900
    $still = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
    $to = 0
    $ping = 0
    if ($still) { $ping = [BpFollow001]::PingNull($hwnd, 3000, [ref]$to) }
    $gui.Refresh()
    $exitCode = 0
    $exitHex = "RUNNING"
    if (-not $still) {
      try { $exitCode = $gui.ExitCode } catch {}
      $exitHex = ('{0:X8}' -f ([int64]$exitCode -band 0xFFFFFFFF))
    }
    $line = "POST id=$($c.Id) name=$($c.Name) ok=$ok alive_after=$([int]$still) ping=$ping timedOut=$to exit=$exitCode hex=$exitHex"
    $postLines.Add($line)
    WLog $line
    if (-not ($still -and $ping -eq 1 -and $to -eq 0)) {
      $bpAllOk = $false
      $killer = $c.Name
      if ($firstFail -eq "NONE") { $firstFail = "GUI_SURVIVAL:$($c.Name)" }
      break
    }
  }

  $cells["BP_CMDS"] = $(if ($bpAllOk) { "PASS" } else { "FAIL" })
  $cells["GUI_SURVIVAL"] = $(if ($bpAllOk) { "PASS" } else { "FAIL" })
  WLog "GUI_SURVIVAL => $($cells['GUI_SURVIVAL']) KILLER=$killer"
}

$postLines.Add("KILLER=$killer")
$postLines | Set-Content (Join-Path $Logs "fiction_cmd_posts.txt")

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$cells["TIP_UNTOUCHED"] = $(if ($tipAfter -eq $ExpectTip) { "PASS" } else { "FAIL" })
if ($cells["TIP_UNTOUCHED"] -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "TIP_UNTOUCHED" }
WLog "TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])"

$cells["CERTIFIED_UNCHANGED"] = "PASS"
WLog "CERTIFIED_UNCHANGED=PASS (CERTIFIED stays 0; no invent BP PRODUCT_PASS)"

if ($gui -and -not $gui.HasExited) {
  Stop-Process -Id $gui.Id -Force -ErrorAction SilentlyContinue
}

$passN = @($cells.Values | Where-Object { $_ -eq "PASS" }).Count
$failN = @($cells.Values | Where-Object { $_ -eq "FAIL" }).Count
$disp = if ($failN -eq 0) { "BREAKPOINT_FOLLOWON_PASS" } else { "BREAKPOINT_FOLLOWON_FAIL_CLOSED" }
$exit = if ($failN -eq 0) { 0 } else { 1 }
WLog "DISPOSITION=$disp EXIT=$exit PASS=$passN FAIL=$failN FIRST=$firstFail"

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$nextPri = if ($failN -eq 0) {
  "AWAITING_AUTH_OR_CAPABLE_HOST"
} else {
  "BREAKPOINT_FOLLOWON_FIX_OR_AWAITING_AUTH_OR_CAPABLE_HOST"
}
$summary = @"
GATE=BREAKPOINT_FOLLOWON_D252_001
RUN_ID=$RunId
ASOF_UTC=$asof
CAND_SHA=$sha
CAND_PRIOR_SHOW=$PriorShow
CAND_PRIOR_7C16=$Prior7C16
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
KILLER=$killer
PASS=$passN
FAIL=$failN
CELL_HASH_BIND=$($cells['HASH_BIND'])
CELL_GUI_LAUNCH=$($cells['GUI_LAUNCH'])
CELL_GUI_BASELINE=$($cells['GUI_BASELINE'])
CELL_BP_CMDS=$($cells['BP_CMDS'])
CELL_GUI_SURVIVAL=$($cells['GUI_SURVIVAL'])
CELL_TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])
CELL_CERTIFIED_UNCHANGED=$($cells['CERTIFIED_UNCHANGED'])
NOTE=GUI_SURVIVAL_PASS != invent Breakpoint panel PRODUCT_PASS; createDebuggerUI never called; BP panel owns Create
NEXT_PRIORITY=$nextPri
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
"@
$summary | Set-Content (Join-Path $Seal "SUMMARY.txt")
$summary | Set-Content (Join-Path $Logs "SUMMARY_COPY.txt")
"BREAKPOINT_FOLLOWON=$disp | RUN_ID=$RunId EXIT=$exit | CAND=$($sha.Substring(0,8))… tip748B=$tipMatch | GUI_SURVIVAL=$($cells['GUI_SURVIVAL']) | KILLER=$killer | PROMOTE=0 | NEXT=$nextPri" |
  Set-Content (Join-Path $Seal "RETURN_LINE.txt")

exit $exit
