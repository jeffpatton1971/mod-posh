<#
    .SYNOPSIS
        Get authentication type from logon event
    .DESCRIPTION
        This script is run as part of an even trigger, the trigger event
        is ID 4624, the logon event on a Domain Controller. The idea is to
        log the type of logon traffic to the server to determine if any clear
        text traffic is being passed in.
    .PARAMETER FileName
        The fully qualified path and filename for the report.
    .PARAMETER FilePath
        The path to where the files should be stored.
    .PARAMETER eventRecordID
        This value is passed in from the even that triggered the task. This is the
        record number of the event in the log. This is used to grab the specific
        event that the script will query data from.
    .PARAMETER eventChannel
        This is the name of the log, as passed in from the Event subsystem.
    .EXAMPLE
        C:\Scripts\Get-AuthType.ps1 -eventRecordID $(eventRecordID) -eventChannel $(eventChannel)
        
        Description
        -----------
        This is how you would call the script when you attach it to an Event Triggered Task.
    .NOTES
        ScriptName : Get-AuthType.ps1
        Created By : jspatton
        Date Coded : 09/24/2012 15:34:45
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-AuthType.ps1
#>
[CmdletBinding()]
Param
    (
    $FileName = "AuthLog-$((Get-Date -Format "yyyMMdd")).csv",
    $FilePath = "C:\Logs",
    $eventRecordID,
    $eventChannel
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        $AuthLogEntry = Get-WinEvent -ErrorAction Stop -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[(EventRecordID=$eventRecordID)]]</Select></Query></QueryList>"
        if (!(Test-Path $FilePath))
        {
            New-Item $FilePath -ItemType Directory |Out-Null
            }
        }
Process
    {
        $AuthLog = New-Object -TypeName PSObject -Property @{
            ComputerName = (& hostname)
            TimeCreated = $AuthLogEntry.TimeCreated
            UserName = $AuthLogEntry.Properties[5].Value
            DomainName = $AuthLogEntry.Properties[6].Value
            LogonProcessName = $AuthLogEntry.Properties[9].Value
            AuthenticationPackageName = $AuthLogEntry.Properties[10].Value
            }
        $AuthLog = $AuthLog |Select-Object -Property ComputerName, TimeCreated, UserName, DomainName, LogonProcessName, AuthenticationPackageName
        $AuthLog = ConvertTo-Csv -InputObject $AuthLog -NoTypeInformation
        }
End
    {
        if ((Test-Path -Path "$($FilePath)\$($FileName)") -eq $true)
        {
            $AuthLog |Select-Object -Skip 1 |Out-File -FilePath "$($FilePath)\$($FileName)" -Append
            }
        else
        {
            $AuthLog |Out-File -FilePath "$($FilePath)\$($FileName)"
            }
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }