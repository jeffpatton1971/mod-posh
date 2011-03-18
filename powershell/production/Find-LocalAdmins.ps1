#
#	Find Local Admins
#
#	This script searches ActiveDirectory for computers.
#	It then queries each computer for the list of users
#	who are in the local Administrators group.
#
$ScriptName = $MyInvocation.MyCommand.ToString()
$LogName = "Application"
$ScriptPath = $MyInvocation.MyCommand.Path
$Username = $env:USERDOMAIN + "\" + $env:USERNAME

	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 
	
	#	Dotsource in the functions you need.
	. .\includes\ActiveDirectoryManagement.ps1
	
	$computers = Get-ADObjects "LDAP://OU=People,DC=soecs,DC=edu"
	
	foreach ($computer in $computers)
		{
			if ($computer -eq $null){}
			else
				{
					write-host $computer.Properties.name
					$groups = Get-LocalGroupMembers $computer.Properties.name Administrators
					$groups | Format-Table -autosize
				}
		}
	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	