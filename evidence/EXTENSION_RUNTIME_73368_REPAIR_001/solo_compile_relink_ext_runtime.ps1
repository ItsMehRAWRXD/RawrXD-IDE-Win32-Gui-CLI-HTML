# EXTENSION_RUNTIME_73368_REPAIR — compile ProductExtensionRuntime* + wire TUs; cand only.
# tip748B untouched. TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED PROMOTE=0
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\EXTENSION_RUNTIME_73368_REPAIR_001'
$relinkSeal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$candBin = Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\bin'
$tipExe = Join-Path $root 'evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$log = Join-Path $seal 'logs\solo_relink_ext_runtime.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content -LiteralPath $log

$beforeCand = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
$tipBefore = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
@"
CAND_SHA_BEFORE=$beforeCand
TIP_SHA_BEFORE=$tipBefore
"@ | Set-Content -LiteralPath (Join-Path $seal 'PRE_HASH.txt')

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
  $files = @(
    'ProductExtensionRuntime_State.cpp',
    'ProductExtensionRuntime_Util.cpp',
    'ProductExtensionRuntime_Scan.cpp',
    'ProductExtensionRuntime_Manifest.cpp',
    'ProductExtensionRuntime_Host.cpp',
    'ProductExtensionRuntime_Toggles.cpp',
    'ProductExtensionRuntime_Activate.cpp',
    'ProductExtensionRuntime_Api.cpp',
    'HeadlessIDE_GuiRoutes.cpp',
    'HeadlessIDE_ToolRoutes.cpp',
    'Win32IDE_LocalServer.cpp'
  )
  foreach ($f in $files) {
    $src = Join-Path $root "src\win32app\$f"
    $out = Join-Path $objdir "src\win32app\$f.obj"
    New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
    Write-Host "COMPILE $f"
    $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$out`" `"$src`" >> `"$log`" 2>&1"
    Add-Content -LiteralPath $log "COMPILE_${f}_EXIT=$rc"
    Write-Host "COMPILE_${f}_EXIT=$rc"
    if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 80; exit $rc }
  }

  # ExtensionHost worker EXE (beside cand bin)
  $hostSrc = Join-Path $root 'src\win32app\ExtensionHostWorker_main.cpp'
  $hostExe = Join-Path $candBin 'RawrXD-ExtensionHost.exe'
  $hostObj = Join-Path $seal 'logs\ExtensionHostWorker_main.obj'
  Write-Host 'COMPILE ExtensionHostWorker_main.cpp'
  $rc = Invoke-VcCmd "cl.exe /nologo /TP /c /O2 /DNDEBUG /DUNICODE /D_UNICODE /DWIN32_LEAN_AND_MEAN /EHsc /MT /Fo`"$hostObj`" `"$hostSrc`" >> `"$log`" 2>&1"
  Add-Content -LiteralPath $log "COMPILE_ExtensionHost_EXIT=$rc"
  if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 40; exit $rc }
  Write-Host 'LINK RawrXD-ExtensionHost.exe'
  $rc = Invoke-VcCmd "link.exe /nologo /SUBSYSTEM:WINDOWS /OUT:`"$hostExe`" `"$hostObj`" user32.lib kernel32.lib >> `"$log`" 2>&1"
  Add-Content -LiteralPath $log "LINK_ExtensionHost_EXIT=$rc"
  if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 40; exit $rc }

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
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_PathBCmdDiagSwarm.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  Copy-Item -Force -LiteralPath $baseRsp -Destination $bakRsp
  $merged = (($orphans -join "`r`n") + "`r`n" + [IO.File]::ReadAllText($baseRsp))
  [IO.File]::WriteAllText($baseRsp, $merged)

  Write-Host 'SOLO LINK cand RawrXD-Win32IDE.exe'
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_ext_runtime.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05'
  try {
    $rc = Invoke-VcCmd "$linkInner >> `"$log`" 2>&1"
  } finally {
    Copy-Item -Force -LiteralPath $bakRsp -Destination $baseRsp
  }
  Add-Content -LiteralPath $log "LINK_EXIT=$rc"
  Write-Host "LINK_EXIT=$rc"
  if ($rc -ne 0) { Get-Content -LiteralPath $log -Tail 100; exit $rc }

  $built = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
  Copy-Item -Force -LiteralPath $built -Destination (Join-Path $candBin 'RawrXD-Win32IDE.exe')
  $pdb = Join-Path $bld 'bin\RawrXD-Win32IDE.pdb'
  if (Test-Path -LiteralPath $pdb) {
    Copy-Item -Force -LiteralPath $pdb -Destination (Join-Path $candBin 'RawrXD-Win32IDE.pdb')
  }

  $afterCand = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
  $tipAfter = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
  $hostSha = (Get-FileHash -LiteralPath $hostExe -Algorithm SHA256).Hash
  $tipOk = [int]($tipBefore -eq $tipAfter -and $tipAfter -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145')
  @"
CAND_SHA_BEFORE=$beforeCand
CAND_SHA_AFTER=$afterCand
TIP_BEFORE=$tipBefore
TIP_AFTER=$tipAfter
tip748B=$tipOk
HOST_SHA=$hostSha
HOST_EXE=$hostExe
TIP_REBUILD=0
ABSORB=NOT_AUTHORIZED
PROMOTE=0
"@ | Set-Content -LiteralPath (Join-Path $seal 'NEW_CAND_SHA.txt')
  Set-Content -LiteralPath (Join-Path $seal 'FROZEN_CANDIDATE_SHA.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $candBin 'FROZEN_CANDIDATE_SHA.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $candBin 'CANDIDATE_SHA256.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\FROZEN_CANDIDATE_SHA.txt') $afterCand
  Write-Host "RELINK_OK AFTER=$afterCand tip748B=$tipOk HOST=$hostSha"
  exit 0
} finally {
  Pop-Location
}
