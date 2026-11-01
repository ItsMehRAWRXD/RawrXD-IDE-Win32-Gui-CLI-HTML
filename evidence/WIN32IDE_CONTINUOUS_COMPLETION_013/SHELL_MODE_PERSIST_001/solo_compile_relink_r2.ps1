# Round 2: lightweight persistShellModeOnly + IRC WM_TIMER gate
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_013\SHELL_MODE_PERSIST_001'
$relinkSeal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$candBin = Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\bin'
$tipExe = Join-Path $root 'evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$log = Join-Path $seal 'logs\solo_relink_r2.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content -LiteralPath $log

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

$defines = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_INCLUDES.txt') -Raw).Trim()

cmd /c "taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
Start-Sleep 1
$before = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
Write-Host "BEFORE=$before"

Push-Location $bld
try {
  foreach ($j in @(
    @{ src = 'src\win32app\Win32IDE_CommandSurface.cpp'; out = 'src\win32app\Win32IDE_CommandSurface.cpp.obj' },
    @{ src = 'src\win32app\Win32IDE_Core.cpp'; out = 'src\win32app\Win32IDE_Core.cpp.obj' }
  )) {
    $src = Join-Path $root $j.src
    $out = Join-Path $objdir $j.out
    $leaf = Split-Path $j.src -Leaf
    Write-Host "COMPILE $leaf"
    $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$out`" `"$src`" >> `"$log`" 2>&1"
    Write-Host "COMPILE_${leaf}=$rc"
    if ($rc -ne 0) { Get-Content $log -Tail 40; exit $rc }
  }

  $orphans = @(
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_State.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Util.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Scan.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Manifest.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Host.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Toggles.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Activate.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ProductExtensionRuntime_Api.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ASM_Bridge_Implementation.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_FabricBridge.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Phase17_AgenticProfiler.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionCiteForce.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionVulkanCite.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_CallStackSymbols.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_TasksDebugUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\BreakpointManagerPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\BreakpointPropertiesDialog.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_BreakpointManagerUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_PathBCmdDiagSwarm.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\ui\CallStackPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\ui\CallStackIntegration.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DapAdapterSpawn.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DapServiceProduct.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DebuggerIntegration.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DebuggerIntegrationUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_CommandPalette.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_CommandPaletteUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_ComposerPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_ComposerPanelUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_ReferencesPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_ReferencesPanelUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\ollama_client.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_ChatWindow.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  Copy-Item -Force $baseRsp $bakRsp
  $merged = (($orphans -join "`r`n") + "`r`n" + [IO.File]::ReadAllText($baseRsp))
  [IO.File]::WriteAllText($baseRsp, $merged)

  $outAlt = 'bin\RawrXD-Win32IDE_c013b.exe'
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:' + $outAlt + ' /implib:RawrXD-Win32IDE_c013b.lib /pdb:bin\RawrXD-Win32IDE_c013b.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05 /INCLUDE:RawrXD_UI_ListBreakpointsAndShowPanel /INCLUDE:RawrXD_UI_InitDebuggerIntegration /INCLUDE:RawrXD_UI_InitCommandPalette /INCLUDE:RawrXD_UI_InitComposerPanel /INCLUDE:RawrXD_UI_InitReferencesPanel /INCLUDE:RawrXDChatWindow_Create'
  $linkLog = Join-Path $seal 'logs\solo_link_r2.txt'
  try {
    $rc = Invoke-VcCmd "$linkInner > `"$linkLog`" 2>&1"
  } finally {
    Copy-Item -Force $bakRsp $baseRsp
  }
  Write-Host "LINK=$rc"
  $built = Join-Path $bld $outAlt
  if (-not (Test-Path $built)) { Get-Content $linkLog -Tail 40; exit 1 }
  $builtSize = (Get-Item $built).Length
  if ($builtSize -lt 100000000) { Write-Host "TRUNCATED=$builtSize"; exit 1 }
  Copy-Item -Force $built (Join-Path $candBin 'RawrXD-Win32IDE.exe')
  $pdb = Join-Path $bld 'bin\RawrXD-Win32IDE_c013b.pdb'
  if (Test-Path $pdb) { Copy-Item -Force $pdb (Join-Path $candBin 'RawrXD-Win32IDE.pdb') }
  New-Item -ItemType Directory -Force -Path (Join-Path $seal 'bin_freeze') | Out-Null
  Copy-Item -Force $built (Join-Path $seal 'bin_freeze\RawrXD-Win32IDE.exe')
  $after = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
  $tip = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
  $tipOk = [int]($tip -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145')
  Write-Host "AFTER=$after tip748B=$tipOk"
  @"
CAND_SHA_BEFORE=$before
CAND_SHA_AFTER=$after
TIP_SHA_AFTER=$tip
tip748B=$tipOk
PROMOTE=0
RELINK_ROUND=2
WIRE=shellMode_persist_lightweight+irc_timer_gate
BUILT_SIZE=$builtSize
"@ | Set-Content (Join-Path $seal 'NEW_CAND_SHA.txt')
  if ($tipOk -ne 1) { exit 2 }
  exit 0
}
finally {
  Pop-Location
}
