# SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001 — PathB CmdDiag 4111 RUNTIME on FROZEN CANDIDATE only
# AUTHORITY: TIP_CANDIDATE_AGENT_RUN_005\bin SHA 8DC1406A… NEVER overwrite TIP_FREEZE_001\bin 748B.
# ABSORB=NOT_AUTHORIZED PROMOTE=0 TIP_CLIMB=HOLD REBUILD_TIP=0
# Fail-closed: Post/Send alone != RUNTIME_REACHED; NOT_RUN != PASS.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "8DC1406A0118AC6A2F6A1E991378A2730AAC07D5593BA3C9BF5E8852E468235B"
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
public class PathBCand8DC {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumChildWindows(IntPtr p, EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool SetWindowTextW(IntPtr h, string s);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  const uint SMTO_ABORTIFHUNG = 0x0002;
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
  public static bool MenuReady(IntPtr main) {
    return GetPropW(main, "RawrXD.MainMenuReady") != IntPtr.Zero;
  }
  public static int SeedEditor(IntPtr main, string text) {
    int seeded = 0;
    EnumChildWindows(main, (h, l) => {
      var cls = new StringBuilder(256);
      GetClassNameW(h, cls, 256);
      string c = cls.ToString();
      bool ed = c.IndexOf("RichEdit", StringComparison.OrdinalIgnoreCase) >= 0
             || c.IndexOf("Scintilla", StringComparison.OrdinalIgnoreCase) >= 0
             || c == "Edit"
             || c.IndexOf("RAWRXD_EDITOR", StringComparison.OrdinalIgnoreCase) >= 0;
      if (!ed) return true;
      if (!IsWindowVisible(h)) return true;
      SendMessageW(h, 0x00B1, (IntPtr)0, (IntPtr)(-1));
      var bytes = Encoding.Unicode.GetBytes(text + "\0");
      GCHandle gch = GCHandle.Alloc(bytes, GCHandleType.Pinned);
      try { SendMessageW(h, 0x00C2, (IntPtr)1, gch.AddrOfPinnedObject()); }
      finally { gch.Free(); }
      SetWindowTextW(h, text);
      seeded++;
      return true;
    }, IntPtr.Zero);
    return seeded;
  }
  public static string Scrape(IntPtr main) {
    var sb = new StringBuilder();
    EnumChildWindows(main, (h, l) => {
      var cls = new StringBuilder(128); GetClassNameW(h, cls, 128);
      var txt = new StringBuilder(4096); GetWindowTextW(h, txt, 4096);
      if (txt.Length > 0) sb.AppendLine(cls + "|" + txt);
      return true;
    }, IntPtr.Zero);
    return sb.ToString();
  }
  public static int PostId(IntPtr h, int id) {
    return PostMessageW(h, 0x0111, (IntPtr)id, IntPtr.Zero) ? 1 : 0;
  }
  public static int SendId(IntPtr h, int id, uint timeoutMs, out long result, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0111, (IntPtr)id, IntPtr.Zero, SMTO_ABORTIFHUNG, timeoutMs, out r);
    result = r.ToInt64();
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
@"
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
CANDIDATE_MATCH=$([int]($candSha -eq $ExpectCand))
TIP_MATCH=$([int]($tipSha -eq $ExpectTip))
TIP_UNTOUCHED_EXPECT=1
"@ | Set-Content (Join-Path $Logs "sha_verify.txt")
WLog "START GATE=SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001 CAND=$candSha TIP=$tipSha"

if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  @"
GATE=SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001
SHA_MATCH=0
RUNTIME_REACHED=NOT_RUN
RUNTIME_PASS=0
PROMOTE=0
ROOT_CAUSE=SHA_MISMATCH
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
  exit 2
}

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"; Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
if (Test-Path $crumb) { Remove-Item $crumb -Force -ErrorAction SilentlyContinue }
$tracePath = Join-Path $CandDir "win32ide_trace.log"
if (Test-Path $tracePath) { Remove-Item $tracePath -Force -ErrorAction SilentlyContinue }

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "16"
$env:RAWRXD_SWARM_MAX_PARALLEL = "4"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
Remove-Item Env:LOCAL_ONLY_NO_OLLAMA -ErrorAction SilentlyContinue
Remove-Item Env:RAWRXD_SWARM_SEQUENTIAL -ErrorAction SilentlyContinue

# NO stdout/stderr redirect — prior PathB PostMessage=0 with redirect.
WLog "LAUNCH candidate GUI cwd=$CandDir NO_REDIRECT=1"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) {
    WLog ("EARLY_EXIT code={0}" -f $p.ExitCode)
    $createWindow = "FAIL_EXIT_$($p.ExitCode)"
    break
  }
  $hwnd = [PathBCand8DC]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [PathBCand8DC]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 250
}
if ($hwnd -ne [IntPtr]::Zero -and $menuReady) { $createWindow = "OK_HWND_MENU_READY" }
elseif ($hwnd -ne [IntPtr]::Zero) { $createWindow = "OK_HWND_MENU_WAIT" }
WLog ("createWindow=$createWindow MAIN_HWND=0x{0:X} MENU_READY={1}" -f $hwnd.ToInt64(), [int]$menuReady)

