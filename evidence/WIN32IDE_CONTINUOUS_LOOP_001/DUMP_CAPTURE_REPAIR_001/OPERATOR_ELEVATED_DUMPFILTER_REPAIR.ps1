#Requires -RunAsAdministrator
<#
  DUMP_CAPTURE_REPAIR_001 — controlled dumpfve DumpFilters removal
  Preconditions (operator-verified):
    - C: not a BitLocker volume (manage-bde / Get-BitLockerVolume)
    - C: absent from Win32_EncryptableVolume enumerate (or unprotected)
  Procedure:
    1) Export CrashControl key backup; abort if export file missing
    2) Remove ONLY dumpfve.sys from DumpFilters; preserve other entries + REG_MULTI_SZ
    3) Do NOT change CrashDumpEnabled/DumpFile/MinidumpDir; do NOT disable BitLocker;
       do NOT delete dumpfve.sys; do NOT force a crash
  Rollback (after backup exists):
    reg import "<BackupReg path from receipt>"
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

$clearSignal = $false

# manage-bde — require clear "not BitLocker volume" language OR fail closed later
$mdb = manage-bde -status C: 2>&1 | Out-String
L 'manage-bde_C_OUTPUT_BEGIN'
$mdb -split "`r?`n" | ForEach-Object { if ($_) { L ("  " + $_) } }
L 'manage-bde_C_OUTPUT_END'
if ($mdb -match 'not a valid BitLocker volume|could not be opened by BitLocker') {
  $clearSignal = $true
  L 'manage-bde_C=NO_VALID_BITLOCKER_VOLUME'
}

try {
  $bl = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
  L "BitLocker_ProtectionStatus=$($bl.ProtectionStatus) VolumeStatus=$($bl.VolumeStatus) Pct=$($bl.EncryptionPercentage)"
  if ([string]$bl.ProtectionStatus -match 'On|Enabled') {
    L 'ACTION=NONE REASON=BitLocker_Protection_On'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 2
  }
  if ([string]$bl.ProtectionStatus -match 'Off|Disabled|Unprotected') {
    $clearSignal = $true
  }
} catch {
  L "Get-BitLockerVolume_C=$($_.Exception.Message)"
  if ($_.Exception.Message -match 'does not have an associated BitLocker volume|not a valid BitLocker') {
    $clearSignal = $true
    L 'BitLocker_C=NO_ASSOCIATED_VOLUME'
  } else {
    L 'ACTION=NONE REASON=BitLocker_status_ambiguous_fail_closed'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 3
  }
}

$enc = @(Get-CimInstance Win32_EncryptableVolume -Namespace 'root/CIMV2/Security/MicrosoftVolumeEncryption' -ErrorAction SilentlyContinue)
$cEnc = @($enc | Where-Object { $_.DriveLetter -eq 'C:' })
if ($cEnc.Count -gt 0) {
  $c = $cEnc[0]
  L "EncryptableVolume_C_Protection=$($c.ProtectionStatus) Conversion=$($c.ConversionStatus)"
  if ([int]$c.ProtectionStatus -ne 0 -or [int]$c.ConversionStatus -ne 0) {
    L 'ACTION=NONE REASON=EncryptableVolume_C_not_fully_clear'
    $lines | Set-Content -Encoding utf8 $receipt
    exit 2
  }
  $clearSignal = $true
} else {
  L 'EncryptableVolume_C=ABSENT'
  $clearSignal = $true
}

if (-not $clearSignal) {
  L 'ACTION=NONE REASON=encryption_status_ambiguous_fail_closed'
  $lines | Set-Content -Encoding utf8 $receipt
  exit 3
}

# Backup CrashControl BEFORE any write
& reg.exe export 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' $backup /y | Out-Null
if (-not (Test-Path -LiteralPath $backup)) {
  L 'ACTION=NONE REASON=CrashControl_backup_export_failed'
  $lines | Set-Content -Encoding utf8 $receipt
  exit 4
}
L "BackupReg=$backup"
L "ROLLBACK=reg import `"$backup`""

$cc = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
$before = @($cc.DumpFilters)
L "Before_CrashDumpEnabled=$($cc.CrashDumpEnabled)"
L "Before_DumpFile=$($cc.DumpFile)"
L "Before_MinidumpDir=$($cc.MinidumpDir)"
L "Before_DumpFilters=$($before -join ',')"

if ($before -notcontains 'dumpfve.sys') {
  L 'ACTION=NONE REASON=dumpfve_not_in_DumpFilters'
  $lines | Set-Content -Encoding utf8 $receipt
  exit 0
}

$after = @($before | Where-Object { $_ -and ($_ -ne 'dumpfve.sys') })
# REG_MULTI_SZ via MultiString; empty @() => empty multi-sz (dumpfve was sole entry)
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' `
  -Name DumpFilters -PropertyType MultiString -Value $after -Force | Out-Null

$cc2 = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
L "After_CrashDumpEnabled=$($cc2.CrashDumpEnabled)"
L "After_DumpFile=$($cc2.DumpFile)"
L "After_MinidumpDir=$($cc2.MinidumpDir)"
L "After_DumpFilters='$($cc2.DumpFilters -join ',')'"

if ([int]$cc2.CrashDumpEnabled -ne [int]$cc.CrashDumpEnabled) {
  L 'WARNING=CrashDumpEnabled_changed_unexpected_restoring_backup'
  & reg.exe import $backup | Out-Null
  L 'ACTION=RESTORED_BACKUP'
  $lines | Set-Content -Encoding utf8 $receipt
  exit 5
}

L 'ACTION=REMOVED_dumpfve_ONLY'
L 'NOTE=BitLocker not disabled; dumpfve.sys file not deleted; no crash forced'
L 'DUMP_CAPTURE=UNVERIFIED'
L "ROLLBACK=reg import `"$backup`""
L 'NEXT=Reboot; verify zero volmgr 45/46 since boot; run ROLLBACK if problems'

$lines | Set-Content -Encoding utf8 $receipt
Write-Host "Wrote $receipt"
Write-Host "Backup $backup"
Write-Host "Rollback: reg import `"$backup`""
