# PathB WM_COMMAND 4111 prove on candidate 99EB54F2. Tip 748B untouched. PROMOTE=0.
# Immediate Post after HWND (prior 8DC crashed ~post-createWindow). NOT_RUN != PASS.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_99EB54F2_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "99EB54F2B876E59D9DC054530FFEDDDF2875EF308EE8A937CA1DECE6A5B481CA"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Log = Join-Path $OutDir "RUNLOG.txt"
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
public class PathBCand99 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern int EnumChildWindows(IntPtr h, EnumProc lp, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageW(IntPtr h, uint m, IntPtr w, [MarshalAs(UnmanagedType.LPWStr)] string l);
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
  public static int SeedEditor(IntPtr main) {
    IntPtr hit = IntPtr.Zero;
    EnumChildWindows(main, (h, l) => {
      var cls = new StringBuilder(256); GetClassNameW(h, cls, 256);
      string s = cls.ToString();
      if (s.IndexOf("RichEdit", StringComparison.OrdinalIgnoreCase) >= 0 ||
          s == "Edit" ||
          s.IndexOf("Scintilla", StringComparison.OrdinalIgnoreCase) >= 0) {
        hit = h; return false;
      }
      return true;
    }, IntPtr.Zero);
    if (hit == IntPtr.Zero) return 0;
    SendMessageW(hit, 0x000C, IntPtr.Zero, "int main(){ return 0; } // pathb swarm seed\r\n");
    return 1;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) { WLog "SHA_MISMATCH FAIL_CLOSED"; exit 2 }

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
$env:RAWRXD_SWARM_N = "16"
$env:RAWRXD_SWARM_MAX_PARALLEL = "4"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_CRASH_DUMP_DIR = (Join-Path $CandDir "crash_dumps")
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

WLog "LAUNCH candidate GUI IMMEDIATE_POST=1 SHA=99EB54F2"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$exitCode = $null
$postOk = 0; $sendOk = 0; $sendTimedOut = 0; $sendResult = 0; $post1001 = 0; $seeded = 0
$postedAt = ""
$deadline = (Get-Date).AddSeconds(30)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) {
    $exitCode = $p.ExitCode
    WLog ("EARLY_EXIT code={0} (0x{0:X})" -f $exitCode)
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_0x{0:X}" -f [uint32]$exitCode }
    break
  }
  $hwnd = [PathBCand99]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [PathBCand99]::MenuReady($hwnd)
    if ($postOk -eq 0) {
      $seeded = [PathBCand99]::SeedEditor($hwnd)
      $post1001 = [PathBCand99]::PostId($hwnd, 1001)
      Start-Sleep -Milliseconds 200
      [void][PathBCand99]::SeedEditor($hwnd)
      $postOk = [PathBCand99]::PostId($hwnd, 4111)
      $postedAt = (Get-Date).ToString("o")
      WLog ("IMMEDIATE_POST hwnd=0x{0:X} seed={1} post1001={2} post4111={3} menuReady={4}" -f $hwnd.ToInt64(), $seeded, $post1001, $postOk, [int]$menuReady)
      $sr = 0L; $to = 0
      $sendOk = [PathBCand99]::SendId($hwnd, 4111, 5000, [ref]$sr, [ref]$to)
      $sendResult = $sr; $sendTimedOut = $to
      WLog ("SEND4111 ok={0} timedOut={1} result={2}" -f $sendOk, $sendTimedOut, $sendResult)
    }
    if ($menuReady) { $createWindow = "OK_HWND_MENU_READY"; break }
  }
  Start-Sleep -Milliseconds 50
}

$grace = (Get-Date).AddSeconds(12)
while ((Get-Date) -lt $grace) {
  if ($p.HasExited) { $exitCode = $p.ExitCode; break }
  if ($hwnd -ne [IntPtr]::Zero -and [PathBCand99]::MenuReady($hwnd)) {
    $menuReady = $true; $createWindow = "OK_HWND_MENU_READY"
  }
  Start-Sleep -Milliseconds 200
}
if (-not $p.HasExited) {
  WLog "STOP_ALIVE pid=$($p.Id)"
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  Start-Sleep 1
  try { $p.Refresh() } catch {}
  if ($p.HasExited) { $exitCode = $p.ExitCode }
} else {
  WLog ("EXIT_CODE={0} (0x{0:X})" -f $exitCode)
}

$traceText = ""
if (Test-Path $tracePath) {
  $traceText = Get-Content $tracePath -Raw -ErrorAction SilentlyContinue
  Copy-Item $tracePath (Join-Path $Logs "win32ide_trace.log") -Force
  if ($traceText -match "createWindow_RETURN_TRUE") {
    if ($createWindow -eq "NOT_RUN" -or $createWindow -eq "OK_HWND") {
      $createWindow = "OK_RETURN_TRUE"
    } elseif ($createWindow -notmatch "RETURN_TRUE") {
      $createWindow = "$createWindow+RETURN_TRUE"
    }
  }
}
$exitHex = ""
if ($null -ne $exitCode) {
  $exitHex = ("0x{0:X}" -f [uint32]$exitCode)
  if ($exitCode -eq -1073741819 -or $exitCode -eq [int]0xC0000005) {
    $createWindow = "$createWindow+CRASH_C0000005"
  } elseif ($exitCode -eq -1073740791 -or $exitCode -eq [int]0xC0000409) {
    $createWindow = "$createWindow+CRASH_C0000409"
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

$cmd4111 = ([regex]::Matches($crumbText, "id=4111 ")).Count
$cmd1001 = ([regex]::Matches($crumbText, "id=1001 ")).Count
$preCompiler4111 = ([regex]::Matches($crumbText, "id=4111 step=WM_COMMAND_PRE_COMPILER")).Count
$onEnter4111 = ([regex]::Matches($crumbText, "id=4111 step=onCommand_ENTER")).Count
$steps4111 = @()
foreach ($m in [regex]::Matches($crumbText, "id=4111 step=([^\s\r\n]+)")) {
  $steps4111 += $m.Groups[1].Value
}
$steps4111Unique = ($steps4111 | Select-Object -Unique) -join ","

$onInv = "NOT_OBSERVED"
$blob = $crumbText + "`n" + $traceText
if (Test-Path $startupLog) { $blob += "`n" + (Get-Content $startupLog -Raw -ErrorAction SilentlyContinue) }
if ($blob -match "onSubAgentSwarm|Starting HexMag swarm|HexMag swarm N=|SubAgentManager not initialized|No editor content for swarm") {
  $onInv = "OBSERVED"
}
$resolveObs = "NOT_OBSERVED"
if ($blob -match "resolveSwarmModelOrchPlan") { $resolveObs = "OBSERVED" }
$execObs = "NOT_OBSERVED"
if ($blob -match "executeSwarm") { $execObs = "OBSERVED" }

$runtimeReached = "0"
if ($onInv -eq "OBSERVED") { $runtimeReached = "1" }
elseif ($cmd4111 -gt 0) { $runtimeReached = "1" }

$crashed = ($null -ne $exitCode) -and (
  $exitCode -eq -1073741819 -or $exitCode -eq [int]0xC0000005 -or
  $exitCode -eq -1073740791 -or $exitCode -eq [int]0xC0000409 -or
  ($exitCode -ne 0 -and $exitCode -lt 0)
)

$runtimePass = "0"
$disposition = "FAIL_CLOSED"
$rootCause = "UNKNOWN"
if ($cmd4111 -gt 0 -and $onInv -eq "OBSERVED" -and -not $crashed) {
  $disposition = "PATH_B_RUNTIME_REACHED_ORCH_WITNESSED"
  $rootCause = "CMD_DIAG_AND_ORCH"
  # still RUNTIME_PASS=0 unless full swarm product complete — do not invent
  $runtimePass = "0"
} elseif ($cmd4111 -gt 0 -and $onInv -eq "OBSERVED" -and $crashed) {
  $disposition = "PATH_B_CMD_DIAG_ORCH_PARTIAL_THEN_CRASH"
  $rootCause = "CMD_DIAG_ORCH_THEN_CRASH_$exitHex"
} elseif ($cmd4111 -gt 0) {
  $disposition = "PATH_B_CMD_DIAG_REACHED_ORCH_OPEN"
  $rootCause = if ($crashed) { "CMD_DIAG_4111_HIT_THEN_CRASH_$exitHex" } else { "CMD_DIAG_4111_HIT" }
} elseif ($createWindow -match "CRASH") {
  $disposition = "FAIL_CLOSED_GUI_CRASH_BEFORE_OR_DURING_4111"
  $rootCause = "CANDIDATE_CRASH_$exitHex"
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
GATE=SWARM_PATH_B_4111_CANDIDATE_99EB54F2_001
RUN=IMMEDIATE_POST_SEEDED
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
SEED_EDITOR=$seeded
EXIT_CODE=$exitCode
EXIT_HEX=$exitHex
POSTED_AT=$postedAt
POSTMESSAGE_1001=$post1001
POSTMESSAGE_WM_COMMAND_4111=$postOk
SENDMESSAGETIMEOUT_WM_COMMAND_4111=$sendOk
SEND_TIMED_OUT=$sendTimedOut
SEND_RESULT=$sendResult
CMD_DIAG_id_1001=$cmd1001
CMD_DIAG_id_4111=$cmd4111
CMD_DIAG_4111_STEPS=$steps4111Unique
WM_COMMAND_PRE_COMPILER_4111=$preCompiler4111
onCommand_ENTER_4111=$onEnter4111
onSubAgentSwarm=$onInv
resolveSwarmModelOrchPlan=$resolveObs
executeSwarm=$execObs
RUNTIME_REACHED=$runtimeReached
RUNTIME_PASS=$runtimePass
DISPOSITION=$disposition
ROOT_CAUSE=$rootCause
ABSORB=NOT_AUTHORIZED
GHOSTTEXT_ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
REBUILD_TIP=0
NO_INVENT_PASS=1
"@ | Set-Content (Join-Path $OutDir "SUMMARY_RUN.txt")

WLog "DISPOSITION=$disposition createWindow=$createWindow CMD_DIAG_id_4111=$cmd4111 onSubAgentSwarm=$onInv EXIT=$exitHex RUNTIME_REACHED=$runtimeReached RUNTIME_PASS=$runtimePass"
exit 0
