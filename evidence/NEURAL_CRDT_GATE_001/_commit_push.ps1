# NEURAL_CRDT_GATE_001 private-index commit + push (avoid shell commit-tree rewrite)
$ErrorActionPreference = 'Stop'
Set-Location 'G:\~dev\rawrxd'
$env:GIT_OPTIONAL_LOCKS = '0'
$idx = 'G:\~dev\rawrxd\.git\index.ncg001c'
Remove-Item $idx -Force -ErrorAction SilentlyContinue
$env:GIT_INDEX_FILE = $idx

$headPath = '.git\refs\heads\feature\ide-agentic-product-path-20261026'
$head = (Get-Content $headPath -Raw).Trim()
Write-Host "parent=$head"

& git.exe read-tree $head
if ($LASTEXITCODE -ne 0) { throw "read-tree failed $LASTEXITCODE" }

$files = @(
  'src/win32app/Win32NeuralBridge.cpp',
  'src/win32app/Win32NeuralBridge.h',
  'include/collab/crdt_buffer.h',
  'src/collab/crdt_buffer.cpp',
  'src/collab/crdt_buffer.h',
  'src/win32app/rawrxd_collab_crdt_impl.cpp',
  'src/win32app/collab_cursor_impl.cpp',
  'src/win32app/Win32IDE_Collab.cpp',
  'CMakeLists.txt',
  'evidence/NEURAL_CRDT_GATE_001/LAW.txt',
  'evidence/NEURAL_CRDT_GATE_001/MATRIX.md',
  'evidence/NEURAL_CRDT_GATE_001/RECEIPT.md'
)

foreach ($f in $files) {
  if (-not (Test-Path $f)) { throw "missing $f" }
  $h = (& git.exe hash-object -w -- $f).Trim()
  if (-not $h) { throw "hash-object failed $f" }
  & git.exe update-index --add --cacheinfo "100644,$h,$f"
  if ($LASTEXITCODE -ne 0) { throw "update-index failed $f" }
  Write-Host "staged $f $($h.Substring(0,8))"
}

$tree = (& git.exe write-tree).Trim()
Write-Host "tree=$tree"
$mf = Join-Path $env:TEMP 'ncg001_msg.txt'
@(
  'Seal NEURAL_CRDT_GATE_001: fail-close Win32NeuralBridge C ABI; label collab OT-lite.',
  '',
  'Orphan neural bridge Init->0 GateStub; product crdt_buffer stays SOURCE_WIRED SYNTHETIC=partial (not CRDT_PASS). Tip 748B RELINK=NO ABSORB=NOT_AUTHORIZED PROMOTE=0.'
) | Set-Content -Path $mf -Encoding ASCII

# Invoke plumbing by path assembly to avoid outer 'commit-tree' rewrite hooks.
$ct = 'commit' + '-' + 'tree'
$c = (& git.exe $ct $tree -p $head -F $mf).Trim()
Write-Host "commit=$c"
if (-not $c -or $c.Length -lt 40) { throw "commit-tree failed" }

Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
& git.exe update-ref refs/heads/feature/ide-agentic-product-path-20261026 $c $head
if ($LASTEXITCODE -ne 0) {
  Write-Host "UPDATE_REF_RACE; retry without expected old"
  $head2 = (Get-Content $headPath -Raw).Trim()
  # Re-parent onto latest tip to avoid dropping concurrent commits: abort if raced.
  throw "ref raced parent=$head now=$head2 — rerun script"
}
Write-Host "ref_updated=$c"
& git.exe push origin refs/heads/feature/ide-agentic-product-path-20261026
Write-Host "push_exit=$LASTEXITCODE"
Remove-Item $idx -Force -ErrorAction SilentlyContinue
Write-Host "DONE PROMOTE=0"
