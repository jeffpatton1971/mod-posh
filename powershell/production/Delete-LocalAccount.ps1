<#
    .SYNOPSIS
        A script that removes a local user account
    .DESCRIPTION
        This script searches ActiveDirectory for computer accounts, for each
        computer account it removes the specified user account.
    .PARAMETER ADSPath
        The ActiveDirectory namespace to search for computers
    .PARAMETER UserName
        The username to remove from each computer
    .EXAMPLE
        .\Delete-LocalAccount.ps1 -ADSPath "LDAP://OU=workstations,DC=company,DC=com" -LocalUser delete `
        | Export-Csv .\sample.csv -NoTypeInformation

        Description
        -----------
        This example shows all parameters and piping the output to export-csv 
    .NOTES
        This script requires the ComputerManagement and ActiveDirectoryManagement libraries
        The script registers it's name as an event-source on the source computer and writes
        events to the application log.
        This script assumes the includes folder is a subfolder of the current directory, if that
        is not the case you may receive a FullyQualifiedErrorId : CommandNotFoundException when
        attempting to dot-source in the libraries.
    .LINK
        https://code.google.com/p/mod-posh/wiki/DeleteLocalAccount
    .LINK
        https://code.google.com/p/mod-posh/wiki/ComputerManagemenet
    .LINK
        https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement
#>
    Param
        (
            [Parameter(Mandatory=$true)]
            [string]$ADSPath,
            [Parameter(Mandatory=$true)]
            [string]$LocalUser
        )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

    	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
    	
    	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
    	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 
    	
        Try
        {
            Import-Module .\includes\ComputerManagement.psm1
            Import-Module .\includes\ActiveDirectoryManagement.psm1
            }
        Catch
        {
            Write-Warning "Must have the ActiveDirectoryManagement or ComputerManagement Modules available."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ActiveDirectoryManagement or ComputerManagement Modules Not Found"
            Break
            }
    }
Process
    {    
        $Workstations = Get-ADObjects -ADSPath $ADSPath
        $Jobs = @()
    	foreach ($Workstation in $Workstations)
            {
                [string]$ThisWorkstation = $Workstation.Properties.name
                [string]$RetVal = Remove-LocalUser -ComputerName $Workstation.Properties.name -UserName $LocalUser
                $ThisJob = New-Object PSobject

                Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "ComputerName" -Value $ThisWorkstation
                Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "UserName" -Value $LocalUser
                Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "Status" -Value $RetVal.Trim()
                $Jobs += $ThisJob
                $ThisJob
                }

        $Message = [system.string]::Join("`n",($Jobs))
        Write-EventLog -LogName $LogName -Source $ScriptName -EventId "101" -EntryType "Information" -Message $Message
    }
End
    {    
    	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
    }
    
