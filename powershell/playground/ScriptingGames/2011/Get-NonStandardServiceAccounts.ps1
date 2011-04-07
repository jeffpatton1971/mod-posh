Function Get-NonStandardServiceAccounts()
	{
		<#
			.SYNOPSIS
				Return a list of services using Non-Standard accounts.
			.DESCRIPTION
				This function returns a list of services from local or remote coputers that have non-standard
				user accounts for logon credentials.
			.PARAMETER Computer
				The NetBIOS name of the computer to pull services from.
			.PARAMETER Credentials
				The DOMAIN\USERNAME of an account with permissions to access services.
			.PARAMETER Filter
				This is a pipe (|) seperated list of accounts to filter out of the returned services list.
			.EXAMPLE
				Get-NonStandardServiceAccounts

				StartName                         Name                             DisplayName
				---------                         ----                             -----------
				.\Jeff Patton                     MyService                        My Test Service
				
				Description
				-----------
				This example shows no parameters provided
			.EXAMPLE
				Get-NonStandardServiceAccounts -Computer dpm -Credentials $Credentials

				StartName                         Name                             DisplayName
				---------                         ----                             -----------
				.\MICROSOFT$DPM$Acct              MSSQL$MS$DPM2007$                SQL Server (MS$DPM2007$)
				.\MICROSOFT$DPM$Acct              MSSQL$MSDPM2010                  SQL Server (MSDPM2010)
				NT AUTHORITY\NETWORK SERVICE      MSSQLServerADHelper100           SQL Active Directory Helper S...
				NT AUTHORITY\NETWORK SERVICE      ReportServer$MSDPM2010           SQL Server Reporting Services...
				.\MICROSOFT$DPM$Acct              SQLAgent$MS$DPM2007$             SQL Server Agent (MS$DPM2007$)
				.\MICROSOFT$DPM$Acct              SQLAgent$MSDPM2010               SQL Server Agent (MSDPM2010)
				
				Description
				-----------
				This example shows all parameters in use
			.EXAMPLE
				Get-NonStandardServiceAccounts -Computer dpm -Credentials $Credentials `
				-Filter "localsystem|NT Authority\LocalService|NT Authority\NetworkService|NT AUTHORITY\NETWORK SERVICE"

				StartName                         Name                             DisplayName
				---------                         ----                             -----------
				.\MICROSOFT$DPM$Acct              MSSQL$MS$DPM2007$                SQL Server (MS$DPM2007$)
				.\MICROSOFT$DPM$Acct              MSSQL$MSDPM2010                  SQL Server (MSDPM2010)
				.\MICROSOFT$DPM$Acct              SQLAgent$MS$DPM2007$             SQL Server Agent (MS$DPM2007$)
				.\MICROSOFT$DPM$Acct              SQLAgent$MSDPM2010               SQL Server Agent (MSDPM2010)
				
				Description
				-----------
				This example uses the Filter parameter to filter out NT AUTHORITY\NETWORK SERVICE account from the
				preceeding example. 
				
				The back-tick (`) was used for readability purposes only.
			.NOTES
				Powershell may need to be run elevated to run this script.
				UAC may need to be disabled to run this script.
				You are the network administrator for a medium-sized, single-site company. You are responsible for 50 
				servers that are running a combination of Windows Server 2003, Windows Server 2008, and Windows Server 
				2008 R2. All of the servers have Windows PowerShell 2.0 installed on them, and Windows PowerShell 
				remoting is enabled. A recent security audit discovered a few services that are not configured to use 
				standard service accounts. Instead, some of the services are using custom service accounts with custom 
				permissions. Because your corporate security plan requires that all services use standard service 
				accounts, your boss has tasked you with writing a Windows PowerShell script that reports all services 
				that are using non-standard accounts. 
			.LINK
				https://2011sg.poshcode.org/419
		#>
		
		Param
			(
				[string]$Computer = (& hostname),
				$Credentials,
				[string]$Filter = "localsystem|NT Authority\LocalService|NT Authority\NetworkService"
			)
			
		$Filter = $Filter.Replace("\","\\")
		
		If ($Computer -eq (& hostname))
			{
				$Services = Get-WmiObject win32_service |Select-Object StartName, Name, DisplayName
			}
		Else
			{
				$Services = Get-WmiObject win32_service -ComputerName $Computer -Credential $Credentials `
							|Select-Object StartName, Name, DisplayName
			}

		
		Return $Services |Where-Object {$_.StartName -notmatch $Filter}
	}