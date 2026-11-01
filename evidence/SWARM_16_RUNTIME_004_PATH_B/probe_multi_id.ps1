# Multi-ID WM_COMMAND crumb differential on tip 748B (PathB orch fail-closed evidence)
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_16_RUNTIME_004_PATH_B\logs"
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$TipDir = Split-Path $TipExe
$Expect = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$out = Join-Path $OutDir "multi_id_probe.txt"
New-Item -Force -ItemType Directory $OutDir | Out-Null

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

$sha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
if ($sha -ne $Expect) { "SHA_MISMATCH $sha" | Set-Content $out; exit 2 }

$cs = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class MultiId {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(
    IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  public static IntPtr FindMain(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256); GetClassNameW(h, cls, 256);
      if (cls.ToString() == "RawrXD.MainWindow" || cls.ToString() == "RawrXD_IDE_MainWindow") {
        found = h; return false;
      }
      return true;
    }, IntPtr.Zero);
    return found;
  }
}
'@
Add-Type -TypeDefinition $cs | Out-Null

$crumbDir = Join-Path $TipDir "evidence\P1_UI_MENU_E2E_001"
New-Item -Force -ItemType Directory $crumbDir | Out-Null
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
if (Test-Path $crumb) { Remove-Item $crumb -Force }

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:LOCAL_ONLY = "1"
$env:RAWRXD_SWARM_N = "16"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

$p = Start-Process -FilePath $TipExe -WorkingDirectory $TipDir -PassThru -WindowStyle Normal
$hwnd = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($p.HasExited) { break }
  $hwnd = [MultiId]::FindMain([uint32]$p.Id)
  if ($hwnd -ne [IntPtr]::Zero -and [MultiId]::GetPropW($hwnd, "RawrXD.MainMenuReady") -ne [IntPtr]::Zero) { break }
  Start-Sleep -Milliseconds 200
}

@(
  "SHA=$sha",
  "PID=$($p.Id)",
  ("HWND=0x{0:X}" -f $hwnd.ToInt64()),
  ("ISWINDOW={0}" -f [MultiId]::IsWindow($hwnd)),
  ("MENU_READY={0}" -f [int]([MultiId]::GetPropW($hwnd, "RawrXD.MainMenuReady") -ne [IntPtr]::Zero))
) | Set-Content $out

if ($hwnd -eq [IntPtr]::Zero -or -not [MultiId]::IsWindow($hwnd)) {
  "FAIL HWND" | Add-Content $out
  if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
  exit 3
}

Start-Sleep 2
foreach ($id in @(1001, 4109, 4110, 4111, 4112, 4113, 40200)) {
  $r = [IntPtr]::Zero
  $ok = [MultiId]::SendMessageTimeoutW($hwnd, 0x0111, [IntPtr]$id, [IntPtr]::Zero, 2, 8000, [ref]$r)
  $post = [MultiId]::PostMessageW($hwnd, 0x0111, [IntPtr]$id, [IntPtr]::Zero)
  "ID=$id SEND=$([int]($ok -ne [IntPtr]::Zero)) POST=$([int]$post) RESULT=$($r.ToInt64())" | Add-Content $out
  Start-Sleep -Milliseconds 500
}
Start-Sleep 3

if (Test-Path $crumb) {
  Copy-Item $crumb (Join-Path $OutDir "CMD_BREADCRUMB_multi.txt") -Force
  foreach ($id in @(1001, 4109, 4110, 4111, 4112, 4113, 40200)) {
    $n = @(Select-String -Path $crumb -Pattern "id=$id ").Count
    "CRUMB id=$id count=$n" | Add-Content $out
  }
  "--- crumb lines containing 411 ---" | Add-Content $out
  Select-String -Path $crumb -Pattern "id=411" | ForEach-Object { $_.Line } | Add-Content $out
} else {
  "NO_CRUMB" | Add-Content $out
}

if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
Get-Content $out
