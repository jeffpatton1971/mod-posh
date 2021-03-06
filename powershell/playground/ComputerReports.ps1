# Events from yesterday

# Get firewall logs from yesterday
$fwlogs = Get-FileLogs -LogFile C:\Windows\System32\LogFiles\Firewall\pfirewall.log -LogType wfw
$fwlogs |Where-Object {$_.Date -gt (Get-Date((Get-Date).AddDays(-1)) -Format "yyyy-MM-d") -AND $_.Date -le (Get-Date -Format "yyyy-MM-dd")} |Format-Table

# Get a list of recent logs
$RecentLogs = Get-WinEvent -ListLog * |Where-Object {$_.RecordCount -gt 0 -AND (Get-Date($_.LastWriteTime).Month) -eq (Get-Date).Month}
$logs = Get-EventsFromYesterday -EventLogs $RecentLogs
$logs |Format-Table -AutoSize

# Get netstat
$NetStat = Get-NetstatReport
$NetStat |Format-Table -AutoSize

# Get updates
$PendingUpdates = Get-PendingUpdates -ComputerName (& hostname)
$PendingUpdates |Format-Table -Property Title, Description, LastDeploymentChangeTime, SupportUrl, RebootRequired