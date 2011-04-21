. ..\production\includes\FileManagement.ps1

$IISLog = Get-WebLogs -LogFile 'C:\Users\Jeff Patton\Desktop\u_ex110418.log' -LogType iis
$ApacheLog = Get-WebLogs -LogFile 'C:\Users\Jeff Patton\Desktop\scripts_access.log' -LogType apache

#	Displays a sorted list of visitors
$ApacheLog | Sort-Object RemoteHost | Group-Object RemoteHost | Sort-Object Count -Descending

#	Displays a sorted list of httpd status codes
$ApacheLog | Sort-Object Status | Group-Object Status | Sort-Object Count -Descending
$ApacheLog |Select-Object RemoteHost, Time, Request, Status |Where-Object {$_.Status -eq 404}
$ApacheLog |Where-Object {$_.RemoteHost -notlike "66.249.*"} |Group-Object RemoteHost |Sort-Object Count -Descending


#   Displays a list of http status codes
$IISLog |Where-Object {$_.ProtocolStatus -eq 404} |Select-Object ClientIP, URIStem, URIQuery |Format-Table