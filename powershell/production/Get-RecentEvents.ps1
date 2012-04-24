<#
    .SYNOPSIS
        Get all events from the active logs that occurred recently.
    .DESCRIPTION
        This script will pull all the logs from one or more remote systems that occurred
        in before the current time. This point in time is determined by the Hours parameter
        that is passed into the script. The default value is 2, so this means we would
        collect all the events on the system that occurred within 2 hours of right now.
        
        All logs are stored in a subfolder of FilePath that is the name of the server
        that we are connecting to.
    .PARAMETER Servers
        One or more servers to query
    .PARAMETER Hours
        A value indicating how many hours to go back
    .PARAMETER FilePath
        This is the location of the exported logs
    .EXAMPLE
        .\Get-RecentEvents -Servers 'fs1','fs2' -Hours 3 -FilePath 'C:\Logs'
        
        Description
        -----------
        This is the basic syntax of the command. The above command would connect
        to the servers node1 and node2 and collect all events 3 hours before and
        store them in the C:\Logs folder.
    .NOTES
        ScriptName : Get-RecentEvents.ps1
        Created By : jspatton
        Date Coded : 04/23/2012 16:59:21
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-RecentEvents.ps1
#>
[CmdletBinding()]
Param
    (
        $Servers,
        $Hours = 2,
        $FilePath = 'C:\LogFiles'
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        Write-Verbose "Setting checkpoint to $(Get-Date)."
        $CheckPoint = Get-Date
        $TimeStamp = Get-Date -f MMddyyy-HHMMss
        $FilePath = "$($FilePath)\$($TimeStamp)"
        
        if ((Test-Path $FilePath) -ne $true)
        {
            Write-Verbose "Creating $($FilePath)"
            New-Item -Path $FilePath -ItemType Directory -Force |Out-Null
            }
        }
Process
    {
        foreach ($ServerName in $Servers)
        {
            Write-Verbose "Get a list of logs that have records from $($ServerName)"
            $ActiveLogs = Get-WinEvent -ListLog * -ComputerName $ServerName |Where-Object {$_.RecordCount -gt 0}
            Write-Verbose "Found $($ActiveLogs.Count) logs"
            
            foreach ($Log in $ActiveLogs)
            {
                Write-Verbose "Build filename"
                $FileName = "$($Log.LogName).csv"
                Write-Verbose "$($FileName)"
                
                try
                {
                    Write-Verbose "Connect to $($ServerName) and return a list of logs that were written within the last ($Hours) hour(s)"
                    $ThisLog = Get-WinEvent -LogName $Log.LogName -ComputerName $ServerName `
                        |Where-Object {(Get-Date($_.TimeCreated)) -gt $CheckPoint.AddHours(-($Hours)) -and (Get-Date($_.TimeCreated)) -lt $CheckPoint}
                    if ($ThisLog)
                    {
                        Write-Verbose "Events were found in $($Log.LogName)"
                        if ((Test-Path "$($FilePath)\$($ServerName)") -ne $true)
                        {
                            Write-Verbose "$($FilePath)\$($ServerName) not found, creating."
                            New-Item -Path "$($FilePath)\$($ServerName)" -ItemType Directory -Force |Out-Null
                            }
                        Write-Verbose "Exporting log entries to $($FilePath)\$($ServerName)\$($FileName)"
                        $ThisLog |Export-Csv -Path "$($FilePath)\$($ServerName)\$($FileName)" -NoTypeInformation
                        }
                    }
                catch
                {
                    $Message = $Error[0].Exception
                    Write-Verbose $Message
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }