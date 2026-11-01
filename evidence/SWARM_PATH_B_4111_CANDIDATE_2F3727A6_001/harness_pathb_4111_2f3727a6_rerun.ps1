# PathB 4111 COMPLETE prove on 2F3727A6 — no stdout/stderr redirect (GUI). Tip untouched.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001"
$Logs = Join-Path $OutDir "logs"
$DumpHook = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CRASH_ROOT_001\dumps"
New-Item -ItemType Directory -Force -Path $Logs,$DumpHook | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "2F3727A6CD8EFF4E934E45C51494B926489FFAD1BC5430B072F3D5BAEE0007C2"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Log = Join-Path $OutDir "RUNLOG_rerun.txt"
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}
function ExitHex([object]$c) {
  if ($null -eq $c) { return "UNSET" }
  return ("0x{0:X8}" -f [uint32]([int]$c -band 0xFFFFFFFF))
}

$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class PathB2FRerun {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
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
  public static int SendId(IntPtr h, int id, uint timeoutMs, out long result, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0111, (IntPtr)id, IntPtr.Zero, 0x0002, timeoutMs, out r);
    result = r.ToInt64();
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
  public static int PingNull(IntPtr h, uint timeoutMs, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, timeoutMs, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "RERUN PRE_HASH CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001
RUN=RERUN_NO_REDIRECT
DISPOSITION=FAIL_CLOSED_SHA_DRIFT
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
RUNTIME_PASS=0
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
  exit 2
}

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
if (Test-Path $crumb) { Remove-Item $crumb -Force }
$tracePath = Join-Path $CandDir "win32ide_trace.log"
if (Test-Path $tracePath) { Remove-Item $tracePath -Force }
$startupLog = Join-Path $CandDir "ide_startup.log"
if (Test-Path $startupLog) { Remove-Item $startupLog -Force }

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "2"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

WLog "LAUNCH GUI no-redirect N=2"
# NO RedirectStandard* — GUI subsystem breaks / early-exit with pipes
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$exitCode = $null
$exitCaptured = 0
$postOk = 0; $sendOk = 0; $sendTimedOut = 0; $sendResult = 0; $post1001 = 0
$postedAt = ""
$deadline = (Get-Date).AddSeconds(25)
while ((Get-Date) -lt $deadline) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
    WLog ("EARLY_EXIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_" + (ExitHex $exitCode) }
    break
  }
  $hwnd = [PathB2FRerun]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [PathB2FRerun]::MenuReady($hwnd)
    if ($postOk -eq 0) {
      # Immediate Post (retry2 pattern) — do not wait for menu beyond HWND
      $post1001 = [PathB2FRerun]::PostId($hwnd, 1001)
      $postOk = [PathB2FRerun]::PostId($hwnd, 4111)
      $postedAt = (Get-Date).ToString("o")
      WLog ("IMMEDIATE_POST hwnd=0x{0:X} post1001={1} post4111={2} menuReady={3}" -f $hwnd.ToInt64(), $post1001, $postOk, [int]$menuReady)
      Start-Sleep -Milliseconds 800
      if (-not $p.HasExited) {
        $sr = 0L; $to = 0
        $sendOk = [PathB2FRerun]::SendId($hwnd, 4111, 3000, [ref]$sr, [ref]$to)
        $sendResult = $sr; $sendTimedOut = $to
        WLog ("SEND4111 ok={0} timedOut={1} result={2}" -f $sendOk, $sendTimedOut, $sendResult)
      } else {
        $exitCode = [int]$p.ExitCode
        $exitCaptured = 1
        WLog ("EXIT_BEFORE_SEND {0}" -f (ExitHex $exitCode))
      }
    }
    if ($menuReady) { $createWindow = "OK_HWND_MENU_READY"; break }
  }
  Start-Sleep -Milliseconds 40
}

