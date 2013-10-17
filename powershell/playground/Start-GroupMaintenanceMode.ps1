$GroupDisplayName = "Exchange Servers"

Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName $ScomServer

$StartTime = [datetime]::Now.touniversaltime()
$ScheduledEndTime = ([datetime]::Now).addminutes($DurationInMin).touniversaltime()
 
ForEach ($Group in (Get-ScomGroup -DisplayName  $GroupDisplayName))
{
    If ($group.InMaintenanceMode -eq $false)
    {
        $group.ScheduleMaintenanceMode($StartTime, $ScheduledEndTime, $Reason, $Comment, "Recursive")
        }
    }