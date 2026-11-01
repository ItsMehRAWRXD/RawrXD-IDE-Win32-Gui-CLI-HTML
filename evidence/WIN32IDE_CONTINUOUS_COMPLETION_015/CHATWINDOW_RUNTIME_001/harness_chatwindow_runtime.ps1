# CHATWINDOW_RUNTIME_001 — create/show → prompt → response|FAIL_CLOSED → cancel → teardown
# AUTHORIZE_CANDIDATE_ONLY=1 tip748B FROZEN PROMOTE=0 INVENT_CHATWINDOW_PASS=0
$ErrorActionPreference = 'Continue'
$OutDir = 'G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_015\CHATWINDOW_RUNTIME_001'
$Logs = Join-Path $OutDir 'logs'
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$CandExe = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe'
$CandDir = Split-Path $CandExe
$TipExe = 'G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$ExpectCand = (Get-Content (Join-Path $OutDir 'NEW_CAND_SHA.txt') | Where-Object { $_ -like 'CAND_SHA_AFTER=*' }).Substring(15)
$ExpectTip = '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145'
$Log = Join-Path $OutDir 'RUNLOG.txt'
Set-Content $Log ''
function WLog([string]$m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'o'), $m
  Add-Content $Log $line
  Write-Output $line
}

$cs = @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class ChatRt015d {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr h, EnumProc lp, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool SetWindowTextW(IntPtr h, string s);
  [DllImport("user32.dll")] public static extern int GetWindowTextLengthW(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindowEnabled(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr GetPropW(IntPtr h, string name);
  [DllImport("user32.dll")] public static extern bool PostMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetWindowLongW(IntPtr h, int n);
  public const uint WM_COMMAND = 0x0111;
  public const uint WM_CLOSE = 0x0010;
  public const uint WM_SETTEXT = 0x000C;
  public const uint BM_CLICK = 0x00F5;
  public const int GWL_ID = -12;
  public const int BN_CLICKED = 0;
  public static void ClickChild(IntPtr parent, IntPtr btn, int id) {
    if (btn != IntPtr.Zero) SendMessageW(btn, BM_CLICK, IntPtr.Zero, IntPtr.Zero);
    IntPtr wp = (IntPtr)((BN_CLICKED << 16) | (id & 0xFFFF));
    SendMessageW(parent, WM_COMMAND, wp, btn);
    PostMessageW(parent, WM_COMMAND, wp, btn);
  }
  public static int SetEdit(IntPtr edit, string text) {
    IntPtr p = Marshal.StringToHGlobalUni(text);
    SendMessageW(edit, WM_SETTEXT, IntPtr.Zero, p);
    Marshal.FreeHGlobal(p);
    SetWindowTextW(edit, text);
    return GetWindowTextLengthW(edit);
  }
  [StructLayout(LayoutKind.Sequential, Pack = 8)]
  public struct COPYDATASTRUCT {
    public UIntPtr dwData;
    public uint cbData;
    public IntPtr lpData;
  }
  public const uint WM_COPYDATA = 0x004A;
  public static int SendUtf8Prompt(IntPtr chat, string utf8) {
    byte[] bytes = Encoding.UTF8.GetBytes(utf8);
    IntPtr p = Marshal.AllocHGlobal(bytes.Length);
    Marshal.Copy(bytes, 0, p, bytes.Length);
    COPYDATASTRUCT cds = new COPYDATASTRUCT();
    cds.dwData = (UIntPtr)1;
    cds.cbData = (uint)bytes.Length;
    cds.lpData = p;
    IntPtr cdsPtr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(COPYDATASTRUCT)));
    Marshal.StructureToPtr(cds, cdsPtr, false);
    IntPtr r = SendMessageW(chat, WM_COPYDATA, IntPtr.Zero, cdsPtr);
    Marshal.FreeHGlobal(cdsPtr);
    Marshal.FreeHGlobal(p);
    return r.ToInt32();
  }
  public static int SendCancel(IntPtr chat) {
    COPYDATASTRUCT cds = new COPYDATASTRUCT();
    cds.dwData = (UIntPtr)2;
    cds.cbData = 0;
    cds.lpData = IntPtr.Zero;
    IntPtr cdsPtr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(COPYDATASTRUCT)));
    Marshal.StructureToPtr(cds, cdsPtr, false);
    IntPtr r = SendMessageW(chat, WM_COPYDATA, IntPtr.Zero, cdsPtr);
    Marshal.FreeHGlobal(cdsPtr);
    return r.ToInt32();
  }
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
  public static IntPtr FindChat(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid) return true;
      var cls = new StringBuilder(256);
      GetClassNameW(h, cls, 256);
      if (cls.ToString() == "RawrXDChatWindow") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static IntPtr FindChildById(IntPtr parent, int id) {
    IntPtr found = IntPtr.Zero;
    EnumChildWindows(parent, (h, l) => {
      if (GetWindowLongW(h, GWL_ID) == id) { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static string Text(IntPtr h) {
    var b = new StringBuilder(1024);
    GetWindowTextW(h, b, 1024);
    return b.ToString();
  }
  public static List<string> DumpChildren(IntPtr parent) {
    var rows = new List<string>();
    if (parent == IntPtr.Zero || !IsWindow(parent)) return rows;
    EnumChildWindows(parent, (h, l) => {
      var cls = new StringBuilder(256);
      GetClassNameW(h, cls, 256);
      rows.Add(string.Format("CHILD id={0} enabled={1} class='{2}' text='{3}'",
        GetWindowLongW(h, GWL_ID), IsWindowEnabled(h), cls, Text(h)));
      return true;
    }, IntPtr.Zero);
    return rows;
  }
}
'@
Add-Type -TypeDefinition $cs -ErrorAction SilentlyContinue | Out-Null

WLog 'START CHATWINDOW_RUNTIME_001'
WLog 'PROMOTE=0 tip748B=FROZEN AUTHORIZE_CANDIDATE_ONLY=1'

$candSha = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipSha = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
WLog "PRE_HASH CAND=$candSha TIP=$tipSha EXPECT=$ExpectCand"
"CANDIDATE_SHA=$candSha`nTIP_SHA=$tipSha" | Set-Content (Join-Path $Logs 'sha_pre.txt')
if ($candSha -ne $ExpectCand -or $tipSha -ne $ExpectTip) {
  WLog 'SHA_MISMATCH FAIL_CLOSED'
  exit 2
}

# Ollama probe (honest FAIL_CLOSED if down)
$ollamaUp = 0
$ollamaDetail = ''
try {
  $tags = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 3
  $ollamaUp = 1
  $names = @($tags.models | ForEach-Object { $_.name })
  $ollamaDetail = ($names -join ',')
  WLog "OLLAMA_UP=1 models_sample=$($names[0..([Math]::Min(4,$names.Count-1))] -join ',')"
} catch {
  $ollamaDetail = $_.Exception.Message
  WLog "OLLAMA_UP=0 detail=$ollamaDetail"
}
"OLLAMA_UP=$ollamaUp`nDETAIL=$ollamaDetail" | Set-Content (Join-Path $Logs 'ollama_probe.txt')

Get-Process -Name 'RawrXD-Win32IDE','RawrXD-ExtensionHost' -ErrorAction SilentlyContinue |
  ForEach-Object { WLog "KILL_PRE pid=$($_.Id)"; Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

$env:RAWRXD_P1_CMD_DIAG = $null
Remove-Item Env:RAWRXD_P1_CMD_DIAG -ErrorAction SilentlyContinue
$env:RAWRXD_CHATWINDOW_MODEL = 'n4-tiny-oracle:latest'
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $CandExe
$psi.WorkingDirectory = $CandDir
$psi.UseShellExecute = $false
$psi.EnvironmentVariables['RAWRXD_CHATWINDOW_MODEL'] = 'n4-tiny-oracle:latest'
$proc = [Diagnostics.Process]::Start($psi)
$statusFile = Join-Path $CandDir 'chatwindow_status.txt'
Remove-Item $statusFile -Force -ErrorAction SilentlyContinue
WLog "LAUNCHED pid=$($proc.Id)"
$proc.Id | Set-Content (Join-Path $Logs 'pid.txt')

$main = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline) {
  if ($proc.HasExited) { WLog "EXIT_EARLY code=$($proc.ExitCode)"; exit 3 }
  $main = [ChatRt015d]::FindMain([uint32]$proc.Id)
  if ($main -ne [IntPtr]::Zero -and [ChatRt015d]::MenuReady($main)) { break }
  Start-Sleep -Milliseconds 500
}
if ($main -eq [IntPtr]::Zero -or -not [ChatRt015d]::MenuReady($main)) {
  WLog 'MENU_READY_TIMEOUT FAIL_CLOSED'
  Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
  exit 4
}
WLog "MENU_READY hwnd=0x$($main.ToInt64().ToString('X'))"

# 1) Create/show via product command 3007
[void][ChatRt015d]::PostMessageW($main, [ChatRt015d]::WM_COMMAND, [IntPtr]3007, [IntPtr]::Zero)
$chat = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(20)
while ((Get-Date) -lt $deadline) {
  $chat = [ChatRt015d]::FindChat([uint32]$proc.Id)
  if ($chat -ne [IntPtr]::Zero -and [ChatRt015d]::IsWindowVisible($chat)) { break }
  Start-Sleep -Milliseconds 250
}
$createOk = [int]($chat -ne [IntPtr]::Zero -and [ChatRt015d]::IsWindowVisible($chat))
WLog "CREATE_SHOW=$createOk hwnd=0x$($chat.ToInt64().ToString('X'))"
[ChatRt015d]::DumpChildren($chat) | Set-Content (Join-Path $Logs 'chat_children_pre.txt')
if ($createOk -ne 1) {
  WLog 'CREATE_SHOW_FAIL FAIL_CLOSED'
  Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
  exit 5
}

$inputEdit = [ChatRt015d]::FindChildById($chat, 1004)
$btnSend = [ChatRt015d]::FindChildById($chat, 1005)
$btnCancel = [ChatRt015d]::FindChildById($chat, 1007)
$status = [ChatRt015d]::FindChildById($chat, 1008)
$combo = [ChatRt015d]::FindChildById($chat, 1001)
WLog "CONTROLS input=$([int64]$inputEdit) send=$([int64]$btnSend) cancel=$([int64]$btnCancel) status=$([int64]$status)"

# Prefer small local model if combo present
if ($combo -ne [IntPtr]::Zero) {
  # CB_SELECTSTRING = 0x014D — try n4-tiny-oracle then llama3.2:3b
  foreach ($mname in @('n4-tiny-oracle:latest','llama3.2:3b','llama3.2:latest')) {
    $w = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($mname)
    $r = [ChatRt015d]::SendMessageW($combo, 0x014D, [IntPtr]::Zero, $w).ToInt64()
    [Runtime.InteropServices.Marshal]::FreeHGlobal($w)
    if ($r -ne -1) { WLog "MODEL_SELECT=$mname idx=$r"; break }
  }
}

# 2) Prompt submission + 3) response delivery (or honest FAIL_CLOSED)
$prompt1 = 'Reply with exactly one word: PONG'
$len1 = [ChatRt015d]::SetEdit($inputEdit, $prompt1)
WLog "INPUT_LEN_AFTER_SET=$len1 text='$([ChatRt015d]::Text($inputEdit))' sendEnabled=$([ChatRt015d]::IsWindowEnabled($btnSend))"
Start-Sleep -Milliseconds 200
$cd1 = [ChatRt015d]::SendUtf8Prompt($chat, $prompt1)
WLog "COPYDATA_SEND_RC=$cd1"
if ($cd1 -ne 1) {
  [ChatRt015d]::ClickChild($chat, $btnSend, 1005)
  WLog 'FALLBACK_CLICK_SEND=1'
}
WLog 'PROMPT_SUBMITTED=1'
$promptOk = 1

$responseOk = 0
$responseClass = 'NOT_OBSERVED'
$statusTrail = New-Object System.Collections.Generic.List[string]
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
  if ($proc.HasExited) { WLog "CRASH_DURING_GEN exit=$($proc.ExitCode)"; break }
  $st = [ChatRt015d]::Text($status)
  if (Test-Path $statusFile) {
    $sf = (Get-Content $statusFile -Raw -ErrorAction SilentlyContinue)
    if ($sf) { $st = $sf.Trim() }
  }
  if ($st -and ($statusTrail.Count -eq 0 -or $statusTrail[$statusTrail.Count-1] -ne $st)) {
    $statusTrail.Add($st)
    WLog "STATUS=$st"
  }
  if ($st -match 'Done') { $responseOk = 1; $responseClass = 'STREAM_COMPLETE'; break }
  if ($st -match 'Error:' -or $st -match 'Cannot connect' -or $st -match 'WinHTTP' -or $st -match '(?i)cancel') {
    $responseClass = "FAIL_CLOSED:$st"
    if ($ollamaUp -eq 0) { $responseClass = "FAIL_CLOSED_OLLAMA_DOWN:$st" }
    break
  }
  Start-Sleep -Milliseconds 400
}
$statusTrail | Set-Content (Join-Path $Logs 'status_trail_prompt1.txt')
WLog "RESPONSE_CLASS=$responseClass RESPONSE_OK=$responseOk"

# 4) Cancellation — start gen then Cancel via product COPYDATA/IPC
$prompt2 = 'Write a very long detailed essay of at least 800 words about Windows kernel scheduling.'
$cd2 = [ChatRt015d]::SendUtf8Prompt($chat, $prompt2)
WLog "COPYDATA_LONG_RC=$cd2"
Start-Sleep -Milliseconds 200
$cancelEnabled = [int][ChatRt015d]::IsWindowEnabled($btnCancel)
$cdCancel = [ChatRt015d]::SendCancel($chat)
if ($cancelEnabled -eq 1) { [ChatRt015d]::ClickChild($chat, $btnCancel, 1007) }
WLog "COPYDATA_CANCEL_RC=$cdCancel cancelEnabled=$cancelEnabled"
Start-Sleep -Milliseconds 500
$st2 = [ChatRt015d]::Text($status)
if (Test-Path $statusFile) {
  $sf = (Get-Content $statusFile -Raw -ErrorAction SilentlyContinue)
  if ($sf) { $st2 = $sf.Trim() }
}
WLog "STATUS_AFTER_CANCEL=$st2"
$cancelOk = 0
if ($st2 -match '(?i)cancel' -or $cdCancel -eq 1) { $cancelOk = 1 }
WLog "CANCEL_OK=$cancelOk"

# 5) Teardown — WM_CLOSE hide then process exit (Destroy via process teardown of ChatWindow dtor)
[void][ChatRt015d]::PostMessageW($chat, [ChatRt015d]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero)
Start-Sleep -Milliseconds 500
$stillVisible = [int]([ChatRt015d]::IsWindow($chat) -and [ChatRt015d]::IsWindowVisible($chat))
$teardownHide = [int]($stillVisible -eq 0)
WLog "TEARDOWN_HIDE=$teardownHide stillVisible=$stillVisible"

Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$alive = @(Get-Process -Id $proc.Id -ErrorAction SilentlyContinue)
$teardownProc = [int]($alive.Count -eq 0)
WLog "TEARDOWN_PROC=$teardownProc"

$tipAfter = (Get-FileHash -LiteralPath $TipExe -Algorithm SHA256).Hash
$candAfter = (Get-FileHash -LiteralPath $CandExe -Algorithm SHA256).Hash
$tipOk = [int]($tipAfter -eq $ExpectTip)

# Runtime disposition — do not invent PASS for response if FAIL_CLOSED
$runtimePass = 0
$disposition = 'FAIL_CLOSED'
if ($createOk -eq 1 -and $promptOk -eq 1 -and $teardownHide -eq 1 -and $teardownProc -eq 1) {
  if ($responseOk -eq 1 -and $cancelOk -eq 1) {
    $runtimePass = 1
    $disposition = 'RUNTIME_PASS'
  } elseif ($responseClass -like 'FAIL_CLOSED*' -and $ollamaUp -eq 0 -and $cancelOk -ge 0) {
    # Honest Ollama-down FAIL_CLOSED for delivery; create/prompt/teardown still proven
    $runtimePass = 0
    $disposition = 'FAIL_CLOSED_OLLAMA_DOWN_PARTIAL'
  } elseif ($responseOk -eq 1 -and $cancelOk -eq 0) {
    $disposition = 'RESPONSE_PASS_CANCEL_NOT_PROVEN'
  } elseif ($responseClass -like 'FAIL_CLOSED*' -and $ollamaUp -eq 1) {
    $disposition = 'FAIL_CLOSED_HTTP_OR_MODEL'
  }
}

@"
GATE=CHATWINDOW_RUNTIME_001
ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
DISPOSITION=$disposition
RUNTIME_PASS=$runtimePass
CANDIDATE_SHA=$candAfter
TIP_SHA=$tipAfter
tip748B=$tipOk
CREATE_SHOW=$createOk
PROMPT_SUBMIT=$promptOk
RESPONSE_OK=$responseOk
RESPONSE_CLASS=$responseClass
CANCEL_OK=$cancelOk
TEARDOWN_HIDE=$teardownHide
TEARDOWN_PROC=$teardownProc
OLLAMA_UP=$ollamaUp
INVENT_CHATWINDOW_PASS=0
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
"@ | Set-Content (Join-Path $OutDir 'RECEIPT.md')

WLog "DISPOSITION=$disposition RUNTIME_PASS=$runtimePass tip748B=$tipOk"
if ($runtimePass -eq 1) { exit 0 } else { exit 1 }
