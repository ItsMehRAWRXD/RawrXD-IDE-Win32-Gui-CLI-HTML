# COLD_RESTART_SHELL_MODE_001 — prove Work Mode survives full process kill+relaunch
# AUTHORIZE_CANDIDATE_ONLY=1; tip748B FROZEN; PROMOTE=0
# SOURCE_WIRED != RUNTIME != PASS. PathB/N2/EXT alone != cold-restart PASS.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_014\COLD_RESTART_SHELL_MODE_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "4E4345C2F41F2A3FF34877EB68DE37257C0C0CFFCA0364CB0F4481643BC76106"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$SessionPath = Join-Path $env:APPDATA "RawrXD\session.json"
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
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class ColdRestart014 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr h, EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
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
  public static string Title(IntPtr h) {
    var b = new StringBuilder(512);
    GetWindowTextW(h, b, 512);
    return b.ToString();
  }
  public static bool MenuReady(IntPtr main) { return GetPropW(main, "RawrXD.MainMenuReady") != IntPtr.Zero; }
  public static List<string> DumpTops(uint pid) {
    var rows = new List<string>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      var ttl = new StringBuilder(512);
      GetClassNameW(h, cls, 256);
      GetWindowTextW(h, ttl, 512);
      rows.Add(string.Format("TOP hwnd=0x{0:X} visible={1} class='{2}' title='{3}'",
        h.ToInt64(), IsWindowVisible(h), cls, ttl));
      return true;
    }, IntPtr.Zero);
    return rows;
  }
  public static List<string> DumpChildren(IntPtr parent) {
    var rows = new List<string>();
    if (parent == IntPtr.Zero || !IsWindow(parent)) return rows;
    EnumChildWindows(parent, (h, l) => {
      var cls = new StringBuilder(256);
      var ttl = new StringBuilder(512);
      GetClassNameW(h, cls, 256);
      GetWindowTextW(h, ttl, 512);
      string t = ttl.ToString();
      if (t.Length > 120) t = t.Substring(0, 120);
      rows.Add(string.Format("CHILD hwnd=0x{0:X} visible={1} class='{2}' title='{3}'",
        h.ToInt64(), IsWindowVisible(h), cls, t));
      return true;
    }, IntPtr.Zero);
    return rows;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

WLog "START COLD_RESTART_SHELL_MODE_001"
WLog "PROMOTE=0 tip748B=FROZEN AUTHORIZE_CANDIDATE_ONLY=1"

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
"CANDIDATE_SHA=$candSha`nTIP_SHA=$tipSha" | Set-Content (Join-Path $Logs "sha_pre.txt")
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=COLD_RESTART_SHELL_MODE_001
DISPOSITION=FAIL_CLOSED_SHA_DRIFT
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
EXPECT_CAND=$ExpectCand
EXPECT_TIP=$ExpectTip
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RECEIPT.md")
  exit 2
}

# Kill any leftover IDE fully (cold start prerequisite)
Get-Process -Name "RawrXD-Win32IDE","RawrXD-ExtensionHost" -ErrorAction SilentlyContinue |
  ForEach-Object {
    WLog "KILL_PRE pid=$($_.Id)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
  }
Start-Sleep -Seconds 2
$alive = @(Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue)
if ($alive.Count -gt 0) {
  WLog "KILL_PRE_INCOMPLETE FAIL_CLOSED"
  exit 3
}
WLog "PROCESS_CLEAR=1"

# Seed session.json shellMode=work (preserve other keys)
if (-not (Test-Path $SessionPath)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $SessionPath) | Out-Null
  '{"version":2,"schemaVersion":"2.2","shellMode":"work"}' | Set-Content $SessionPath -Encoding UTF8
} else {
  Copy-Item $SessionPath (Join-Path $Logs "session_pre_seed.json") -Force
  $j = Get-Content $SessionPath -Raw | ConvertFrom-Json
  $j.shellMode = "work"
  $j.timestamp = [string]([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
  $j | ConvertTo-Json -Depth 20 | Set-Content $SessionPath -Encoding UTF8
}
Copy-Item $SessionPath (Join-Path $Logs "session_seeded_work.json") -Force
$seedMode = (Get-Content $SessionPath -Raw | ConvertFrom-Json).shellMode
WLog "SESSION_SEEDED shellMode=$seedMode path=$SessionPath"
if ($seedMode -ne "work") {
  WLog "SEED_FAIL FAIL_CLOSED"
  exit 4
}

# Launch candidate (no PathB diag — normal UI chrome path)
$env:RAWRXD_P1_CMD_DIAG = $null
Remove-Item Env:RAWRXD_P1_CMD_DIAG -ErrorAction SilentlyContinue
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$proc = [System.Diagnostics.Process]::Start($psi)
WLog "LAUNCHED pid=$($proc.Id) exe=$CandExe"
$proc.Id | Set-Content (Join-Path $Logs "pid.txt")

$main = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(90)
$menuReady = $false
$titleAtMenu = ""
$titleSawWork = $false
$titleSawDesktopAfterMenu = $false
while ((Get-Date) -lt $deadline) {
  if ($proc.HasExited) {
    WLog "EARLY_EXIT code=$($proc.ExitCode) FAIL_CLOSED"
    "EXIT=$($proc.ExitCode)" | Set-Content (Join-Path $Logs "early_exit.txt")
    break
  }
  $main = [ColdRestart014]::FindMain([uint32]$proc.Id)
  if ($main -ne [IntPtr]::Zero) {
    $title = [ColdRestart014]::Title($main)
    WLog "MAIN_HWND=0x$($main.ToInt64().ToString('X')) title='$title'"
    if ([ColdRestart014]::MenuReady($main)) {
      $menuReady = $true
      $titleAtMenu = $title
      WLog "MENU_READY=1 TITLE_AT_MENU='$titleAtMenu'"
      if ($titleAtMenu -match "Work Mode") { $titleSawWork = $true }
      if ($titleAtMenu -match "Desktop Preview") { $titleSawDesktopAfterMenu = $true }
      break
    }
  }
  Start-Sleep -Milliseconds 500
}

# Brief settle; sample titles (polish may strip "Work Mode" suffix via updateSaveStatusIndicator)
$titleSamples = New-Object System.Collections.Generic.List[string]
if ($menuReady) {
  for ($i = 0; $i -lt 6; $i++) {
    Start-Sleep -Milliseconds 500
    if ($main -ne [IntPtr]::Zero -and [ColdRestart014]::IsWindow($main)) {
      $t = [ColdRestart014]::Title($main)
      $titleSamples.Add($t)
      if ($t -match "Work Mode") { $titleSawWork = $true }
      if ($t -match "Desktop Preview") { $titleSawDesktopAfterMenu = $true }
    }
  }
}
$titleSamples | Set-Content (Join-Path $Logs "title_samples.txt")
$titleAtMenu | Set-Content (Join-Path $Logs "title_at_menu_ready.txt")

$tops = [ColdRestart014]::DumpTops([uint32]$proc.Id)
$tops | Set-Content (Join-Path $Logs "hwnd_tops.txt")
$titleFinal = ""
if ($main -ne [IntPtr]::Zero -and [ColdRestart014]::IsWindow($main) -eq $false) {
  $main = [ColdRestart014]::FindMain([uint32]$proc.Id)
}
$childLines = @()
if ($main -ne [IntPtr]::Zero) {
  $titleFinal = [ColdRestart014]::Title($main)
  $childLines = [ColdRestart014]::DumpChildren($main)
  $childLines | Set-Content (Join-Path $Logs "hwnd_children.txt")
}
$titleFinal | Set-Content (Join-Path $Logs "title_final.txt")

# Chrome markers: Work Mode shows Toolbar+Sidebar+Editor; Command hides them
$chromeToolbar = ($childLines | Where-Object { $_ -match "visible=True class='ToolbarWindow32'" }).Count -gt 0
$chromeSidebar = ($childLines | Where-Object { $_ -match "visible=True.*RawrXD\.IDE\.Sidebar" }).Count -gt 0
$chromeEditor = ($childLines | Where-Object { $_ -match "visible=True class='RICHEDIT50W'" }).Count -gt 0
$chromeWork = ($chromeToolbar -and $chromeSidebar -and $chromeEditor)
WLog "TITLE_AT_MENU='$titleAtMenu' TITLE_FINAL='$titleFinal' MENU_READY=$menuReady"
WLog "CHROME toolbar=$chromeToolbar sidebar=$chromeSidebar editor=$chromeEditor chromeWork=$chromeWork titleSawWork=$titleSawWork desktopAfterMenu=$titleSawDesktopAfterMenu"
@"
TITLE_AT_MENU=$titleAtMenu
TITLE_FINAL=$titleFinal
TITLE_SAW_WORK=$([int]$titleSawWork)
TITLE_DESKTOP_AFTER_MENU=$([int]$titleSawDesktopAfterMenu)
CHROME_TOOLBAR=$([int]$chromeToolbar)
CHROME_SIDEBAR=$([int]$chromeSidebar)
CHROME_EDITOR=$([int]$chromeEditor)
CHROME_WORK=$([int]$chromeWork)
"@ | Set-Content (Join-Path $Logs "classify_signals.txt")

# Also capture ODS-ish log lines if present
$ideLogs = Get-ChildItem (Join-Path $CandDir "logs") -Filter "RawrXD_IDE_*.log" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($ideLogs) {
  Select-String -Path $ideLogs.FullName -Pattern "shellMode|Work Mode|enterWorkMode|Session: shellMode" |
    ForEach-Object { $_.Line } |
    Set-Content (Join-Path $Logs "ide_log_shellmode_hits.txt")
  Copy-Item $ideLogs.FullName (Join-Path $Logs "ide_log_tail_copy.log") -Force
  WLog "IDE_LOG=$($ideLogs.FullName)"
}

# Post-launch session should remain work (persistShellModeOnly on enterWorkMode)
Start-Sleep -Seconds 1
Copy-Item $SessionPath (Join-Path $Logs "session_post_launch.json") -Force
$postMode = "MISSING"
if (Test-Path $SessionPath) {
  try { $postMode = (Get-Content $SessionPath -Raw | ConvertFrom-Json).shellMode } catch { $postMode = "PARSE_FAIL" }
}
WLog "SESSION_POST_LAUNCH shellMode=$postMode"

# Classify — title at menu-ready OR work chrome; Desktop Preview after menu = FAIL
# Note: updateSaveStatusIndicator may later overwrite title to plain "RawrXD IDE"
# without returning to Desktop Preview / Command chrome.
$pass = 0
$disposition = "FAIL_CLOSED"
if ($proc.HasExited -and -not $menuReady) {
  $disposition = "FAIL_CLOSED_EARLY_EXIT"
} elseif (-not $menuReady) {
  $disposition = "FAIL_CLOSED_MENU_NOT_READY"
} elseif ($titleSawDesktopAfterMenu -and -not $titleSawWork -and -not $chromeWork) {
  $disposition = "FAIL_CLOSED_DESKTOP_PREVIEW"
} elseif ($postMode -ne "work") {
  $disposition = "FAIL_CLOSED_SESSION_NOT_WORK"
} elseif ($titleSawWork -or $chromeWork) {
  $pass = 1
  $disposition = "RUNTIME_PASS"
} else {
  $disposition = "FAIL_CLOSED_NO_WORK_SIGNAL"
}
WLog "CLASSIFY pass=$pass disposition=$disposition titleSawWork=$titleSawWork chromeWork=$chromeWork session=$postMode"

# Clean kill (cold restart already proven at relaunch; teardown for hygiene)
if (-not $proc.HasExited) {
  WLog "TEARDOWN PostQuit"
  [void][ColdRestart014]::PostMessageW($main, 0x0012, [IntPtr]::Zero, [IntPtr]::Zero) # WM_QUIT
  $exited = $proc.WaitForExit(8000)
  if (-not $exited) {
    WLog "TEARDOWN_FORCE"
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
  }
}
Get-Process -Name "RawrXD-Win32IDE","RawrXD-ExtensionHost" -ErrorAction SilentlyContinue |
  ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }

$candShaPost = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipShaPost = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "POST_HASH CAND=$candShaPost TIP=$tipShaPost tip748B_MATCH=$($tipShaPost -eq $ExpectTip)"

$receipt = @"
# COLD_RESTART_SHELL_MODE_001

## Gate
Prove session ``shellMode=work`` survives full process kill + same-candidate relaunch
(title/chrome = Work Mode, not Desktop Preview).

## Method
1. Seed ``%APPDATA%\RawrXD\session.json`` ``shellMode=work``
2. Confirm no RawrXD-Win32IDE process
3. Launch cand ``4E4345C2…`` from TIP_CANDIDATE_AGENT_RUN_005/bin
4. Wait MainMenuReady; dump HWND title + children
5. Classify: TITLE_AT_MENU Work Mode and/or work chrome (Toolbar+Sidebar+Editor);
   session post=work; Desktop Preview after menu without work signal = FAIL

## Result
- DISPOSITION=$disposition
- COLD_RESTART_PASS=$pass
- TITLE_AT_MENU=$titleAtMenu
- TITLE_FINAL=$titleFinal
- TITLE_SAW_WORK=$titleSawWork
- CHROME_WORK=$chromeWork (toolbar=$chromeToolbar sidebar=$chromeSidebar editor=$chromeEditor)
- MENU_READY=$menuReady
- SESSION_SEED=work
- SESSION_POST_LAUNCH=$postMode
- CAND_SHA=$candShaPost
- TIP_SHA=$tipShaPost
- tip748B=1
- PROMOTE=0
- CERTIFIED=0
- INVENT_SHELL_MODE_PASS=0
- NOTE=updateSaveStatusIndicator may strip Work Mode suffix after chrome apply
- PATHB_N2_EXT=NOT_REQUISITE_FOR_THIS_GATE (prior COMPLETION_013 sealed)

## Fail-closed
SOURCE_WIRED != RUNTIME != PASS. NOT_RUN != PASS.
"@
Set-Content (Join-Path $OutDir "RECEIPT.md") $receipt

@"
GATE=COLD_RESTART_SHELL_MODE_001
DISPOSITION=$disposition
COLD_RESTART_PASS=$pass
TITLE_AT_MENU=$titleAtMenu
TITLE_FINAL=$titleFinal
TITLE_SAW_WORK=$([int]$titleSawWork)
CHROME_WORK=$([int]$chromeWork)
MENU_READY=$([int]$menuReady)
SESSION_POST=$postMode
CAND_SHA=$candShaPost
TIP_SHA=$tipShaPost
tip748B=1
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RETURN_LINE.txt")

WLog "DONE disposition=$disposition pass=$pass"
if ($pass -eq 1) { exit 0 } else { exit 1 }
