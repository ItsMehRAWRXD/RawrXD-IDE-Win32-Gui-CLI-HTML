# HOST_HEAP_C0000374_REPRO_001 — independent of Tier5 survival cmds
# Attempts: 09DB idle settle x3; pinned 2F37 launch (historical C0000374 class)
$ErrorActionPreference = 'Continue'
$seal = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001'
$log = Join-Path $seal 'logs\RUNLOG.txt'
$dumpDir = 'C:\Users\Garrett\AppData\Local\Temp\RawrXD_Dumps'
$exe09 = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001\bin_freeze\RawrXD-Win32IDE.exe'
$exe2f = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin_pinned_2F3727A6\RawrXD-Win32IDE.exe'
$tip = 'G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$expect09 = 'D0A6A65CFB5C04E11AECCB4F99ADB4F70652225368F0FFC181FB4C5248F77811'
$expect2f = '2F3727A6CD8EFF4E934E45C51494B926489FFAD1BC5430B072F3D5BAEE0007C2'
$expectTip = '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'
$runId = 'HOSTHEAP_' + (Get-Date -Format 'yyyyMMddTHHmmss')
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content $log
function L([string]$m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'o'), $m
  Add-Content $log $line
  Write-Host $line
}
function Alive([int]$procId) { return [bool](Get-Process -Id $procId -EA SilentlyContinue) }
function ExitHex($proc) {
  try {
    $proc.Refresh()
    return ('{0:X8}' -f ([int64]$proc.ExitCode -band 0xFFFFFFFF))
  } catch { return 'UNKNOWN' }
}
function DumpSnapshot() {
  if (-not (Test-Path $dumpDir)) { return @() }
  return @(Get-ChildItem $dumpDir -Filter 'RawrXD-Win32IDE.exe.*.dmp' -EA SilentlyContinue |
    Select-Object Name, Length, LastWriteTimeUtc)
}

Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public class HostHeapH {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
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
  public static int Ping(IntPtr h, uint ms, out int timedOut) {
    IntPtr r; IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, ms, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0; return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
'@ -ErrorAction SilentlyContinue | Out-Null

$sha09 = (Get-FileHash $exe09 -A SHA256).Hash
$sha2f = (Get-FileHash $exe2f -A SHA256).Hash
$tipSha = (Get-FileHash $tip -A SHA256).Hash
$sha09 | Set-Content (Join-Path $seal 'logs\exe_sha_09db.txt')
$sha2f | Set-Content (Join-Path $seal 'logs\exe_sha_2f37.txt')
$tipSha | Set-Content (Join-Path $seal 'logs\tip_sha.txt')
L "RUN_ID=$runId"
L "HASH_09DB=$sha09 match=$([int]($sha09 -eq $expect09))"
L "HASH_2F37=$sha2f match=$([int]($sha2f -eq $expect2f))"
L "HASH_TIP=$tipSha tip748B=$([int]($tipSha -eq $expectTip))"
if ($sha09 -ne $expect09) { L "ABORT cand not 09DB"; exit 2 }

$preDumps = DumpSnapshot
$preNames = @($preDumps | ForEach-Object { $_.Name })
L "PRE_DUMP_COUNT=$($preDumps.Count)"

$results = New-Object System.Collections.Generic.List[string]
$c0000374Hits = 0
$anyHeapExit = 0

function KillIde() {
  cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
  Start-Sleep 2
}

function AttemptIdle([string]$label, [string]$exe, [int]$idleSec) {
  KillIde
  L "ATTEMPT=$label EXE=$exe IDLE_SEC=$idleSec (NO WM_COMMAND survival cmds)"
  $gui = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) `
    -ArgumentList @('--local','--dir','G:\~dev\rawrxd') -PassThru -WindowStyle Normal
  $pidGui = $gui.Id
  $hwnd = [IntPtr]::Zero
  $ready = $false
  $deadline = (Get-Date).AddSeconds(90)
  while ((Get-Date) -lt $deadline) {
    if (-not (Alive $pidGui)) { break }
    $hwnd = [HostHeapH]::FindMain([uint32]$pidGui)
    if ($hwnd -ne [IntPtr]::Zero) {
      $ready = [HostHeapH]::MenuReady($hwnd)
      if ($ready) { break }
    }
    Start-Sleep -Milliseconds 250
  }
  $aliveLaunch = [int](Alive $pidGui)
  L "  PID=$pidGui HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$ready) ALIVE=$aliveLaunch"
  $phase = 'LAUNCH'
  $hex = 'ALIVE'
  if (-not (Alive $pidGui)) {
    $hex = ExitHex $gui
    $phase = 'LAUNCH_FAIL'
  } elseif (-not $ready) {
    $phase = 'MENU_TIMEOUT'
    # still idle-watch briefly
  } else {
    # idle settle — no IDM posts
    $idleDeadline = (Get-Date).AddSeconds($idleSec)
    $died = $false
    while ((Get-Date) -lt $idleDeadline) {
      if (-not (Alive $pidGui)) { $died = $true; break }
      Start-Sleep -Milliseconds 500
    }
    if ($died) {
      $hex = ExitHex $gui
      $phase = 'IDLE_DEATH'
    } else {
      $to = 0
      $ping = [HostHeapH]::Ping($hwnd, 4000, [ref]$to)
      L "  IDLE_PING ping=$ping timedOut=$to alive=$([int](Alive $pidGui))"
      if (-not (Alive $pidGui)) {
        $hex = ExitHex $gui
        $phase = 'POST_IDLE_DEATH'
      } else {
        $phase = 'IDLE_SURVIVED'
        $hex = 'ALIVE'
      }
    }
  }
  L "  RESULT phase=$phase exit=$hex"
  $script:results.Add("$label|$phase|$hex")
  if ($hex -match 'C0000374') {
    $script:c0000374Hits++
    $script:anyHeapExit++
  } elseif ($hex -match 'C0000409|C0000005') {
    $script:anyHeapExit++  # related fatal; note only
  }
  # leave process killed for next attempt cleanliness
  if (Alive $pidGui) {
    try { Stop-Process -Id $pidGui -Force -EA SilentlyContinue } catch {}
  }
  KillIde
  return @{ Label=$label; Phase=$phase; Exit=$hex }
}

# --- A: live cand 09DB idle x3 (independent of 12200/12230/5170) ---
$a1 = AttemptIdle 'A1_09DB_IDLE15' $exe09 15
$a2 = AttemptIdle 'A2_09DB_IDLE20' $exe09 20
$a3 = AttemptIdle 'A3_09DB_IDLE30' $exe09 30

# --- B: historical pinned 2F37 launch class ---
$b1 = AttemptIdle 'B1_2F37_LAUNCH' $exe2f 10
$b2 = AttemptIdle 'B2_2F37_LAUNCH' $exe2f 10

# New dumps?
Start-Sleep 2
$postDumps = DumpSnapshot
$newDumps = @($postDumps | Where-Object { $preNames -notcontains $_.Name })
L "NEW_DUMP_COUNT=$($newDumps.Count)"
$newDumpLines = @()
foreach ($d in $newDumps) {
  $p = Join-Path $dumpDir $d.Name
  $h = (Get-FileHash $p -A SHA256).Hash
  $line = "NEW_DUMP name=$($d.Name) sha=$h len=$($d.Length) lw=$($d.LastWriteTimeUtc.ToString('o'))"
  L $line
  $newDumpLines += $line
}
$newDumpLines | Set-Content (Join-Path $seal 'logs\NEW_DUMPS.txt')
$results | Set-Content (Join-Path $seal 'logs\ATTEMPTS.txt')

# Host RAM note
$os = Get-CimInstance Win32_OperatingSystem
$totalGb = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
$freeGb = [math]::Round($os.FreePhysicalMemory/1MB, 1)
L "HOST_RAM totalGB=$totalGb freeGB=$freeGb"

$repro09 = [int](($a1.Exit -match 'C0000374') -or ($a2.Exit -match 'C0000374') -or ($a3.Exit -match 'C0000374'))
$repro2f = [int](($b1.Exit -match 'C0000374') -or ($b2.Exit -match 'C0000374'))
$reproLive = $repro09

@"
RUN_ID=$runId
CAND_09DB=$sha09
PIN_2F37=$sha2f
tip748B=$([int]($tipSha -eq $expectTip))
A1=$($a1.Phase)/$($a1.Exit)
A2=$($a2.Phase)/$($a2.Exit)
A3=$($a3.Phase)/$($a3.Exit)
B1=$($b1.Phase)/$($b1.Exit)
B2=$($b2.Phase)/$($b2.Exit)
C0000374_HITS=$c0000374Hits
REPRO_ON_09DB=$repro09
REPRO_ON_2F37=$repro2f
NEW_DUMPS=$($newDumps.Count)
HOST_RAM_TOTAL_GB=$totalGb
HOST_RAM_FREE_GB=$freeGb
SURVIVAL_CMDS_POSTED=0
PROMOTE=0
"@ | Set-Content (Join-Path $seal 'logs\RESULT.txt')

L "DONE REPRO_ON_09DB=$repro09 REPRO_ON_2F37=$repro2f C0000374_HITS=$c0000374Hits"
if ($reproLive -eq 1) { exit 1 } else { exit 0 }