# Swarm wait — GUI executeSwarm is detached; timeoutMs hardcoded 60000 in product
$swarmDeadline = (Get-Date).AddSeconds(150)
$sawEnter = $false
$sawReturn = $false
while ((Get-Date) -lt $swarmDeadline) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
    WLog ("EXIT_DURING_WAIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    break
  }
  if ($hwnd -ne [IntPtr]::Zero -and [PathB2FRerun]::MenuReady($hwnd)) {
    $menuReady = $true
    if ($createWindow -match "^OK_HWND") { $createWindow = "OK_HWND_MENU_READY" }
  }
  $live = ""
  if (Test-Path $crumb) { $live += (Get-Content $crumb -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $tracePath) { $live += "`n" + (Get-Content $tracePath -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $startupLog) { $live += "`n" + (Get-Content $startupLog -Raw -ErrorAction SilentlyContinue) }
  if ($live -match "onSubAgentSwarm_BEFORE_executeSwarm|executeSwarm_RUNTIME=1") { $sawEnter = $true }
  if ($live -match "Swarm complete|HexMag Swarm completed|Swarm FAIL_CLOSED|executeSwarm DONE") { $sawReturn = $true }
  if ($sawEnter -and $sawReturn) {
    WLog "SWARM_RETURN_WITNESSED"
    Start-Sleep -Seconds 4
    break
  }
  # Early exit wait if enter seen + long enough for 2x60s budgets
  Start-Sleep -Milliseconds 750
}

$guiResponsive = 0
$pingTo = 1
if (-not $p.HasExited -and $hwnd -ne [IntPtr]::Zero -and [PathB2FRerun]::IsWindow($hwnd)) {
  $pingOk = [PathB2FRerun]::PingNull($hwnd, 2000, [ref]$pingTo)
  if ($pingOk -eq 1 -and $pingTo -eq 0) { $guiResponsive = 1 }
  WLog ("GUI_PING ok={0} timedOut={1}" -f $pingOk, $pingTo)
}

$forcedStop = 0
if (-not $p.HasExited) {
  WLog "WM_CLOSE then wait pid=$($p.Id)"
  [void][PathB2FRerun]::PostMessageW($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
  $closeDeadline = (Get-Date).AddSeconds(10)
  while ((Get-Date) -lt $closeDeadline) {
    try { $p.Refresh() } catch {}
    if ($p.HasExited) {
      $exitCode = [int]$p.ExitCode
      $exitCaptured = 1
      break
    }
    Start-Sleep -Milliseconds 200
  }
  if (-not $p.HasExited) {
    $forcedStop = 1
    WLog "FORCE_STOP"
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    try { $p.Refresh() } catch {}
    if ($p.HasExited) {
      $exitCode = [int]$p.ExitCode
      $exitCaptured = 1
    }
  }
}

# Final exit capture — never leave empty
if ($exitCaptured -eq 0) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
  } else {
    $exitCode = -1
    $exitCaptured = 1
    WLog "EXIT_UNOBTAINABLE set -1"
  }
}
$exitHex = ExitHex $exitCode
WLog ("FINAL_EXIT dec={0} hex={1} captured={2} forced={3}" -f $exitCode, $exitHex, $exitCaptured, $forcedStop)

$traceText = ""
if (Test-Path $tracePath) {
  $traceText = Get-Content $tracePath -Raw -ErrorAction SilentlyContinue
  Copy-Item $tracePath (Join-Path $Logs "win32ide_trace_rerun.log") -Force
  if ($traceText -match "createWindow_RETURN_TRUE") {
    if ($createWindow -match "^OK_HWND") { $createWindow = "OK_RETURN_TRUE" }
    elseif ($createWindow -eq "NOT_RUN") { $createWindow = "OK_RETURN_TRUE" }
  }
}

$crashed = $false
$u = [uint32]([int]$exitCode -band 0xFFFFFFFF)
if ($u -eq 0xC0000005 -or $u -eq 0xC0000409 -or $u -eq 0xC0000374 -or ([int]$exitCode -lt 0 -and [int]$exitCode -ne -1)) {
  # negative NTSTATUS as signed
  if ($u -ge 0xC0000000) { $crashed = $true }
}
if ($u -eq 0xC0000005) { $createWindow = "$createWindow+CRASH_C0000005" }
elseif ($u -eq 0xC0000409) { $createWindow = "$createWindow+CRASH_C0000409" }
elseif ($u -eq 0xC0000374) { $createWindow = "$createWindow+CRASH_C0000374" }

$crumbText = ""
if (Test-Path $crumb) {
  $crumbText = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
  Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB_rerun.txt") -Force
}
if (Test-Path $startupLog) {
  Copy-Item $startupLog (Join-Path $Logs "ide_startup_rerun.log") -Force
}

