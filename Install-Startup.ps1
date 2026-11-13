# Downloads Organizer - Copyright (c) 2026 fmpanggabean
# Licensed under CC BY-NC-SA 4.0 (attribution required, non-commercial, share-alike)
# Original project: https://github.com/fmpanggabean/DownloadsOrganizer
param([switch]$Remove)  # -Remove uninstalls the startup task

$TaskName = 'DownloadsOrganizer'

if ($Remove) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    "Removed scheduled task '$TaskName'."
    return
}

$vbs = Join-Path $PSScriptRoot 'Run-Hidden.vbs'
$action    = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$vbs`""
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Principal $principal -Settings $settings -Force | Out-Null
"Installed. '$TaskName' will start at your next login. To start it now: Start-ScheduledTask $TaskName"
