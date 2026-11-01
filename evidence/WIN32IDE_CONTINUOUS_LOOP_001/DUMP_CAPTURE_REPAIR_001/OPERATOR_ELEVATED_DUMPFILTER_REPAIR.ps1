#Requires -RunAsAdministrator
<#
  DUMP_CAPTURE_REPAIR_001 — conditional DumpFilters repair
  Evidence: volmgr 45/46 on \Device\HarddiskVolume10 == C: with DumpFilters=dumpfve.sys
  Does NOT disable BitLocker. Clears dumpfve from DumpFilters ONLY if C: is not protected.
  Does NOT force a crash. DUMP_CAPTURE stays UNVERIFIED until capture evidence.
#>
$ErrorActionPreference = 'Stop'
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$receipt = Join-Path $outDir 'DUMPFILTER_REPAIR_RECEIPT.txt'
$lines = @()
function L([string]$s) { $script:lines += $s; Write-Host $s }

L "ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('o'))"
L 'IsAdmin=True'

# BitLocker status on C:
$bl = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
L "BitLocker_VolumeStatus=$($bl.VolumeStatus)"
L "BitLocker_ProtectionStatus=$($bl.ProtectionStatus)"
L "BitLocker_EncryptionPercentage=$($bl.EncryptionPercentage)"
L "BitLocker_MountPoint=$($bl.MountPoint)"

$cc = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
L "Before_CrashDumpEnabled=$($cc.CrashDumpEnabled)"
L "Before_DumpFilters=$($cc.DumpFilters -join ',')"

$prot = [string]$bl.ProtectionStatus
$protected = ($prot -match 'On|Enabled|1') -or ($bl.EncryptionPercentage -gt 0 -and $prot -notmatch 'Off|Disabled|Unprotected|0')

if ($protected) {
  L 'ACTION=NONE'
  L 'REASON=BitLocker protection/encryption indicated on C:; refuse DumpFilters clear'
  L 'DUMP_CAPTURE=UNVERIFIED'
  L 'NEXT=Manual FVE-compatible dump path review (do not disable BitLocker here)'
  $lines | Set-Content -Encoding utf8 $receipt
  Write-Host "Wrote $receipt"
  exit 2
}

# Not protected: remove dumpfve dump filter only
# Empty DumpFilters multi-sz
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name DumpFilters -PropertyType MultiString -Value @() -Force | Out-Null
$cc2 = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
L "After_DumpFilters='$($cc2.DumpFilters -join ',')'"
L 'ACTION=CLEARED_DUMPFILTERS_dumpfve'
L 'NOTE=BitLocker not disabled; only CrashControl DumpFilters dump stack filter removed'
L 'DUMP_CAPTURE=UNVERIFIED (config change; reboot required; no crash forced)'
L 'NEXT=Reboot then verify zero volmgr 45/46 since boot'

$lines | Set-Content -Encoding utf8 $receipt
Write-Host "Wrote $receipt"