$cmd4111 = ([regex]::Matches($crumbText, "id=4111 ")).Count
$cmd1001 = ([regex]::Matches($crumbText, "id=1001 ")).Count
$steps4111 = @()
foreach ($m in [regex]::Matches($crumbText, "id=4111 step=([^\s\r\n]+)")) {
  $steps4111 += $m.Groups[1].Value
}
$steps4111Unique = ($steps4111 | Select-Object -Unique) -join ","
$vehFatal = ([regex]::Matches($crumbText, "VEH_FATAL")).Count

$blob = $crumbText + "`n" + $traceText
if (Test-Path $startupLog) { $blob += "`n" + (Get-Content $startupLog -Raw -ErrorAction SilentlyContinue) }

$onInv = "NOT_OBSERVED"
if ($blob -match "onSubAgentSwarm|Starting HexMag swarm|HexMag swarm N=") { $onInv = "OBSERVED" }
$resolveObs = "NOT_OBSERVED"
if ($blob -match "resolveSwarmModelOrchPlan") { $resolveObs = "OBSERVED" }

$execEnter = "0"
if ($blob -match "onSubAgentSwarm_BEFORE_executeSwarm|executeSwarm_RUNTIME=1") { $execEnter = "1" }
$execReturn = "0"
$afterLiteral = "0"
if ($blob -match "AFTER_executeSwarm|onSubAgentSwarm_AFTER_executeSwarm") { $afterLiteral = "1"; $execReturn = "1" }
if ($blob -match "Swarm complete \(merged result\)|HexMag Swarm completed|Swarm FAIL_CLOSED: empty merge|\[SWARM_ORCH\] executeSwarm DONE") {
  $execReturn = "1"
}

$taskCount = 0
if ($blob -match "executeSwarm_RUNTIME=1 taskCount=(\d+)") { $taskCount = [int]$Matches[1] }
elseif ($blob -match "HexMag swarm N=(\d+)") { $taskCount = [int]$Matches[1] }
elseif ($blob -match "resolveSwarmModelOrchPlan_RUNTIME=1 taskCount=(\d+)") { $taskCount = [int]$Matches[1] }

$completed = 0
$timedOut = 0
$failed = 0
if ($blob -match "completed=(\d+)") { $completed = [int]$Matches[1] }
if ($blob -match "timed_out=(\d+)") { $timedOut = [int]$Matches[1] }
elseif ($blob -match "state=timed_out|TimedOut") { $timedOut = 1 }
if ($blob -match "failed=(\d+)") { $failed = [int]$Matches[1] }

$runtimeReached = "0"
if ($onInv -eq "OBSERVED" -or $cmd4111 -gt 0) { $runtimeReached = "1" }

$exitClean = 0
if ([int]$exitCode -eq 0 -and -not $crashed) { $exitClean = 1 }

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$shaMatch = [int]($candSha -eq $ExpectCand)
$candStable = [int]($candAfter -eq $ExpectCand -and $candAfter -eq $candSha)
$tipUntouched = [int]($tipAfter -eq $ExpectTip)
$cmdObs = [int]($cmd4111 -gt 0)

