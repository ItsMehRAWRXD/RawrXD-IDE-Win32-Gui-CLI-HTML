$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$log = Join-Path $seal 'logs\solo_relink_fmf_fix.txt'
New-Item -ItemType Directory -Force -Path (Join-Path $seal 'logs') | Out-Null
'' | Set-Content $log

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

$defines = (Get-Content (Join-Path $seal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content (Join-Path $seal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content (Join-Path $seal 'cl_INCLUDES.txt') -Raw).Trim()

# Host may already be clear; taskkill "not found" must not Stop the script.
cmd /c "taskkill /F /IM link.exe >nul 2>&1 & taskkill /F /IM cmake.exe >nul 2>&1 & taskkill /F /IM RawrXD-Win32IDE.exe >nul 2>&1" | Out-Null
# Remove zero-byte prior failed out if present
$priorOut = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
if ((Test-Path -LiteralPath $priorOut) -and ((Get-Item -LiteralPath $priorOut).Length -eq 0)) {
  Remove-Item -LiteralPath $priorOut -Force -ErrorAction SilentlyContinue
}

Push-Location $bld
try {
  $out = Join-Path $objdir 'src\win32app\ASM_Bridge_Implementation.cpp.obj'
  Write-Host 'COMPILE ASM_Bridge (no FMF)'
  $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$out`" `"$root\src\win32app\ASM_Bridge_Implementation.cpp`" >> `"$log`" 2>&1"
  if ($rc -ne 0) { throw "ASM_Bridge compile rc=$rc" }

  # Also refresh CiteForce (G04/G05/G08/G12/G16 strings)
  $cf = Join-Path $objdir 'src\win32app\Win32IDE_StubFictionCiteForce.cpp.obj'
  $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$cf`" `"$root\src\win32app\Win32IDE_StubFictionCiteForce.cpp`" >> `"$log`" 2>&1"
  if ($rc -ne 0) { throw "CiteForce compile rc=$rc" }

  $orphans = @(
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ASM_Bridge_Implementation.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_FabricBridge.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Phase17_AgenticProfiler.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionCiteForce.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionVulkanCite.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  Copy-Item -Force $baseRsp $bakRsp
  $merged = (($orphans -join "`r`n") + "`r`n" + [IO.File]::ReadAllText($baseRsp))
  [IO.File]::WriteAllText($baseRsp, $merged)

  Write-Host 'SOLO LINK'
  # No /LTCG: emergency finish (prior LTCG hung/slow); still MAP+FORCE:MULTIPLE candidate.
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_stubff.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05'
  try {
    $rc = Invoke-VcCmd "$linkInner >> `"$log`" 2>&1"
  } finally {
    Copy-Item -Force $bakRsp $baseRsp
  }
  Add-Content $log "LINK_EXIT=$rc"
  Write-Host "LINK_EXIT=$rc"
  if ($rc -ne 0) { exit $rc }

  $exe = Join-Path $bld 'bin\RawrXD-Win32IDE.exe'
  $sha = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
  Set-Content (Join-Path $seal 'NEW_CAND_SHA.txt') $sha
  Write-Host "NEW_SHA=$sha"
  exit 0
} finally {
  Pop-Location
}
