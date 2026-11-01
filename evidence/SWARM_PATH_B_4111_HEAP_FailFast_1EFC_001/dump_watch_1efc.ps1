# Dump-watch PathB: MiniDump on first fatal/first-chance interesting code; hard timeout.
# Tip 748B untouched. Authority cand from TIP_CANDIDATE_AGENT_RUN_005.
$ErrorActionPreference = "Continue"
$OutDir = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_HEAP_FailFast_1EFC_001"
$DumpDir = Join-Path $OutDir "dumps"
$CandExe = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe"
$CandDir = Split-Path $CandExe
$TipExe = "G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe"
$ExpectCand = (Get-Content (Join-Path $OutDir "NEW_CAND_SHA.txt") -Raw).Trim()
$ExpectTip = "748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145"
$DumpPath = Join-Path $DumpDir "RawrXD-Win32IDE_60473_FailFast.dmp"
$Log = Join-Path $OutDir "logs\RUNLOG_dumpwatch.txt"
New-Item -ItemType Directory -Force -Path (Join-Path $OutDir "logs"),$DumpDir | Out-Null
Set-Content $Log ""
function WLog([string]$m) {
  $line = "[{0}] {1}" -f (Get-Date -Format "o"), $m
  Add-Content $Log $line
  Write-Output $line
}

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha"
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) { WLog "SHA_MISMATCH"; exit 2 }

Get-Process -Name "RawrXD-Win32IDE" -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep 2

