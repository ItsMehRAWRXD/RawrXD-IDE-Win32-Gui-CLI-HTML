$map = "G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.map"
$targets = @(0x13EA448, 0x134397B, 0x2DD35, 0x1BF2F, 0x345A7, 0x1EFABEE)
$pubs = New-Object System.Collections.Generic.List[object]
$reader = [System.IO.StreamReader]::new($map)
while ($null -ne ($line = $reader.ReadLine())) {
  if ($line.Length -lt 40) { continue }
  if ($line[0] -ne ' ' -or $line[1] -ne '0') { continue }
  if (-not $line.StartsWith(" 0001:")) { continue }
  $idx = $line.IndexOf(" 000000014")
  if ($idx -lt 0) { continue }
  $symStart = 20
  while ($symStart -lt $idx -and $line[$symStart] -eq ' ') { $symStart++ }
  $sym = $line.Substring($symStart, $idx - $symStart).Trim()
  if (-not $sym.StartsWith("?")) { continue }
  $vaHex = $line.Substring($idx + 10, 9)
  $rva = [Convert]::ToInt64($vaHex, 16) - 0x140000000
  $pubs.Add([PSCustomObject]@{ Rva = $rva; Sym = $sym })
}
$reader.Close()
Write-Output "pubs=$($pubs.Count)"
$sorted = $pubs | Sort-Object Rva
foreach ($t in $targets) {
  $best = $null
  foreach ($p in $sorted) {
    if ($p.Rva -le $t) { $best = $p } else { break }
  }
  if ($best) {
    ("RVA=0x{0:X} -> {1} +0x{2:X}" -f $t, $best.Sym, ($t - $best.Rva))
  } else {
    ("RVA=0x{0:X} UNRESOLVED" -f $t)
  }
}
