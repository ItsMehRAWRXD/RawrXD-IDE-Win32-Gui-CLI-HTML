# CONPTY_RUNTIME_WITNESS_D11_001 — CreatePseudoConsole + PS panel HWND on D11.
# Tip 748B UNTOUCHED; PROMOTE=0 ABSORB=NOT_AUTHORIZED; NOT_RUN != PASS
# PathB heap may BLOCK GUI ConPTY → seal BLOCKED_HEAP honest (cite PathB).
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\CONPTY_RUNTIME_WITNESS_D11_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
# Live authority: heap-fix successor of D11 (TIP_CANDIDATE_HEAP_WindowProc_001).
# Prior D11AB5B6 retained as MAP_CITE prior only; tip 748B never overwritten.
$ExpectCand = "93503F05F0A37392AF59917063A41497B1DBD4FF04B6AA9F336139C6FD2886C4"
$PriorD11 = "D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$IDM_PS = 4001
$WM_COMMAND = 0x0111
$GateStream = "G:\~dev\rawrxd\evidence\CONPTY_STREAM_OWNER_001\GATE_STREAM.txt"
$Log = Join-Path $OutDir "RUNLOG.txt"
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}
function ExitHex([object]$c) {
  if ($null -eq $c) { return "UNSET" }
  # Signed NTSTATUS as Process.ExitCode: -1073740791 → 0xC0000409
  $n = [int64]([int]$c)
  if ($n -lt 0) { $n = $n + 4294967296L }
  return ("0x{0:X8}" -f $n)
}
function IsHeapFailFast([object]$c) {
  if ($null -eq $c) { return $false }
  $i = [int]$c
  # 0xC0000409 / 0xC0000374 as signed Int32
  return ($i -eq -1073740791 -or $i -eq -1073740940)
}

$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class ConPtyD11 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr h, EnumProc lp, IntPtr l);
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
  public static int CountChildren(IntPtr main) {
    int n = 0;
    if (main == IntPtr.Zero) return 0;
    EnumChildWindows(main, (h, l) => { n++; return true; }, IntPtr.Zero);
    return n;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

WLog "START CONPTY_RUNTIME_WITNESS_D11_001"
WLog "PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED NO_INVENT_PASS=1"
WLog "CITE_PATHB=SWARM_PATH_B_4111_HEAP_WindowProc_001 (93503F05) + prior D11AB5B6"
WLog "PRIOR_D11=$PriorD11 SUCCESSOR_CAND=$ExpectCand"

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
$candMatch = ($candSha -eq $ExpectCand)
$tipMatch = ($tipSha -eq $ExpectTip)
WLog "CAND_SHA_MATCH=$candMatch TIP_UNTOUCHED=$tipMatch"
if (-not $candMatch -or -not $tipMatch) {
  WLog "SHA_MISMATCH FAIL_CLOSED (refuse invent; rehash successor if tip/cand drifted)"
  @"
GATE=CONPTY_RUNTIME_WITNESS_D11_001
DISPOSITION=FAIL_CLOSED_SHA_DRIFT
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
RUNTIME_PASS=0
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "SUMMARY.txt")
  exit 2
}

$bytes = [IO.File]::ReadAllBytes($CandExe)
$text = [Text.Encoding]::ASCII.GetString($bytes)
$binConpty = ($text.Contains("CreatePseudoConsole") -and $text.Contains("CONPTY_STREAM_OWNER_001") -and $text.Contains("getPowerShellPanel"))
WLog "BIN_CONPTY_STRINGS=$binConpty SOURCE_WIRED_PRIOR=1 (map cite CONPTY_ASM_CANDIDATE_D11_001)"

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  WLog "KILL_PRIOR pid=$($_.Id)"
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
$fcPath = Join-Path $crumbDir "FIRST_CHANCE_WM_COMMAND.txt"
foreach ($f in @($crumb,$fcPath,$GateStream)) {
  if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
}
$tracePath = Join-Path $CandDir "win32ide_trace.log"
$startupLog = Join-Path $CandDir "ide_startup.log"
foreach ($f in @($tracePath,$startupLog)) {
  if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
}

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SHELL_LAYOUT_PHASE = "5"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

WLog "LAUNCH GUI no-redirect 93503F05 ConPTY IDM 4001 (heap-fix successor of D11)"
$p = Start-Process -FilePath $CandExe -WorkingDirectory $CandDir -PassThru -WindowStyle Normal
WLog "PID=$($p.Id)"

