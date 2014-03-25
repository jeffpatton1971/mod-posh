function Get-ServicesThatPause()
	{
		<#
			.SYNOPSIS
				Returns a list of running services that can be paused
			.DESCRIPTION
				This function returns a list of services that can be paused. As this only appears to work against
				running services, that's all that get returned.
			.PARAMETER Computer
				The NetBIOS name of the computer to check
			.EXAMPLE
				Get-ServicesThatPause

				Status   Name               DisplayName
				------   ----               -----------
				Running  AppHostSvc         Application Host Helper Service
				Running  LanmanServer       Server
				Running  LanmanWorkstation  Workstation
				Running  MSSQL$SQLEXPRESS   SQL Server (SQLEXPRESS)
				Running  MySQL              MySQL
				Running  seclogon           Secondary Logon
				Running  WAS                Windows Process Activation Service
				Running  Winmgmt            Windows Management Instrumentation
				
				Description
				-----------
				This example shows running the function against the local computer without specifying the
				computer name parameter.
			.EXAMPLE
				Get-ServicesThatPause -Computer Remote

				Status   Name               DisplayName
				------   ----               -----------
				Running  AppHostSvc         Application Host Helper Service
				Running  LanmanServer       Server
				Running  LanmanWorkstation  Workstation
				Running  MSSQL$MSDPM2010    SQL Server (MSDPM2010)
				Running  Netlogon           Netlogon
				Running  SQLBrowser         SQL Server Browser
				Running  WAS                Windows Process Activation Service
				Running  Winmgmt            Windows Management Instrumentation
				
				Description
				-----------
				This example shows running the function against a remote computer.
			.NOTES
				You are a power user who has always enjoyed “tweaking” the performance of your workstation. You are 
				rather careful about what you do, and you always like to have a way to fix the changes you make. You 
				recently became aware of the fact that some services allow you to pause them, and then later unpause 
				them. Unfortunately, so far none of the services you have attempted to pause have accepted the pause 
				command. You then got the bright idea that perhaps you could retrieve this information by using Windows 
				PowerShell. Your script must only report on running services that accept a pause command. The output 
				should display the status of the service, name, and display name of the services that meet the criteria.
			.LINK
				https://2011sg.poshcode.org/298
		#>
		
		Param
			(
				[string]$Computer = (& hostname),
			)

		If ($Computer -eq (& hostname))
			{		
				$Services = get-service | Where-Object {$_.CanPauseAndContinue -eq $true}
			}
		Else
			{
				$Services = get-service -ComputerName $Computer | Where-Object {$_.CanPauseAndContinue -eq $true}
			}
		
		Return $Services
	}