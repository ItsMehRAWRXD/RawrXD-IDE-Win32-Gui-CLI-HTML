# Retry2: post WM_COMMAND 4111 immediately on HWND (candidate crashes ~3s post createWindow)
# FROZEN CANDIDATE 8DC1406A only. Tip 748B untouched. PROMOTE=0.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "8DC1406A0118AC6A2F6A1E991378A2730AAC07D5593BA3C9BF5E8852E468235B"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Log = Join-Path $OutDir "RUNLOG_retry2.txt"
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}

$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class PathBCandRetry2 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
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
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "RETRY2 CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) { WLog "SHA_MISMATCH"; exit 2 }

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

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "16"
$env:RAWRXD_SWARM_MAX_PARALLEL = "4"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

WLog "LAUNCH candidate GUI IMMEDIATE_POST=1"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
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
    WLog ("EARLY_EXIT code={0} (0x{0:X})" -f $exitCode)
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_0x{0:X}" -f [uint32]$exitCode }
    break
  }
  $hwnd = [PathBCandRetry2]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [PathBCandRetry2]::MenuReady($hwnd)
    # IMMEDIATE PathB exercise — do not wait for MENU_READY (crash race)
    if ($postOk -eq 0) {
      $post1001 = [PathBCandRetry2]::PostId($hwnd, 1001)
      $postOk = [PathBCandRetry2]::PostId($hwnd, 4111)
      $postedAt = (Get-Date).ToString("o")
      WLog ("IMMEDIATE_POST hwnd=0x{0:X} post1001={1} post4111={2} menuReady={3}" -f $hwnd.ToInt64(), $post1001, $postOk, [int]$menuReady)
      $sr = 0L; $to = 0
      $sendOk = [PathBCandRetry2]::SendId($hwnd, 4111, 3000, [ref]$sr, [ref]$to)
      $sendResult = $sr; $sendTimedOut = $to
      WLog ("IMMEDIATE_SEND4111 ok={0} timedOut={1} result={2}" -f $sendOk, $sendTimedOut, $sendResult)
    }
    if ($menuReady) { $createWindow = "OK_HWND_MENU_READY"; break }
    # keep polling briefly for menu / crash
  }
  Start-Sleep -Milliseconds 50
}

# Drain until exit or short grace for crumb flush
$grace = (Get-Date).AddSeconds(8)
while ((Get-Date) -lt $grace) {
  if ($p.HasExited) { $exitCode = $p.ExitCode; break }
  if ($hwnd -ne [IntPtr]::Zero -and [PathBCandRetry2]::MenuReady($hwnd)) {
    $menuReady = $true; $createWindow = "OK_HWND_MENU_READY"
  }
  Start-Sleep -Milliseconds 200
}
if (-not $p.HasExited) {
  WLog "STOP_ALIVE pid=$($p.Id)"
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  Start-Sleep 1
  if ($p.HasExited) { $exitCode = $p.ExitCode }
} else {
  WLog ("EXIT_CODE={0} (0x{0:X})" -f $exitCode)
}

$traceText = ""
if (Test-Path $tracePath) {
  $traceText = Get-Content $tracePath -Raw -ErrorAction SilentlyContinue
  Copy-Item $tracePath (Join-Path $Logs "win32ide_trace_retry2.log") -Force
  if ($traceText -match "createWindow_RETURN_TRUE") { $createWindow = "OK_RETURN_TRUE_THEN_EXIT" }
}
if ($exitCode -eq -1073740791 -or $exitCode -eq [int]0xC0000409) {
  $createWindow = "$createWindow+CRASH_C0000409"
}

$crumbText = ""
if (Test-Path $crumb) {
  $crumbText = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
  Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB_retry2.txt") -Force
}
$cmd4111 = ([regex]::Matches($crumbText, "id=4111 ")).Count
$cmd1001 = ([regex]::Matches($crumbText, "id=1001 ")).Count
$preCompiler4111 = ([regex]::Matches($crumbText, "id=4111 step=WM_COMMAND_PRE_COMPILER")).Count
$onEnter4111 = ([regex]::Matches($crumbText, "id=4111 step=onCommand_ENTER")).Count
$onInv = "NOT_OBSERVED"
$blob = $crumbText + "`n" + $traceText
if ($blob -match "onSubAgentSwarm|Starting HexMag swarm|HexMag swarm N=|SubAgentManager not initialized|No editor content for swarm") {
  $onInv = "OBSERVED"
}

$runtimeReached = "0"
if ($onInv -eq "OBSERVED") { $runtimeReached = "1" }
elseif ($cmd4111 -gt 0) { $runtimeReached = "1" }

$disposition = "FAIL_CLOSED"
$rootCause = "UNKNOWN"
if ($cmd4111 -gt 0 -and $onInv -eq "OBSERVED") {
  $disposition = "PATH_B_RUNTIME_REACHED"; $rootCause = "CMD_DIAG_AND_ORCH"
} elseif ($cmd4111 -gt 0) {
  $disposition = "PATH_B_CMD_DIAG_REACHED_ORCH_OPEN"; $rootCause = "CMD_DIAG_4111_HIT"
} elseif ($createWindow -match "CRASH") {
  $disposition = "FAIL_CLOSED_GUI_CRASH_BEFORE_OR_DURING_4111"
  $rootCause = "CANDIDATE_CRASH_C0000409_POST_CREATEWINDOW"
} elseif ($postOk -eq 1) {
  $disposition = "FAIL_CLOSED_CMD_DIAG_MISS"
  $rootCause = "POSTED_4111_NO_CMD_DIAG"
} else {
  $disposition = "FAIL_CLOSED_NO_POST"
  $rootCause = "HWND_OR_POST_FAIL"
}

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash

@"
GATE=SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001
RUN=RETRY2_IMMEDIATE_POST
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
AUTHORITY_EXE=$CandExe
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candAfter
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipAfter
TIP_UNTOUCHED=$([int]($tipAfter -eq $ExpectTip))
SHA_MATCH=1
createWindow=$createWindow
MAIN_HWND=0x$('{0:X}' -f $hwnd.ToInt64())
MENU_READY=$([int]$menuReady)
EXIT_CODE=$exitCode
POSTED_AT=$postedAt
POSTMESSAGE_1001=$post1001
POSTMESSAGE_WM_COMMAND_4111=$postOk
SENDMESSAGETIMEOUT_WM_COMMAND_4111=$sendOk
SEND_TIMED_OUT=$sendTimedOut
SEND_RESULT=$sendResult
CMD_DIAG_id_1001=$cmd1001
CMD_DIAG_id_4111=$cmd4111
WM_COMMAND_PRE_COMPILER_4111=$preCompiler4111
onCommand_ENTER_4111=$onEnter4111
onSubAgentSwarm=$onInv
RUNTIME_REACHED=$runtimeReached
RUNTIME_PASS=0
DISPOSITION=$disposition
ROOT_CAUSE=$rootCause
ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
REBUILD_TIP=0
NO_INVENT_PASS=1
"@ | Set-Content (Join-Path $OutDir "SUMMARY_retry2.txt")

WLog "DISPOSITION=$disposition createWindow=$createWindow CMD_DIAG_id_4111=$cmd4111 onSubAgentSwarm=$onInv RUNTIME_REACHED=$runtimeReached"
exit 0