$pass = 0
if ($shaMatch -eq 1 -and $candStable -eq 1 -and $tipUntouched -eq 1 -and $cmdObs -eq 1 `
    -and $execEnter -eq "1" -and $execReturn -eq "1" `
    -and $completed -ge 2 -and $timedOut -eq 0 `
    -and $exitClean -eq 1 -and $guiResponsive -eq 1 -and -not $crashed) {
  $pass = 1
}

$disposition = "FAIL_CLOSED"
$rootCause = "ACCEPTANCE_INCOMPLETE"
if ($pass -eq 1) {
  $disposition = "PATH_B_4111_RUNTIME_PASS"
  $rootCause = "ALL_ACCEPTANCE_MET"
} elseif ($crashed) {
  $disposition = "PATH_B_CMD_DIAG_ORCH_THEN_CRASH"
  $rootCause = "CRASH_$exitHex"
} elseif ($cmdObs -eq 1 -and $execEnter -eq "1" -and $execReturn -eq "0") {
  $disposition = "PATH_B_EXECUTE_SWARM_ENTER_NO_RETURN"
  $rootCause = "BEFORE_ONLY_OR_NO_RETURN_WITNESS"
} elseif ($cmdObs -eq 1 -and $onInv -eq "OBSERVED") {
  $disposition = "PATH_B_RUNTIME_REACHED_ACCEPTANCE_OPEN"
  $rootCause = "PARTIAL_WITNESS"
} elseif ($cmdObs -eq 0) {
  $disposition = "FAIL_CLOSED_CMD_DIAG_MISS"
  $rootCause = "NO_CMD_DIAG_4111"
}

$dumpStandby = 0
if ([int]$exitCode -ne 0 -or $crashed) {
  $dumpStandby = 1
  @"
DUMP_STANDBY=1
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
CANDIDATE_SHA=$candSha
EXIT_CODE_DEC=$exitCode
EXIT_HEX=$exitHex
CRASHED=$([int]$crashed)
PID_WAS=$($p.Id)
NOTE=Crash-root standby dump/instrument on 2F3727A6 only. No rebuild. PathB PASS=0.
"@ | Set-Content (Join-Path $DumpHook "STANDBY_REQUEST_2F3727A6.txt")
}

# Preserve interim as SUMMARY_interim.txt if present
$summaryPath = Join-Path $OutDir "SUMMARY.txt"
if (Test-Path $summaryPath) {
  Copy-Item $summaryPath (Join-Path $OutDir "SUMMARY_interim_run1.txt") -Force
}

@"
GATE=SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001
RUN=RERUN_NO_REDIRECT_IMMEDIATE_POST
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
AUTHORITY_EXE=$CandExe
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candAfter
CANDIDATE_SHA_MATCH=$shaMatch
CANDIDATE_SHA_STABLE=$candStable
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipAfter
TIP_UNTOUCHED=$tipUntouched
createWindow=$createWindow
MAIN_HWND=0x$('{0:X}' -f $hwnd.ToInt64())
MENU_READY=$([int]$menuReady)
EXIT_CODE_DEC=$exitCode
EXIT_CODE=$exitCode
EXIT_HEX=$exitHex
EXIT_CAPTURED=$exitCaptured
EXIT_CLEAN=$exitClean
FORCED_STOP=$forcedStop
POSTED_AT=$postedAt
POSTMESSAGE_1001=$post1001
POSTMESSAGE_WM_COMMAND_4111=$postOk
SENDMESSAGETIMEOUT_WM_COMMAND_4111=$sendOk
SEND_TIMED_OUT=$sendTimedOut
CMD_DIAG_id_1001=$cmd1001
CMD_DIAG_id_4111=$cmd4111
CMD_DIAG_4111_OBSERVED=$cmdObs
CMD_DIAG_4111_STEPS=$steps4111Unique
VEH_FATAL_COUNT=$vehFatal
onSubAgentSwarm=$onInv
resolveSwarmModelOrchPlan=$resolveObs
EXECUTE_SWARM_ENTER=$execEnter
EXECUTE_SWARM_RETURN=$execReturn
AFTER_executeSwarm_LITERAL=$afterLiteral
AFTER_executeSwarm_PRODUCT_RETURN=$execReturn
taskCount=$taskCount
COMPLETED=$completed
TIMED_OUT=$timedOut
FAILED=$failed
GUI_RESPONSIVE=$guiResponsive
DUMP_STANDBY=$dumpStandby
RUNTIME_REACHED=$runtimeReached
RUNTIME_PASS=$pass
DISPOSITION=$disposition
ROOT_CAUSE=$rootCause
ABSORB=NOT_AUTHORIZED
GHOSTTEXT_ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
REBUILD_TIP=0
NO_INVENT_PASS=1
N2_HEADLESS_TRANSFER_PASS=0
HISTORICAL_99EB54F2=forensic_only
HANDOFF_CITE=evidence/SWARM_PATH_B_4111_CRASH_ROOT_001/HANDOFF_ALIGNMENT_CONFIRMED.txt
INTERIM_RUN1=FAIL_CLOSED_CMD_DIAG_MISS (redirect pipes; superseded by this rerun)
"@ | Set-Content $summaryPath

WLog "DISPOSITION=$disposition CMD_DIAG=$cmd4111 ENTER=$execEnter RETURN=$execReturn COMPLETED=$completed TIMED_OUT=$timedOut EXIT=$exitHex/$exitCode GUI_RESPONSIVE=$guiResponsive RUNTIME_PASS=$pass"
exit 0
