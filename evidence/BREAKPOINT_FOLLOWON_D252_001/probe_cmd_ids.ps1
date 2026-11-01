$ErrorActionPreference = 'Continue'
$CandExe = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe'
cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
Start-Sleep 1
Add-Type -TypeDefinition @"
using System; using System.Text; using System.Runtime.InteropServices;
public class BpProbe4 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  public static IntPtr FindMain(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var c = new StringBuilder(256);
      GetClassNameW(h, c, 256);
      if (c.ToString() == "RawrXD_IDE_MainWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static bool MenuReady(IntPtr main) { return GetPropW(main, "RawrXD.MainMenuReady") != IntPtr.Zero; }
}
"@ -ErrorAction SilentlyContinue | Out-Null

function Start-Ide {
  cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
  Start-Sleep 1
  $gui = Start-Process -FilePath $CandExe -WorkingDirectory (Split-Path $CandExe) `
    -ArgumentList @('--local','--dir','G:\~dev\rawrxd') -PassThru -WindowStyle Normal
  $hwnd = [IntPtr]::Zero
  $deadline = (Get-Date).AddSeconds(90)
  while ((Get-Date) -lt $deadline) {
    if ($gui.HasExited) { break }
    $hwnd = [BpProbe4]::FindMain([uint32]$gui.Id)
    if ($hwnd -ne [IntPtr]::Zero -and [BpProbe4]::MenuReady($hwnd)) { break }
    Start-Sleep -Milliseconds 400
  }
  Start-Sleep 2
  return @{ Gui = $gui; Hwnd = $hwnd }
}

# Fresh process per ID so one killer doesn't poison the series.
$ids = @(
  @{ Id = 12230; Name = 'IDM_DBGWATCH_SHOW' },
  @{ Id = 5001; Name = 'TOOLS_START_PROFILING' },
  @{ Id = 5184; Name = 'IDM_DBG_STATUS' },
  @{ Id = 5170; Name = 'IDM_DBG_LIST_BPS' },
  @{ Id = 5166; Name = 'IDM_DBG_ADD_BP' },
  @{ Id = 5999; Name = 'TOOLS_UNHANDLED_5999' }
)
$out = Join-Path $PSScriptRoot 'logs\probe_ids.txt'
New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
'' | Set-Content $out

foreach ($c in $ids) {
  $s = Start-Ide
  $gui = $s.Gui
  $hwnd = $s.Hwnd
  $line0 = "START name=$($c.Name) id=$($c.Id) hwnd=0x{0:X} exited_before={1}" -f $hwnd.ToInt64(), $gui.HasExited
  Write-Output $line0
  Add-Content $out $line0
  if ($hwnd -eq [IntPtr]::Zero -or $gui.HasExited) {
    Add-Content $out "LAUNCH_FAIL name=$($c.Name)"
    continue
  }
  $ok = [BpProbe4]::PostMessageW($hwnd, 0x0111, [IntPtr]$c.Id, [IntPtr]::Zero)
  Start-Sleep -Milliseconds 1200
  $still = [bool](Get-Process -Id $gui.Id -ErrorAction SilentlyContinue)
  $gui.Refresh()
  $ex = 'RUNNING'
  if (-not $still) { $ex = '{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF) }
  $line = "POST name=$($c.Name) id=$($c.Id) ok=$([int]$ok) alive=$([int]$still) exit=$ex"
  Write-Output $line
  Add-Content $out $line
  if ($still) { Stop-Process -Id $gui.Id -Force -ErrorAction SilentlyContinue }
  Start-Sleep 1
}
