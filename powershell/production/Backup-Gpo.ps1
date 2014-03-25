<#
    .SYNOPSIS
        A script to backup GPO's from the local domain.
    .DESCRIPTION
        This script will connect to the local domain, get a list of available
        GPOs and then create a backup of those GPO's in the specified folder.
    .PARAMETER BackupFolder
        This is the folder the GPO's will be stored in.
    .PARAMETER dnsDomain
        This is the FQDN of the local domain.
    .EXAMPLE
        .\Backup-Gpo.ps1
        
        Description
        -----------
        This is the basic syntax of the command.
    .NOTES
        ScriptName : Backup-Gpo.ps1
        Created By : jspatton
        Date Coded : 10/04/2012 15:14:41
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Backup-Gpo.ps1
#>
[CmdletBinding()]
Param
    (
        $BackupFolder = "C:\GPO_Backup",
        $dnsDomain =  [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
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
        $GpoMgmt = New-Object -ComObject gpmgmt.gpm
        $gpmConstants = $GpoMgmt.GetConstants()
        $gpSearchCriteria = $GpoMgmt.CreateSearchCriteria()

        $gpmDomain = $GpoMgmt.GetDomain($dnsDomain,'',$gpConstants.UsePDC)
        $gpoList = $gpmDomain.SearchGPOs($gpSearchCriteria)

        foreach ($Gpo in $gpoList)
        {
            Write-Verbose "Backing up $($gpo.DisplayName) GPO"
            $gpmResult = $Gpo.Backup($BackupFolder, "Backup performed by $($env:Username)")
            if ($gpmResult.Status.Count -ne 0)
            {
                $Gpo |Format-List |Out-File "$($BackupFolder)\Error.log" -Append
                $gpmResult |Format-List |Out-File "$($BackupFolder)\Error.log" -Append
                }
            else
            {
                Write-Verbose "GPO succesfully backed up."
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }