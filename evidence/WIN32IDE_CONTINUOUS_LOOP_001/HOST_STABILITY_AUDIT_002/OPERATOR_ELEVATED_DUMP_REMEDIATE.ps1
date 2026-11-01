#Requires -RunAsAdministrator
<#
  HOST_STABILITY_AUDIT_002 — elevated dump + pagefile remediation
  Recommended: CrashDumpEnabled=2 (Kernel) + system-managed pagefile on C:
  Does NOT force a crash. DUMP_CAPTURE remains UNVERIFIED until real capture evidence.
#>
$ErrorActionPreference = 'Stop'
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$receipt = Join-Path $outDir 'DUMP_REMEDIATE_RECEIPT.txt'
$lines = @()
function L([string]$s) { $script:lines += $s; Write-Host $s }

L "ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('o'))"
L "IsAdmin=True"

$sys = Get-PSDrive C
L ("C_FreeGB={0:N1}" -f ($sys.Free/1GB))
$os = Get-CimInstance Win32_OperatingSystem
L ("TotalRAM_GB={0:N1}" -f ($os.TotalVisibleMemorySize/1MB))

New-Item -ItemType Directory -Force -Path 'C:\Windows\Minidump' | Out-Null

# Kernel memory dump
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -Value 2 -Type DWord
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name DumpFile -Value '%SystemRoot%\MEMORY.DMP' -Type ExpandString
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name MinidumpDir -Value '%SystemRoot%\Minidump' -Type ExpandString
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name Overwrite -Value 1 -Type DWord
L 'CrashDumpEnabled=2 (Kernel_memory_dump)'

# System-managed pagefile on C:
$cs = Get-CimInstance Win32_ComputerSystem
Set-CimInstance -InputObject $cs -Property @{ AutomaticManagedPagefile = $true }
L 'AutomaticManagedPagefile=True'

$cc = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
L "Verify_CrashDumpEnabled=$($cc.CrashDumpEnabled)"
L "Verify_DumpFile=$($cc.DumpFile)"
L "Verify_MinidumpDir=$($cc.MinidumpDir)"
L "Verify_DumpFilters=$($cc.DumpFilters)"
L 'DUMP_CAPTURE=UNVERIFIED (config applied; no crash forced)'
L 'NEXT=Normalize AMD drivers, then reboot for POST_REBOOT_BASELINE'

$lines | Set-Content -Encoding utf8 $receipt
Write-Host "Wrote $receipt"