$postOk = 0; $sendOk = 0; $sendTimedOut = 0; $sendResult = 0; $seeded = 0
$post1001 = 0
$cmdDiag4111 = 0; $cmdDiag1001 = 0
$crumbHit = "NOT_OBSERVED"; $preCompiler = "NOT_OBSERVED"
$onInv = "NOT_OBSERVED"; $resolveInv = "NOT_OBSERVED"; $execInv = "NOT_OBSERVED"
$runtimeReached = "NOT_RUN"; $runtimePass = 0
$rootCause = "NOT_SET"
$disposition = "NOT_SET"

if ($hwnd -eq [IntPtr]::Zero) {
  $rootCause = "MAIN_HWND_ZERO_CREATEWINDOW_FAIL_OR_HEADLESS"
  $disposition = "FAIL_CLOSED_NO_GUI"
  $runtimeReached = "NOT_RUN"
} else {
  Start-Sleep 2
  # Control: id=1001 must earn crumbs under same diag (prior tip differential)
  $post1001 = [PathBCand8DC]::PostId($hwnd, 1001)
  WLog "POSTMESSAGE_1001=$post1001"
  Start-Sleep 1

  $seedText = 'int main(){ /* pathb swarm orch seed candidate 8DC1406A */ return 0; }' + "`n"
  $seeded = [PathBCand8DC]::SeedEditor($hwnd, $seedText)
  WLog "EDITOR_SEEDED_CONTROLS=$seeded"
  Start-Sleep 1

  $postOk = [PathBCand8DC]::PostId($hwnd, 4111)
  WLog "POSTMESSAGE_4111=$postOk"
  Start-Sleep 2

  $sr = 0L; $to = 0
  $sendOk = [PathBCand8DC]::SendId($hwnd, 4111, 15000, [ref]$sr, [ref]$to)
  $sendResult = $sr; $sendTimedOut = $to
  WLog "SENDMESSAGETIMEOUT_4111=$sendOk timedOut=$sendTimedOut result=$sendResult"

  Start-Sleep 20

  $ui = [PathBCand8DC]::Scrape($hwnd)
  $ui | Set-Content (Join-Path $Logs "ui_scrape.txt") -Encoding UTF8

  $crumbText = ""
  if (Test-Path $crumb) {
    $crumbText = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
    Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB.txt") -Force
  }
  $crumbText | Set-Content (Join-Path $Logs "crumb_copy.txt")

  $traceText = ""
  if (Test-Path $tracePath) {
    $traceText = Get-Content $tracePath -Raw -ErrorAction SilentlyContinue
    Copy-Item $tracePath (Join-Path $Logs "win32ide_trace.log") -Force
    if ($traceText -match "createWindow") { $createWindow = "$createWindow+TRACE_HIT" }
  }

  $ideLogs = @()
  $logDir = Join-Path $CandDir "logs"
  if (Test-Path $logDir) {
    Get-ChildItem $logDir -Filter "RawrXD_IDE_*.log" -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object {
        $ideLogs += (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue)
        Copy-Item $_.FullName (Join-Path $Logs $_.Name) -Force -ErrorAction SilentlyContinue
      }
  }
  $audit = ""
  $auditPath = Join-Path $CandDir "rawrxd_audit.jsonl"
  if (Test-Path $auditPath) {
    $audit = Get-Content $auditPath -Tail 200 -ErrorAction SilentlyContinue | Out-String
    $audit | Set-Content (Join-Path $Logs "audit_tail.txt")
  }

  $nl = [Environment]::NewLine
  $blob = $ui + $nl + $crumbText + $nl + $traceText + $nl + ($ideLogs -join $nl) + $nl + $audit
  $blob.Substring(0, [Math]::Min(12000, $blob.Length)) | Set-Content (Join-Path $Logs "witness_blob_head.txt")

  if ($crumbText) {
    $cmdDiag4111 = @(Select-String -InputObject $crumbText -Pattern "id=4111 " -AllMatches).Count
    if ($cmdDiag4111 -eq 0) {
      $cmdDiag4111 = ([regex]::Matches($crumbText, "id=4111 ")).Count
    }
    $cmdDiag1001 = ([regex]::Matches($crumbText, "id=1001 ")).Count
    if ($crumbText -match "id=4111 ") { $crumbHit = "HIT" }
    if ($crumbText -match "id=4111 step=WM_COMMAND_PRE_COMPILER") { $preCompiler = "HIT" }
  }

  if ($blob -match "onSubAgentSwarm|Starting HexMag swarm|HexMag swarm N=") { $onInv = "OBSERVED" }
  if ($blob -match "resolveSwarmModelOrchPlan|FAIL_CLOSED: swarm model inventory") {
    $resolveInv = "OBSERVED"; $onInv = "OBSERVED"
  }
  if ($blob -match "executeSwarm|Swarm complete|Swarm FAIL_CLOSED|Starting HexMag swarm") {
    $execInv = "OBSERVED"
  }
  if ($blob -match "SubAgentManager not initialized|No editor content for swarm|agent bridge unavailable") {
    $onInv = "OBSERVED"
  }

  # RUNTIME_REACHED: CmdDiag saw 4111 OR orch handler observed (honest ladder)
  if ($onInv -eq "OBSERVED" -or $resolveInv -eq "OBSERVED" -or $execInv -eq "OBSERVED") {
    $runtimeReached = "1"
  } elseif ($crumbHit -eq "HIT") {
    $runtimeReached = "1"  # SOURCE_WIRED proved at CmdDiag; orch may still miss
  } else {
    $runtimeReached = "0"
  }

  # RUNTIME_PASS requires orch product completion — never invent
  $runtimePass = 0
  if ($execInv -eq "OBSERVED" -and $blob -match "Swarm complete") {
    $runtimePass = 0
  }

  if ($runtimeReached -eq "1" -and $onInv -eq "OBSERVED") {
    $rootCause = "NONE_ORCH_OR_CMDDIAG_REACHED"
    $disposition = "PATH_B_RUNTIME_REACHED"
  } elseif ($runtimeReached -eq "1" -and $crumbHit -eq "HIT") {
    $rootCause = "CMD_DIAG_4111_HIT_ORCH_UNWITNESSED"
    $disposition = "PATH_B_CMD_DIAG_REACHED_ORCH_OPEN"
  } elseif ($postOk -eq 1 -or $sendOk -eq 1) {
    if ($crumbHit -ne "HIT") {
      $rootCause = "MSG_QUEUED_OR_SENT_BUT_NO_CMD_DIAG_4111"
      $disposition = "FAIL_CLOSED_CMD_DIAG_MISS"
    } else {
      $rootCause = "CMD_DIAG_SEEN_ORCH_NOT_OBSERVED"
      $disposition = "FAIL_CLOSED_ORCH_MISS"
    }
  } elseif ($sendTimedOut -eq 1) {
    $rootCause = "SENDMESSAGE_TIMEOUT_UI_THREAD_HUNG"
    $disposition = "FAIL_CLOSED_UI_HUNG"
  } else {
    $rootCause = "POST_AND_SEND_FAILED"
    $disposition = "FAIL_CLOSED_POST_SEND"
  }
}

if (-not $p.HasExited) {
  WLog "STOP pid=$($p.Id)"
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  Start-Sleep 2
}

# Tip still frozen after prove
$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash

@"
GATE=SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
WORKSTREAM=G07_PATH_B_SWARM_RUNTIME
AUTHORITY_EXE=$CandExe
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candAfter
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipAfter
TIP_UNTOUCHED=$([int]($tipAfter -eq $ExpectTip))
SHA_MATCH=1
SOURCE_WIRED_PRIOR=SWARM_PATH_B_4111_SOURCE_001
REBUILD_TIP=0
ABSORB=NOT_AUTHORIZED
GHOSTTEXT_ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
NO_INVENT_PASS=1
createWindow=$createWindow
MAIN_HWND=0x$('{0:X}' -f $hwnd.ToInt64())
MENU_READY=$([int]$menuReady)
EDITOR_SEEDED_CONTROLS=$seeded
POSTMESSAGE_1001=$post1001
POSTMESSAGE_WM_COMMAND_4111=$postOk
SENDMESSAGETIMEOUT_WM_COMMAND_4111=$sendOk
SEND_TIMED_OUT=$sendTimedOut
SEND_RESULT=$sendResult
CMD_DIAG_id_1001=$cmdDiag1001
CMD_DIAG_id_4111=$cmdDiag4111
CMD_DIAG_4111=$crumbHit
WM_COMMAND_PRE_COMPILER=$preCompiler
onSubAgentSwarm=$onInv
resolveSwarmModelOrchPlan=$resolveInv
executeSwarm=$execInv
RUNTIME_REACHED=$runtimeReached
RUNTIME_PASS=$runtimePass
DISPOSITION=$disposition
ROOT_CAUSE=$rootCause
NOTE=SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
NOTE2=NOT_RUN != PASS; tip absorb NOT_AUTHORIZED
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")

WLog "DISPOSITION=$disposition createWindow=$createWindow CMD_DIAG_id_4111=$cmdDiag4111 RUNTIME_REACHED=$runtimeReached RUNTIME_PASS=$runtimePass"
WLog "END SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001"
exit 0
