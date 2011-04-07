Function Get-AllLogs()
	{
		<#
			.SYNOPSIS
				Return a list of Classic and ETL logs
			.DESCRIPTION
				This function returns a list of both Classic and ETL logs, from the local or remote computer.
			.PARAMETER Computer
				The NetBIOS name of a computer to pull logs from
			.PARAMETER Credential
				The DOMAIN\USERNAME with permissions to retrieve logs
			.PARAMETER SortBy
				What column to sort the output by, possible choices are
					LastWriteTime
					IsClassicLog
					FileSize
			.EXAMPLE
				Get-AllLogs

				LogName                                  FileSize             IsClassicLog LastWriteTime
				-------                                  --------             ------------ -------------
				OAlerts                                   1052672                     True 4/3/2011 6:53:08 PM
				Microsoft-Windows-Dia...                    69632                    False 4/3/2011 1:00:05 AM
				Microsoft-Windows-Dia...                    69632                    False 4/3/2011 1:00:04 AM
				Microsoft-Windows-Dia...                  1052672                    False 4/3/2011 1:00:03 AM
				Application                              14749696                     True 4/2/2011 9:03:45 PM
				
				Description
				-----------
				This example uses all defaults to return a list of logs sorted by LastWriteTime from the local computer
			.EXAMPLE
				Get-AllLogs -SortBy FileSize

				LogName                                  FileSize             IsClassicLog LastWriteTime
				-------                                  --------             ------------ -------------
				Security                                 20975616                     True 3/30/2011 2:18:28 PM
				System                                   15798272                     True 3/30/2011 2:18:26 PM
				Application                              14749696                     True 4/2/2011 9:03:45 PM
				Microsoft-Windows-Gro...                  4198400                    False 3/30/2011 2:18:30 PM
				Windows PowerShell                        1118208                     True 3/30/2011 6:56:44 PM

				Description
				-----------
				This example demostrates the use of the SortBy parameter to sort by FileSize
			.Example
				Get-AllLogs -Computer mobile -Credential "DOMAIN\Administrator" -SortBy isclassiclog

				LogName                                  FileSize             IsClassicLog LastWriteTime
				-------                                  --------             ------------ -------------
				OAlerts                                   1052672                     True 4/3/2011 6:53:08 PM
				Media Center                                69632                     True 10/21/2010 7:17:04 PM
				Security                                 20975616                     True 3/30/2011 2:18:28 PM
				Windows PowerShell                        1118208                     True 3/30/2011 6:56:44 PM
				System                                   15798272                     True 3/30/2011 2:18:26 PM
				
				Description
				-----------
				This example shows the use of the Computer and Credentials parameters as well as using SortBy
			.NOTES
				PowerShell may need to run elevated for this script to return all logs
				You may need to disable UAC
				You are in charge of server monitoring at a medium-sized company that consists of three geographically 
				dispersed sites and 50 servers. The servers are running a combination of Windows Server 2008 R2 and 
				Windows Server 2008. You want to produce a report of all classic event logs and the ETL diagnostic logs 
				that also exist. Your report should only list logs that are enabled. The list should be sorted by the 
				last time the log was written to, and the most recent dates should be on top of the list. In addition, 
				the report should state the size of the log, and whether or not it is a classic log.
			.LINK
				https://2011sg.poshcode.org/344
		#>
		
		Param
			(
				[string]$Computer = (& hostname),
				$Credential,
				[string]$SortBy
			)
			
		If ($Computer -eq (& hostname))
			{		
				$Logs = Get-WinEvent -ListLog *
			}
		Else
			{
				$Logs = Get-WinEvent -ComputerName $Computer -Credential $Credentials -ListLog *
			}
		Switch ($SortBy)
			{
				LastWriteTime
					{
						$Logs |Select-Object LogName, FileSize, IsClassicLog, LastWriteTime `
							|Sort-Object LastWriteTime -Descending
					}
				IsClassicLog
					{
						$Logs |Select-Object LogName, FileSize, IsClassicLog, LastWriteTime `
						|Sort-Object IsClassicLog -Descending
					}
				FileSize
					{
						$Logs |Select-Object LogName, FileSize, IsClassicLog, LastWriteTime `
						|Sort-Object FileSize -Descending
					}
				default
					{
						$Logs |Select-Object LogName, FileSize, IsClassicLog, LastWriteTime `
						|Sort-Object LastWriteTime -Descending
					}
			}
	}