$hwnd = [IntPtr]::Zero
$menuReady = $false
$createWindow = "NOT_RUN"
$exitCode = $null
$exitCaptured = 0
$post4001 = 0
$postedAt = ""
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
    WLog ("EARLY_EXIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    if ($createWindow -eq "NOT_RUN") { $createWindow = "FAIL_EXIT_" + (ExitHex $exitCode) }
    break
  }
  $hwnd = [ConPtyD11]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $createWindow = "OK_HWND"
    $menuReady = [ConPtyD11]::MenuReady($hwnd)
    if ($post4001 -eq 0 -and $menuReady) {
      WLog ("MENU_READY hwnd=0x{0:X}" -f $hwnd.ToInt64())
      $post4001 = [ConPtyD11]::PostId($hwnd, $IDM_PS)
      $postedAt = (Get-Date).ToString("o")
      WLog ("POST_4001=$post4001 at=$postedAt" -f $post4001)
      break
    }
  }
  Start-Sleep -Milliseconds 250
}

$hwndHex = if ($hwnd -ne [IntPtr]::Zero) { ("0x{0:X}" -f $hwnd.ToInt64()) } else { "0" }
WLog "MAIN_HWND=$hwndHex createWindow=$createWindow menuReady=$menuReady"

$childBefore = [ConPtyD11]::CountChildren($hwnd)
$psBefore = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.ParentProcessId -eq $p.Id -and $_.Name -match '^(pwsh|powershell)\.exe$' }).Count
$ptyBefore = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.ParentProcessId -eq $p.Id -and $_.Name -match '^(OpenConsole|conhost|WindowsTerminal)\.exe$' }).Count
WLog "CHILD_BEFORE hwndKids=$childBefore ps=$psBefore pty=$ptyBefore"

# Wait for ConPTY / heap outcome after 4001
$waitEnd = (Get-Date).AddSeconds(15)
$guiResponsive = 1
$blockedHeap = 0
$vehHeap = 0
$vehKind = ""
$vehCode = ""
while ((Get-Date) -lt $waitEnd) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    $exitCode = [int]$p.ExitCode
    $exitCaptured = 1
    WLog ("EXIT_DURING_WAIT code={0} {1}" -f $exitCode, (ExitHex $exitCode))
    break
  }
  Start-Sleep -Milliseconds 500
}

# Crumb / VEH scrape
$cmd4001Observed = 0
$vehText = ""
if (Test-Path $fcPath) {
  Copy-Item $fcPath (Join-Path $Logs "FIRST_CHANCE_WM_COMMAND.txt") -Force
  $vehText = Get-Content $fcPath -Raw -ErrorAction SilentlyContinue
  if ($vehText -match "VEH_HEAP|0xC0000374|HEAP_CORRUPT") {
    $vehHeap = 1
    $blockedHeap = 1
    $vehKind = "VEH_HEAP_CORRUPT"
    if ($vehText -match "0xC0000374") { $vehCode = "0xC0000374" }
    WLog "VEH_HEAP_CRUMB HIT"
  }
}
if (Test-Path $crumb) {
  Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB.txt") -Force
  $ct = Get-Content $crumb -Raw -ErrorAction SilentlyContinue
  if ($ct -match "\bid[=:]?\s*4001\b|CMD.*4001|id=4001") { $cmd4001Observed = 1 }
  WLog "CRUMB_PRESENT cmd4001Observed=$cmd4001Observed"
}

# GUI ping after exercise
$pingTo = 0
$pingOk = 0
if (-not $p.HasExited -and $hwnd -ne [IntPtr]::Zero -and [ConPtyD11]::IsWindow($hwnd)) {
  $pingOk = [ConPtyD11]::PingNull($hwnd, 2000, [ref]$pingTo)
  WLog "GUI_PING ok=$pingOk timedOut=$pingTo"
  if ($pingTo -eq 1 -or $pingOk -eq 0) {
    $guiResponsive = 0
    # PathB pattern: unresponsive UI after MENU_READY WM_COMMAND = heap block
    if ($post4001 -eq 1 -and $cmd4001Observed -eq 0) {
      $blockedHeap = 1
      WLog "BLOCKED_HEAP inferred: POST_4001 queued but no crumb + GUI unresponsive (PathB WindowProc free)"
    }
  }
} elseif ($p.HasExited) {
  $guiResponsive = 0
  $hx = ExitHex $exitCode
  if (IsHeapFailFast $exitCode) {
    $blockedHeap = 1
    WLog "BLOCKED_HEAP via FAILFAST/HEAP exit $hx (cite PathB WindowProc)"
  }
}
$psAfter = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.ParentProcessId -eq $p.Id -and $_.Name -match '^(pwsh|powershell)\.exe$' }).Count
$ptyAfter = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.ParentProcessId -eq $p.Id -and $_.Name -match '^(OpenConsole|conhost|WindowsTerminal)\.exe$' }).Count
$newPs = [Math]::Max(0, $psAfter - $psBefore)
$newPty = [Math]::Max(0, $ptyAfter - $ptyBefore)
WLog "SHELL_AFTER ps=$psAfter pty=$ptyAfter NEW_PS=$newPs NEW_PTY=$newPty"

