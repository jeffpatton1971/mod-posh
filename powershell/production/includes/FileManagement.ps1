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
				Update-Content "C:\logfiles\access.log" "Host Identity User DateTime Offset Request Status Size Referrer UserAgent"
				
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
Function New-LogFile
    {
        <#
            .SYNOPSIS
                Create a logfile
            .DESCRIPTION
                This function create's a log file in the provided folder, whose data can be piped in via the command
                line or passed directly to the function. The filename for the log is generated from the current system
                date, and if a file with same name exists, a new file is created with an incremented digit for each
                matched filename.
            .PARAMETER LogData
                This is the information to send to the log.
            .PARAMETER LogPath
                This is the destination of the log file. If the provided folder doesn't exist on the computer, it 
                is created automatically.
            .EXAMPLE
                Get-Process |New-LogFile
                
                Description
                -----------
                This example shows piping the output from Get-Process into the New-LogFile function, the default
                log folder (C:\LogFiles) is used.
            .EXAMPLE
                Get-Process |New-LogFile -LogPath c:\logging
                
                Description
                -----------
                This example shows piping the output from Get-Process into the New-LogFile function and specifying a
                different folder to store the logs in.
            .EXAMPLE
                New-LogFile -LogPath c:\logging -LogData "Script finished execution."
                
                Description
                -----------
                This example shows passing in the LogPath and LogData parameters to the New-LogFile function directly.
            .NOTES
                This space intentionally left blank.
            .LINK
                http://scripts.patton-tech.com/wiki/PowerShell/FileManagement#New-LogFile
        #>
        
        Param
            (
                [Parameter(ValueFromPipeline=$true)]
                $LogData,
                $LogPath = "C:\LogFiles"
            )

        $FileName = (Get-Date).ToString('yyyyMMdd')
        If ((Test-Path $LogPath) -ne $true)
            {
                New-Item $LogPath -ItemType Directory
            }
        If ((Test-Path (($LogPath + "\" + $FileName) + ".log")) -eq $true)
            {
                $FileName = (Get-Date).ToString('yyyyMMdd') + "-" `
                            + @((Get-ChildItem $LogPath -Filter ($fileName + "*"))).count
            }
        $LogData |Out-File -FilePath (($LogPath + "\" + $FileName) + ".log") -Encoding ASCII -NoClobber
    }