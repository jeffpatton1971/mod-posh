Function New-User
	{
		<#
			.SYNOPSIS
				Create a new user account on the local computer.
			.DESCRIPTION
				This function will create a user account on the local computer.
			.PARAMETER Computer
				The NetBIOS name of the computer that you will create the account on.
			.PARAMETER User
				The user name of the account that will be created.
			.PARAMETER Password
				The password for the account, this must follow password policies enforced
				on the destination computer.
			.PARAMETER Description
				A description of what this account will be used for.
			.NOTES
				You will need to run this with either UAC disabled or from an elevated prompt.
			.EXAMPLE
				add-user MyComputer MyUserAccount MyP@ssw0rd "This is my account."
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
		#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Password,
				[string]$Description
			)
			
		$objComputer = [ADSI]"WinNT://$Computer"
		$objUser = $objComputer.Create("User", $User)
		$objUser.setpassword($password)
		$objUser.SetInfo()
		$objUser.description = $Description
		$objUser.SetInfo()
	}

Function Set-Pass
	{
		<#
			.SYNOPSIS
				Change the password of an existing user account.
			.DESCRIPTION
				This function will change the password for an existing user account. 
			.PARAMETER Computer
				The NetBIOS name of the computer that you will add the account to.
			.PARAMETER User
				The user name of the account that will be created.
			.PARAMETER Password
				The password for the account, this must follow password policies enforced
				on the destination computer.
			.NOTES
				You will need to run this with either UAC disabled or from an elevated prompt.
			.EXAMPLE
				set-pass MyComputer MyUserAccount N3wP@ssw0rd
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
		#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Password
			)
			
		$objUser=[adsi]("WinNT://$strComputer/$User, user")
		$objUser.psbase.invoke("SetPassword", $Password)
	}
	
Function Set-Group
	{
		<#
			.SYNOPSIS
				Add an existing user to a local group.
			.DESCRIPTION
				This function will add an existing user to an existing group.
			.PARAMETER Computer
				The NetBIOS name of the computer that you will add the account to.
			.PARAMETER User
				The user name of the account that will be created.
			.PARAMETER Group
				The name of an existing group to add this user to.
			.NOTES
				You will need to run this with either UAC disabled or from an elevated prompt.
			.EXAMPLE
				set-group MyComputer MyUserAccount Administrators
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
		#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Group
			)
			
		$objComputer = [ADSI]"WinNT://$Computer/$Group,group"
		$objComputer.add("WinNT://$Computer/$User")
	}
Function New-ScheduledTask
	{
		<#
		.SYNOPSIS
			Create a Scheduled Task on a computer.
		.DESCRIPTION
			Create a Scheduled Task on a local or remote computer. 
		.PARAMETER TaskName
			Specifies a name for the task.
		.PARAMETER TaskRun
			Specifies the program or command that the task runs. Type 
			the fully qualified path and file name of an executable file, 
			script file, or batch file. If you omit the path, SchTasks.exe 
			assumes that the file is in the Systemroot\System32 directory. 
		.PARAMETER TaskSchedule
			Specifies the schedule type. Valid values are 
				MINUTE
				HOURLY
				DAILY
				WEEKLY
				MONTHLY
				ONCE
				ONSTART
				ONLOGON
				ONIDLE
		.PARAMETER StartTime
			Specifies the time of day that the task starts in HH:MM:SS 24-hour 
			format. The default value is the current local time when the command 
			completes. The /st parameter is valid with MINUTE, HOURLY, DAILY, 
			WEEKLY, MONTHLY, and ONCE schedules. It is required with a ONCE 
			schedule. 
		.PARAMETER StartDate
			Specifies the date that the task starts in MM/DD/YYYY format. The 
			default value is the current date. The /sd parameter is valid with all 
			schedules, and is required for a ONCE schedule. 
		.PARAMETER TaskUser
			Runs the tasks with the permission of the specified user account. By 
			default, the task runs with the permissions of the user logged on to the 
			computer running SchTasks.
		.PARAMETER Server
			The NetBIOS name of the computer to create the scheduled task on.
		.NOTES
			You will need to run this with either UAC disabled or from an elevated prompt.
			The full syntax of the command can be found here:
				http://technet.microsoft.com/en-us/library/bb490996.aspx
		.EXAMPLE
			new-scheduledtask "Reboot Computer" "shutdown /r" ONCE "18:00:00" "03/16/2011" SYSTEM MyDesktopPC
		.LINK
			http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$TaskName,
				[Parameter(Mandatory=$true)]
				[string]$TaskRun,
				[Parameter(Mandatory=$true)]
				[string]$TaskSchedule,
				[Parameter(Mandatory=$true)]
				[string]$StartTime,
				[Parameter(Mandatory=$true)]
				[string]$StartDate,
				[Parameter(Mandatory=$true)]
				[string]$TaskUser,
				[Parameter(Mandatory=$true)]
				[string]$Server	
			)

		schtasks /create /tn $TaskName /tr $TaskRun /sc $TaskSchedule /st $StartTime /sd $StartDate /ru $TaskUser /s $Server
	}