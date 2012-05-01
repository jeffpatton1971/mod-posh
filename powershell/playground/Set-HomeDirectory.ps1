<#
    .SYNOPSIS
        Update the homeDirectory property for users in an OU
    .DESCRIPTION
        This script updates the homeDirectory property for a collection
        of users in a given OU.
    .PARAMETER AdsPath
        The fully qualified ADSpath to the OU that contains your user account
        
        LDAP://OU=Accounts,DC=company,DC=com
    .PARAMETER NewHome
        The UNC path to change the homeDirectory to
        
        \\fs\users\path
    .EXAMPLE
        .\Set-HomeDirectory.ps1 -AdsPath LDAP://OU=Accounts,DC=company,DC=com -NewHome \\fs\users\path
    .NOTES
        ScriptName : Set-HomeDirectory.ps1
        Created By : jspatton
        Date Coded : 05/01/2012 15:01:32
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Set-HomeDirectory.ps1
 #>
[CmdletBinding()]
Param
    (
    [Parameter(Mandatory=$true)]
    $AdsPath,
    [Parameter(Mandatory=$true)]
    $NewHome
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        Write-Verbose "Create a searchfilter"
        $SearchFilter = "(&(objectClass=user))"
        Write-Verbose "Create a DirectoryEntry object for $($AdsPath)"
        $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
        Write-Verbose "Create a new DirectorySearcher object to find the user"
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
        Write-Verbose "Assign the searchfilter to the DirectorySearcher"
        $DirectorySearcher.Filter = $SearchFilter
        Write-Verbose "Walk the path to find objects"
        $DirectorySearcher.SearchScope = "Subtree"
        Write-Verbose "Set the root to the DirectoryEntry object"
        $DirectorySearcher.SearchRoot = $DirectoryEntry
        Write-Verbose "Set the pagesize"
        $DirectorySearcher.PageSize = 1000
        [void]$DirectorySearcher.PropertiesToLoad.Add('objectClass')
        }
Process
    {
        Write-Verbose "Do the search"
        foreach ($Account in $DirectorySearcher.FindAll())
        {
            if ($Account.properties.objectclass -notcontains 'computer')
            {
                Write-Verbose "Found user account"
                $User = [adsi]"$($Account.Properties.adspath)"
                $ThisAccount = New-Object -TypeName PSObject -Property @{
                    DisplayName = $User.displayName
                    CurrentHome = $User.homeDirectory
                    NewHome = $NewHome
                    }
                Write-Verbose $ThisAccount
                Write-Verbose "Changing $($User.homeDirectory) to $($NewHome)"
                $User.put("homedirectory","$($NewHome)\$User.cn")
                Write-Verbose "Commit changes back to object"
                $User.setinfo()
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }