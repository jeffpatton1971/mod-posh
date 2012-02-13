<#
    .SYNOPSIS
        Local administrator password update
    .DESCRIPTION
        This script changes the local administrator password.
    .PARAMETER ADSPath
        The ActiveDirectory namespace to search for computers
    .PARAMETER AdminAccount
        The username of the administrator account
    .PARAMETER NewPassword
        The new password
    .EXAMPLE
        .\Update-AdminPassword.ps1 -ADSPath "LDAP://DC=company,DC=com" -AdminAccount "administrator" `
        -NewPassword "N3wp@ssw0rd" |Export-Csv .\sample.csv -NoTypeInformation
        
        Description
        -----------
        This example shows all parameters being used with the output being piped to a spreadsheet.
    .EXAMPLE
        .\Update-AdminPassword.ps1 -ADSPath "LDAP://OU=TestOU,DC=company,Dc=com" -AdminAccount Administrator `
        -NewPassword Pass12345
        
        ComputerName    UserName        Status
        ------------    --------        ------
        L1132C-VM01     Administrator   The network path was not found.
        l1132c-pc17     Administrator   The user name could not be found.
        l1132c-pc05     Administrator   Access is denied.
        L1132C-PC01     Administrator   Password updated

        Description
        -----------
        This shows an example of the output
    .NOTES
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        This script assumes that the includes folder contains the libraries needed for this script to work.
        I've not added credentials for this, so it will need to be run from an account that has the ability to 
        change passwords on your computers.
    .LINK
        https://code.google.com/p/mod-posh/wiki/UpdateAdminPassword
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
        [string]$AdminAccount,
        [Parameter(Mandatory=$true)]
        [string]$NewPassword            
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
    	
    	. .\includes\ActiveDirectoryManagement.ps1
        . .\includes\ComputerManagement.ps1
    }
Process
    {    
        $Workstations = Get-ADObjects -ADSPath $ADSPath
        $Jobs = @()
    	foreach ($Workstation in $Workstations)
            {
                [string]$ThisWorkstation = $Workstation.Properties.name
                $ThisJob = New-Object PSobject

                [string]$Retval = Set-Pass -ComputerName $ThisWorkstation -UserName $AdminAccount -Password $NewPassword

                Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "ComputerName" -Value $ThisWorkstation
                Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "UserName" -Value $AdminAccount
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
