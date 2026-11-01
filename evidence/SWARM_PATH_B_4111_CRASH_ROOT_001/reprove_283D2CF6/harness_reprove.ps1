# PathB 4111 re-prove on crash-root candidate 283D2CF6 (tip untouched; 2F3727A6 pinned).
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CRASH_ROOT_001\reprove_283D2CF6"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "283D2CF6704B3D138B9196FED082D47EDD4A3949106C3AA81E01789617E94621"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Log = Join-Path $OutDir "RUNLOG.txt"
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}
$cs = @'
using System; using System.Text; using System.Runtime.InteropServices;
public class PathB283 {
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
      var cls = new StringBuilder(256); GetClassNameW(h, cls, 256);
      if (cls.ToString() == "RawrXD_IDE_MainWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static bool MenuReady(IntPtr main) { return GetPropW(main, "RawrXD.MainMenuReady") != IntPtr.Zero; }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=SWARM_PATH_B_4111_CRASH_ROOT_001_REPROVE
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
Remove-Item (Join-Path $crumbDir "CMD_BREADCRUMB.txt") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $crumbDir "FIRST_CHANCE_WM_COMMAND.txt") -Force -ErrorAction SilentlyContinue

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "2"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"
$hwnd = [IntPtr]::Zero
$ready = $false
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline -and -not $p.HasExited) {
  $hwnd = [PathB283]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero -and [PathB283]::MenuReady($hwnd)) { $ready = $true; break }
  Start-Sleep -Milliseconds 250
}
WLog "HWND=$hwnd MENU_READY=$ready"
$post1001 = 0; $post4111 = 0
if ($ready) {
  $post1001 = if ([PathB283]::PostMessageW($hwnd, 0x0111, [IntPtr]1001, [IntPtr]::Zero)) { 1 } else { 0 }
  Start-Sleep -Milliseconds 500
  $post4111 = if ([PathB283]::PostMessageW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero)) { 1 } else { 0 }
  WLog "POST1001=$post1001 POST4111=$post4111"
}

$waitEnd = (Get-Date).AddSeconds(180)
$guiOk = 0
$bodyRetSeen = 0
while ((Get-Date) -lt $waitEnd) {
  if ($p.HasExited) { break }
  $r = [IntPtr]::Zero
  $ok = [PathB283]::SendMessageTimeoutW($hwnd, 0, [IntPtr]::Zero, [IntPtr]::Zero, 0x0002, 1000, [ref]$r)
  if ($ok -ne [IntPtr]::Zero) { $guiOk = 1 }
  $crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
  if (Test-Path $crumb) {
    $t = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
    if ($t -match "executeSwarm_BODY_RETURN") { $bodyRetSeen = 1; WLog "BODY_RETURN_SEEN"; break }
  }
  Start-Sleep -Milliseconds 1000
}
if (-not $p.HasExited) { Start-Sleep 8 }
$forced = 0
if (-not $p.HasExited) {
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  $forced = 1
  Start-Sleep 2
}
try { $p.Refresh() } catch {}
$exit = $p.ExitCode
WLog "EXIT=$exit FORCED=$forced GUI_LAST_OK=$guiOk BODY_RET=$bodyRetSeen"

Copy-Item (Join-Path $crumbDir "CMD_BREADCRUMB.txt") (Join-Path $Logs "CMD_BREADCRUMB.txt") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $crumbDir "FIRST_CHANCE_WM_COMMAND.txt") (Join-Path $Logs "FIRST_CHANCE_WM_COMMAND.txt") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $CandDir "win32ide_trace.log") (Join-Path $Logs "win32ide_trace.log") -Force -ErrorAction SilentlyContinue

$crumbText = ""
if (Test-Path (Join-Path $Logs "CMD_BREADCRUMB.txt")) {
  $crumbText = Get-Content (Join-Path $Logs "CMD_BREADCRUMB.txt") -Raw
}
$enter = [int]($crumbText -match "onSubAgentSwarm_BEFORE_executeSwarm|executeSwarm_BODY_ENTER|executeSwarm_ASYNC_SPAWN")
$bodyRet = [int]($crumbText -match "executeSwarm_BODY_RETURN")
$spawnAfter = [int]($crumbText -match "onSubAgentSwarm_AFTER_executeSwarm_SPAWN")
$veh = [int]($crumbText -match "VEH_FATAL")
$cmd4111 = [int]($crumbText -match "id=4111")
$afterSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$exitU = [uint32]([int]$exit -band 0xffffffff)
$exitHex = ("0x{0:X8}" -f $exitU)
$exitClean = [int](($exit -eq 0) -and ($forced -eq 0))
$runtimePass = [int](($enter -eq 1) -and ($bodyRet -eq 1) -and ($exitClean -eq 1) -and ($afterSha -eq $ExpectCand) -and ($guiOk -eq 1) -and ($tipAfter -eq $ExpectTip))

@"
GATE=SWARM_PATH_B_4111_CRASH_ROOT_001_REPROVE
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$afterSha
CANDIDATE_SHA_STABLE=$([int]($afterSha -eq $ExpectCand))
TIP_SHA=$tipAfter
TIP_UNTOUCHED=$([int]($tipAfter -eq $ExpectTip))
EXIT_CODE=$exit
EXIT_HEX=$exitHex
EXIT_CLEAN=$exitClean
FORCED_STOP=$forced
GUI_RESPONSIVE=$guiOk
CMD_DIAG_4111_OBSERVED=$cmd4111
EXECUTE_SWARM_ENTER=$enter
EXECUTE_SWARM_BODY_RETURN=$bodyRet
EXECUTE_SWARM_SPAWN_AFTER=$spawnAfter
VEH_FATAL=$veh
COMPLETED=UNMEASURED
RUNTIME_PASS=$runtimePass
READY_FOR_PATHB_REPROVE=$([int]($runtimePass -eq 0))
HISTORICAL_PIN_2F3727A6=PRESERVED
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB=NOT_AUTHORIZED
CERTIFIED=0
NO_INVENT_PASS=1
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
Get-Content (Join-Path $OutDir "SUMMARY.txt")
if (Test-Path (Join-Path $Logs "CMD_BREADCRUMB.txt")) {
  Get-Content (Join-Path $Logs "CMD_BREADCRUMB.txt") | Select-String -Pattern "4111|executeSwarm|VEH_FATAL|onSubAgent" | Select-Object -Last 40
}
exit 0
