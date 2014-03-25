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
                You need to add the ability to create a log file to one of your scripts. You would like the file name 
                to follow the year, month, and day pattern so that you can easily discover which log file represents 
                which day. For the purposes of this event, it is only necessary to create a text file with the name 
                made up of the year, month, and day.
            .LINK
                https://2011sg.poshcode.org/1292
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