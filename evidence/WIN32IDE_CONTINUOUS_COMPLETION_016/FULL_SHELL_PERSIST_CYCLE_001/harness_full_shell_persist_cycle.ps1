# FULL_SHELL_PERSIST_CYCLE_001 — unseeded UI Work Mode → kill → relaunch restore
# AUTHORIZE_CANDIDATE_ONLY=1; tip748B FROZEN; PROMOTE=0
# INVENT PASS forbidden. Do NOT pre-write session.json shellMode=work.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_016\FULL_SHELL_PERSIST_CYCLE_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "4A10F3F40D3A5FF08E475671C8BF87AA8E5C79D68E405CA3027DA5FCCB53104B"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$SessionPath = Join-Path $env:APPDATA "RawrXD\session.json"
$IDM_ENTER_WORK = 12520
$IDM_ENTER_COMMAND = 12521
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
public class FullPersist016 {
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
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  public const uint WM_COMMAND = 0x0111;
  public const uint WM_CLOSE = 0x0010;
  public const uint WM_QUIT = 0x0012;
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
  public static int PostId(IntPtr h, int id) {
    return PostMessageW(h, WM_COMMAND, (IntPtr)id, IntPtr.Zero) ? 1 : 0;
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

function Kill-AllIde {
  param([string]$Tag)
  Get-Process -Name "RawrXD-Win32IDE","RawrXD-ExtensionHost" -ErrorAction SilentlyContinue |
    ForEach-Object {
      WLog "KILL_$Tag pid=$($_.Id)"
      Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
  Start-Sleep -Seconds 2
  $alive = @(Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue)
  return ($alive.Count -eq 0)
}

function Get-SessionMode {
  if (-not (Test-Path $SessionPath)) { return "MISSING" }
  try { return [string]((Get-Content $SessionPath -Raw | ConvertFrom-Json).shellMode) }
  catch { return "PARSE_FAIL" }
}

function Wait-MenuReady {
  param($Proc, [int]$TimeoutSec = 90)
  $main = [IntPtr]::Zero
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  $menuReady = $false
  $titleAtMenu = ""
  while ((Get-Date) -lt $deadline) {
    if ($Proc.HasExited) {
      WLog "EARLY_EXIT code=$($Proc.ExitCode)"
      return @{ Main=$main; MenuReady=$false; Title=""; Exited=$true; ExitCode=$Proc.ExitCode }
    }
    $main = [FullPersist016]::FindMain([uint32]$Proc.Id)
    if ($main -ne [IntPtr]::Zero) {
      $title = [FullPersist016]::Title($main)
      if ([FullPersist016]::MenuReady($main)) {
        $menuReady = $true
        $titleAtMenu = $title
        WLog "MENU_READY=1 TITLE='$titleAtMenu' hwnd=0x$($main.ToInt64().ToString('X'))"
        break
      }
    }
    Start-Sleep -Milliseconds 400
  }
  return @{ Main=$main; MenuReady=$menuReady; Title=$titleAtMenu; Exited=$false; ExitCode=0 }
}

function Classify-Chrome {
  param($Main)
  $childLines = @()
  if ($Main -ne [IntPtr]::Zero) {
    $childLines = [FullPersist016]::DumpChildren($Main)
  }
  $chromeToolbar = ($childLines | Where-Object { $_ -match "visible=True class='ToolbarWindow32'" }).Count -gt 0
  $chromeSidebar = ($childLines | Where-Object { $_ -match "visible=True.*RawrXD\.IDE\.Sidebar" }).Count -gt 0
  $chromeEditor = ($childLines | Where-Object { $_ -match "visible=True class='RICHEDIT50W'" }).Count -gt 0
  $chromeWork = ($chromeToolbar -and $chromeSidebar -and $chromeEditor)
  return @{
    Lines = $childLines
    Toolbar = $chromeToolbar
    Sidebar = $chromeSidebar
    Editor = $chromeEditor
    Work = $chromeWork
  }
}

function Sample-Titles {
  param($Main, [int]$N = 6)
  $samples = New-Object System.Collections.Generic.List[string]
  $sawWork = $false
  $sawDesktop = $false
  for ($i = 0; $i -lt $N; $i++) {
    Start-Sleep -Milliseconds 400
    if ($Main -ne [IntPtr]::Zero -and [FullPersist016]::IsWindow($Main)) {
      $t = [FullPersist016]::Title($Main)
      $samples.Add($t)
      if ($t -match "Work Mode") { $sawWork = $true }
      if ($t -match "Desktop Preview") { $sawDesktop = $true }
    }
  }
  return @{ Samples=$samples; SawWork=$sawWork; SawDesktop=$sawDesktop }
}

WLog "START FULL_SHELL_PERSIST_CYCLE_001"
WLog "PROMOTE=0 tip748B=FROZEN AUTHORIZE_CANDIDATE_ONLY=1 UNSEEDED=1"

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
"CANDIDATE_SHA=$candSha`nTIP_SHA=$tipSha" | Set-Content (Join-Path $Logs "sha_pre.txt")
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  @"
GATE=FULL_SHELL_PERSIST_CYCLE_001
DISPOSITION=FAIL_CLOSED_SHA_DRIFT
CANDIDATE_SHA=$candSha
TIP_SHA=$tipSha
EXPECT_CAND=$ExpectCand
EXPECT_TIP=$ExpectTip
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RECEIPT.md")
  exit 2
}

# --- Phase 0: cold clear + UNSEED baseline (command, NOT work) ---
if (-not (Kill-AllIde -Tag "PRE")) {
  WLog "KILL_PRE_INCOMPLETE FAIL_CLOSED"
  exit 3
}
WLog "PROCESS_CLEAR=1"

if (Test-Path $SessionPath) {
  Copy-Item $SessionPath (Join-Path $Logs "session_before.json") -Force
  $j = Get-Content $SessionPath -Raw | ConvertFrom-Json
  $j.shellMode = "command"
  $j.timestamp = [string]([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
  $j | ConvertTo-Json -Depth 20 | Set-Content $SessionPath -Encoding UTF8
} else {
  New-Item -ItemType Directory -Force -Path (Split-Path $SessionPath) | Out-Null
  '{"version":2,"schemaVersion":"2.2","shellMode":"command"}' | Set-Content $SessionPath -Encoding UTF8
}
Copy-Item $SessionPath (Join-Path $Logs "session_unseed_command.json") -Force
$preMode = Get-SessionMode
WLog "UNSEED_BASELINE shellMode=$preMode (NOT work; UI enterWorkMode is sole work writer)"
if ($preMode -eq "work") {
  WLog "UNSEED_FAILED still work FAIL_CLOSED"
  exit 4
}

# --- Phase 1: launch → Command/Desktop → UI enter Work Mode ---
$env:RAWRXD_P1_CMD_DIAG = $null
Remove-Item Env:RAWRXD_P1_CMD_DIAG -ErrorAction SilentlyContinue
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$proc1 = [System.Diagnostics.Process]::Start($psi)
WLog "LAUNCH1 pid=$($proc1.Id) exe=$CandExe"
$proc1.Id | Set-Content (Join-Path $Logs "pid1.txt")

$w1 = Wait-MenuReady -Proc $proc1 -TimeoutSec 90
$main1 = $w1.Main
$title1 = $w1.Title
$menu1 = [bool]$w1.MenuReady
$s1 = Sample-Titles -Main $main1
$c1 = Classify-Chrome -Main $main1
$c1.Lines | Set-Content (Join-Path $Logs "hwnd_children_phase1_pre_work.txt")
$s1.Samples | Set-Content (Join-Path $Logs "title_samples_phase1_pre_work.txt")
$title1 | Set-Content (Join-Path $Logs "title_phase1_menu.txt")
[FullPersist016]::DumpTops([uint32]$proc1.Id) | Set-Content (Join-Path $Logs "hwnd_tops_phase1.txt")
WLog "PHASE1_PRE title='$title1' sawWork=$($s1.SawWork) sawDesktop=$($s1.SawDesktop) chromeWork=$($c1.Work)"

$phase1CmdOk = 0
if ($menu1 -and -not $c1.Work -and ($s1.SawDesktop -or $title1 -match "Desktop Preview" -or $title1 -match "RawrXD" -or -not $s1.SawWork)) {
  $phase1CmdOk = 1
}
# Allow Command chrome even if title stripped; reject if already Work before UI
if ($c1.Work -or $s1.SawWork) {
  WLog "PHASE1_UNEXPECTED_WORK_BEFORE_UI FAIL_CLOSED (would invent cycle)"
  @"
GATE=FULL_SHELL_PERSIST_CYCLE_001
DISPOSITION=FAIL_CLOSED_ALREADY_WORK_BEFORE_UI
TITLE=$title1
CHROME_WORK=$($c1.Work)
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RECEIPT.md")
  [void](Kill-AllIde -Tag "ABORT1")
  exit 5
}

# UI enter Work Mode via product command id (Ctrl+Shift+W accelerator target)
[void][FullPersist016]::SetForegroundWindow($main1)
$postWork = [FullPersist016]::PostId($main1, $IDM_ENTER_WORK)
WLog "POST_IDM_CMD_ENTER_WORK=$postWork id=$IDM_ENTER_WORK"
Start-Sleep -Seconds 2

$s1b = Sample-Titles -Main $main1 -N 8
# refresh main if needed
if (-not [FullPersist016]::IsWindow($main1)) { $main1 = [FullPersist016]::FindMain([uint32]$proc1.Id) }
$c1b = Classify-Chrome -Main $main1
$c1b.Lines | Set-Content (Join-Path $Logs "hwnd_children_phase1_post_work.txt")
$s1b.Samples | Set-Content (Join-Path $Logs "title_samples_phase1_post_work.txt")
$title1b = ""
if ($main1 -ne [IntPtr]::Zero) { $title1b = [FullPersist016]::Title($main1) }
$title1b | Set-Content (Join-Path $Logs "title_phase1_post_work.txt")
Start-Sleep -Seconds 1
Copy-Item $SessionPath (Join-Path $Logs "session_after_ui_work.json") -Force
$modeAfterUi = Get-SessionMode
WLog "PHASE1_POST title='$title1b' sawWork=$($s1b.SawWork) chromeWork=$($c1b.Work) session=$modeAfterUi"

$uiWorkOk = ($s1b.SawWork -or $c1b.Work) -and ($modeAfterUi -eq "work")
if (-not $uiWorkOk) {
  WLog "UI_ENTER_WORK_FAIL FAIL_CLOSED"
  @"
GATE=FULL_SHELL_PERSIST_CYCLE_001
DISPOSITION=FAIL_CLOSED_UI_ENTER_WORK
TITLE_POST=$title1b
TITLE_SAW_WORK=$($s1b.SawWork)
CHROME_WORK=$($c1b.Work)
SESSION_AFTER_UI=$modeAfterUi
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RECEIPT.md")
  [void](Kill-AllIde -Tag "ABORT_UI")
  exit 6
}
WLog "UI_ENTER_WORK_PASS=1"

# Clean exit / save path
WLog "CLEAN_EXIT WM_CLOSE"
[void][FullPersist016]::PostMessageW($main1, [FullPersist016]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero)
$exitedClean = $proc1.WaitForExit(12000)
if (-not $exitedClean) {
  WLog "CLEAN_EXIT_TIMEOUT force"
  [void][FullPersist016]::PostMessageW($main1, [FullPersist016]::WM_QUIT, [IntPtr]::Zero, [IntPtr]::Zero)
  Start-Sleep -Seconds 2
  if (-not $proc1.HasExited) { Stop-Process -Id $proc1.Id -Force -ErrorAction SilentlyContinue }
}
Start-Sleep -Seconds 1
if (-not (Kill-AllIde -Tag "POST1")) {
  WLog "KILL_POST1_INCOMPLETE FAIL_CLOSED"
  exit 7
}
WLog "PROCESS_DEAD_AFTER_WORK_SAVE=1"
Copy-Item $SessionPath (Join-Path $Logs "session_after_clean_exit.json") -Force
$modeDead = Get-SessionMode
WLog "SESSION_AFTER_EXIT shellMode=$modeDead"
if ($modeDead -ne "work") {
  WLog "SESSION_LOST_WORK_ON_EXIT FAIL_CLOSED"
  @"
GATE=FULL_SHELL_PERSIST_CYCLE_001
DISPOSITION=FAIL_CLOSED_SESSION_NOT_WORK_AFTER_EXIT
SESSION=$modeDead
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RECEIPT.md")
  exit 8
}

# --- Phase 2: relaunch SAME cand WITHOUT touching session (unseeded restore) ---
WLog "RELAUNCH_UNSEEDED no session rewrite"
$modePreRelaunch = Get-SessionMode
Copy-Item $SessionPath (Join-Path $Logs "session_pre_relaunch.json") -Force
WLog "SESSION_PRE_RELAUNCH=$modePreRelaunch (harness must not rewrite)"

$psi2 = New-Object System.Diagnostics.ProcessStartInfo
$psi2.FileName = $CandExe
$psi2.WorkingDirectory = $CandDir
$psi2.UseShellExecute = $false
$proc2 = [System.Diagnostics.Process]::Start($psi2)
WLog "LAUNCH2 pid=$($proc2.Id)"
$proc2.Id | Set-Content (Join-Path $Logs "pid2.txt")

$w2 = Wait-MenuReady -Proc $proc2 -TimeoutSec 90
$main2 = $w2.Main
$title2 = $w2.Title
$menu2 = [bool]$w2.MenuReady
$s2 = Sample-Titles -Main $main2
$c2 = Classify-Chrome -Main $main2
$c2.Lines | Set-Content (Join-Path $Logs "hwnd_children_phase2_restore.txt")
$s2.Samples | Set-Content (Join-Path $Logs "title_samples_phase2_restore.txt")
$title2 | Set-Content (Join-Path $Logs "title_phase2_menu.txt")
[FullPersist016]::DumpTops([uint32]$proc2.Id) | Set-Content (Join-Path $Logs "hwnd_tops_phase2.txt")
Copy-Item $SessionPath (Join-Path $Logs "session_post_relaunch.json") -Force
$mode2 = Get-SessionMode
WLog "PHASE2_RESTORE title='$title2' sawWork=$($s2.SawWork) sawDesktop=$($s2.SawDesktop) chromeWork=$($c2.Work) session=$mode2"

$restorePass = 0
if ($menu2 -and ($s2.SawWork -or $c2.Work) -and ($mode2 -eq "work") -and -not ($s2.SawDesktop -and -not $s2.SawWork -and -not $c2.Work)) {
  $restorePass = 1
}
WLog "RESTORE_PASS=$restorePass"

# --- Phase 3 optional reverse: Command → save → kill → relaunch → Desktop ---
$reversePass = 0
$reverseDisposition = "NOT_RUN"
$title3 = ""
$mode3 = "N/A"
$c3Work = $false
$s3Desktop = $false
if ($restorePass -eq 1 -and -not $proc2.HasExited) {
  WLog "REVERSE_START enterCommandMode via IDM $IDM_ENTER_COMMAND"
  [void][FullPersist016]::SetForegroundWindow($main2)
  $postCmd = [FullPersist016]::PostId($main2, $IDM_ENTER_COMMAND)
  WLog "POST_IDM_CMD_ENTER_COMMAND=$postCmd"
  Start-Sleep -Seconds 2
  $s2c = Sample-Titles -Main $main2 -N 6
  $c2c = Classify-Chrome -Main $main2
  $c2c.Lines | Set-Content (Join-Path $Logs "hwnd_children_phase2_command.txt")
  $modeCmd = Get-SessionMode
  Copy-Item $SessionPath (Join-Path $Logs "session_after_ui_command.json") -Force
  WLog "REVERSE_UI title sawDesktop=$($s2c.SawDesktop) sawWork=$($s2c.SawWork) chromeWork=$($c2c.Work) session=$modeCmd"
  if (($modeCmd -eq "command") -and -not $c2c.Work) {
    [void][FullPersist016]::PostMessageW($main2, [FullPersist016]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero)
    $null = $proc2.WaitForExit(12000)
    if (-not $proc2.HasExited) { Stop-Process -Id $proc2.Id -Force -ErrorAction SilentlyContinue }
    [void](Kill-AllIde -Tag "REV")
    $modeCmdDead = Get-SessionMode
    Copy-Item $SessionPath (Join-Path $Logs "session_pre_relaunch_command.json") -Force
    WLog "REVERSE_SESSION_DEAD=$modeCmdDead"
    $psi3 = New-Object System.Diagnostics.ProcessStartInfo
    $psi3.FileName = $CandExe
    $psi3.WorkingDirectory = $CandDir
    $psi3.UseShellExecute = $false
    $proc3 = [System.Diagnostics.Process]::Start($psi3)
    WLog "LAUNCH3_REVERSE pid=$($proc3.Id)"
    $proc3.Id | Set-Content (Join-Path $Logs "pid3.txt")
    $w3 = Wait-MenuReady -Proc $proc3 -TimeoutSec 90
    $main3 = $w3.Main
    $title3 = $w3.Title
    $s3 = Sample-Titles -Main $main3
    $c3 = Classify-Chrome -Main $main3
    $c3.Lines | Set-Content (Join-Path $Logs "hwnd_children_phase3_command_restore.txt")
    $s3.Samples | Set-Content (Join-Path $Logs "title_samples_phase3.txt")
    $title3 | Set-Content (Join-Path $Logs "title_phase3_menu.txt")
    Copy-Item $SessionPath (Join-Path $Logs "session_post_relaunch_command.json") -Force
    $mode3 = Get-SessionMode
    $c3Work = $c3.Work
    $s3Desktop = $s3.SawDesktop
    WLog "PHASE3 title='$title3' sawDesktop=$($s3.SawDesktop) chromeWork=$($c3.Work) session=$mode3"
    if ([bool]$w3.MenuReady -and ($mode3 -eq "command") -and -not $c3.Work) {
      $reversePass = 1
      $reverseDisposition = "RUNTIME_PASS"
    } else {
      $reverseDisposition = "FAIL_CLOSED_REVERSE"
    }
    if (-not $proc3.HasExited) {
      [void][FullPersist016]::PostMessageW($main3, [FullPersist016]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero)
      $null = $proc3.WaitForExit(8000)
      if (-not $proc3.HasExited) { Stop-Process -Id $proc3.Id -Force -ErrorAction SilentlyContinue }
    }
    [void](Kill-AllIde -Tag "END")
  } else {
    $reverseDisposition = "FAIL_CLOSED_REVERSE_UI"
    [void](Kill-AllIde -Tag "REV_UI_FAIL")
  }
} else {
  [void](Kill-AllIde -Tag "END_NO_REV")
}

$candShaPost = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipShaPost = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "POST_HASH CAND=$candShaPost TIP=$tipShaPost tip748B_MATCH=$($tipShaPost -eq $ExpectTip)"

$pass = 0
$disposition = "FAIL_CLOSED"
if ($restorePass -eq 1) {
  $pass = 1
  $disposition = "RUNTIME_PASS"
  if ($reverseDisposition -eq "RUNTIME_PASS") {
    $disposition = "RUNTIME_PASS_WITH_REVERSE"
  }
}
WLog "CLASSIFY pass=$pass disposition=$disposition restore=$restorePass reverse=$reversePass/$reverseDisposition"

$receipt = @"
# FULL_SHELL_PERSIST_CYCLE_001

## Gate
Prove FULL user shellMode persistence cycle WITHOUT manual session seed of work:
UI enter Work Mode → clean exit → full kill → same-cand relaunch restores Work Mode.

## Method (unseeded)
1. Baseline session.json ``shellMode=command`` (explicit anti-seed; NOT work)
2. Launch cand ``4A10F3F4…`` TIP_CANDIDATE_AGENT_RUN_005/bin
3. Wait MainMenuReady; confirm NOT already Work
4. UI ``WM_COMMAND IDM_CMD_ENTER_WORK=12520`` (Ctrl+Shift+W product path)
5. Wait Work chrome/title; session shellMode=work via persistShellModeOnly
6. Clean WM_CLOSE; confirm process dead; session remains work
7. Relaunch SAME EXE with NO session rewrite
8. Prove Work Mode restored (title/chrome + session=work)
9. Optional reverse: IDM_CMD_ENTER_COMMAND → save → kill → relaunch → Command/Desktop

## Result
- DISPOSITION=$disposition
- FULL_PERSISTENCE_CYCLE=$pass
- RESTORE_PASS=$restorePass
- REVERSE_PASS=$reversePass ($reverseDisposition)
- PHASE1_PRE_TITLE=$title1
- PHASE1_POST_WORK_TITLE=$title1b
- PHASE2_RESTORE_TITLE=$title2
- PHASE2_CHROME_WORK=$($c2.Work)
- PHASE2_TITLE_SAW_WORK=$($s2.SawWork)
- PHASE3_TITLE=$title3
- PHASE3_CHROME_WORK=$c3Work
- PHASE3_SAW_DESKTOP=$s3Desktop
- SESSION_UNSEED=$preMode
- SESSION_AFTER_UI_WORK=$modeAfterUi
- SESSION_AFTER_EXIT=$modeDead
- SESSION_POST_RELAUNCH=$mode2
- SESSION_REVERSE_FINAL=$mode3
- CAND_SHA=$candShaPost
- TIP_SHA=$tipShaPost
- tip748B=1
- PROMOTE=0
- CERTIFIED=0
- INVENT_SHELL_MODE_PASS=0
- SEEDED_WORK=0
- AUTHORIZE_CANDIDATE_ONLY=1

## Fail-closed
SOURCE_WIRED != RUNTIME != PASS. NOT_RUN != PASS. Invent PASS forbidden.
"@
Set-Content (Join-Path $OutDir "RECEIPT.md") $receipt

@"
GATE=FULL_SHELL_PERSIST_CYCLE_001
DISPOSITION=$disposition
FULL_PERSISTENCE_CYCLE=$pass
RESTORE_PASS=$restorePass
REVERSE_PASS=$reversePass
REVERSE_DISPOSITION=$reverseDisposition
TITLE_PHASE2=$title2
CHROME_WORK_PHASE2=$([int]$c2.Work)
TITLE_SAW_WORK_PHASE2=$([int]$s2.SawWork)
SESSION_POST_RELAUNCH=$mode2
CAND_SHA=$candShaPost
TIP_SHA=$tipShaPost
tip748B=1
SEEDED_WORK=0
PROMOTE=0
"@ | Set-Content (Join-Path $OutDir "RETURN_LINE.txt")

Copy-Item $Log (Join-Path $Logs "console_tee.txt") -Force
WLog "DONE disposition=$disposition pass=$pass"
if ($pass -eq 1) { exit 0 } else { exit 1 }