$cs = @'
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class DumpWatch2 {
  public const uint DBG_CONTINUE = 0x00010002;
  public const uint DBG_EXCEPTION_NOT_HANDLED = 0x80010001;
  public const uint EXCEPTION_DEBUG_EVENT = 1;
  public const uint EXIT_PROCESS_DEBUG_EVENT = 5;
  public const uint CREATE_PROCESS_DEBUG_EVENT = 3;
  public const uint LOAD_DLL_DEBUG_EVENT = 6;
  public const uint OUTPUT_DEBUG_STRING_EVENT = 8;

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
      return MiniDumpWriteDump(proc.Handle, (uint)proc.Id, fs.SafeFileHandle.DangerousGetHandle(), 2,
        IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);
    }
  }
  public static uint GetExceptionCode(DEBUG_EVENT ev) { return BitConverter.ToUInt32(ev.bytes, 0); }
  public static uint GetFirstChance(DEBUG_EVENT ev) { return BitConverter.ToUInt32(ev.bytes, 4 + 4*IntPtr.Size + 4 + 4); }
  public static ulong GetExceptionAddress(DEBUG_EVENT ev) {
    // EXCEPTION_RECORD: code(4)+flags(4)+record(ptr)+address(ptr)
    int off = 8 + IntPtr.Size;
    if (IntPtr.Size == 8) return BitConverter.ToUInt64(ev.bytes, off);
    return BitConverter.ToUInt32(ev.bytes, off);
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

$env:RAWRXD_P1_CMD_DIAG = "1"
$env:RAWRXD_DISABLE_OLLAMA_FETCH = "1"
$env:LOCAL_ONLY_NO_OLLAMA = "1"
$env:RAWRXD_SKIP_GPU_POWER_PROBE = "1"
$env:RAWRXD_GUI = "1"
$env:RAWRXD_SWARM_N = "2"
$env:RAWRXD_SWARM_MAX_PARALLEL = "2"
$env:RAWRXD_MODELS = "G:\~dev\rawrxd\models"
$env:RAWRXD_SWARM_MODEL_DIR = "G:\~dev\rawrxd\models"
$env:LOCAL_ONLY = "1"
Remove-Item Env:RAWRXD_HEADLESS -ErrorAction SilentlyContinue

$crumbDir = Join-Path $CandDir "evidence\P1_UI_MENU_E2E_001"
New-Item -ItemType Directory -Force -Path $crumbDir | Out-Null
foreach ($n in @("CMD_BREADCRUMB.txt","FIRST_CHANCE_WM_COMMAND.txt","FIRST_CHANCE_JOURNAL.txt")) {
  $p = Join-Path $crumbDir $n
  if (Test-Path $p) { Remove-Item $p -Force }
}

WLog "LAUNCH under debugger CREATE_PROCESS"
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$p = [Diagnostics.Process]::Start($psi)
WLog "PID=$($p.Id)"

# Attach after brief settle (avoids CREATE_PROCESS hang storm of prior dump_watch)
Start-Sleep -Milliseconds 400
$attached = $false
try {
  $null = [DumpWatch2] | Out-Null
  Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class DbgAtt { [DllImport("kernel32.dll", SetLastError=true)] public static extern bool DebugActiveProcess(uint pid); [DllImport("kernel32.dll", SetLastError=true)] public static extern bool DebugSetProcessKillOnExit(bool kill); }' -ErrorAction SilentlyContinue | Out-Null
  $attached = [DbgAtt]::DebugActiveProcess([uint32]$p.Id)
  [void][DbgAtt]::DebugSetProcessKillOnExit($false)
  WLog "DebugActiveProcess=$attached"
} catch {
  WLog "ATTACH_FAIL $_"
}

$dumpOk = 0
$excCode = "NONE"
$excAddr = "NONE"
$posted = 0
$deadline = (Get-Date).AddSeconds(50)
$ev = New-Object DumpWatch2+DEBUG_EVENT
$ev.bytes = New-Object byte[] 176

while ((Get-Date) -lt $deadline) {
  try { $p.Refresh() } catch {}
  if ($p.HasExited) {
    WLog ("EXIT code={0}" -f $p.ExitCode)
    break
  }
  if ($attached) {
    $got = [DumpWatch2]::WaitForDebugEvent([ref]$ev, 50)
    if ($got) {
      $code = $ev.dwDebugEventCode
      if ($code -eq 1) { # EXCEPTION
        $ec = [DumpWatch2]::GetExceptionCode($ev)
        $addr = [DumpWatch2]::GetExceptionAddress($ev)
        # skip breakpoint / single-step / c++ eh / thread name
        $noise = ($ec -eq 0x80000003 -or $ec -eq 0x80000004 -or $ec -eq 0xE06D7363 -or $ec -eq 0x406D1388 -or $ec -eq 0x40010006)
        if (-not $noise) {
          WLog ("DBG_EXC code=0x{0:X8} addr=0x{1:X} firstChance-ish" -f $ec, $addr)
          $excCode = ("0x{0:X8}" -f $ec)
          $excAddr = ("0x{0:X}" -f $addr)
          if ($ec -eq 0xC0000409 -or $ec -eq 0xC0000374 -or $ec -eq 0xC0000005) {
            try {
              if ([DumpWatch2]::WriteDump($p, $DumpPath)) {
                $dumpOk = 1
                WLog "DUMP_OK $DumpPath size=$((Get-Item $DumpPath).Length)"
              } else { WLog "DUMP_WRITE_FAIL err=$([Runtime.InteropServices.Marshal]::GetLastWin32Error())" }
            } catch { WLog "DUMP_EXC $_" }
            [void][DumpWatch2]::ContinueDebugEvent($ev.dwProcessId, $ev.dwThreadId, [DumpWatch2]::DBG_EXCEPTION_NOT_HANDLED)
            break
          }
        }
        [void][DumpWatch2]::ContinueDebugEvent($ev.dwProcessId, $ev.dwThreadId, [DumpWatch2]::DBG_CONTINUE)
      } else {
        [void][DumpWatch2]::ContinueDebugEvent($ev.dwProcessId, $ev.dwThreadId, [DumpWatch2]::DBG_CONTINUE)
      }
    }
  } else {
    Start-Sleep -Milliseconds 50
  }

  if ($posted -eq 0) {
    $hwnd = [DumpWatch2]::FindMain([uint32]$p.Id)
    if ($hwnd -ne [IntPtr]::Zero -and [DumpWatch2]::MenuReady($hwnd)) {
      [void][DumpWatch2]::PostMessageW($hwnd, 0x0111, [IntPtr]1001, [IntPtr]::Zero)
      [void][DumpWatch2]::PostMessageW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero)
      $posted = 1
      WLog ("MENU_READY_POST hwnd=0x{0:X}" -f $hwnd.ToInt64())
      Start-Sleep -Milliseconds 200
      $sr = [IntPtr]::Zero
      $ok = [DumpWatch2]::SendMessageTimeoutW($hwnd, 0x0111, [IntPtr]4111, [IntPtr]::Zero, 0x0002, 3000, [ref]$sr)
      WLog ("SEND4111 ok={0} result={1}" -f [int]($ok -ne [IntPtr]::Zero), $sr.ToInt64())
    }
  }
}

if ($attached) {
  try { [void][DumpWatch2]::DebugActiveProcessStop([uint32]$p.Id) } catch {}
}
if (-not $p.HasExited) {
  try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
}
WLog "DUMP_CAPTURED=$dumpOk EXC=$excCode ADDR=$excAddr"
@"
DUMP_CAPTURED=$dumpOk
DUMP_PATH=$DumpPath
EXCEPTION_CODE=$excCode
EXCEPTION_ADDRESS=$excAddr
CAND_SHA=$candSha
TIP_SHA=$tipSha
TIP_UNTOUCHED=1
"@ | Set-Content (Join-Path $DumpDir "DUMP_WATCH_RECEIPT.txt")
exit 0
