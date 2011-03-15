#
#	Template Script
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

	New-EventLog -Source $ScriptName -LogName $LogName
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username
	
	LogEvent($ScriptName, $LogName, "100", "Information", $Message + "Started: " + (Get-Date).toString())
	Main
	LogEvent($ScriptName, $LogName, "100", "Information", $Message + "Finished: " + (Get-Date).toString())
	
Function Main()
	{
		#	This function kicks everything off.
	}

Function LogEvent($ScriptName, $LogName, $EventID, $EventType, $Message)
	{
		Write-EventLog -LogName $LogName -Source $ScriptName -EventID $EventID -EntryType $EntryType -Message $Message
	}
