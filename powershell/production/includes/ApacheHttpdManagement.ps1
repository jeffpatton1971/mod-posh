Function Update-ContentTop
	{
		<#
			.SYNOPSIS
				Adds a header to a combined Apache logfile
			.DESCRIPTION
				This function adds a header to an Apache combined logfile. It's very crude at the moment, but it serves
				the purpose it was designed for.
			.PARAMETER LogFile
				The full path and filename to the access log
			.PARAMETER Header
				Column header for your log file, space delimited
			.EXAMPLE
				$Header = "Host Identity User DateTime Offset Request Status Size Referrer UserAgent"
				
				Update-ContentTop c:\logiles\access.log $Header
				
				This example sets a variable named header to be used in the command-line. We then pass the path and
				header variable into the function for processing.
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/ApacheHttpdManagement#Update-ContentTop
		#>

		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$LogFile,
				[Parameter(Mandatory=$true)]
				[string]$Header
			)	

		if (Test-Path $LogFile -eq $True)
			{
				$Data = Get-Content $LogFile
				if ($Data[0].Contains("Host") -eq $True)
					{
						Write-Host "Skipping $LogFile, header exists"
					}
				else
					{
						Write-Host "Writing header to $LogFile"
						Set-Content $LogFile -Value $Header,$Data
					}				
			}
		else
			{
				Write-Host "File $LogFile does not exist"
			}
	}