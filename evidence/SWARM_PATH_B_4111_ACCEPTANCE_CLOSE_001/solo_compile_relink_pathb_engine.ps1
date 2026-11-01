# PathB CLOSE_GAPS: light_mgr engine bind + FailFast VEH; cand only. Tip 748B untouched.
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_ACCEPTANCE_CLOSE_001'
$relinkSeal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$candBin = Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\bin'
$tipExe = Join-Path $root 'evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe'
$log = Join-Path $seal 'logs\solo_relink_pathb_engine.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs'),(Join-Path $seal 'dumps') | Out-Null
'' | Set-Content -LiteralPath $log

$beforeCand = (Get-FileHash -LiteralPath (Join-Path $candBin 'RawrXD-Win32IDE.exe') -Algorithm SHA256).Hash
$tipBefore = (Get-FileHash -LiteralPath $tipExe -Algorithm SHA256).Hash
Set-Content -LiteralPath (Join-Path $seal 'PRE_HASH.txt') "CAND=$beforeCand`nTIP=$tipBefore"

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

$defines = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content -LiteralPath (Join-Path $relinkSeal 'cl_INCLUDES.txt') -Raw).Trim()

cmd /c "taskkill /F /IM link.exe >nul 2>&1 & taskkill /F /IM cl.exe >nul 2>&1 & taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
Start-Sleep -Seconds 1

Push-Location $bld
try {
  $files = @(
    'Win32IDE_SubAgent.cpp',
    'Win32IDE_PathBCmdDiagSwarm.cpp',
    'Win32IDE_CommandFlight.cpp',
    'Win32IDE_Core.cpp'
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

  $orphans = @(
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

  Write-Host 'SOLO LINK pathb_engine'
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_pathb_engine.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05'
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
  $tipOk = [int]($tipBefore -eq $tipAfter -and $tipAfter -eq '748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145')
  @"
BEFORE=$beforeCand
AFTER=$afterCand
TIP_BEFORE=$tipBefore
TIP_AFTER=$tipAfter
TIP_UNTOUCHED=$tipOk
SOURCE_WIRE=post_BOTH_COMPLETE_quiet_SKIP_compiler_WM_CLOSE_onDestroy_EXIT0
PRIOR_3AF0=3AF0462CA26FD40AE44D9B097470006CCDB79D038998D6C471CD1B85C8EBE9DF
PRIOR_A9F1=A9F10267266FB8ADC7EB6AC0C44DC574D874951D381DEA7080D81B4B5506530B
PRIOR_8DDC=8DDCBEF31AB978379073B7052F33793F41BA4F2BDEE939C22CA587D4D645A348
"@ | Set-Content -LiteralPath (Join-Path $seal 'NEW_CAND_SHA.txt')
  Set-Content -LiteralPath (Join-Path $seal 'FROZEN_CANDIDATE_SHA.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $candBin 'FROZEN_CANDIDATE_SHA.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $candBin 'CANDIDATE_SHA256.txt') $afterCand
  Set-Content -LiteralPath (Join-Path $root 'evidence\TIP_CANDIDATE_AGENT_RUN_005\FROZEN_CANDIDATE_SHA.txt') $afterCand
  Write-Host "PROMOTED=$afterCand TIP_UNTOUCHED=$tipOk"
  exit 0
} finally {
  Pop-Location
}