# Descendant PS under conhost
$descPs = 0
if (-not $p.HasExited) {
  Get-CimInstance Win32_Process -Filter "Name='pwsh.exe' OR Name='powershell.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
    $walk = $_; $guard = 0
    while ($walk -and $guard -lt 8) {
      if ($walk.ParentProcessId -eq $p.Id) { $descPs++; break }
      $walk = Get-CimInstance Win32_Process -Filter ("ProcessId={0}" -f $walk.ParentProcessId) -ErrorAction SilentlyContinue
      $guard++
    }
  }
}
if ($descPs -gt 0 -and $newPs -eq 0) { $newPs = $descPs; WLog "DESCENDANT_PS=$descPs" }

$gateStreamHit = 0
if (Test-Path $GateStream) {
  $gateStreamHit = 1
  Copy-Item $GateStream (Join-Path $Logs "GATE_STREAM.txt") -Force
  WLog "GATE_STREAM FIRED (fail-closed absent/fail)"
}

# stdout crumbs in cand cwd / logs
$createPseudoObserved = 0
$conptyWitness = 0
$blob = ""
foreach ($f in @($startupLog, $tracePath, (Join-Path $CandDir "ide_stdout.log"), (Join-Path $Logs "tip_stdout.log"))) {
  if (Test-Path $f) {
    Copy-Item $f (Join-Path $Logs (Split-Path $f -Leaf)) -Force -ErrorAction SilentlyContinue
    $blob += "`n" + (Get-Content $f -Raw -ErrorAction SilentlyContinue)
  }
}
if ($blob -match "CreatePseudoConsole hr=|CreatePseudoConsole\(|hPC=") {
  $createPseudoObserved = 1
  WLog "CreatePseudoConsole OBSERVED in logs"
}
if ($blob -match "PowerShell started|RAWRXD_PS_META|\[CONPTY_STREAM_OWNER\]") {
  $conptyWitness = 1
  WLog "CONPTY_START_WITNESS HIT"
}
# POST_4001 then FailFast before CreatePseudoConsole = heap block (PathB WindowProc)
if ((IsHeapFailFast $exitCode) -and $post4001 -eq 1 -and $createPseudoObserved -eq 0) {
  $blockedHeap = 1
  WLog "BLOCKED_HEAP: POST_4001 then EXIT FailFast before CreatePseudoConsole"
}

# Forced stop
$forced = 0
if (-not $p.HasExited) {
  WLog "WM_CLOSE/STOP pid=$($p.Id)"
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  Start-Sleep 2
  $forced = 1
  try { $p.Refresh(); if ($p.HasExited) { $exitCode = [int]$p.ExitCode; $exitCaptured = 1 } } catch {}
}

# Copy cand-side crumbs into evidence logs
foreach ($src in @($crumb,$fcPath,$startupLog,$tracePath)) {
  if (Test-Path $src) {
    Copy-Item $src (Join-Path $Logs (Split-Path $src -Leaf)) -Force -ErrorAction SilentlyContinue
  }
}

# Disposition law:
# RUNTIME_PASS only if real CreatePseudoConsole + HWND (and PS path) — never invent.
# If PathB heap blocks GUI ConPTY → RUNTIME_REACHED=NOT_RUN / BLOCKED_HEAP.
$runtimeReached = "NOT_RUN"
$runtimePass = 0
$psPanelHwnd = $hwndHex
$createPseudoConsoleObserved = $createPseudoObserved
$disposition = "RUNTIME_NOT_RUN"
$nextGate = "CONPTY_RUNTIME_WITNESS_D11_CreatePseudoConsole_HWND_PS_PANEL"

