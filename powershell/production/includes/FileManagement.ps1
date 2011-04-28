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
Function Convert-Delimiter
    {
        <#
            .SYNOPSIS
                A function to convert between different delimiters.
            .DESCRIPTION
                Written primarily as a way of enabling the use of Import-CSV when
                the source file was a columnar text file with data like services.txt:
                
                ip              service         port
                --              -------         ----
                13.13.13.1      http            8000
                13.13.13.2      https           8001
                13.13.13.1      irc             6665-6669
            .PARAMETER From
                The delimiter that needs to be replaced
            .PARAMETER To
                The delimiter to replace with
            .EXAMPLE
                Get-Content services.txt | Convert-Delimiter " +" "," | Set-Content services.csv
                
                Description
                -----------
                Would convert the file above into something that could passed to:
                Import-Csv services.csv
            .NOTES
                This function was taken from http://poshcode.org/146 
                I tweaked it to fit my style of functions,  but otherwise the actual code that does all the 
                work was left in tact.
            .LINK
                http://scripts.patton-tech.com/wiki/PowerShell/FileManagement#Convert-Delimiter
        #>
        
        Param
            (
                [regex]$From,
                [string]$To
            )

        Process
            {
                ## replace the original delimiter with the new one, wrapping EVERY block in Þ
                ## if there's quotes around some text with a delimiter, assume it doesn't count
                ## if there are two quotes "" stuck together inside quotes, assume they're an 'escaped' quote
                $_ = $_ -replace "(?:`"((?:(?:[^`"]|`"`"))+)(?:`"$from|`"`$))|(?:((?:.(?!$from))*.)(?:$from|`$))","Þ`$1`$2Þ$to" 

                ## clean up the end where there might be duplicates
                $_ = $_ -replace "Þ(?:$to|Þ)?`$","Þ"

                ## normalize quotes so that they're all double "" quotes
                $_ = $_ -replace "`"`"","`"" -replace "`"","`"`"" 

                ## remove the Þ wrappers if there are no quotes inside them
                $_ = $_ -replace "Þ((?:[^Þ`"](?!$to))+)Þ($to|`$)","`$1`$2"

                ## replace the Þ with quotes, and explicitly emit the result
                Return $_ -replace "Þ","`""
            }
    }
Function Get-FileLogs
    {
        <#
            .SYNOPSIS
                Get log data from requested log file.
            .DESCRIPTION
                This function returns the data from either an Apache, Windows Firewall or IIS log file. Very simple 
                routine, it simply returns the data to be handled by some other function.
            .PARAMETER LogFile
                The path and filename to the log file to parse.
            .PARAMETER LogType
                The kind of logfile to work with, Apache or IIS.
            .EXAMPLE
            .NOTES
            .LINK
        #>
        
        Param
            (
                [Parameter(Mandatory=$true)]
                $LogFile,
                [Parameter(Mandatory=$true)]
                $LogType
            )
        
        switch ($LogType)
            {
                apache
                    {
                        #   Apache Log
                        #	Import the log file for processing
                        $WebTemp = foreach ($item in Get-Content $LogFile){$item.Remove(($item.IndexOf("]")-6),1)} 
                        $WebTemp |Convert-Delimiter " " "," |Set-Content .\templog.csv
                        $Return = Import-Csv .\templog.csv -Header "RemoteHost", "RemoteLogName", "RemoteUser", "Time", "Request", "Status", "Size", "Referer", "UserAgent"
                        Remove-Item .\templog.csv
                        Remove-Variable WebTemp
                    }
                iis
                    {
                        #   iis log
                        #   Remove header information wherever it appears
                        $WebTemp = Get-Content $LogFile |Where-Object {$_ -match "/#*"}
                        $WebTemp |Convert-Delimiter -From " " -To "`t" |Set-Content .\templog.csv
                        $Return = Import-Csv .\templog.csv  -Delimiter `t -header "Date", "Time", "ServerSitename", "ServerIP", "Method", "URIStem", "URIQuery", "ServerPort", "ClientUsername", "ClientIP", "HTTPStatus", "ProtocolStatus", "Win32Status", "BytesSent", "BytesReceived" ,"TimeTaken"
                        Remove-Item .\templog.csv
                        Remove-Variable WebTemp
                    }
                wfw
                    {
                        #   wfw log
                        #   Remove header information wherever it appears
                        $WfwTemp = foreach ($item in Get-Content $LogFile){if ($item.Length -gt 0){$item |Where-Object {$_ -notmatch '#'}}}
                        $WfwTemp |Convert-Delimiter -From " " -To "," |Set-Content .\templog.csv
                        $Return = Import-Csv .\templog.csv -Header "Date", "Time", "Action", "Protocol", "src-ip", "dst-ip", "src-port", "dst-port", "size", "tcpflags", "tcpsyn", "tcpack", "tcpwin", "icmptype", "icmpmode", "Info", "Path"
                        Remove-Item .\templog.csv
                        Remove-Variable WfwTemp
                    }
            }

        Return $Return
    }