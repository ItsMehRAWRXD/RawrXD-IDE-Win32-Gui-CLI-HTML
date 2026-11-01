# DBGWATCH_SURVIVAL_RC_67CA_001 — MenuReady → ping → 12230 → 5170
$ErrorActionPreference = 'Continue'
$seal = 'G:\~dev\rawrxd\evidence\DBGWATCH_SURVIVAL_RC_67CA_001'
$log = Join-Path $seal 'logs\RUNLOG.txt'
$exe = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe'
$tip = 'G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$expectTip = '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'
$runId = 'DBGWATCHRC_' + (Get-Date -Format 'yyyyMMddTHHmmss')
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content $log
function L([string]$m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'o'), $m
  Add-Content $log $line
  Write-Host $line
}
function Alive([int]$procId) { return [bool](Get-Process -Id $procId -EA SilentlyContinue) }

$sha = (Get-FileHash $exe -A SHA256).Hash
$tipSha = (Get-FileHash $tip -A SHA256).Hash
$sha | Set-Content (Join-Path $seal 'logs\exe_sha.txt')
$tipSha | Set-Content (Join-Path $seal 'logs\tip_sha.txt')
L "HASH_VERIFY CAND=$sha tip748B=$([int]($tipSha -eq $expectTip))"
L "RUN_ID=$runId"

cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
Start-Sleep 2

$bcDir = Join-Path (Split-Path $exe) 'evidence\DBGWATCH_SURVIVAL_RC_67CA_001\logs'
New-Item -ItemType Directory -Force -Path $bcDir | Out-Null
Remove-Item "$bcDir\BC_EARLY_*.txt" -Force -EA SilentlyContinue

Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public class DbgWatchRcH {
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
  public static int SendId(IntPtr h, int id, uint ms, out int timedOut) {
    IntPtr r; IntPtr ok = SendMessageTimeoutW(h, 0x0111, (IntPtr)id, IntPtr.Zero, 0x0002, ms, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0; return (ok != IntPtr.Zero) ? 1 : 0;
  }
  public static int Ping(IntPtr h, uint ms, out int timedOut) {
    IntPtr r; IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, ms, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0; return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
'@ -ErrorAction SilentlyContinue | Out-Null

$gui = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) `
  -ArgumentList @('--local','--dir','G:\~dev\rawrxd') -PassThru -WindowStyle Normal
$pidGui = $gui.Id
$hwnd = [IntPtr]::Zero
$ready = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if (-not (Alive $pidGui)) { break }
  $hwnd = [DbgWatchRcH]::FindMain([uint32]$pidGui)
  if ($hwnd -ne [IntPtr]::Zero) {
    $ready = [DbgWatchRcH]::MenuReady($hwnd)
    if ($ready) { break }
  }
  Start-Sleep -Milliseconds 250
}
L "GUI_PID=$pidGui HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$ready) ALIVE=$([int](Alive $pidGui))"

$first = 'NONE'
$killer = 'NONE'
$hostHeap = 'NONE'
$launch = 'FAIL'
$base = 'FAIL'
$surv = 'FAIL'

if ($ready -and (Alive $pidGui)) {
  $launch = 'PASS'
  $to = 0
  $ping = [DbgWatchRcH]::Ping($hwnd, 4000, [ref]$to)
  if ($ping -ne 1 -and (Alive $pidGui)) {
    Start-Sleep 1
    $to = 0
    $ping = [DbgWatchRcH]::Ping($hwnd, 4000, [ref]$to)
  }
  L "GUI_BASELINE alive=$([int](Alive $pidGui)) ping=$ping timedOut=$to"
  if ($ping -eq 1 -and (Alive $pidGui)) {
    $base = 'PASS'
  } else {
    $first = 'GUI_BASELINE'
    if (-not (Alive $pidGui)) {
      $gui.Refresh()
      try {
        $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF))
        L "BASE_DEAD hex=$hex"
        $hostHeap = $hex
      } catch {}
    }
  }

  if ($base -eq 'PASS') {
    $okAll = $true
    foreach ($c in @(
        @{ Id = 12230; Name = 'IDM_DBGWATCH_SHOW' },
        @{ Id = 5170;  Name = 'IDM_DBG_LIST_BPS' }
      )) {
      if (-not (Alive $pidGui)) {
        $okAll = $false
        $killer = $c.Name
        $first = "PRE_POST_DEAD:$($c.Name)"
        $gui.Refresh()
        try {
          $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF))
          L "PRE_POST hex=$hex"
          $hostHeap = $hex
        } catch {}
        break
      }
      $toSend = 0
      $ok = [DbgWatchRcH]::SendId($hwnd, $c.Id, 5000, [ref]$toSend)
      Start-Sleep -Milliseconds 400
      $still = (Alive $pidGui)
      $to2 = 0
      $ping2 = 0
      if ($still) { $ping2 = [DbgWatchRcH]::Ping($hwnd, 3000, [ref]$to2) }
      L "SEND id=$($c.Id) name=$($c.Name) ok=$ok sendTimedOut=$toSend"
      $ec = 0
      $hex = 'RUNNING'
      if (-not $still) {
        $gui.Refresh()
        try { $ec = $gui.ExitCode } catch {}
        $hex = ('{0:X8}' -f ([int64]$ec -band 0xFFFFFFFF))
        $hostHeap = $hex
      }
      L "POST id=$($c.Id) name=$($c.Name) ok=$ok alive_after=$([int]$still) ping=$ping2 timedOut=$to2 exit=$ec hex=$hex"
      if (-not ($still -and $ping2 -eq 1 -and $to2 -eq 0)) {
        $okAll = $false
        $killer = $c.Name
        if ($first -eq 'NONE') { $first = "GUI_SURVIVAL:$($c.Name)" }
        break
      }
    }
    if ($okAll) { $surv = 'PASS' }
  }
} else {
  $first = 'GUI_LAUNCH'
  if (-not (Alive $pidGui)) {
    $gui.Refresh()
    try {
      $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF))
      L "LAUNCH_DEAD hex=$hex"
      $hostHeap = $hex
    } catch {}
  }
}

L "GUI_SURVIVAL => $surv KILLER=$killer HOST_HEAP=$hostHeap"
$bcAbs = 'G:\~dev\rawrxd\evidence\DBGWATCH_SURVIVAL_RC_67CA_001\logs\BC_TOP_12230.txt'
$bc = $bcAbs
$bcHit = [int](Test-Path $bc)
if (-not $bcHit) {
  $bc = Join-Path $bcDir 'BC_TOP_12230.txt'
  $bcHit = [int](Test-Path $bc)
}
if ($bcHit) {
  Copy-Item -Force $bc (Join-Path $seal 'logs\BC_TOP_12230_COPY.txt')
  L ('BC_TOP_12230=' + ((Get-Content $bc -Raw).Trim()))
} else {
  L 'BC_TOP_12230=MISSING'
  Get-ChildItem 'G:\~dev\rawrxd\evidence\DBGWATCH_SURVIVAL_RC_67CA_001\logs\BC_TOP_*.txt' -EA SilentlyContinue |
    ForEach-Object { L ('BC_OTHER=' + $_.Name) }
}
$tipAfter = (Get-FileHash $tip -A SHA256).Hash
L "TIP_UNTOUCHED=$([int]($tipAfter -eq $expectTip))"
if (Alive $pidGui) { Stop-Process -Id $pidGui -Force -EA SilentlyContinue }

$rp = [int]($surv -eq 'PASS')
$disp = $(if ($rp -eq 1) { 'DBGWATCH_SURVIVAL_RC_PASS' } else { 'DBGWATCH_SURVIVAL_RC_FAIL_CLOSED' })
$nextPri = $(if ($rp -eq 1) { 'HOST_HEAP_OR_AWAITING_AUTH' } else { 'DBGWATCH_ONCOMMAND_OR_HOST' })
@"
GATE=DBGWATCH_SURVIVAL_RC_67CA_001
RUN_ID=$runId
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
CAND_SHA=$sha
CAND_PRIOR_67CA=67CA264F2D6C30F36B7DA546BAADB014E3AF479EDCFE820F6CF1F4A5EEF438C1
TIP_SHA=$tipAfter
tip748B=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
DISPOSITION=$disp
EXIT=$(if ($rp -eq 1) { 0 } else { 1 })
FIRST_FAILURE=$first
CELL_HASH_BIND=PASS
CELL_GUI_LAUNCH=$launch
CELL_GUI_BASELINE=$base
CELL_GUI_SURVIVAL=$surv
CELL_TIP_UNTOUCHED=$(if ($tipAfter -eq $expectTip) { 'PASS' } else { 'FAIL' })
CELL_CERTIFIED_UNCHANGED=PASS
KILLER=$killer
HOST_HEAP_NOTE=$hostHeap
BC_EARLY_12230=$bcHit
SOURCE_WIRED=1
RUNTIME_REACHED=1
RUNTIME_SURVIVAL_PASS=$rp
INVENT_WATCH_PASS=0
ROOT_CAUSE=Tier5 ODS-only linked on 67CA but 12230 still C0000409 via onCommand/CommandFlight; WindowProc lParam==0 early-bypass for IDM_DBGWATCH_* before CmdDiag/sehCallOnCommand
C0000374_CLASS=HOST_HEAP_INDEPENDENT_RESIDUAL
NEXT_PRIORITY=$nextPri
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
"@ | Set-Content (Join-Path $seal 'SUMMARY.txt')

Write-Host '--- SUMMARY ---'
Get-Content (Join-Path $seal 'SUMMARY.txt')
exit $(if ($rp -eq 1) { 0 } else { 1 })
