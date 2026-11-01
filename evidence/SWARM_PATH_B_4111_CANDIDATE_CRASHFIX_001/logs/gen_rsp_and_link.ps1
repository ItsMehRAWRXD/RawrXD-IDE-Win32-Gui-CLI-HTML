$ErrorActionPreference = "Stop"
$build = "G:\~dev\rawrxd\build_win32ide_link001"
$ninjaPath = Join-Path $build "build.ninja"
# Read the giant link edge as one line via StreamReader search
$reader = [System.IO.StreamReader]::new($ninjaPath)
$buildLine = $null
$linkPath = $null
$linkLibs = $null
while ($null -ne ($line = $reader.ReadLine())) {
  if ($line.StartsWith("build bin\RawrXD-Win32IDE.exe: CXX_EXECUTABLE_LINKER__RawrXD-Win32IDE_Release ")) {
    $buildLine = $line
    # next variable lines until blank/build
    while ($null -ne ($line = $reader.ReadLine())) {
      if ($line.Length -eq 0) { break }
      if ($line.StartsWith("build ")) { break }
      if ($line.StartsWith("  LINK_PATH = ")) { $linkPath = $line.Substring("  LINK_PATH = ".Length) }
      if ($line.StartsWith("  LINK_LIBRARIES = ")) { $linkLibs = $line.Substring("  LINK_LIBRARIES = ".Length) }
      if ($line.StartsWith("  RSP_FILE = ")) { break }
    }
    break
  }
}
$reader.Close()
if (-not $buildLine) { throw "build edge not found" }
if (-not $linkLibs) { throw "LINK_LIBRARIES missing" }

# Inputs: between rule name and " |" or end
$marker = "CXX_EXECUTABLE_LINKER__RawrXD-Win32IDE_Release "
$rest = $buildLine.Substring($buildLine.IndexOf($marker) + $marker.Length)
# Drop order-only deps after " || "
if ($rest.Contains(" || ")) { $rest = $rest.Substring(0, $rest.IndexOf(" || ")) }
# Drop implicit deps after " | " (libs already in LINK_LIBRARIES usually duplicated)
if ($rest.Contains(" | ")) { $rest = $rest.Substring(0, $rest.IndexOf(" | ")) }
$ins = $rest -split " " | Where-Object { $_ -ne "" }

$rspPath = Join-Path $build "CMakeFiles\RawrXD-Win32IDE.rsp"
$sb = New-Object System.Text.StringBuilder
foreach ($i in $ins) { [void]$sb.AppendLine($i) }
if ($linkPath) { [void]$sb.AppendLine($linkPath.Trim()) }
[void]$sb.AppendLine($linkLibs.Trim())
[System.IO.File]::WriteAllText($rspPath, $sb.ToString())
Write-Output "RSP_OK lines_in=$($ins.Count) bytes=$((Get-Item $rspPath).Length)"

$cmd = @"
@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64 >nul
cd /d "$build"
if exist bin\RawrXD-Win32IDE.exe del /f /q bin\RawrXD-Win32IDE.exe
if exist bin\RawrXD-Win32IDE.pdb del /f /q bin\RawrXD-Win32IDE.pdb
"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests  -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG /LARGEADDRESSAWARE /DEBUG:FULL /MAP:G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304
echo LINK_EXIT=%ERRORLEVEL%
if exist bin\RawrXD-Win32IDE.exe (
  echo EXE_OK
  powershell -NoProfile -Command "(Get-FileHash 'G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.exe' -Algorithm SHA256).Hash"
) else (
  echo EXE_MISSING
)
"@
$cmdPath = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CANDIDATE_CRASHFIX_001\logs\link_only_genrsp.cmd"
Set-Content -Path $cmdPath -Value $cmd -Encoding ASCII
Write-Output "CMD=$cmdPath"
& cmd /c $cmdPath
Write-Output "DONE_EXIT=$LASTEXITCODE"
