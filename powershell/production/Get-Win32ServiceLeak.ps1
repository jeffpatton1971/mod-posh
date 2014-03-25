<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-Win32ServiceLeak
        Created By : jspatton
        Date Coded : 07/02/2012 10:48:50
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-Win32ServiceLeak
#>
[CmdletBinding()]
Param
    (
    [Parameter(ValueFromPipeline=$True)]
    [string]$ComputerName = (& hostname),
    [string]$FilePath = 'C:\Windows\System32\wbem\cimwin32.dll'
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
        foreach ($Computer in $ComputerName)
        {
            if ($Computer -eq (& hostname))
            {
                $CimWin32 = Get-Item $FilePath
                }
            else
            {
                $CimWin32 = Get-Item "\\$($Computer)\$($FilePath.Replace(':','$'))"
                }
            $VersionInfo = $CimWin32.VersionInfo
            $Return = New-Object -TypeName PSObject -Property @{
                ComputerName = $Computer
                FileName = $CimWin32.FullName
                FileVersion = $VersionInfo.FileVersion
                FileSize = $CimWin32.Length
                Date = $CimWin32.CreationTime
                }
            Return $Return |Select-Object -Property ComputerName, FileName, FileVersion, FileSize, Date
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }