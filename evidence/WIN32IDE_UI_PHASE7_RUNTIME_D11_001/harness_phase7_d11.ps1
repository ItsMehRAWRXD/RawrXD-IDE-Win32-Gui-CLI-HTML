# WIN32IDE_UI_PHASE7_RUNTIME_D11_001 — live candidate Phase7 Settings+TaskRunner prove
# Tip 748B UNTOUCHED; PROMOTE=0 ABSORB=NOT_AUTHORIZED; NOT_RUN != PASS
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\WIN32IDE_UI_PHASE7_RUNTIME_D11_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$Log = Join-Path $OutDir "RUNLOG.txt"
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
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class Phase7D11 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
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
  public static int PostId(IntPtr h, int id) { return PostMessageW(h, 0x0111, (IntPtr)id, IntPtr.Zero) ? 1 : 0; }
  public static int PingNull(IntPtr h, uint timeoutMs, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, timeoutMs, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
  public static int CountClass(uint pid, string className) {
    int n = 0;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      GetClassNameW(h, cls, 256);
      if (cls.ToString() == className) n++;
      return true;
    }, IntPtr.Zero);
    return n;
  }
  public static int CountTitleNeedle(uint pid, string needle) {
    int n = 0;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      var ttl = new StringBuilder(512);
      GetClassNameW(h, cls, 256);
      GetWindowTextW(h, ttl, 512);
      string c = cls.ToString(); string t = ttl.ToString();
      if (t.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0 ||
          c.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0) n++;
      return true;
    }, IntPtr.Zero);
    return n;
  }
  public static List<string> DumpTops(uint pid) {
    var rows = new List<string>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      var ttl = new StringBuilder(512);
      GetClassNameW(h, cls, 256);
      GetWindowTextW(h, ttl, 512);
      rows.Add("0x" + h.ToInt64().ToString("X") + "|" + cls + "|" + ttl);
      return true;
    }, IntPtr.Zero);
    return rows;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

WLog "START WIN32IDE_UI_PHASE7_RUNTIME_D11_001"
WLog "PROMOTE=0 ABSORB=NOT_AUTHORIZED SOURCE_PRIOR=WIN32IDE_UI_PHASE7_SETTINGS_TASKRUNNER_SOURCE_001"

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
"CANDIDATE_SHA=$candSha`nTIP_SHA=$tipSha" | Set-Content (Join-Path $Logs "sha_pre.txt")
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=WIN32IDE_UI_PHASE7_RUNTIME_D11_001
DISPOSITION=FAIL_CLOSED_SHA_DRIFT
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
EXPECT_CAND=$ExpectCand
EXPECT_TIP=$ExpectTip
UI_ACCEPTANCE_PASS=0
RUNTIME_REACHED=0
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB=NOT_AUTHORIZED
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
  exit 2
}

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
$fcPath = Join-Path $crumbDir "FIRST_CHANCE_WM_COMMAND.txt"
foreach ($f in @($crumb,$fcPath)) { if (Test-Path $f) { Remove-Item $f -Force } }
$tracePath = Join-Path $CandDir "win32ide_trace.log"
if (Test-Path $tracePath) { Remove-Item $tracePath -Force }
$startupLog = Join-Path $CandDir "ide_startup.log"
if (Test-Path $startupLog) { Remove-Item $startupLog -Force }

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
Remove-Item Env:RAWRXD_SWARM_N -ErrorAction SilentlyContinue

WLog "LAUNCH GUI no-redirect D11 Phase7 Settings+TaskRunner"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$exitCode = $null
$exitCaptured = 0
$blockedHeap = 0
$uiReached = 0
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
    $u = [uint32]($exitCode -band 0xFFFFFFFF)
    WLog ("EARLY_EXIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_" + (ExitHex $exitCode) }
    if ($u -eq 0xC0000409 -or $u -eq 0xC0000374 -or $u -eq 0xC0000005) {
      $blockedHeap = 1
      WLog "BLOCKED_HEAP early crash before Phase7 exercise"
    }
    break
  }
  $hwnd = [Phase7D11]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [Phase7D11]::MenuReady($hwnd)
    if ($menuReady) {
      $createWindow = "OK_HWND_MENU_READY"
      $uiReached = 1
      WLog ("MENU_READY hwnd=0x{0:X}" -f $hwnd.ToInt64())
      break
    }
  }
  Start-Sleep -Milliseconds 100
}

# If HWND but no menu-ready after wait: still observe crash vs hang
if ($uiReached -eq 0 -and -not $p.HasExited -and $hwnd -ne [IntPtr]::Zero) {
  WLog ("HWND_NO_MENU_READY hwnd=0x{0:X} wait more" -f $hwnd.ToInt64())
  $extra = (Get-Date).AddSeconds(30)
  while ((Get-Date) -lt $extra) {
    try { $p.Refresh() } catch {}
    if ($p.HasExited) {
      $exitCode = [int]$p.ExitCode; $exitCaptured = 1
      $u = [uint32]($exitCode -band 0xFFFFFFFF)
      WLog ("EXIT_WAITING_MENU {0}" -f (ExitHex $exitCode))
      if ($u -eq 0xC0000409 -or $u -eq 0xC0000374) { $blockedHeap = 1 }
      break
    }
    if ([Phase7D11]::MenuReady($hwnd)) {
      $menuReady = $true; $uiReached = 1
      $createWindow = "OK_HWND_MENU_READY"
      WLog "MENU_READY late"
      break
    }
    Start-Sleep -Milliseconds 200
  }
}

$post5199 = 0; $post5016 = 0; $post502 = 0; $post12040 = 0
$taskRunnerHits = 0; $settingsHits = 0
$gateTaskRunner = "NOT_RUN"
$gateSettings = "NOT_RUN"
$guiResponsive = 0
$pingTo = 1

if ($blockedHeap -eq 1 -or ($uiReached -eq 0 -and $exitCaptured -eq 1)) {
  WLog "STOP_NO_EXERCISE blockedHeap=$blockedHeap uiReached=$uiReached"
  $gateTaskRunner = "BLOCKED_HEAP"
  $gateSettings = "BLOCKED_HEAP"
} elseif ($uiReached -eq 1 -and -not $p.HasExited) {
  # Exercise Phase7 IDs — fail-closed if heap kills UI thread mid-command
  WLog "EXERCISE_IDM TaskRunner=5199 Settings=5016 502 12040"
  $post5199 = [Phase7D11]::PostId($hwnd, 5199)
  WLog "POST_5199=$post5199"
  Start-Sleep -Seconds 2
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode; $exitCaptured = 1
    $u = [uint32]($exitCode -band 0xFFFFFFFF)
    WLog ("EXIT_AFTER_5199 {0}" -f (ExitHex $exitCode))
    if ($u -eq 0xC0000409 -or $u -eq 0xC0000374) {
      $blockedHeap = 1
      $gateTaskRunner = "BLOCKED_HEAP"
      $gateSettings = "BLOCKED_HEAP"
    } else {
      $gateTaskRunner = "FAIL_CLOSED_EXIT"
      $gateSettings = "NOT_RUN"
    }
  } else {
    $taskRunnerHits = [Phase7D11]::CountClass([uint32]$p.Id, "RawrXD_TaskRunner")
    if ($taskRunnerHits -eq 0) {
      $taskRunnerHits = [Phase7D11]::CountTitleNeedle([uint32]$p.Id, "Task Runner")
    }
    WLog "TASKRUNNER_HITS=$taskRunnerHits"
    if (($post5199 -eq 1) -and ($taskRunnerHits -gt 0)) {
      $gateTaskRunner = "RUNTIME_REACHED"
    } elseif ($post5199 -eq 1) {
      $gateTaskRunner = "RUNTIME_REACHED_POST_ONLY"
    } else {
      $gateTaskRunner = "FAIL_CLOSED_POST"
    }

    $post5016 = [Phase7D11]::PostId($hwnd, 5016)
    WLog "POST_5016=$post5016"
    Start-Sleep -Seconds 1
    try { $p.Refresh() } catch {}
    if ($p.HasExited) {
      $exitCode = [int]$p.ExitCode; $exitCaptured = 1
      $u = [uint32]($exitCode -band 0xFFFFFFFF)
      WLog ("EXIT_AFTER_5016 {0}" -f (ExitHex $exitCode))
      if ($u -eq 0xC0000409 -or $u -eq 0xC0000374) {
        $blockedHeap = 1
        $gateSettings = "BLOCKED_HEAP"
      } else {
        $gateSettings = "FAIL_CLOSED_EXIT"
      }
    } else {
      $post502 = [Phase7D11]::PostId($hwnd, 502)
      WLog "POST_502=$post502"
      Start-Sleep -Milliseconds 800
      $post12040 = [Phase7D11]::PostId($hwnd, 12040)
      WLog "POST_12040=$post12040"
      Start-Sleep -Seconds 2
      try { $p.Refresh() } catch {}
      if ($p.HasExited) {
        $exitCode = [int]$p.ExitCode; $exitCaptured = 1
        $u = [uint32]($exitCode -band 0xFFFFFFFF)
        WLog ("EXIT_AFTER_SETTINGS {0}" -f (ExitHex $exitCode))
        if ($u -eq 0xC0000409 -or $u -eq 0xC0000374) {
          $blockedHeap = 1
          $gateSettings = "BLOCKED_HEAP"
        } else {
          $gateSettings = "FAIL_CLOSED_EXIT"
        }
      } else {
        $settingsHits = [Phase7D11]::CountTitleNeedle([uint32]$p.Id, "Settings")
        $settingsHits += [Phase7D11]::CountTitleNeedle([uint32]$p.Id, "Preferences")
        WLog "SETTINGS_HITS=$settingsHits"
        $anyPost = (($post5016 + $post502 + $post12040) -gt 0)
        if ($anyPost -and ($settingsHits -gt 0)) {
          $gateSettings = "RUNTIME_REACHED"
        } elseif ($anyPost) {
          $gateSettings = "RUNTIME_REACHED_POST_ONLY"
        } else {
          $gateSettings = "FAIL_CLOSED_POST"
        }
        $to = 0
        $pingOk = [Phase7D11]::PingNull($hwnd, 2000, [ref]$to)
        $pingTo = $to
        if ($pingOk -eq 1 -and $pingTo -eq 0) { $guiResponsive = 1 }
        WLog ("GUI_PING ok={0} timedOut={1}" -f $pingOk, $pingTo)
        [Phase7D11]::DumpTops([uint32]$p.Id) | Set-Content (Join-Path $Logs "toplevel_hwnd.txt")
      }
    }
  }
} else {
  WLog "NO_UI_REACHED createWindow=$createWindow"
  $gateTaskRunner = "FAIL_CLOSED_NO_UI"
  $gateSettings = "FAIL_CLOSED_NO_UI"
}

$forcedStop = 0
if ($p -and (-not $p.HasExited)) {
  WLog "WM_CLOSE pid=$($p.Id)"
  if ($hwnd -ne [IntPtr]::Zero) {
    [void][Phase7D11]::PostMessageW($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
  }
  $closeDeadline = (Get-Date).AddSeconds(10)
  while ((Get-Date) -lt $closeDeadline) {
    try { $p.Refresh() } catch {}
    if ($p.HasExited) { $exitCode = [int]$p.ExitCode; $exitCaptured = 1; break }
    Start-Sleep -Milliseconds 200
  }
  if (-not $p.HasExited) {
    $forcedStop = 1
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    try { $p.Refresh() } catch {}
    if ($p.HasExited) { $exitCode = [int]$p.ExitCode; $exitCaptured = 1 }
  }
}

if ($exitCaptured -eq 0) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) { $exitCode = [int]$p.ExitCode; $exitCaptured = 1 }
  else { $exitCode = -1; $exitCaptured = 1 }
}
$exitHex = ExitHex $exitCode
$uFinal = [uint32]([int]$exitCode -band 0xFFFFFFFF)
if ($uFinal -eq 0xC0000409 -or $uFinal -eq 0xC0000374) {
  if ($gateTaskRunner -ne "RUNTIME_REACHED" -or $gateSettings -ne "RUNTIME_REACHED") {
    $blockedHeap = 1
  }
}
WLog ("FINAL_EXIT dec={0} hex={1} blockedHeap={2} forced={3}" -f $exitCode, $exitHex, $blockedHeap, $forcedStop)

