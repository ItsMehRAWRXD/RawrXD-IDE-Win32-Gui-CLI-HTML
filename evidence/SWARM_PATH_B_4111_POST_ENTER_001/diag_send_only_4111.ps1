$ErrorActionPreference = 'Continue'
$exe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
findstr /C:"WindowProc_TOP_4111_BEFORE_handleMessage" $exe > $null
Write-Output "TOP_PIN=$LASTEXITCODE"
findstr /C:"handleMessage_SUBAGENT_SKIP_V280" $exe > $null
Write-Output "SKIP_V280=$LASTEXITCODE"
$candDir = Split-Path $exe
$gate = Join-Path $candDir "evidence\P1_UI_MENU_E2E_001"
$crumbLive = Join-Path $gate "CMD_BREADCRUMB.txt"
$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class Diag5D {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern IntPtr GetWindowLongPtrW(IntPtr h, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(IntPtr h, uint Msg, IntPtr w, IntPtr l, uint flags, uint timeout, out IntPtr result);
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
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null
Get-Process RawrXD-Win32IDE -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
New-Item -ItemType Directory -Force -Path $gate | Out-Null
if (Test-Path $crumbLive) { Remove-Item $crumbLive -Force }
$env:RAWRXD_P1_CMD_DIAG='1'
$env:RAWRXD_DISABLE_OLLAMA_FETCH='1'
$env:RAWRXD_GUI='1'
$env:RAWRXD_SWARM_N='2'
$env:RAWRXD_MODELS='G:\~dev\rawrxd\models'
$env:RAWRXD_SWARM_MODEL_DIR='G:\~dev\rawrxd\models'
$env:LOCAL_ONLY='1'
$env:LOCAL_ONLY_NO_OLLAMA='1'
$env:RAWRXD_SKIP_GPU_POWER_PROBE='1'
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue
$p = Start-Process -FilePath $exe -WorkingDirectory $candDir -PassThru -WindowStyle Normal
$hwnd = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $deadline -and -not $p.HasExited) {
  $hwnd = [Diag5D]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero -and [Diag5D]::GetPropW($hwnd, "RawrXD.MainMenuReady") -ne [IntPtr]::Zero) { break }
  Start-Sleep -Milliseconds 50
}
$wndProc = [Diag5D]::GetWindowLongPtrW($hwnd, -4)
$mod = (Get-Process -Id $p.Id).Modules | Where-Object { $_.ModuleName -eq 'RawrXD-Win32IDE.exe' } | Select-Object -First 1
$exeBase = $mod.BaseAddress
$rva = [int64]$wndProc.ToInt64() - [int64]$exeBase.ToInt64()
Write-Output ("PID={0} HWND=0x{1:X} WNDPROC=0x{2:X} BASE=0x{3:X} RVA=0x{4:X}" -f $p.Id,$hwnd.ToInt64(),$wndProc.ToInt64(),$exeBase.ToInt64(),$rva)
Write-Output ("crumb_before={0}" -f $(if(Test-Path $crumbLive){(Get-Item $crumbLive).Length}else{0}))
$sr = [IntPtr]::Zero
$ok = [Diag5D]::SendMessageTimeoutW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero, 0x0002, 5000, [ref]$sr)
Write-Output ("SEND_only ok={0} result={1} exited={2}" -f ($ok -ne [IntPtr]::Zero), $sr.ToInt64(), $p.HasExited)
Start-Sleep -Milliseconds 800
try { $p.Refresh() } catch {}
Write-Output ("exited_after={0} code={1}" -f $p.HasExited, $(if($p.HasExited){$p.ExitCode}else{'alive'}))
Write-Output ("crumb_after={0}" -f $(if(Test-Path $crumbLive){(Get-Item $crumbLive).Length}else{0}))
if (Test-Path $crumbLive) {
  Select-String -LiteralPath $crumbLive -Pattern "4111|TOP_4111|SKIP_V280|onSubAgent" | ForEach-Object { $_.Line }
}
# Map expected WindowProc RVA from map file
Select-String -LiteralPath "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE_postenter.map" -Pattern "\?WindowProc@Win32IDE@@" | Select-Object -First 3
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
$tip = (Get-FileHash "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe" -Algorithm SHA256).Hash
Write-Output "TIP=$tip TIP_OK=$([int]($tip -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'))"
