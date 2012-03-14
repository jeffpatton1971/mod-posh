$LibFile = (Join-Path $pwd "ActiveDirectoryManagement.ps1")
$LibURL = "http://mod-posh.googlecode.com/svn/powershell/production/includes/ActiveDirectoryManagement.ps1"
$webclient = New-Object Net.Webclient
$webClient.UseDefaultCredentials = $true
$webClient.DownloadFile($LibURL, $LibFile)
. $LibFile