# PathB WM_COMMAND 4111 prove on candidate 2F3727A6 only. Tip 748B untouched. PROMOTE=0.
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
$Log = Join-Path $OutDir "RUNLOG.txt"
$ErrLog = Join-Path $Logs "stderr.txt"
$OutLog = Join-Path $Logs "stdout.txt"
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}
function ExitHex([int]$c) {
  if ($null -eq $c) { return "" }
  return ("0x{0:X8}" -f [uint32]($c -band 0xFFFFFFFF))
}

$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class PathBCand2F {
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
  // WM_NULL ping for GUI responsive
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
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001
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
if (Test-Path $ErrLog) { Remove-Item $ErrLog -Force }
if (Test-Path $OutLog) { Remove-Item $OutLog -Force }

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "2"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

WLog "LAUNCH candidate GUI PathB_4111 N=2 maxParallel=2 SHA=2F3727A6"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal `
  -RedirectStandardError $ErrLog -RedirectStandardOutput $OutLog
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$exitCode = $null
$postOk = 0; $sendOk = 0; $sendTimedOut = 0; $sendResult = 0; $post1001 = 0
$postedAt = ""
$deadline = (Get-Date).AddSeconds(30)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) {
    $exitCode = $p.ExitCode
    WLog ("EARLY_EXIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_" + (ExitHex $exitCode) }
    break
  }
  $hwnd = [PathBCand2F]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [PathBCand2F]::MenuReady($hwnd)
    if ($postOk -eq 0 -and $menuReady) {
      $post1001 = [PathBCand2F]::PostId($hwnd, 1001)
      Start-Sleep -Milliseconds 400
      $postOk = [PathBCand2F]::PostId($hwnd, 4111)
      $postedAt = (Get-Date).ToString("o")
      WLog ("POST hwnd=0x{0:X} post1001={1} post4111={2} menuReady=1" -f $hwnd.ToInt64(), $post1001, $postOk)
      Start-Sleep -Milliseconds 500
      if (-not $p.HasExited) {
        $sr = 0L; $to = 0
        # Short Send only to confirm dispatch; swarm runs async detached
        $sendOk = [PathBCand2F]::SendId($hwnd, 4111, 2000, [ref]$sr, [ref]$to)
        $sendResult = $sr; $sendTimedOut = $to
        WLog ("SEND4111 ok={0} timedOut={1} result={2}" -f $sendOk, $sendTimedOut, $sendResult)
      }
      $createWindow = "OK_HWND_MENU_READY"
      break
    }
  }
  Start-Sleep -Milliseconds 50
}

# Wait for swarm completion witnesses (N=2 serialized can exceed 60s+60s)
# GUI path hardcodes timeoutMs=60000 per worker clock; wait wall for BOTH + UI settle
$swarmDeadline = (Get-Date).AddSeconds(180)
$sawEnter = $false
$sawReturn = $false
$completedHint = 0
$timedOutHint = 0
while ((Get-Date) -lt $swarmDeadline) {
  if ($p.HasExited) {
    $exitCode = $p.ExitCode
    WLog ("EXIT_DURING_SWARM_WAIT {0}" -f (ExitHex $exitCode))
    break
  }
  $blobParts = @()
  if (Test-Path $crumb) { $blobParts += (Get-Content $crumb -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $ErrLog) { $blobParts += (Get-Content $ErrLog -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $OutLog) { $blobParts += (Get-Content $OutLog -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $tracePath) { $blobParts += (Get-Content $tracePath -Raw -ErrorAction SilentlyContinue) }
  if (Test-Path $startupLog) { $blobParts += (Get-Content $startupLog -Raw -ErrorAction SilentlyContinue) }
  $live = ($blobParts -join "`n")
  if ($live -match "onSubAgentSwarm_BEFORE_executeSwarm|executeSwarm_RUNTIME=1") { $sawEnter = $true }
  if ($live -match "Swarm complete|HexMag Swarm completed|Swarm FAIL_CLOSED|executeSwarm DONE|swarms_completed") { $sawReturn = $true }
  if ($live -match "completed=(\d+)") {
    try { $completedHint = [int]$Matches[1] } catch {}
  }
  if ($live -match "timed_out=(\d+)|TimedOut") {
    if ($live -match "timed_out=(\d+)") { try { $timedOutHint = [int]$Matches[1] } catch {} }
  }
  if ($sawEnter -and $sawReturn) {
    WLog "SWARM_RETURN_WITNESSED enter=1 return=1"
    Start-Sleep -Seconds 3
    break
  }
  Start-Sleep -Milliseconds 750
}

