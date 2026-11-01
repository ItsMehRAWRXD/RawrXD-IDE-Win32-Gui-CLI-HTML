$ErrorActionPreference = 'Stop'
$seal = 'G:\~dev\rawrxd\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001'
$root = 'G:\~dev\rawrxd'
$bld = Join-Path $root 'build_win32ide_link001'
$objdir = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.dir'
$logDir = Join-Path $seal 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'solo_compile_link.txt'
'' | Set-Content $log

function Invoke-VcCmd([string]$inner) {
  $vc = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
  $cmd = "`"$vc`" >nul && $inner"
  cmd /c $cmd
  return $LASTEXITCODE
}

$defines = (Get-Content (Join-Path $seal 'cl_DEFINES.txt') -Raw).Trim()
$flags = (Get-Content (Join-Path $seal 'cl_FLAGS.txt') -Raw).Trim()
$includes = (Get-Content (Join-Path $seal 'cl_INCLUDES.txt') -Raw).Trim()

$win32 = @(
  'Win32IDE_Core.cpp',
  'Win32IDE_ChatPanel_Ollama.cpp',
  'Win32IDE_CommandSurface.cpp',
  'Win32IDE_FeatureManifest.cpp',
  'Win32IDE_TabManager.cpp',
  'Win32IDE_IRCBridge.cpp',
  'Win32IDE_VoiceChat.cpp',
  'ASM_Bridge_Implementation.cpp',
  'Win32IDE_FabricBridge.cpp',
  'Win32IDE_Phase17_AgenticProfiler.cpp',
  'Win32IDE_StubFictionCiteForce.cpp'
)

New-Item -ItemType Directory -Force -Path (Join-Path $objdir 'src\win32app') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $objdir 'src\agentic\vulkan') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $objdir 'src\agentic') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $objdir 'src\core') | Out-Null

Push-Location $bld
try {
  foreach ($f in $win32) {
    $src = Join-Path $root "src\win32app\$f"
    $out = Join-Path $objdir "src\win32app\$f.obj"
    $line = "COMPILE $f"
    Write-Host $line
    Add-Content $log $line
    $inner = "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$out`" `"$src`" >> `"$log`" 2>&1"
    $rc = Invoke-VcCmd $inner
    if ($rc -ne 0) { throw "compile failed $f rc=$rc" }
  }

  $vkOut = Join-Path $objdir 'src\win32app\Win32IDE_StubFictionVulkanCite.cpp.obj'
  Write-Host 'COMPILE Win32IDE_StubFictionVulkanCite.cpp'
  $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$vkOut`" `"$root\src\win32app\Win32IDE_StubFictionVulkanCite.cpp`" >> `"$log`" 2>&1"
  if ($rc -ne 0) { throw "compile VulkanCite rc=$rc" }

  # G08: agentic_tool_executor.cpp orphan/unbuildable under Win32IDE flags
  # (stdout macro + header mismatch). EXE fail-close string via CiteForce.

  $vcOut = Join-Path $objdir 'src\core\voice_chat.cpp.obj'
  Write-Host 'COMPILE voice_chat.cpp'
  $rc = Invoke-VcCmd "cl.exe /nologo /TP /c $flags $defines $includes /Fo`"$vcOut`" `"$root\src\core\voice_chat.cpp`" >> `"$log`" 2>&1"
  if ($rc -ne 0) { throw "compile voice_chat rc=$rc" }

  $orphans = @(
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ASM_Bridge_Implementation.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_FabricBridge.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Phase17_AgenticProfiler.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionCiteForce.cpp.obj',
    'CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionVulkanCite.cpp.obj'
  )
  $baseRsp = Join-Path $bld 'CMakeFiles\RawrXD-Win32IDE.rsp'
  $bakRsp = Join-Path $seal 'RawrXD-Win32IDE.rsp.bak'
  $mergedSeal = Join-Path $seal 'RawrXD-Win32IDE_relink_merged.rsp'
  $orphanTxt = ($orphans -join "`r`n") + "`r`n"
  $baseTxt = [IO.File]::ReadAllText($baseRsp)
  # Keep @CMakeFiles\RawrXD-Win32IDE.rsp short so vs_link_exe does not expand
  # the entire rsp onto the CreateProcess command line (name too long).
  Copy-Item -Force $baseRsp $bakRsp
  [IO.File]::WriteAllText($baseRsp, $orphanTxt + $baseTxt)
  [IO.File]::WriteAllText($mergedSeal, $orphanTxt + $baseTxt)

  Write-Host 'SOLO LINK'
  Add-Content $log 'SOLO LINK'
  $linkInner = @(
    '"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944',
    '--intdir=CMakeFiles\RawrXD-Win32IDE.dir',
    '--rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe"',
    '--mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe"',
    '--manifests --',
    '"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe"',
    '/nologo @CMakeFiles\RawrXD-Win32IDE.rsp',
    '/out:bin\RawrXD-Win32IDE.exe',
    '/implib:RawrXD-Win32IDE.lib',
    '/pdb:bin\RawrXD-Win32IDE.pdb',
    '/version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG',
    '/LARGEADDRESSAWARE /DEBUG:FULL',
    '/MAP:bin\RawrXD-Win32IDE_stubff.map /MAPINFO:EXPORTS',
    '/MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304',
    '/INCLUDE:Win32IDE_StubFictionCiteForce_G04_G05'
  ) -join ' '
  try {
    $rc = Invoke-VcCmd "$linkInner >> `"$log`" 2>&1"
  } finally {
    if (Test-Path $bakRsp) { Copy-Item -Force $bakRsp $baseRsp }
  }
  Add-Content $log "LINK_EXIT=$rc"
  Write-Host "LINK_EXIT=$rc"
  if ($rc -ne 0) { exit $rc }
  exit 0
}
finally {
  Pop-Location
}