# Collect logs
if (Test-Path $crumb) { Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB.txt") -Force }
if (Test-Path $fcPath) { Copy-Item $fcPath (Join-Path $Logs "FIRST_CHANCE_WM_COMMAND.txt") -Force }
if (Test-Path $tracePath) { Copy-Item $tracePath (Join-Path $Logs "win32ide_trace.log") -Force }
if (Test-Path $startupLog) { Copy-Item $startupLog (Join-Path $Logs "ide_startup.log") -Force }

$vehHeap = 0
$vehText = ""
if (Test-Path $fcPath) {
  $vehText = Get-Content $fcPath -Raw -ErrorAction SilentlyContinue
  if ($vehText -match "VEH_HEAP|0xC0000374|HEAP_CORRUPT") { $vehHeap = 1; $blockedHeap = 1 }
}
$crumbText = ""
if (Test-Path $crumb) { $crumbText = Get-Content $crumb -Raw -ErrorAction SilentlyContinue }
if ($crumbText -match "WindowProc" -and ($crumbText -match "0xC0000374|VEH_HEAP|HEAP")) {
  $blockedHeap = 1; $vehHeap = 1
}

$candShaAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipShaAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
"CANDIDATE_SHA_AFTER=$candShaAfter`nTIP_SHA_AFTER=$tipShaAfter" | Set-Content (Join-Path $Logs "sha_post.txt")

$runtimeReached = 0
if ($gateTaskRunner -eq "RUNTIME_REACHED" -and $gateSettings -eq "RUNTIME_REACHED") { $runtimeReached = 1 }

# FAIL-CLOSED: never invent PASS
$uiAccept = 0
$disposition = "PHASE7_RUNTIME_FAIL_CLOSED"
if ($blockedHeap -eq 1) {
  $disposition = "BLOCKED_HEAP"
  $uiAccept = 0
  if ($gateTaskRunner -eq "NOT_RUN") { $gateTaskRunner = "BLOCKED_HEAP" }
  if ($gateSettings -eq "NOT_RUN") { $gateSettings = "BLOCKED_HEAP" }
} elseif ($runtimeReached -eq 1 -and $guiResponsive -eq 1 -and $forcedStop -eq 0 -and $uFinal -eq 0) {
  # Still require honest E2E — do not auto-promote UI_ACCEPTANCE without dialog HWND proof
  $uiAccept = 0
  $disposition = "RUNTIME_REACHED_UI_ACCEPTANCE_HELD"
} elseif ($runtimeReached -eq 1) {
  $uiAccept = 0
  $disposition = "RUNTIME_PARTIAL_NO_UI_ACCEPTANCE"
} elseif ($uiReached -eq 1) {
  $disposition = "MENU_READY_PHASE7_EXERCISE_INCOMPLETE"
} else {
  $disposition = "FAIL_CLOSED_NO_UI"
}

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$nextGate = "HEAP_OWNER_SITE_WindowProc_free_caller_DUMP_THEN_SOURCE_WIRE"
if ($blockedHeap -eq 0 -and $runtimeReached -eq 1) {
  $nextGate = "PHASE7_HWND_DIALOG_E2E_THEN_UI_ACCEPTANCE"
} elseif ($blockedHeap -eq 0 -and $uiReached -eq 1) {
  $nextGate = "PHASE7_REPROVE_TASKRUNNER_SETTINGS_HWND"
}

$summary = @"
GATE=WIN32IDE_UI_PHASE7_RUNTIME_D11_001
ASOF_UTC=$asof
CONTROLLING=1
AUTHORITY_EXE=$CandExe
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candShaAfter
CANDIDATE_SHA_MATCH=$([int]($candSha -eq $ExpectCand))
CANDIDATE_SHA_STABLE=$([int]($candShaAfter -eq $candSha))
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipShaAfter
TIP_UNTOUCHED=$([int](($tipSha -eq $ExpectTip) -and ($tipShaAfter -eq $ExpectTip)))
PRIOR_SOURCE=WIN32IDE_UI_PHASE7_SETTINGS_TASKRUNNER_SOURCE_001
SOURCE_WIRED=1
createWindow=$createWindow
MAIN_HWND=0x$("{0:X}" -f $(if ($hwnd -ne [IntPtr]::Zero) { $hwnd.ToInt64() } else { 0 }))
MENU_READY=$([int]$menuReady)
UI_REACHED=$uiReached
BLOCKED_HEAP=$blockedHeap
VEH_HEAP=$vehHeap
EXIT_CODE_DEC=$exitCode
EXIT_HEX=$exitHex
EXIT_CAPTURED=$exitCaptured
FORCED_STOP=$forcedStop
GUI_RESPONSIVE=$guiResponsive
POST_5199=$post5199
POST_5016=$post5016
POST_502=$post502
POST_12040=$post12040
TASKRUNNER_HITS=$taskRunnerHits
SETTINGS_HITS=$settingsHits
GATE_TASKRUNNER=$gateTaskRunner
GATE_SETTINGS=$gateSettings
RUNTIME_REACHED=$runtimeReached
UI_ACCEPTANCE_PASS=$uiAccept
DISPOSITION=$disposition
ABSORB=NOT_AUTHORIZED
GHOSTTEXT_ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
REBUILD_TIP=0
NO_INVENT_PASS=1
NEXT_GATE=$nextGate
"@
$summary | Set-Content (Join-Path $OutDir "SUMMARY.txt")
WLog "SUMMARY written disposition=$disposition UI_ACCEPTANCE_PASS=$uiAccept"
WLog "END"
exit 0
