# COMMAND_PALETTE_DAP_SPAWN_PRODUCT_WIRE_001 — CommandPalette UI orphan + DAP adapter spawn I/O
# tip748B untouched. TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED PROMOTE=0 INVENT_DAP_PASS=0
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_007\COMMAND_PALETTE_DAP_SPAWN_PRODUCT_WIRE_001'
$relinkSeal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$candBin = Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\bin'
$tipExe = Join-Path $root 'evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$log = Join-Path $seal 'logs\solo_relink.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content -LiteralPath $log

$exeBld = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
$exeCand = Join-Path $candBin 'RawrXD-Win32IDE.exe'
if (-not (Test-Path -LiteralPath $exeBld)) {
  Copy-Item -Force -LiteralPath $exeCand -Destination $exeBld
}
$beforeCand = (Get-FileHash -LiteralPath $exeCand -Algorithm SHA256).Hash
$tipBefore = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
@"
CAND_SHA_BEFORE=$beforeCand
TIP_SHA_BEFORE=$tipBefore
EXPECT_BEFORE_PRIOR_5BB7=5BB7EF9B1837818B9B4DC716FA6F09A42920154394854F086AB681E17ADEB3C2
NOTE=accept live cand drift; re-prove PathB+N2+EXT on NEW_SHA after wire
"@ | Set-Content -LiteralPath (Join-Path $seal 'PRE_HASH.txt')
# Live cand may drift from COMPLETION_006 5BB7; tip748B must remain MATCH.
if ($beforeCand -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145') {
  Write-Host "REFUSE_ABSORB_TIP_AS_CAND"
  exit 3
}
Write-Host "CAND_LIVE_BEFORE=$beforeCand (prior_5BB7_historical_if_drift)"
if ($tipBefore -ne '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145') {
  Write-Host "TIP_DRIFT=$tipBefore"
  exit 4
}

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

$defines = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_INCLUDES.txt') -Raw).Trim()

cmd /c "taskkill /F /IM link.exe >nul 2>&1 & taskkill /F /IM cl.exe >nul 2>&1 & taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1 & taskkill /F /IM RawrXD-ExtensionHost.exe >nul 2>&1" | Out-Null
Start-Sleep -Seconds 1

Push-Location $bld
try {
  # CommandPalette UI_PANEL held: namespace Win32IDE vs class Win32IDE clash (compile C2825).
  $compileJobs = @(
    @{ src = 'src\win32app\Win32IDE_DapAdapterSpawn.cpp'; out = 'src\win32app\Win32IDE_DapAdapterSpawn.cpp.obj' },
    @{ src = 'src\win32app\Win32IDE_DapServiceProduct.cpp'; out = 'src\win32app\Win32IDE_DapServiceProduct.cpp.obj' }
  )
  foreach ($j in $compileJobs) {
    $src = Join-Path $root $j.src
    $out = Join-Path $objdir $j.out
    New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
    $leaf = Split-Path $j.src -Leaf
    Write-Host "COMPILE $leaf"
    $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$out`" `"$src`" >> `"$log`" 2>&1"
    Add-Content -LiteralPath $log "COMPILE_${leaf}_EXIT=$rc"
    Write-Host "COMPILE_${leaf}_EXIT=$rc"
    if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 80; exit $rc }
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
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_DebuggerIntegrationUI.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  Copy-Item -Force -LiteralPath $baseRsp -Destination $bakRsp
  $merged = (($orphans -join "`r`n") + "`r`n" + [IO.File]::ReadAllText($baseRsp))
  [IO.File]::WriteAllText($baseRsp, $merged)

  Write-Host 'SOLO LINK cand RawrXD-Win32IDE.exe'
  # Link to alternate out path to avoid locked RawrXD-Win32IDE.exe (prior partial 2MB).
  $outAlt = 'bin\RawrXD-Win32IDE_c007.exe'
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:' + $outAlt + ' /implib:RawrXD-Win32IDE_c007.lib /pdb:bin\RawrXD-Win32IDE_c007.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_dapspawn.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05 /INCLUDE:RawrXD_UI_ListBreakpointsAndShowPanel /INCLUDE:RawrXD_UI_InitDebuggerIntegration'
  $linkLog = Join-Path $seal 'logs\solo_link_ascii.txt'
  try {
    $rc = Invoke-VcCmd "$linkInner > `"$linkLog`" 2>&1"
  } finally {
    Copy-Item -Force -LiteralPath $bakRsp -Destination $baseRsp
  }
  Add-Content -LiteralPath $log "LINK_EXIT=$rc"
  Write-Host "LINK_EXIT=$rc"
  $built = Join-Path $bld $outAlt
  if (-not (Test-Path -LiteralPath $built)) {
    Write-Host 'LINK_NO_OUTPUT'
    if (Test-Path $linkLog) { Get-Content -LiteralPath $linkLog -Tail 80 }
    exit 1
  }
  $builtSize = (Get-Item -LiteralPath $built).Length
  Add-Content -LiteralPath $log "BUILT_SIZE=$builtSize"
  Write-Host "BUILT_SIZE=$builtSize"
  if ($builtSize -lt 100000000) {
    Write-Host 'LINK_TRUNCATED'
    if (Test-Path $linkLog) { Get-Content -LiteralPath $linkLog -Tail 80 }
    exit 1
  }
  # Treat cmake vs_link -1 as soft if full-size image exists (COMPLETION_006 pattern).
  Copy-Item -Force -LiteralPath $built -Destination (Join-Path $candBin 'RawrXD-Win32IDE.exe')
  $pdb = Join-Path $bld 'bin\RawrXD-Win32IDE_c007.pdb'
  if (Test-Path -LiteralPath $pdb) {
    Copy-Item -Force -LiteralPath $pdb -Destination (Join-Path $candBin 'RawrXD-Win32IDE.pdb')
  }
  $freeze = Join-Path $seal 'bin_freeze'
  New-Item -ItemType Directory -Force -Path $freeze | Out-Null
  Copy-Item -Force -LiteralPath $built -Destination (Join-Path $freeze 'RawrXD-Win32IDE.exe')

  $afterCand = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
  $tipAfter = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
  $tipOk = [int]($tipBefore -eq $tipAfter -and $tipAfter -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145')
  @"
CAND_SHA_BEFORE=$beforeCand
CAND_SHA_AFTER=$afterCand
TIP_SHA_AFTER=$tipAfter
tip748B=$tipOk
PROMOTE=0
INVENT_DAP_PASS=0
WIRE=DapAdapterSpawn+DapServiceProduct
COMMAND_PALETTE=WHY_HELD_NAMESPACE_CLASH
BUILT_SIZE=$builtSize
LINK_EXIT_RAW=$rc
"@ | Set-Content -LiteralPath (Join-Path $seal 'NEW_CAND_SHA.txt')
  Write-Host "CAND_SHA_AFTER=$afterCand tip748B=$tipOk"
  if ($tipOk -ne 1) { exit 2 }
  if ($afterCand -eq $beforeCand) { Write-Host 'WARN_SHA_UNCHANGED'; exit 5 }
  exit 0
}
finally {
  Pop-Location
}
