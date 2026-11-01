# Link-only after objs already compiled by solo_compile_link.ps1
$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$bld = 'G:\~dev\rawrxd\build_win32ide_link001'
$log = Join-Path $seal 'logs\solo_link_only.txt'
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
[IO.File]::WriteAllText((Join-Path $seal 'RawrXD-Win32IDE_relink_merged.rsp'), $merged)

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  cmd /c "`"$vc`" >nul && $inner"
  return $LASTEXITCODE
}

Push-Location $bld
try {
  $linkInner = '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_stubff.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 /INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05'
  Write-Host 'SOLO LINK ONLY'
  $rc = Invoke-VcCmd "$linkInner > `"$log`" 2>&1"
  Write-Host "LINK_EXIT=$rc"
  Add-Content $log "LINK_EXIT=$rc"
  exit $rc
} finally {
  if (Test-Path $bakRsp) { Copy-Item -Force $bakRsp $baseRsp }
  Pop-Location
}
