# TIER5_GSFAULT_RC_001 — MenuReady → ping → 12200 → 12230 → 5170
$ErrorActionPreference = 'Continue'
$seal = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001'
$log = Join-Path $seal 'logs\RUNLOG.txt'
$exe = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001\bin_freeze\RawrXD-Win32IDE.exe'
$tip = 'G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$expectTip = '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'
$runId = 'HOSTHEAP_SURV_' + (Get-Date -Format 'yyyyMMddTHHmmss')
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

$bcDir = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001\logs'
New-Item -ItemType Directory -Force -Path $bcDir | Out-Null
Remove-Item "$bcDir\BC_TOP_*.txt" -Force -EA SilentlyContinue
Remove-Item "$bcDir\BC_EARLY_*.txt" -Force -EA SilentlyContinue
# Also local seal BC mirror path if Core writes absolute DBGWATCH path only

Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public class Tier5GsH {
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
  $hwnd = [Tier5GsH]::FindMain([uint32]$pidGui)
  if ($hwnd -ne [IntPtr]::Zero) {
    $ready = [Tier5GsH]::MenuReady($hwnd)
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
$matrix = @()

if ($ready -and (Alive $pidGui)) {
  $launch = 'PASS'
  # Settle: prior killer was async CompilerIntegration abort ~2s after MenuReady
  Start-Sleep -Seconds 3
  if (-not (Alive $pidGui)) {
    $gui.Refresh()
    try {
      $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF))
      L "PRE_BASELINE_DEAD hex=$hex (CompilerIntegration residual?)"
      $hostHeap = $hex
      $first = 'PRE_BASELINE_SETTLE'
    } catch {}
  } else {
    $to = 0
    $ping = [Tier5GsH]::Ping($hwnd, 4000, [ref]$to)
    if ($ping -ne 1 -and (Alive $pidGui)) {
      Start-Sleep 1
      $to = 0
      $ping = [Tier5GsH]::Ping($hwnd, 4000, [ref]$to)
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
  }

  if ($base -eq 'PASS') {
    $okAll = $true
    foreach ($c in @(
        @{ Id = 12200; Name = 'IDM_LINEENDING_DETECT' },
        @{ Id = 12230; Name = 'IDM_DBGWATCH_SHOW' },
        @{ Id = 5170;  Name = 'IDM_DBG_LIST_BPS' }
      )) {
      if (-not (Alive $pidGui)) { $okAll = $false; break }
      $to = 0
      $sok = [Tier5GsH]::SendId($hwnd, $c.Id, 8000, [ref]$to)
      L "SEND id=$($c.Id) name=$($c.Name) ok=$sok sendTimedOut=$to"
      if ($sok -ne 1) {
        $pok = [Tier5GsH]::PostId($hwnd, $c.Id)
        Start-Sleep -Milliseconds 800
        $pto = 0
        $pping = [Tier5GsH]::Ping($hwnd, 3000, [ref]$pto)
        $alive = [int](Alive $pidGui)
        $hex = 'ALIVE'
        if (-not (Alive $pidGui)) {
          $gui.Refresh()
          try { $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)) } catch { $hex = 'DEAD' }
        }
        L "POST id=$($c.Id) name=$($c.Name) ok=$pok alive_after=$alive ping=$pping timedOut=$pto exit=$hex"
        if (-not (Alive $pidGui)) {
          $okAll = $false
          $first = "GUI_SURVIVAL:$($c.Name)"
          $killer = $c.Name
          $hostHeap = $hex
          $matrix += "$($c.Name)=FAIL exit=$hex"
          break
        }
      } else {
        Start-Sleep -Milliseconds 400
        if (-not (Alive $pidGui)) {
          $gui.Refresh()
          try { $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)) } catch { $hex = 'DEAD' }
          $okAll = $false
          $first = "GUI_SURVIVAL:$($c.Name)"
          $killer = $c.Name
          $hostHeap = $hex
          $matrix += "$($c.Name)=FAIL exit=$hex"
          break
        }
        $matrix += "$($c.Name)=PASS"
      }
      $bc = Join-Path $bcDir ("BC_TOP_{0}.txt" -f $c.Id)
      L ("BC_TOP_{0}={1}" -f $c.Id, $(if (Test-Path $bc) { 'PRESENT' } else { 'MISSING' }))
    }
    if ($okAll -and (Alive $pidGui)) {
      $surv = 'PASS'
      # linger to catch late abort
      Start-Sleep -Seconds 5
      if (-not (Alive $pidGui)) {
        $gui.Refresh()
        try { $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)) } catch { $hex = 'DEAD' }
        $surv = 'FAIL'
        $first = 'POST_SURVIVAL_LINGER'
        $killer = 'LATE_ABORT'
        $hostHeap = $hex
        L "LINGER_DEAD hex=$hex"
      }
    }
  }
}

if (Alive $pidGui) {
  try { Stop-Process -Id $pidGui -Force -EA SilentlyContinue } catch {}
}
Start-Sleep 1

$bc12200 = [int](Test-Path (Join-Path $bcDir 'BC_TOP_12200.txt'))
$bc12230 = [int](Test-Path (Join-Path $bcDir 'BC_TOP_12230.txt'))
$runtimePass = [int]($surv -eq 'PASS')
L "RESULT launch=$launch base=$base surv=$surv first=$first killer=$killer host=$hostHeap"
L "BC_TOP_12200=$bc12200 BC_TOP_12230=$bc12230 RUNTIME_SURVIVAL_PASS=$runtimePass"
L "MATRIX $($matrix -join '; ')"
L "TIP_UNTOUCHED=$([int]((Get-FileHash $tip -A SHA256).Hash -eq $expectTip))"

@"
RUN_ID=$runId
CAND_SHA=$sha
LAUNCH=$launch
BASELINE=$base
SURVIVAL=$surv
FIRST_FAILURE=$first
KILLER=$killer
HOST_HEAP_OR_EXIT=$hostHeap
BC_TOP_12200=$bc12200
BC_TOP_12230=$bc12230
RUNTIME_SURVIVAL_PASS=$runtimePass
MATRIX=$($matrix -join '; ')
PROMOTE=0
"@ | Set-Content (Join-Path $seal 'logs\RESULT.txt')

if ($runtimePass -ne 1) { exit 1 }
exit 0
