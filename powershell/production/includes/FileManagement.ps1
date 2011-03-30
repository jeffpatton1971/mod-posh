Function Update-Content
	{
		<#
			.SYNOPSIS
				Updates the contents of a file.
			.DESCRIPTION
				This function adds content to the top or bottom of an existing file. By default the function will update
				the beginning of a file.
			.PARAMETER ThisFile
				The full path and filename to the file to update
			.PARAMETER Content
				Content to add to the file
			.PARAMETER Beginning
				True or False to add content to top (true) or bottom (false) of file
			.EXAMPLE
				$Header = "Host Identity User DateTime Offset Request Status Size Referrer UserAgent"
				$LogFile = "C:\logfiles\access.log"
				
				Update-Content $LogFile $Header
				
				This example sets a variable named header to be used in the command-line. We then pass the path and
				header variable into the function for processing.
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/FileManagement#Update-Content
		#>

		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ThisFile,
				[Parameter(Mandatory=$true)]
				[string]$Content,			
				[bool]$Beginning=$true
			)	

		if ((Test-Path $ThisFile) -eq $True)
			{
				$Data = Get-Content $ThisFile
				if ($Beginning -eq $True)
					{
						if ($Data[0].Contains($Content) -eq $True)
							{
								Write-Host "Skipping $ThisFile, content exists"
							}
						else
							{
								Write-Host "Writing content to $ThisFile"
								Set-Content $ThisFile -Value $Content,$Data
							}
					}
				else
					{
						Add-Content -Path $ThisFile -Value $Content
					}
			}
		else
			{
				Write-Host "File $ThisFile does not exist"
			}
	}