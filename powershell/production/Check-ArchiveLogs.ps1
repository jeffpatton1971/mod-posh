<#
    .SYNOPSIS
        This script returns the age of files in the archive path
    .DESCRIPTION
        A simple script to return the age of all the files that 
        are found in the archive path on the server.
    .PARAMETER ArchivePath
        This is where the security logs are archived.
    .EXAMPLE
        .\Check-ArchiveLogs.ps1

        FileAge FileName
        ------- --------
             43 adhome-lawc-05-Archive-Security-2012-11-06-20-57-32-049
             43 adhome-lawc-05-Archive-Security-2012-11-06-18-20-39-591
             42 adhome-lawc-06-Archive-Security-2012-11-07-17-54-09-644
             42 adhome-lawc-06-Archive-Security-2012-11-07-04-29-52-648
             42 adhome-lawc-05-Archive-Security-2012-11-07-14-13-24-150

        Description
        -----------
        This is the only method of running this script.
    .NOTES
        ScriptName : Check-ArchiveLogs.ps1
        Created By : jspatton
        Date Coded : 12/19/2012 14:29:30
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Check-ArchiveLogs.ps1
 #>
[CmdletBinding()]
Param
    (
    [string]$ArchivePath = "\\ent-cifsprd-02.cc.ku.edu\DC_Logs$"
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
        $Report = @()
        }
Process
    {
        
        foreach ($ZipFile in ($ZipFiles = Get-ChildItem $ArchivePath))
        {
            [int]$ZipFileAge = ((Get-Date) - ([datetime]($ZipFile.BaseName.Substring(($ZipFile.BaseName.Length - 23),23)).SubString(0,10))).Days
            $LineItem = New-Object -TypeName PSobject -Property @{
                FileName = $ZipFile.BaseName
                FileAge = $ZipFileAge
                }
            $Report += $LineItem
            }
        }
End
    {
        Return $Report |Sort-Object -Property FileAge -Descending
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }