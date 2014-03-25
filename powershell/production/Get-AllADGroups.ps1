<#
    .SYNOPSIS
        Return all group members in each group
    .DESCRIPTION
        This script returns all the members of each group in a provided AD Path. If you pass in just an OU
        it will return all the groups and members in that OU.
    .PARAMETER ADSPath
        This is an LDAP URI in the form of LDAP://OU=something,DC=domain,DC=suffix
    .EXAMPLE
        .\Get-AllADGroups -ADSPath "LDAP://OU=groups,DC=company,DC=com"
        
        GroupPath                GroupName                UserName                 DistinguishedName
        ---------                ---------                --------                 -----------------
        LDAP://CN=SoftwareAcc... SoftwareAccess           Jack Tripper             CN=Jack Tripper,CN=Us...
        LDAP://CN=SoftwareAcc... SoftwareAccess           Les Nessman              CN=Les Nessman,CN=Use...
        LDAP://CN=Admin User ... Admin User Accounts      Ralph Monroe             CN=Ralph Monroe,CN=Us...
        LDAP://CN=Admin User ... Admin User Accounts      Gunther Toody            CN=Gunther Toody,CN=U...

        Description
        -----------
        Showing the basic syntax and output of the script
    .EXAMPLE
        .\Get-AllADGroups -ADSPath "LDAP://OU=groups,DC=company,DC=com" |Export-Csv -Path .\MyGroups.csv
        
        Description
        -----------
        This example outputs the groups and members to a csv file.
    .NOTES
        ScriptName: Get-AllADGroups.ps1
        Created By: Jeff Patton
        Date Coded: June 1, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-AllADGroups
#>
Param
    (
        [Parameter(Mandatory=$true)]
        [string]$ADSPath
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

        #	Dotsource in the functions you need.
        Try
        {
            Import-Module .\includes\ActiveDirectoryManagement.psm1
            }
        Catch
        {
            Write-Warning "Must have the ActiveDirectoryManagement Module available."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ActiveDirectoryManagement Module Not Found"
            Break
            }
        
        $SecurityGroups = Get-ADObjects -ADSPath $ADSPath -SearchFilter "(objectCategory=group)"
        $MyGroups = @()
    }
Process
    {
        foreach ($SecurityGroup in $SecurityGroups)
        {
            $Members = Get-ADGroupMembers -UserGroup $($SecurityGroup.Properties.name)
            
            foreach ($Member in $Members)
            {
                $ThisGroup = New-Object -TypeName PSObject -Property @{
                    GroupName = $($SecurityGroup.Properties.name)
                    GroupPath = $($SecurityGroup.Path)
                    UserName = $($Member.name)
                    DistinguishedName = $($Member.distinguishedName)
                    }
                $MyGroups += $ThisGroup
                }
            }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
        Return $MyGroups
    }