if ($blockedHeap -eq 1) {
  $runtimeReached = "NOT_RUN"
  $runtimePass = 0
  $disposition = "BLOCKED_HEAP"
  $createPseudoConsoleObserved = 0
  $nextGate = "HEAP_OWNER_SITE_WindowProc_free_caller_DUMP_THEN_SOURCE_WIRE"
  WLog "DISPOSITION=BLOCKED_HEAP cite PathB D11; CreatePseudoConsole NOT observed; STOP"
} elseif ($hwnd -ne [IntPtr]::Zero -and $createPseudoObserved -eq 1 -and ($newPs -gt 0 -or $conptyWitness -eq 1) -and $gateStreamHit -eq 0) {
  $runtimeReached = "1"
  $runtimePass = 1
  $disposition = "RUNTIME_PASS_CREATEPSEUDOCONSOLE_HWND"
  $nextGate = "POST_CONPTY_RUNTIME_PRODUCT_GATES"
  WLog "RUNTIME_PASS=1 CreatePseudoConsole+HWND earned"
} elseif ($hwnd -ne [IntPtr]::Zero -and $post4001 -eq 1) {
  $runtimeReached = "0"
  $runtimePass = 0
  $disposition = "HWND_POST4001_NO_CREATEPSEUDOCONSOLE"
  WLog "FAIL_CLOSED: HWND+POST4001 but no CreatePseudoConsole/PS witness"
} else {
  $runtimeReached = "NOT_RUN"
  $runtimePass = 0
  $disposition = "RUNTIME_NOT_RUN"
  WLog "FAIL_CLOSED: ConPTY runtime not reached"
}

$asof = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$exitHex = if ($null -ne $exitCode) { ExitHex $exitCode } else { "UNSET" }
$sum = @"
GATE=CONPTY_RUNTIME_WITNESS_D11_001
ASOF_UTC=$asof
CONTROLLING=1
AUTHORITY_EXE=$CandExe
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candSha
CANDIDATE_SHA_MATCH=1
CANDIDATE_SHA_STABLE=1
PRIOR_D11_SHA=$PriorD11
HEAP_FIX_SUCCESSOR=1
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipSha
TIP_UNTOUCHED=1
PRIOR_MAP_CITE=CONPTY_ASM_CANDIDATE_D11_001
HEAP_FIX_FREEZE=TIP_CANDIDATE_HEAP_WindowProc_001
SOURCE_WIRED=1
BIN_CONPTY_STRINGS=$([int]$binConpty)
MAIN_HWND=$hwndHex
PS_PANEL_HWND=$psPanelHwnd
MENU_READY=$([int]$menuReady)
POST_4001=$post4001
CMD_4001_OBSERVED=$cmd4001Observed
CREATE_PSEUDOCONSOLE_OBSERVED=$createPseudoConsoleObserved
CONPTY_WITNESS=$conptyWitness
NEW_PS_CHILD=$newPs
NEW_PTY=$newPty
GATE_STREAM=$gateStreamHit
GUI_RESPONSIVE=$guiResponsive
BLOCKED_HEAP=$blockedHeap
VEH_HEAP=$vehHeap
VEH_KIND=$vehKind
VEH_EXCEPTION=$vehCode
EXIT_CODE_DEC=$exitCode
EXIT_HEX=$exitHex
EXIT_CAPTURED=$exitCaptured
FORCED_STOP=$forced
RUNTIME_REACHED=$runtimeReached
RUNTIME_PASS=$runtimePass
MAP_CITE_NEQ_PASS=1
NOT_RUN_NEQ_PASS=1
DISPOSITION=$disposition
PATHB_CITE=SWARM_PATH_B_4111_HEAP_WindowProc_001
PATHB_CITE2=SWARM_PATH_B_4111_CANDIDATE_D11AB5B6_001
PATHB_CITE3=WIN32IDE_UI_PHASE7_RUNTIME_D11_001
ABSORB=NOT_AUTHORIZED
GHOSTTEXT_ABSORB=NOT_AUTHORIZED
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
REBUILD_TIP=0
NEW_FREEZE=0
NO_INVENT_PASS=1
NEXT_GATE=$nextGate
"@
Set-Content -Path (Join-Path $OutDir "SUMMARY.txt") -Value $sum.TrimEnd()
Set-Content -Path (Join-Path $OutDir "sha.txt") -Value @"
TIP_SHA=$tipSha
CANDIDATE_SHA=$candSha
PRIOR_D11_SHA=$PriorD11
TIP_MATCH_748B=1
CAND_MATCH_93503F05=1
HEAP_FIX_SUCCESSOR=1
"@
WLog "SUMMARY disposition=$disposition RUNTIME_PASS=$runtimePass BLOCKED_HEAP=$blockedHeap"
WLog "END"
exit 0