# GUI responsive after wait (or after return)
$guiResponsive = 0
$pingTo = 1
if (-not $p.HasExited -and $hwnd -ne [IntPtr]::Zero -and [PathBCand2F]::IsWindow($hwnd)) {
  $pingOk = [PathBCand2F]::PingNull($hwnd, 2000, [ref]$pingTo)
  if ($pingOk -eq 1 -and $pingTo -eq 0) { $guiResponsive = 1 }
  WLog ("GUI_PING ok={0} timedOut={1} visible={2}" -f $pingOk, $pingTo, [int][PathBCand2F]::IsWindowVisible($hwnd))
}

if (-not $p.HasExited) {
  WLog "STOP_ALIVE_AFTER_WAIT pid=$($p.Id) guiResponsive=$guiResponsive"
  # graceful close attempt via WM_CLOSE then force
  [void][PathBCand2F]::PostMessageW($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
  $closeDeadline = (Get-Date).AddSeconds(8)
  while ((Get-Date) -lt $closeDeadline -and -not $p.HasExited) { Start-Sleep -Milliseconds 200 }
  if (-not $p.HasExited) {
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep 1
  }
  try { $p.Refresh() } catch {}
  if ($p.HasExited) { $exitCode = $p.ExitCode }
} else {
  WLog ("EXIT_CODE={0} {1}" -f $exitCode, (ExitHex $exitCode))
}

$traceText = ""
if (Test-Path $tracePath) {
  $traceText = Get-Content $tracePath -Raw -ErrorAction SilentlyContinue
  Copy-Item $tracePath (Join-Path $Logs "win32ide_trace.log") -Force
  if ($traceText -match "createWindow_RETURN_TRUE") {
    if ($createWindow -match "^OK_HWND") { $createWindow = "OK_RETURN_TRUE" }
    elseif ($createWindow -eq "NOT_RUN") { $createWindow = "OK_RETURN_TRUE" }
  }
}
$exitHex = if ($null -ne $exitCode) { ExitHex $exitCode } else { "" }
$crashed = $false
if ($null -ne $exitCode) {
  $u = [uint32]($exitCode -band 0xFFFFFFFF)
  if ($u -eq 0xC0000005 -or $u -eq 0xC0000409 -or $u -eq 0xC0000374 -or ($exitCode -ne 0 -and $exitCode -lt 0)) {
    $crashed = $true
    if ($u -eq 0xC0000005) { $createWindow = "$createWindow+CRASH_C0000005" }
    elseif ($u -eq 0xC0000409) { $createWindow = "$createWindow+CRASH_C0000409" }
    elseif ($u -eq 0xC0000374) { $createWindow = "$createWindow+CRASH_C0000374" }
  }
}

$crumbText = ""
if (Test-Path $crumb) {
  $crumbText = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
  Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB.txt") -Force
}
if (Test-Path $startupLog) {
  Copy-Item $startupLog (Join-Path $Logs "ide_startup.log") -Force
}

$errText = ""
$outText = ""
if (Test-Path $ErrLog) { $errText = Get-Content $ErrLog -Raw -ErrorAction SilentlyContinue }
if (Test-Path $OutLog) { $outText = Get-Content $OutLog -Raw -ErrorAction SilentlyContinue }

$cmd4111 = ([regex]::Matches($crumbText, "id=4111 ")).Count
$cmd1001 = ([regex]::Matches($crumbText, "id=1001 ")).Count
$steps4111 = @()
foreach ($m in [regex]::Matches($crumbText, "id=4111 step=([^\s\r\n]+)")) {
  $steps4111 += $m.Groups[1].Value
}
$steps4111Unique = ($steps4111 | Select-Object -Unique) -join ","
$vehFatal = ([regex]::Matches($crumbText, "VEH_FATAL")).Count

$blob = $crumbText + "`n" + $traceText + "`n" + $errText + "`n" + $outText
if (Test-Path $startupLog) { $blob += "`n" + (Get-Content $startupLog -Raw -ErrorAction SilentlyContinue) }

$onInv = "NOT_OBSERVED"
if ($blob -match "onSubAgentSwarm|Starting HexMag swarm|HexMag swarm N=|SubAgentManager not initialized|No editor content for swarm") {
  $onInv = "OBSERVED"
}
$resolveObs = "NOT_OBSERVED"
if ($blob -match "resolveSwarmModelOrchPlan") { $resolveObs = "OBSERVED" }

$execEnter = "0"
if ($blob -match "onSubAgentSwarm_BEFORE_executeSwarm|executeSwarm_RUNTIME=1") { $execEnter = "1" }

# Literal AFTER crumb absent in frozen candidate; product return = executeSwarm returned
$execReturn = "0"
$afterLiteral = "0"
if ($blob -match "AFTER_executeSwarm|onSubAgentSwarm_AFTER_executeSwarm") { $afterLiteral = "1"; $execReturn = "1" }
if ($blob -match "Swarm complete \(merged result\)|HexMag Swarm completed|Swarm FAIL_CLOSED: empty merge|\[SWARM_ORCH\] executeSwarm DONE") {
  $execReturn = "1"
}

# Worker receipts from stderr/logs (best-effort)
$taskCount = 0
if ($blob -match "executeSwarm_RUNTIME=1 taskCount=(\d+)") { $taskCount = [int]$Matches[1] }
elseif ($blob -match "HexMag swarm N=(\d+)") { $taskCount = [int]$Matches[1] }
elseif ($blob -match "resolveSwarmModelOrchPlan_RUNTIME=1 taskCount=(\d+)") { $taskCount = [int]$Matches[1] }

$completed = 0
$timedOut = -1
$failed = -1
if ($blob -match "completed=(\d+)") { $completed = [int]$Matches[1] }
if ($blob -match "timed_out=(\d+)") { $timedOut = [int]$Matches[1] }
if ($blob -match "failed=(\d+)") { $failed = [int]$Matches[1] }
# Alternate: count worker completed lines
$workerDone = ([regex]::Matches($blob, "state=completed|swarm_tasks_completed|worker.*completed")).Count
if ($completed -eq 0 -and $workerDone -gt 0) { $completed = $workerDone }
if ($timedOut -lt 0) {
  if ($blob -match "TimedOut|timed out|state=timed_out") { $timedOut = 1 } else { $timedOut = 0 }
}

# If return witnessed with Swarm complete and N=2 requested, infer completed=taskCount only when return + no timeout language
if ($execReturn -eq "1" -and $blob -match "Swarm complete \(merged result\)" -and $taskCount -ge 2 -and $timedOut -eq 0 -and $completed -lt $taskCount) {
  # Do NOT invent completed=2 from merge alone without receipts — leave measured
  $completedNote = "MERGE_SEEN_COMPLETED_COUNT_UNMEASURED"
} else {
  $completedNote = ""
}

$runtimeReached = "0"
if ($onInv -eq "OBSERVED" -or $cmd4111 -gt 0) { $runtimeReached = "1" }

# Clean EXIT: process ended 0, or we force-stopped after success (treat force-stop as EXIT_FORCED if previously alive)
$exitClean = 0
if ($null -ne $exitCode -and $exitCode -eq 0 -and -not $crashed) { $exitClean = 1 }

# If we force-killed after GUI responsive + swarm return, EXIT may be non-zero from Stop-Process
# Acceptance requires EXIT_CODE=0 — force-kill fails that unless process self-exited 0
$forcedStop = 0
if ($exitHex -eq "0x00000001" -or ($null -ne $exitCode -and $exitCode -ne 0 -and -not $crashed -and $guiResponsive -eq 1)) {
  # likely Stop-Process after success path
  $forcedStop = 1
}

$shaMatch = [int]($candSha -eq $ExpectCand)
$tipUntouchedPre = [int]($tipSha -eq $ExpectTip)

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$candStable = [int]($candAfter -eq $ExpectCand -and $candAfter -eq $candSha)
$tipUntouched = [int]($tipAfter -eq $ExpectTip)

# Acceptance conjunction
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
  $rootCause = "BEFORE_ONLY_OR_TIMEOUT"
} elseif ($cmdObs -eq 1 -and $onInv -eq "OBSERVED") {
  $disposition = "PATH_B_RUNTIME_REACHED_ACCEPTANCE_OPEN"
  $rootCause = "PARTIAL_WITNESS"
} elseif ($cmdObs -eq 0) {
  $disposition = "FAIL_CLOSED_CMD_DIAG_MISS"
  $rootCause = "NO_CMD_DIAG_4111"
}

# Crash-root dump hook marker if EXIT != 0
$dumpStandby = 0
if ($null -ne $exitCode -and ($exitCode -ne 0 -or $crashed)) {
  $dumpStandby = 1
  @"
DUMP_STANDBY=1
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
CANDIDATE_SHA=$candSha
EXIT_CODE=$exitCode
EXIT_HEX=$exitHex
CRASHED=$([int]$crashed)
PID_WAS=$($p.Id)
NOTE=Crash-root standby: capture dump/instrument on 2F3727A6 only. No rebuild. PathB PASS=0.
"@ | Set-Content (Join-Path $DumpHook "STANDBY_REQUEST_2F3727A6.txt")
}

@"
GATE=SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001
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
EXIT_CODE=$exitCode
EXIT_HEX=$exitHex
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
COMPLETED_NOTE=$completedNote
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
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")

WLog "DISPOSITION=$disposition createWindow=$createWindow CMD_DIAG=$cmd4111 ENTER=$execEnter RETURN=$execReturn COMPLETED=$completed TIMED_OUT=$timedOut EXIT=$exitHex GUI_RESPONSIVE=$guiResponsive RUNTIME_PASS=$pass"
exit 0
