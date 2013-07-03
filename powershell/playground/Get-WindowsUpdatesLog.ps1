$WindowsUpdateLogs = Import-Csv C:\Windows\WindowsUpdate.log -Delimiter `t -Header "Date","Time","PID","TID","Component","Text"
$WindowsUpdateLogs |Where-Object {$_.Date -eq '2012-10-18'} |Format-Table -AutoSize -Property Date, Time, Text

Import-Csv C:\Windows\WindowsUpdate.log -Delimiter `t -Header "Date","Time","PID","TID","Component","Text" |Where-Object {$_.Date -eq '2012-10-18'} |Format-Table -AutoSize -Property Date, Time, Text