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
    .PARAMETER ComputerName
        One or more servers to query
    .PARAMETER Hours
        A value indicating how many hours to go back
    .PARAMETER FilePath
        This is the location of the exported logs
    .PARAMETER ErrorsOnly
        This switch will tell the script to grab only error entries from the logs.
    .PARAMETER Logs
        A comma seperated list of specific logs to query.
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
    [string]$ComputerName = (& hostname),
    [int]$Hours = 2,
    [string]$FilePath = 'C:\LogFiles',
    [switch]$ErrorsOnly,
    $Logs
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        Write-Verbose "Setting checkpoint to $(Get-Date)."
        $CheckPoint = Get-Date
        $TimeStamp = Get-Date -f MMddyyy
        $LogPath = "$($FilePath)\$($TimeStamp)"
        
        if ((Test-Path $LogPath) -ne $true)
        {
            Write-Verbose "Creating $($LogPath)"
            New-Item -Path $LogPath -ItemType Directory -Force |Out-Null
            }
        }
Process
    {
        foreach ($Computer in $ComputerName)
        {
            try
            {
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
                Write-Verbose "Get a list of logs that have records from $($Computer)"
                if ($OS.Version -ge 6)
                {
                    $ActiveLogs = Get-WinEvent -ListLog * -ComputerName $Computer |Where-Object {$_.RecordCount -gt 0}
                    Write-Verbose "Found $($ActiveLogs.Count) logs"
                    }
                else
                {
                    $ActiveLogs = @()
                    $ActiveLogs += ((New-Object -TypeName PSObject) |Add-Member -MemberType NoteProperty -Name LogName -Value 'System' -PassThru)
                    $ActiveLogs += ((New-Object -TypeName PSObject) |Add-Member -MemberType NoteProperty -Name LogName -Value 'Application' -PassThru)
                    $ActiveLogs += ((New-Object -TypeName PSObject) |Add-Member -MemberType NoteProperty -Name LogName -Value 'Security' -PassThru)
                    }
                if ($Logs)
                {
                    $ActiveLogs = @()
                    foreach ($Log in $Logs)
                    {
                        $ActiveLogs += ((New-Object -TypeName PSObject) |Add-Member -MemberType NoteProperty -Name LogName -Value $Log  -PassThru)
                        }
                    }
                foreach ($Log in $ActiveLogs)
                {                   
                    Write-Verbose "Connect to $($Computer) and return a list of logs that were written within the last $($Hours) hour(s)"
                    if ($OS.Version -ge 6)
                    {
                        if ($ErrorsOnly)
                        {
                            $ThisLog = Get-WinEvent -ComputerName $Computer -FilterHashtable @{LogName = $Log.LogName; Level = 2}`
                                |Where-Object {(Get-Date($_.TimeCreated)) -gt $CheckPoint.AddHours(-($Hours)) -and (Get-Date($_.TimeCreated)) -lt $CheckPoint}
                            }
                        else
                        {
                            $ThisLog = Get-WinEvent -LogName $Log.LogName -ComputerName $Computer `
                                |Where-Object {(Get-Date($_.TimeCreated)) -gt $CheckPoint.AddHours(-($Hours)) -and (Get-Date($_.TimeCreated)) -lt $CheckPoint}
                            }
                        }
                    else
                    {
                        $ThisLog = Get-EventLog -LogName $Log.LogName -ComputerName $Computer `
                            |Where-Object {(Get-Date($_.TimeGenerated)) -gt $CheckPoint.AddHours(-($Hours)) -and (Get-Date($_.TimeGenerated)) -lt $CheckPoint}
                        }
                    if ($ThisLog)
                    {
                        Write-Verbose "$($ThisLog.Count) event(s) were found in $($Log.LogName)"
                        Write-Verbose "Building filename from $($Log.LogName)"
                        $FileName = "$(($Log.LogName).Replace('/','-')).csv"
                        Write-Verbose "$($FileName)"
                        if ((Test-Path "$($LogPath)\$($Computer)") -ne $true)
                        {
                            Write-Verbose "$($LogPath)\$($Computer) not found, creating."
                            New-Item -Path "$($LogPath)\$($Computer)" -ItemType Directory -Force |Out-Null
                            }
                        Write-Verbose "Exporting $($ThisLog.Count) log entries to $($LogPath)\$($Computer)\$($FileName)"
                        $ThisLog |Export-Csv -Path "$($LogPath)\$($Computer)\$($FileName)" -NoTypeInformation
                        }
                    }
                }
            catch
            {
                $Message = $Error[0].Exception
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }