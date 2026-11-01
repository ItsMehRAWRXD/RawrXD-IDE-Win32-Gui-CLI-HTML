# PathB crash repro: seed editor then Post 4111. Tip untouched. PROMOTE=0.
$ErrorActionPreference = "Continue"
$CandDir = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin"
$CandExe = Join-Path $CandDir "RawrXD-Win32IDE.exe"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_CRASHFIX_001"
$Logs = Join-Path $OutDir "logs"
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 1

Remove-Item (Join-Path $CandDir "ide_startup.log") -Force -ErrorAction SilentlyContinue
$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
Remove-Item $crumb -Force -ErrorAction SilentlyContinue
$stderr = Join-Path $Logs "stderr_repro2.txt"
Remove-Item $stderr -Force -ErrorAction SilentlyContinue

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "1"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_CRASH_DUMP_DIR = (Join-Path $CandDir "crash_dumps")
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

$cs = @'
using System; using System.Text; using System.Runtime.InteropServices;
public class PathBRepro2 {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindowExW(IntPtr p, IntPtr c, string cls, string win);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageW(IntPtr h, uint m, IntPtr w, [MarshalAs(UnmanagedType.LPWStr)] string l);
  [DllImport("user32.dll")] public static extern int EnumChildWindows(IntPtr h, EnumProc lp, IntPtr l);
  public static IntPtr FindMain(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256); GetClassNameW(h, cls, 256);
      if (cls.ToString() == "RawrXD_IDE_MainWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static int SeedEditor(IntPtr main) {
    IntPtr hit = IntPtr.Zero;
    EnumChildWindows(main, (h, l) => {
      var cls = new StringBuilder(256); GetClassNameW(h, cls, 256);
      string s = cls.ToString();
      if (s.IndexOf("RichEdit", StringComparison.OrdinalIgnoreCase) >= 0 ||
          s == "Edit" ||
          s.IndexOf("Scintilla", StringComparison.OrdinalIgnoreCase) >= 0) {
        hit = h; return false;
      }
      return true;
    }, IntPtr.Zero);
    if (hit == IntPtr.Zero) return 0;
    SendMessageW(hit, 0x000C, IntPtr.Zero, "int main(){ return 0; } // pathb swarm seed\r\n");
    return 1;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$psi.RedirectStandardError = $true
$psi.RedirectStandardOutput = $true
$psi.CreateNoWindow = $false
$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi
[void]$proc.Start()
$errBuilder = New-Object System.Text.StringBuilder
$outBuilder = New-Object System.Text.StringBuilder
$proc.ErrorDataReceived += { param($s,$e) if ($e.Data) { [void]$errBuilder.AppendLine($e.Data) } }
$proc.OutputDataReceived += { param($s,$e) if ($e.Data) { [void]$outBuilder.AppendLine($e.Data) } }
$proc.BeginErrorReadLine()
$proc.BeginOutputReadLine()
Write-Output "PID=$($proc.Id)"

$posted = 0
$seeded = 0
$deadline = (Get-Date).AddSeconds(18)
while ((Get-Date) -lt $deadline) {
  if ($proc.HasExited) {
    Write-Output ("EXIT=0x{0:X}" -f [uint32]$proc.ExitCode)
    break
  }
  $hwnd = [PathBRepro2]::FindMain([uint32]$proc.Id)
  if ($hwnd -ne [IntPtr]::Zero -and $posted -eq 0) {
    $seeded = [PathBRepro2]::SeedEditor($hwnd)
    Write-Output "SEED=$seeded"
    [void][PathBRepro2]::PostMessageW($hwnd, 0x0111, [IntPtr]1001, [IntPtr]::Zero)
    Start-Sleep -Milliseconds 400
    $seeded = [PathBRepro2]::SeedEditor($hwnd)
    Write-Output "SEED2=$seeded"
    [void][PathBRepro2]::PostMessageW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero)
    $posted = 1
    Write-Output ("POSTED hwnd=0x{0:X}" -f $hwnd.ToInt64())
  }
  Start-Sleep -Milliseconds 120
}

Start-Sleep 8
if (-not $proc.HasExited) {
  Write-Output "STILL_ALIVE"
  Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
  Start-Sleep 1
}
if ($proc.HasExited) {
  Write-Output ("FINAL_EXIT=0x{0:X}" -f [uint32]$proc.ExitCode)
}

$errText = $errBuilder.ToString()
$outText = $outBuilder.ToString()
Set-Content -Path $stderr -Value $errText -Encoding UTF8
Set-Content -Path (Join-Path $Logs "stdout_repro2.txt") -Value $outText -Encoding UTF8
Copy-Item (Join-Path $CandDir "ide_startup.log") (Join-Path $Logs "ide_startup_repro2.log") -Force -ErrorAction SilentlyContinue
Copy-Item $crumb (Join-Path $Logs "CMD_BREADCRUMB_repro2.txt") -Force -ErrorAction SilentlyContinue

Write-Output "==== STDERR KEY ===="
($errText -split "`n") | Where-Object { $_ -match "onSubAgent|swarm|FAIL|STARTUP|exception|crash|C000" } | Select-Object -Last 40
Write-Output "==== STARTUP TAIL ===="
if (Test-Path (Join-Path $CandDir "ide_startup.log")) {
  Get-Content (Join-Path $CandDir "ide_startup.log") -Tail 20
}
Write-Output "==== DUMPS ===="
Get-ChildItem (Join-Path $CandDir "crash_dumps") -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime
Get-ChildItem $CandDir -Filter "*.dmp" -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime
Get-ChildItem "C:\Users\Garrett\AppData\Local\CrashDumps" -Filter "RawrXD*" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 5 Name, Length, LastWriteTime
Write-Output "==== CRUMB ===="
if (Test-Path $crumb) {
  Select-String -Path $crumb -Pattern "id=4111|AFTER_route" | Select-Object -Last 20 Line
}
