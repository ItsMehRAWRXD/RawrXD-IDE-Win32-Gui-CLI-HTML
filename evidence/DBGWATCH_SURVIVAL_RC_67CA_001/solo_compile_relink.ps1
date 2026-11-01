# DBGWATCH_SURVIVAL_RC_67CA_001 — Core early-bypass 12230 + Tier5 ODS + clean Commands.
# tip748B HOLD. PROMOTE=0 ABSORB=NOT_AUTHORIZED. NOT invent Watch PASS.
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\DBGWATCH_SURVIVAL_RC_67CA_001'
$relinkSeal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$priorSeal = 'G:\~dev\rawrxd\evidence\BREAKPOINT_FOLLOWON_REPROVE_5BB7_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$candBin = Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\bin'
$tipExe = Join-Path $root 'evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$freeze67 = Join-Path $priorSeal 'bin_freeze\RawrXD-Win32IDE.exe'
$log = Join-Path $seal 'logs\solo_relink.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs'), (Join-Path $seal 'bin_freeze') | Out-Null
'' | Set-Content -LiteralPath $log

$exeBld = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
$exeCand = Join-Path $candBin 'RawrXD-Win32IDE.exe'
if (-not (Test-Path -LiteralPath $exeBld)) {
  if (Test-Path -LiteralPath $freeze67) { Copy-Item -Force -LiteralPath $freeze67 -Destination $exeBld }
  else { Copy-Item -Force -LiteralPath $exeCand -Destination $exeBld }
}
$beforeCand = (Get-FileHash -LiteralPath $exeCand -Algorithm SHA256).Hash
$tipBefore = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
@"
CAND_SHA_BEFORE=$beforeCand
TIP_SHA_BEFORE=$tipBefore
NOTE=Core_WM_COMMAND_EARLY_BYPASS_12230 + Tier5 ODS + clean Commands; tip748B HOLD
PRIOR_67CA=67CA264F2D6C30F36B7DA546BAADB014E3AF479EDCFE820F6CF1F4A5EEF438C1
"@ | Set-Content -LiteralPath (Join-Path $seal 'PRE_HASH.txt')

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

$defines = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_INCLUDES.txt') -Raw).Trim()
if ($defines -match 'STRIP_STUB_SOURCES=1' -or $defines -match 'COMMANDS_STUB_INTERCEPT') {
  Write-Host 'REFUSE stub-poison defines'; exit 9
}

cmd /c "taskkill /F /IM link.exe >nul 2>&1 & taskkill /F /IM cl.exe >nul 2>&1 & taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
Start-Sleep -Seconds 1

Push-Location $bld
try {
  $files = @('Win32IDE_Core.cpp','Win32IDE_Commands.cpp','Win32IDE_Tier5Cosmetics.cpp')
  foreach ($f in $files) {
    $src = Join-Path $root "src\win32app\$f"
    $out = Join-Path $objdir "src\win32app\$f.obj"
    New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
    Write-Host "COMPILE $f"
    $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags /FS $defines $includes /Fo`"$out`" `"$src`" >> `"$log`" 2>&1"
    Add-Content -LiteralPath $log "COMPILE_${f}_EXIT=$rc"
    Write-Host "COMPILE_${f}_EXIT=$rc"
    if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 100; exit $rc }
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
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_NativeDebugPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Tier5Cosmetics.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Core.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Commands.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\ui\CallStackPanel.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\ui\CallStackIntegration.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DapServiceProduct.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DebuggerIntegration.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DebuggerIntegrationUI.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DapAdapterSpawn.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  Copy-Item -Force -LiteralPath $baseRsp -Destination $bakRsp
  $merged = (($orphans -join "`r`n") + "`r`n" + [IO.File]::ReadAllText($baseRsp))
  [IO.File]::WriteAllText($baseRsp, $merged)

  Write-Host 'SOLO LINK'
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_dbgwatch_rc.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05 /INCLUDE:RawrXD_UI_StartDebugging /INCLUDE:RawrXD_UI_ListBreakpointsAndShowPanel /INCLUDE:RawrXD_UI_InitDebuggerIntegration'
  try {
    $rc = Invoke-VcCmd "$linkInner >> `"$log`" 2>&1"
  } finally {
    Copy-Item -Force -LiteralPath $bakRsp -Destination $baseRsp
  }
  Add-Content -LiteralPath $log "LINK_EXIT=$rc"
  Write-Host "LINK_EXIT=$rc"
  if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 150; exit $rc }

  $built = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
  Copy-Item -Force -LiteralPath $built -Destination $exeCand
  Copy-Item -Force -LiteralPath $built -Destination (Join-Path $seal 'bin_freeze\RawrXD-Win32IDE.exe')
  $pdb = Join-Path $bld 'bin\RawrXD-Win32IDE.pdb'
  if (Test-Path -LiteralPath $pdb) {
    Copy-Item -Force -LiteralPath $pdb -Destination (Join-Path $candBin 'RawrXD-Win32IDE.pdb')
  }

  $afterCand = (Get-FileHash -LiteralPath $built -Algorithm SHA256).Hash
  $tipAfter = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
  $tipOk = [int]($tipBefore -eq $tipAfter -and $tipAfter -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145')
  $needles = @('WM_COMMAND_EARLY_BYPASS FAIL_CLOSED','FEATURE_FICTION=1 FAIL_CLOSED IDM_DBGWATCH','TIER5_HANDLER BC=DBGWATCH_SURVIVAL_RC_67CA_001')
  $bind = @()
  foreach ($n in $needles) {
    $hit = cmd /c "findstr /C:`"$n`" `"$built`" >nul && echo 1 || echo 0"
    $bind += ("ODS_BIND=" + $hit.Trim() + " :: " + $n)
  }
  @"
CAND_SHA_BEFORE=$beforeCand
CAND_SHA_AFTER=$afterCand
TIP_SHA_AFTER=$tipAfter
tip748B=$tipOk
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
COMMANDS_CLEAN_REBUILD=1
STUB_POISON=0
LINK_EXIT=$rc
$($bind -join "`n")
"@ | Set-Content -LiteralPath (Join-Path $seal 'NEW_CAND_SHA.txt')
  Write-Host "CAND_SHA_AFTER=$afterCand tip748B=$tipOk"
  $bind | ForEach-Object { Write-Host $_ }
} finally { Pop-Location }
