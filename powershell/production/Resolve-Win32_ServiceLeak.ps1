<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Resolve-Win32_ServiceLeak.ps1
        Created By : jspatton
        Date Coded : 08/24/2012 14:34:20
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Resolve-Win32_ServiceLeak.ps1
#>
[CmdletBinding()]
Param
    (
    [datetime]$Date
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
        $Seconds = ((Get-Date($Date)) - (Get-Date) |Select-Object -Property @{Label='Seconds';Expression={[math]::Round($_.TotalSeconds)}}).Seconds
        }
Process
    {
        # New-Item C:\scripts -ItemType directory
        Set-Location C:\scripts

        # $LibFile = (Join-Path $pwd "QfeLibrary.psm1")
        # $LibURL = "http://mod-posh.googlecode.com/svn/powershell/production/includes/QfeLibrary.psm1"
        # $webclient = New-Object Net.Webclient
        # $webClient.UseDefaultCredentials = $true
        # $webClient.DownloadFile($LibURL, $LibFile)

        Import-Module C:\scripts\QfeLibrary.psm1
        Set-QfeServer -QfeServer '\\groups1\it\Units\EIO\ITSA\Microsoft\Hotfixes'
        Get-QfeList -Download
        Install-QfePatch -QfeFilename C:\Hotfixes\981314-Microsoft-Windows-Server-2008-R2-Enterprise-x64.xml
        $Update = Get-HotFix -Id kb981314
       }
End
    {
        if ($Update)
        {
            & shutdown /r /t $Seconds /c "Applied update kb981314 requires restart" /d P:2:17
            }
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }