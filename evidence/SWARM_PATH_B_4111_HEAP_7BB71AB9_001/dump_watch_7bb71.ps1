# Debug-attach PathB prove: capture full dump on first-chance fatal, then continue PathB post.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_HEAP_7BB71AB9_001"
$DumpHook = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CRASH_ROOT_001\dumps"
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = "7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB"
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$DumpPath = Join-Path $DumpHook "RawrXD-Win32IDE_7BB71AB9_HeapFailFast.dmp"
$Log = Join-Path $OutDir "RUNLOG_dumpwatch.txt"
New-Item -ItemType Directory -Force -Path (Join-Path $OutDir "logs"),$DumpHook | Out-Null
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}
function ExitHex([int]$c) {
  $u = [uint32]([int64]$c -band [int64]0xFFFFFFFF)
  return ("0x{0:X8}" -f $u)
}

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog "SHA_MISMATCH FAIL_CLOSED"
  exit 2
}

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object {
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 2

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
foreach ($n in @("CMD_BREADCRUMB.txt","FIRST_CHANCE_WM_COMMAND.txt")) {
  $p = Join-Path $crumbDir $n
  if (Test-Path $p) { Remove-Item $p -Force }
}
foreach ($n in @("win32ide_trace.log","ide_startup.log")) {
  $p = Join-Path $CandDir $n
  if (Test-Path $p) { Remove-Item $p -Force }
}

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "2"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

$cs = @'
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

public class DumpWatch {
  public const uint DBG_CONTINUE = 0x00010002;
  public const uint DBG_EXCEPTION_NOT_HANDLED = 0x80010001;
  public const uint EXCEPTION_BREAKPOINT = 0x80000003;
  public const uint EXCEPTION_SINGLE_STEP = 0x80000004;
  public const uint STATUS_HEAP_CORRUPTION = 0xC0000374;
  public const uint STATUS_ACCESS_VIOLATION = 0xC0000005;
  public const uint STATUS_STACK_BUFFER_OVERRUN = 0xC0000409;

  [StructLayout(LayoutKind.Sequential)]
  public struct EXCEPTION_RECORD {
    public uint ExceptionCode;
    public uint ExceptionFlags;
    public IntPtr ExceptionRecord;
    public IntPtr ExceptionAddress;
    public uint NumberParameters;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=15)]
    public UIntPtr[] ExceptionInformation;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct EXCEPTION_DEBUG_INFO {
    public EXCEPTION_RECORD ExceptionRecord;
    public uint dwFirstChance;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct DEBUG_EVENT {
    public uint dwDebugEventCode;
    public uint dwProcessId;
    public uint dwThreadId;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=176)]
    public byte[] bytes;
  }
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool WaitForDebugEvent(ref DEBUG_EVENT ev, uint ms);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool ContinueDebugEvent(uint pid, uint tid, uint status);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool DebugActiveProcessStop(uint pid);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern IntPtr OpenThread(uint access, bool inherit, uint tid);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool TerminateProcess(IntPtr h, uint code);
  [DllImport("dbghelp.dll", SetLastError=true)]
  public static extern bool MiniDumpWriteDump(IntPtr hProcess, uint pid, IntPtr hFile, int dumpType,
    IntPtr expParam, IntPtr userStream, IntPtr callback);

  [DllImport("user32.dll", CharSet=CharSet.Unicode)]
  public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)]
  public static extern IntPtr SendMessageTimeoutW(IntPtr h, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);

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

  public static bool WriteDump(Process proc, string path) {
    using (var fs = new FileStream(path, FileMode.Create, FileAccess.ReadWrite, FileShare.None)) {
      // MiniDumpWithFullMemory = 0x00000002
      return MiniDumpWriteDump(proc.Handle, (uint)proc.Id, fs.SafeFileHandle.DangerousGetHandle(), 2,
        IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);
    }
  }

  public static uint GetExceptionCode(DEBUG_EVENT ev) {
    // EXCEPTION_DEBUG_EVENT union starts at offset 12
    return BitConverter.ToUInt32(ev.bytes, 0);
  }
  public static uint GetFirstChance(DEBUG_EVENT ev) {
    return BitConverter.ToUInt32(ev.bytes, 152); // may vary; also parse ExceptionFlags path
  }
}
'@
Add-Type -TypeDefinition $cs -ReferencedAssemblies System.Runtime.InteropServices | Out-Null

