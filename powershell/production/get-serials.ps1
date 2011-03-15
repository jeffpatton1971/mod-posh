#
#	Get-Serials
#
#	This script sets up the basic framework that I use
#	for all my scripts.
#
#	$ScriptName is used to register events for this script
#	in the $LogName log.
#
#	$LogName is which classic log you want to log to
#		Application
#		System
#		Security
#
$ScriptName = $MyInvocation.MyCommand.ToString()
$LogName = "Application"
$ScriptPath = $MyInvocation.MyCommand.Path
$Username = $env:USERDOMAIN + "\" + $env:USERNAME

	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
	
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

	#	Dotsource in the AD functions I need
	. .\includes\ActiveDirectoryManagement.ps1
	$ADSPath =  Read-Host "Please provide an LDAP URL"
	$computers = Get-ADObjects $ADSPath "computer" "name"
	foreach ($computer in $computers)
		{
			if ($computer -eq $null){}
			else
				{
					write-host $computer.Properties.name
					$serial = Get-WmiObject -query "select SerialNumber from win32_bios" -computername $computer.Properties.name
					write-host $serial.serialnumber
				}
		}
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
