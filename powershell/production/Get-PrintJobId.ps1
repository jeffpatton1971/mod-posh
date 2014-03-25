<#
    .SYNOPSIS
        This script grabs the Job ID of a print job
    .DESCRIPTION
        This script grabs the Job ID of a print job and writes it out to an
        xml file on the server. This script works in conjunction with the
        New-PrintJob script. This particular script is attached to Event 805
        on the Microsoft-Windows-PrintService/Operational log.
        
        The purpose of the script is to capture the copies property that
        is stored seperately from the pages printed property in Event 307. The
        output of this script is read in when the New-PrintJob script is run.
    .PARAMETER FilePath
        The path to where the files should be stored.
    .PARAMETER eventRecordID
        This value is passed in from the even that triggered the task. This is the
        record number of the event in the log. This is used to grab the specific
        event that the script will query data from.
    .PARAMETER eventChannel
        This is the name of the log, as passed in from the Event subsystem.
    .EXAMPLE
        .\Get-PrintJobId.ps1 -eventRecordID $(eventRecordID) -eventChannel $(eventChannel)
        
        Description
        -----------
        This is how you would call the script when you attach it to an Event Triggered Task.
    .NOTES
        ScriptName : Get-PrintJobId.ps1
        Created By : jspatton
        Date Coded : 04/26/2012 11:11:39
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-PrintJobId.ps1
#>
[CmdletBinding()]
Param
    (
    $FilePath = "P:\PrintLogs",
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
        }
Process
    {
        $JobId = Get-WinEvent -ErrorAction Stop -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[(EventRecordID=$eventRecordID)]]</Select></Query></QueryList>"
        $JobId = ([xml]$JobId.ToXml())
        
        $JobOutput = New-Object -TypeName PSobject -Property @{
            JobId = $JobId.Event.UserData.RenderJobDiag.JobId
            Copies = $JobId.Event.UserData.RenderJobDiag.Copies
            }
        }
End
    {
        $JobOutput |Export-Clixml -Path "$($FilePath)\$($JobOutput.JobId).xml"
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }