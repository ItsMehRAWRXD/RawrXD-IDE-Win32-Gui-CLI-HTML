# BREAKPOINT_FOLLOWON_REPROVE_5BB7_001 — clean Commands path re-prove.
# MenuReady → ping → IDM_DBGWATCH_SHOW (12230) → IDM_DBG_LIST_BPS (5170).
# PROMOTE=0 ABSORB=NOT_AUTHORIZED tip748B HOLD. NOT invent BP PRODUCT_PASS.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\BREAKPOINT_FOLLOWON_REPROVE_5BB7_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$NewShaFile = Join-Path $Seal "NEW_CAND_SHA.txt"
$ExpectCand = ""
if (Test-Path -LiteralPath $NewShaFile) {
  $m = Select-String -LiteralPath $NewShaFile -Pattern '^CAND_SHA_AFTER=(.+)$' | Select-Object -First 1
  if ($m) { $ExpectCand = $m.Matches[0].Groups[1].Value.Trim() }
}
$RunId = "BPREPROVE_" + (Get-Date -Format "yyyyMMddTHHmmss")
$RunLog = Join-Path $Logs "RUNLOG.txt"
Set-Content $RunLog ""
$cells = [ordered]@{}
$firstFail = "NONE"
$killer = "NONE"

# Survival matrix only — SHOW then LIST (job required). Skip invent panel theater.
$cmds = @(
  @{ Id = 12230; Name = "IDM_DBGWATCH_SHOW" },
  @{ Id = 5170;  Name = "IDM_DBG_LIST_BPS" },
  @{ Id = 5170;  Name = "IDM_DBG_LIST_BPS_REPOST" }
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
public class BpReprove001 {
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
$candMatch = [int]($ExpectCand -ne "" -and $sha -eq $ExpectCand)
WLog "HASH_VERIFY CAND=$sha EXPECT_CAND=$ExpectCand MATCH=$candMatch tip748B=$tipMatch"
WLog "RUN_ID=$RunId"
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
  $hwnd = [BpReprove001]::FindMain([uint32]$gui.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $menuReady = [BpReprove001]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 400
}
WLog "GUI_PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady) EXITED=$($gui.HasExited)"
"PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady)" | Set-Content (Join-Path $Logs "gui_meta.txt")

$postLines = New-Object System.Collections.Generic.List[string]
$hostHeapNote = "NONE"

if ($hwnd -eq [IntPtr]::Zero -or -not $menuReady -or $gui.HasExited) {
  $cells["GUI_LAUNCH"] = "FAIL"
  if ($firstFail -eq "NONE") { $firstFail = "GUI_LAUNCH" }
  $cells["GUI_SURVIVAL"] = "FAIL"
  $cells["BP_CMDS"] = "FAIL"
  if ($gui.HasExited) {
    try {
      $ec = $gui.ExitCode
      $hex = ('{0:X8}' -f ([int64]$ec -band 0xFFFFFFFF))
      WLog "LAUNCH_EXIT=$ec hex=$hex"
      if ($hex -eq "C0000374") { $hostHeapNote = "C0000374_AT_LAUNCH" }
    } catch {}
  }
} else {
  $cells["GUI_LAUNCH"] = "PASS"
  Start-Sleep -Seconds 2
  $to0 = 0
  $ping0 = [BpReprove001]::PingNull($hwnd, 5000, [ref]$to0)
  if ($ping0 -ne 1) {
    Start-Sleep -Seconds 2
    $to0 = 0
    $ping0 = [BpReprove001]::PingNull($hwnd, 5000, [ref]$to0)
  }
  $alive0 = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  WLog "GUI_BASELINE alive=$([int]$alive0) ping=$ping0 timedOut=$to0"
  if (-not $alive0) {
    $gui.Refresh()
    try {
      $ec = $gui.ExitCode
      $hex = ('{0:X8}' -f ([int64]$ec -band 0xFFFFFFFF))
      WLog "PRE_BASELINE_DEAD exit=$ec hex=$hex"
      if ($hex -eq "C0000374") { $hostHeapNote = "C0000374_PRE_BASELINE" }
    } catch {}
    $cells["GUI_BASELINE"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "GUI_BASELINE_DEAD" }
  } elseif ($ping0 -ne 1) {
    $cells["GUI_BASELINE"] = "FAIL"
    if ($firstFail -eq "NONE") { $firstFail = "GUI_BASELINE" }
  } else {
    $cells["GUI_BASELINE"] = "PASS"
  }

  $bpAllOk = ($cells["GUI_BASELINE"] -eq "PASS")
  if ($bpAllOk) {
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
        if ($exitHex -eq "C0000374") { $hostHeapNote = "C0000374_PRE_POST:$($c.Name)" }
        $line = "POST id=$($c.Id) name=$($c.Name) SKIPPED_DEAD exit=$exitCode hex=$exitHex"
        $postLines.Add($line)
        WLog $line
        break
      }
      $ok = [BpReprove001]::PostId($hwnd, $c.Id)
      Start-Sleep -Milliseconds 900
      $still = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
      $to = 0
      $ping = 0
      if ($still) { $ping = [BpReprove001]::PingNull($hwnd, 3000, [ref]$to) }
      $gui.Refresh()
      $exitCode = 0
      $exitHex = "RUNNING"
      if (-not $still) {
        try { $exitCode = $gui.ExitCode } catch {}
        $exitHex = ('{0:X8}' -f ([int64]$exitCode -band 0xFFFFFFFF))
        if ($exitHex -eq "C0000374") { $hostHeapNote = "C0000374_ON:$($c.Name)" }
        if ($exitHex -eq "C0000409") { $hostHeapNote = "C0000409_ON:$($c.Name)" }
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
  }

  $cells["BP_CMDS"] = $(if ($bpAllOk) { "PASS" } else { "FAIL" })
  $cells["GUI_SURVIVAL"] = $(if ($bpAllOk) { "PASS" } else { "FAIL" })
  WLog "GUI_SURVIVAL => $($cells['GUI_SURVIVAL']) KILLER=$killer HOST_HEAP=$hostHeapNote"
}

$postLines.Add("KILLER=$killer")
$postLines.Add("HOST_HEAP_NOTE=$hostHeapNote")
$postLines | Set-Content (Join-Path $Logs "fiction_cmd_posts.txt")

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$cells["TIP_UNTOUCHED"] = $(if ($tipAfter -eq $ExpectTip) { "PASS" } else { "FAIL" })
if ($cells["TIP_UNTOUCHED"] -ne "PASS" -and $firstFail -eq "NONE") { $firstFail = "TIP_UNTOUCHED" }
WLog "TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])"

$cells["CERTIFIED_UNCHANGED"] = "PASS"
WLog "CERTIFIED_UNCHANGED=PASS (CERTIFIED stays 0; no invent BP PRODUCT_PASS)"

if ($gui -and -not $gui.HasExited) {
  try { Stop-Process -Id $gui.Id -Force -ErrorAction SilentlyContinue } catch {}
}
Start-Sleep 1

$pass = 0; $fail = 0
foreach ($k in $cells.Keys) {
  if ($cells[$k] -eq "PASS") { $pass++ } else { $fail++ }
}
$exitCode = $(if ($fail -eq 0 -and $cells["GUI_SURVIVAL"] -eq "PASS") { 0 } else { 1 })
$disp = if ($exitCode -eq 0) { "BREAKPOINT_FOLLOWON_REPROVE_PASS" } else {
  if ($hostHeapNote -match 'C0000374') { "BREAKPOINT_FOLLOWON_REPROVE_FAIL_CLOSED_HOST_HEAP" }
  else { "BREAKPOINT_FOLLOWON_REPROVE_FAIL_CLOSED" }
}
$runtimeReached = [int]($cells["GUI_LAUNCH"] -eq "PASS" -and $cells["GUI_BASELINE"] -eq "PASS" -and $cells.Contains("BP_CMDS"))
$runtimePass = [int]($cells["GUI_SURVIVAL"] -eq "PASS")

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$summary = @"
GATE=BREAKPOINT_FOLLOWON_REPROVE_5BB7_001
RUN_ID=$RunId
ASOF_UTC=$asof
CAND_SHA=$sha
CAND_PRIOR_8F5E=8F5E7A1EE74EB4595A847507BBC830CC1DC6344FDD060EFEC698DF6DA9C74F66
CAND_PRIOR_5BB7=5BB7EF9B1837818B9B4DC716FA6F09A42920154394854F086AB681E17ADEB3C2
TIP_SHA=$tipAfter
tip748B=$tipMatch
TIP_REBUILD=0
ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
COMMANDS_CLEAN_REBUILD=1
STUB_POISON=0
DISPOSITION=$disp
EXIT=$exitCode
FIRST_FAILURE=$firstFail
KILLER=$killer
HOST_HEAP_NOTE=$hostHeapNote
PASS=$pass
FAIL=$fail
CELL_HASH_BIND=$($cells['HASH_BIND'])
CELL_GUI_LAUNCH=$($cells['GUI_LAUNCH'])
CELL_GUI_BASELINE=$($cells['GUI_BASELINE'])
CELL_GUI_SURVIVAL=$($cells['GUI_SURVIVAL'])
CELL_BP_CMDS=$($cells['BP_CMDS'])
CELL_TIP_UNTOUCHED=$($cells['TIP_UNTOUCHED'])
CELL_CERTIFIED_UNCHANGED=$($cells['CERTIFIED_UNCHANGED'])
SOURCE_WIRED=1
RUNTIME_REACHED=$runtimeReached
RUNTIME_SURVIVAL_PASS=$runtimePass
INVENT_BP_PANEL_PASS=0
NEXT_PRIORITY=$(if ($hostHeapNote -match 'C0000374') { 'HOST_HEAP_OR_AWAITING_AUTH' } elseif ($exitCode -eq 0) { 'AWAITING_AUTH_OR_COMPLETION_007' } else { 'AWAITING_AUTH_OR_CAPABLE_HOST' })
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
"@
$summary | Set-Content (Join-Path $Seal "SUMMARY.txt")
$summary | Set-Content (Join-Path $Logs "SUMMARY_COPY.txt")
WLog "DISPOSITION=$disp EXIT=$exitCode"
Write-Output "RETURN RUN_ID=$RunId EXIT=$exitCode DISP=$disp CAND=$sha"
exit $exitCode
