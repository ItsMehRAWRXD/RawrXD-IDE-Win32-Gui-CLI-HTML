# Targeted IDM_DBGWATCH_SHOW PostMessage smoke on NEW_SHA cand.
# Survival != invent Watch PASS. tip748B untouched. PROMOTE=0.
$ErrorActionPreference = "Continue"
$Seal = "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_005\DBGWATCH_SHOW_FAILCLOSED_001"
$Logs = Join-Path $Seal "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = ((Get-Content (Join-Path $Seal "NEW_CAND_SHA.txt") | Where-Object { $_ -match '^CAND_SHA_AFTER=' }) -replace 'CAND_SHA_AFTER=','')
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$RunLog = Join-Path $Logs "dbgwatch_smoke_RUNLOG.txt"
Set-Content $RunLog ""

function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $RunLog $line
  Write-Output $line
}

$cs = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class DbgWatchSmoke005 {
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
  public static int PingNull(IntPtr h, uint timeoutMs, out int timedOut) {
    IntPtr r = IntPtr.Zero;
    IntPtr ok = SendMessageTimeoutW(h, 0x0000, IntPtr.Zero, IntPtr.Zero, 0x0002, timeoutMs, out r);
    timedOut = (ok == IntPtr.Zero) ? 1 : 0;
    return (ok != IntPtr.Zero) ? 1 : 0;
  }
}
"@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$sha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$sha | Set-Content (Join-Path $Logs "exe_sha.txt")
$tipSha | Set-Content (Join-Path $Logs "tip_sha.txt")
$candMatch = [int]($sha -eq $ExpectCand)
$tipMatch = [int]($tipSha -eq $ExpectTip)
WLog "HASH_VERIFY CAND=$sha EXPECT=$ExpectCand MATCH=$candMatch"
WLog "HASH_VERIFY TIP=$tipSha EXPECT=$ExpectTip MATCH=$tipMatch tip748B=$tipMatch"
if ($candMatch -ne 1 -or $tipMatch -ne 1) {
  "DISPOSITION=HASH_FAIL EXIT=2" | Set-Content (Join-Path $Seal "SMOKE_RECEIPT.txt")
  exit 2
}

$workDir = Split-Path $CandExe
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
Start-Sleep -Seconds 1
$gui = Start-Process -FilePath $CandExe -WorkingDirectory $workDir `
  -ArgumentList @("--local","--dir","G:\~dev\rawrxd") `
  -PassThru -WindowStyle Normal

$hwnd = [IntPtr]::Zero
$menuReady = $false
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($gui.HasExited) { break }
  $hwnd = [DbgWatchSmoke005]::FindMain([uint32]$gui.Id)
  if ($hwnd -ne [IntPtr]::Zero) {
    $menuReady = [DbgWatchSmoke005]::MenuReady($hwnd)
    if ($menuReady) { break }
  }
  Start-Sleep -Milliseconds 400
}
WLog "GUI_PID=$($gui.Id) HWND=0x$('{0:X}' -f $hwnd.ToInt64()) MENU_READY=$([int]$menuReady) EXITED=$($gui.HasExited)"

$survived = 0
$postOk = 0
$ping = 0
$to = 1
$alive = 0
$killer = "NONE"
if ($hwnd -eq [IntPtr]::Zero -or -not $menuReady -or $gui.HasExited) {
  $killer = "GUI_LAUNCH"
  WLog "GUI_LAUNCH=FAIL"
} else {
  $to0 = 0
  $ping0 = [DbgWatchSmoke005]::PingNull($hwnd, 3000, [ref]$to0)
  $alive0 = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  WLog "GUI_BASELINE alive=$([int]$alive0) ping=$ping0 timedOut=$to0"
  $postOk = [DbgWatchSmoke005]::PostId($hwnd, 12230)
  Start-Sleep -Milliseconds 800
  $alive = [int][bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  if ($alive -eq 0) {
    $killer = "IDM_DBGWATCH_SHOW"
  } else {
    $to = 0
    $ping = [DbgWatchSmoke005]::PingNull($hwnd, 3000, [ref]$to)
    if ($ping -eq 1 -and $to -eq 0) { $survived = 1 } else { $killer = "PING_FAIL_AFTER_DBGWATCH" }
  }
  WLog "POST id=12230 name=IDM_DBGWATCH_SHOW ok=$postOk alive_after=$alive ping=$ping timedOut=$to survived=$survived killer=$killer"
  "POST id=12230 name=IDM_DBGWATCH_SHOW ok=$postOk alive_after=$alive ping=$ping timedOut=$to survived=$survived`nKILLER=$killer" |
    Set-Content (Join-Path $Logs "dbgwatch_post.txt")
}

try { if (-not $gui.HasExited) { $gui.Kill() } } catch {}
Start-Sleep -Milliseconds 400

$disp = if ($survived -eq 1) { "DBGWATCH_SHOW_SURVIVED_FAILCLOSED" } else { "DBGWATCH_SHOW_STILL_CRASH" }
$exit = if ($survived -eq 1) { 0 } else { 1 }
@"
DISPOSITION=$disp
EXIT=$exit
CAND_SHA=$sha
TIP_SHA=$tipSha
tip748B=$tipMatch
SURVIVED=$survived
POST_OK=$postOk
KILLER=$killer
FEATURE_FICTION_CLAIM=FAIL_CLOSED_ODS
INVENT_WATCH_PASS=0
PROMOTE=0
"@ | Set-Content (Join-Path $Seal "SMOKE_RECEIPT.txt")
WLog "DISPOSITION=$disp EXIT=$exit SURVIVED=$survived"
exit $exit
