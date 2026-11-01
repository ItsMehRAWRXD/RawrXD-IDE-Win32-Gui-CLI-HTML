$map = "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE_n2both.map"
$out = "G:\~dev\rawrxd\evidence\SWARM_PATH_B_4111_CRASH_ROOT_001\dumps\MAP_RESOLVE_D11AB5B6_HEAP.txt"
$rvas = @(0x1F6C5EC, 0x381EF4, 0x379658, 0x29230, 0x1BFD9, 0x34607, 0x1EF910E)
$syms = New-Object System.Collections.Generic.List[object]
$reader = [System.IO.StreamReader]::new($map)
while ($null -ne ($ln = $reader.ReadLine())) {
  if ($ln -match '000[12]:[0-9a-fA-F]+\s+(\S+)\s+(00000001[0-9a-fA-F]{7})\b') {
    $syms.Add([pscustomobject]@{
      Name = $Matches[1]
      Abs = [Convert]::ToInt64($Matches[2], 16)
    }) | Out-Null
  }
}
$reader.Close()
$arr = $syms.ToArray() | Sort-Object Abs
$lines = @()
$lines += "MAP=$map"
$lines += "SYM_COUNT=$($arr.Count)"
foreach ($r in $rvas) {
  $abs = [int64]0x140000000 + [int64]$r
  $lo = 0; $hi = $arr.Length - 1; $bestIdx = -1
  while ($lo -le $hi) {
    $mid = [int](($lo + $hi) / 2)
    if ($arr[$mid].Abs -le $abs) { $bestIdx = $mid; $lo = $mid + 1 } else { $hi = $mid - 1 }
  }
  if ($bestIdx -ge 0) {
    $best = $arr[$bestIdx]
    $delta = $abs - $best.Abs
    $lines += ("RVA=0x{0:X} ABS=0x{1:X} SYM={2}+0x{3:X}" -f $r, $abs, $best.Name, $delta)
  } else {
    $lines += ("RVA=0x{0:X} SYM=UNRESOLVED" -f $r)
  }
}
$lines | Set-Content $out
$lines | ForEach-Object { Write-Output $_ }
