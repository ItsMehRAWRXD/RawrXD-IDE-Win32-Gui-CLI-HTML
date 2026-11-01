#Requires -RunAsAdministrator
<#
  DUMP_CAPTURE_REPAIR_001 — controlled dumpfve DumpFilters removal
  Preconditions (operator-verified):
    - C: not a BitLocker volume (manage-bde / Get-BitLockerVolume)
    - C: absent from Win32_EncryptableVolume enumerate (or unprotected)
  Procedure:
    1) Export CrashControl key backup
    2) Remove ONLY dumpfve.sys from DumpFilters; preserve other entries
    3) Do NOT disable BitLocker, delete dumpfve.sys, or force a crash
  After: reboot; check volmgr 45/46; DUMP_CAPTURE remains UNVERIFIED
#>
$ErrorActionPreference = 'Stop'
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$receipt = Join-Path $outDir 'DUMPFILTER_REPAIR_RECEIPT.txt'
$backup = Join-Path $outDir ("CrashControl_backup_{0:yyyyMMdd_HHmmss}.reg" -f (Get-Date))
$lines = @()
function L([string]$s) { $script:lines += $s; Write-Host $s }

L "ASOF_UTC=$((Get-Date).ToUniversalTime().ToString('o'))"
L 'IsAdmin=True'

# Independent BitLocker / encryptable checks
$blOk = $false
try {
  $null = manage-bde -status C: 2>&1 | Out-String
  L 'manage-bde_C=RAN (see console; expect not-a-BitLocker-volume)'
} catch { L "manage-bde_C_ERROR=$($_.Exception.Message)" }

try {
  $bl = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
  L "BitLocker_ProtectionStatus=$($bl.ProtectionStatus) VolumeStatus=$($bl.VolumeStatus) Pct=$($bl.EncryptionPercentage)"
  if ([string]$bl.ProtectionStatus -match 'On|Enabled') {
    L 'ACTION=NONE REASON=BitLocker_Protection_On'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 2
  }
} catch {
  L "Get-BitLockerVolume_C=$($_.Exception.Message)"
  if ($_.Exception.Message -match 'does not have an associated BitLocker volume|not a valid BitLocker') {
    $blOk = $true
    L 'BitLocker_C=NO_ASSOCIATED_VOLUME'
  } else {
    L 'ACTION=NONE REASON=BitLocker_status_unavailable_fail_closed'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 3
  }
}

$enc = @(Get-CimInstance Win32_EncryptableVolume -Namespace 'root/CIMV2/Security/MicrosoftVolumeEncryption' -ErrorAction SilentlyContinue)
$cEnc = $enc | Where-Object { $_.DriveLetter -eq 'C:' -or ($_.DeviceID -and (Get-Volume -DriveLetter C -EA SilentlyContinue).UniqueId -eq $_.DeviceID) }
if ($cEnc) {
  L "EncryptableVolume_C_Protection=$($cEnc.ProtectionStatus) Conversion=$($cEnc.ConversionStatus)"
  if ([int]$cEnc.ProtectionStatus -ne 0 -or [int]$cEnc.ConversionStatus -ne 0) {
    L 'ACTION=NONE REASON=EncryptableVolume_C_not_fully_clear'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 2
  }
} else {
  L 'EncryptableVolume_C=ABSENT'
  $blOk = $true
}

# Backup CrashControl
& reg.exe export 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' $backup /y | Out-Null
L "BackupReg=$backup"

$cc = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
$before = @($cc.DumpFilters)
L "Before_CrashDumpEnabled=$($cc.CrashDumpEnabled)"
L "Before_DumpFilters=$($before -join ',')"

$after = @($before | Where-Object { $_ -and ($_ -ne 'dumpfve.sys') })
if ($before -notcontains 'dumpfve.sys') {
  L 'ACTION=NONE REASON=dumpfve_not_in_DumpFilters'
  $lines | Set-Content -Encoding utf8 $receipt
  exit 0
}

# Preserve other filters; empty array if dumpfve was sole entry
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' `
  -Name DumpFilters -PropertyType MultiString -Value $after -Force | Out-Null

$cc2 = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
L "After_DumpFilters='$($cc2.DumpFilters -join ',')'"
L 'ACTION=REMOVED_dumpfve_ONLY'
L 'NOTE=BitLocker not disabled; dumpfve.sys file not deleted; no crash forced'
L 'DUMP_CAPTURE=UNVERIFIED'
L 'NEXT=Reboot; verify zero volmgr 45/46 since boot; restore backup .reg if problems'

$lines | Set-Content -Encoding utf8 $receipt
Write-Host "Wrote $receipt"
Write-Host "Backup $backup"
