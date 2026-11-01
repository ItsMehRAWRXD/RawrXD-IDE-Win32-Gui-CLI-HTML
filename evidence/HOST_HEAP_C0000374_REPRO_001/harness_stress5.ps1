# D0A6-only idle stress x5 (no 2F37; no survival cmds)
$ErrorActionPreference = 'Continue'
$seal = 'G:\~dev\rawrxd\evidence\HOST_HEAP_C0000374_REPRO_001'
$exe = Join-Path $seal 'bin_freeze\RawrXD-Win32IDE.exe'
$dumpDir = 'C:\Users\Garrett\AppData\Local\Temp\RawrXD_Dumps'
$log = Join-Path $seal 'logs\STRESS5.txt'
'' | Set-Content $log
Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public class HH2 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(IntPtr h, uint Msg, IntPtr w, IntPtr l, uint f, uint t, out IntPtr r);
  public static IntPtr FindMain(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p); if (p != pid) return true;
      var c = new StringBuilder(256); GetClassNameW(h, c, 256);
      if (c.ToString() == "RawrXD_IDE_MainWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static bool Ready(IntPtr m) { return GetPropW(m, "RawrXD.MainMenuReady") != IntPtr.Zero; }
  public static int Ping(IntPtr h, uint ms, out int to) {
    IntPtr r; IntPtr ok = SendMessageTimeoutW(h, 0, IntPtr.Zero, IntPtr.Zero, 2, ms, out r);
    to = ok == IntPtr.Zero ? 1 : 0; return ok != IntPtr.Zero ? 1 : 0;
  }
}
'@ -ErrorAction SilentlyContinue | Out-Null
function Alive([int]$id) { return [bool](Get-Process -Id $id -EA SilentlyContinue) }
$pre = @((Get-ChildItem $dumpDir -Filter 'RawrXD-Win32IDE.exe.*.dmp' -EA SilentlyContinue).Name)
$hits = 0
$sha = (Get-FileHash $exe -A SHA256).Hash
Add-Content $log "CAND=$sha"
for ($i = 1; $i -le 5; $i++) {
  cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
  Start-Sleep 2
  $gui = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) `
    -ArgumentList @('--local','--dir','G:\~dev\rawrxd') -PassThru -WindowStyle Normal
  $ready = $false; $hwnd = [IntPtr]::Zero; $dl = (Get-Date).AddSeconds(90)
  while ((Get-Date) -lt $dl) {
    if (-not (Alive $gui.Id)) { break }
    $hwnd = [HH2]::FindMain([uint32]$gui.Id)
    if ($hwnd -ne [IntPtr]::Zero -and [HH2]::Ready($hwnd)) { $ready = $true; break }
    Start-Sleep -Milliseconds 250
  }
  $phase = 'LAUNCH'; $hex = 'ALIVE'
  if (-not (Alive $gui.Id)) {
    $gui.Refresh(); $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)); $phase = 'LAUNCH_FAIL'
  } elseif ($ready) {
    $end = (Get-Date).AddSeconds(35)
    while ((Get-Date) -lt $end) {
      if (-not (Alive $gui.Id)) {
        $gui.Refresh(); $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)); $phase = 'IDLE_DEATH'; break
      }
      Start-Sleep -Milliseconds 400
    }
    if ($phase -ne 'IDLE_DEATH') {
      $to = 0; $p = [HH2]::Ping($hwnd, 4000, [ref]$to)
      if (-not (Alive $gui.Id)) {
        $gui.Refresh(); $hex = ('{0:X8}' -f ([int64]$gui.ExitCode -band 0xFFFFFFFF)); $phase = 'POST_IDLE_DEATH'
      } else { $phase = 'IDLE_SURVIVED'; $hex = "ALIVE_ping=$p" }
    }
  } else { $phase = 'MENU_TIMEOUT' }
  if ($hex -match 'C0000374') { $hits++ }
  $line = "S$i phase=$phase exit=$hex pid=$($gui.Id) ready=$([int]$ready)"
  Add-Content $log $line; Write-Host $line
  if (Alive $gui.Id) { Stop-Process -Id $gui.Id -Force -EA SilentlyContinue }
}
$post = @(Get-ChildItem $dumpDir -Filter 'RawrXD-Win32IDE.exe.*.dmp' -EA SilentlyContinue | Where-Object { $pre -notcontains $_.Name })
$summary = "NEW_DUMPS=$($post.Count) C0000374_HITS=$hits"
Add-Content $log $summary; Write-Host $summary
$post | ForEach-Object { Add-Content $log $_.Name; Write-Host $_.Name }
if ($hits -gt 0) { exit 1 } else { exit 0 }
