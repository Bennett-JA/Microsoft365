<#
.STATUS
    Work in progress - requires further testing
        - GUID extraction from scheduled task path needs validation
        - Confirm required task names match exactly on target machines
        
.SYNOPSIS
    Remediates failed Intune hybrid enrollment by clearing stale scheduled tasks and registry keys.

.DESCRIPTION
    Checks whether the required Intune MDM enrollment scheduled tasks exist on the machine.
    If they are missing, the script will:
        - Remove all stale scheduled tasks under EnterpriseMgmt
        - Remove the matching stale enrollment registry key
        - Force a GPUpdate to recreate the scheduled tasks
        - Trigger MDM re-enrollment via deviceenroller.exe

.NOTES
    Must be run as Administrator
    A reboot is recommended after the script completes
    Verify enrollment in Intune portal and Settings > Access work or school > Info > Sync
#>

# Step 1 - Get all scheduled tasks
$tasks = Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\*" -ErrorAction SilentlyContinue

# Step 2 - Check if enrollment is healthy (key tasks present)
$requiredTasks = @(
    "Schedule created by enrollment client for automatically enrolling in MDM from AAD",
    "Schedule #1 created by enrollment client",
    "Schedule #2 created by enrollment client",
    "Schedule #3 created by enrollment client"
)

$existingTaskNames = $tasks | Select-Object -ExpandProperty TaskName
$missingTasks = $requiredTasks | Where-Object { $existingTaskNames -notcontains $_ }

if ($missingTasks.Count -eq 0) {
    Write-Host "Enrollment tasks are healthy, no action required." -ForegroundColor Green
    exit
}

Write-Host "Missing tasks detected, proceeding with remediation..." -ForegroundColor Yellow
$missingTasks | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }

# Step 3 - Get the GUID from the first scheduled task path
$guid = ($tasks | Select-Object -First 1).TaskPath.Trim('\').Split('\') | Where-Object { $_.Length -eq 36 -and $_ -match '-' }
Write-Host "Found enrollment GUID: $guid" -ForegroundColor Yellow

# Step 4 - Remove all stale scheduled tasks
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# Step 5 - Delete only the matching registry key using the GUID from the task path
$regPath = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid"
if (Test-Path $regPath) {
    Write-Host "Removing registry key: $regPath" -ForegroundColor Yellow
    Remove-Item -Path $regPath -Recurse -Force
} else {
    Write-Host "Registry key not found: $regPath" -ForegroundColor Red
}

# Step 6 - Force GPUpdate to recreate scheduled tasks
gpupdate /force

# Step 7 - Trigger MDM re-enrollment
Write-Host "Triggering MDM re-enrollment..."
Start-Process -FilePath "$env:windir\system32\deviceenroller.exe" -ArgumentList "/c /AutoEnrollMDM" -Wait

Write-Host "Done. Reboot recommended, then verify in Intune portal and Settings > Access work or school > Info > Sync."