WLog "LAUNCH under debugger"
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
# CREATE_SUSPENDED not via ProcessStartInfo; use Debug flag
$psi.CreateNoWindow = $false
# Start then DebugActiveProcess â€” racey. Prefer ProcessStart with DEBUG via kernel32.
$native = @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class NativeStart {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct STARTUPINFO {
    public int cb; public IntPtr lpReserved; public IntPtr lpDesktop; public IntPtr lpTitle;
    public int dwX,dwY,dwXSize,dwYSize,dwXCountChars,dwYCountChars,dwFillAttribute,dwFlags;
    public short wShowWindow,cbReserved2; public IntPtr lpReserved2,hStdInput,hStdOutput,hStdError;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct PROCESS_INFORMATION {
    public IntPtr hProcess; public IntPtr hThread; public uint dwProcessId; public uint dwThreadId;
  }
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  public static extern bool CreateProcessW(string app, string cmd, IntPtr pa, IntPtr ta, bool inherit, uint flags,
    IntPtr env, string dir, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern uint ResumeThread(IntPtr h);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool CloseHandle(IntPtr h);
  public const uint DEBUG_ONLY_THIS_PROCESS = 0x00000002;
  public const uint CREATE_UNICODE_ENVIRONMENT = 0x00000400;
}
'@
Add-Type -TypeDefinition $native -ErrorAction SilentlyContinue | Out-Null

$si = New-Object NativeStart+STARTUPINFO
$si.cb = [Runtime.InteropServices.Marshal]::SizeOf($si)
$si.dwFlags = 0x1; $si.wShowWindow = 1
$pi = New-Object NativeStart+PROCESS_INFORMATION
$cmd = "`"$CandExe`""
$ok = [NativeStart]::CreateProcessW($CandExe, $cmd, [IntPtr]::Zero, [IntPtr]::Zero, $false,
  [NativeStart]::DEBUG_ONLY_THIS_PROCESS, [IntPtr]::Zero, $CandDir, [ref]$si, [ref]$pi)
if (-not $ok) {
  WLog ("CreateProcess DEBUG fail gle={0}" -f [Runtime.InteropServices.Marshal]::GetLastWin32Error())
  exit 3
}
$procId = [int]$pi.dwProcessId
WLog "PID=$procId DEBUG_ONLY_THIS_PROCESS=1"
$proc = [Diagnostics.Process]::GetProcessById($procId)

$dumpCaptured = 0
$fatalCode = 0
$hwnd = [IntPtr]::Zero
$menuReady = 0
$post4111 = 0
$posted = 0
$exitCode = $null
$deadline = (Get-Date).AddSeconds(180)
$ev = New-Object DumpWatch+DEBUG_EVENT
$ev.bytes = New-Object byte[] 176

while ((Get-Date) -lt $deadline) {
  $got = [DumpWatch]::WaitForDebugEvent([ref]$ev, 200)
  if ($got) {
    $cont = [DumpWatch]::DBG_CONTINUE
    if ($ev.dwDebugEventCode -eq 1) { # EXCEPTION_DEBUG_EVENT
      $code = [DumpWatch]::GetExceptionCode($ev)
      $first = BitConverter.ToUInt32($ev.bytes, 152)
      if ($code -ne [DumpWatch]::EXCEPTION_BREAKPOINT -and $code -ne [DumpWatch]::EXCEPTION_SINGLE_STEP) {
        WLog ("DBG_EXCEPTION code=0x{0:X8} firstChance={1} tid={2}" -f $code, $first, $ev.dwThreadId)
        if ($code -eq [DumpWatch]::STATUS_HEAP_CORRUPTION -or $code -eq [DumpWatch]::STATUS_ACCESS_VIOLATION -or $code -eq [DumpWatch]::STATUS_STACK_BUFFER_OVERRUN -or ($code -band 0xC0000000) -eq 0xC0000000) {
          if ($dumpCaptured -eq 0) {
            try {
              if (Test-Path $DumpPath) { Remove-Item $DumpPath -Force }
              $okDump = [DumpWatch]::WriteDump($proc, $DumpPath)
              if ($okDump -and (Test-Path $DumpPath)) {
                $dumpCaptured = 1
                $fatalCode = $code
                WLog ("DUMP_OK size={0} path={1}" -f (Get-Item $DumpPath).Length, $DumpPath)
              } else {
                WLog ("DUMP_FAIL gle={0}" -f [Runtime.InteropServices.Marshal]::GetLastWin32Error())
              }
            } catch {
              WLog ("DUMP_EXCEPTION $($_.Exception.Message)")
            }
          }
          $cont = [DumpWatch]::DBG_EXCEPTION_NOT_HANDLED
        }
      }
    } elseif ($ev.dwDebugEventCode -eq 5) { # EXIT_PROCESS
      $exitCode = [BitConverter]::ToInt32($ev.bytes, 0)
      WLog ("EXIT_PROCESS code={0} {1}" -f $exitCode, (ExitHex $exitCode))
      [void][DumpWatch]::ContinueDebugEvent($ev.dwProcessId, $ev.dwThreadId, $cont)
      break
    } elseif ($ev.dwDebugEventCode -eq 3) { # CREATE_PROCESS
      WLog "CREATE_PROCESS"
    }
    [void][DumpWatch]::ContinueDebugEvent($ev.dwProcessId, $ev.dwThreadId, $cont)
  }

  # UI post path while debugging
  if ($posted -eq 0) {
    try { $proc.Refresh() } catch {}
    if (-not $proc.HasExited) {
      $hwnd = [DumpWatch]::FindMain([uint32]$procId)
      if ($hwnd -ne [IntPtr]::Zero -and [DumpWatch]::MenuReady($hwnd)) {
        $menuReady = 1
        [void][DumpWatch]::PostMessageW($hwnd, 0x0111, [IntPtr]1001, [IntPtr]::Zero)
        $post4111 = if ([DumpWatch]::PostMessageW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero)) { 1 } else { 0 }
        $posted = 1
        WLog ("POSTED hwnd=0x{0:X} post4111={1}" -f $hwnd.ToInt64(), $post4111)
      }
    }
  }
}

try { [void][DumpWatch]::DebugActiveProcessStop([uint32]$procId) } catch {}
try { if (-not $proc.HasExited) { $proc.Kill() } } catch {}
Start-Sleep 1
try {
  $proc.Refresh()
  if ($null -eq $exitCode -and $proc.HasExited) { $exitCode = [int]$proc.ExitCode }
} catch {}
if ($null -eq $exitCode) { $exitCode = -1 }

# Copy crumbs
$logs = Join-Path $OutDir "logs"
$crumb = Join-Path $crumbDir "CMD_BREADCRUMB.txt"
$fc = Join-Path $crumbDir "FIRST_CHANCE_WM_COMMAND.txt"
if (Test-Path $crumb) {
  Copy-Item $crumb (Join-Path $logs "CMD_BREADCRUMB_dumpwatch.txt") -Force
  Copy-Item $crumb (Join-Path $DumpHook "CMD_BREADCRUMB_7BB71AB9_dumpwatch.txt") -Force
}
if (Test-Path $fc) {
  Copy-Item $fc (Join-Path $logs "FIRST_CHANCE_WM_COMMAND_dumpwatch.txt") -Force
  Copy-Item $fc (Join-Path $DumpHook "FIRST_CHANCE_7BB71AB9_dumpwatch.txt") -Force
}

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$exitHex = ExitHex ([int]$exitCode)
$fatalHex = ("0x{0:X8}" -f [uint32]$fatalCode)
$asof = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$shaMatch = [int]($candSha -eq $ExpectCand)
$shaStable = [int]($candAfter -eq $ExpectCand)
$tipOk = [int]($tipAfter -eq $ExpectTip)
@"
GATE=SWARM_PATH_B_4111_HEAP_7BB71AB9_001
RUN=DUMPWATCH_DEBUG_ATTACH
ASOF_UTC=$asof
CANDIDATE_SHA=$candSha
CANDIDATE_SHA_AFTER=$candAfter
CANDIDATE_SHA_MATCH=$shaMatch
CANDIDATE_SHA_STABLE=$shaStable
TIP_SHA=$tipSha
TIP_SHA_AFTER=$tipAfter
TIP_UNTOUCHED=$tipOk
MENU_READY=$menuReady
POSTMESSAGE_WM_COMMAND_4111=$post4111
EXIT_CODE_DEC=$exitCode
EXIT_HEX=$exitHex
DUMP_CAPTURED=$dumpCaptured
DUMP_PATH=$DumpPath
FATAL_EXCEPTION=$fatalHex
RUNTIME_PASS=0
PROMOTE=0
TIP_CLIMB=HOLD
"@ | Set-Content (Join-Path $OutDir "SUMMARY_dumpwatch.txt")
WLog "DONE DUMP=$dumpCaptured EXIT=$exitHex FATAL=$fatalHex"
exit 0

