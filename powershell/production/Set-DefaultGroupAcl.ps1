<#
    .SYNOPSIS
        This script will remove Read permissions from SELF and AuthenticatedUsers
    .DESCRIPTION
        This script will remove Read permissions from SELF and AuthenticatedUsers. This
        will prevent a group member from doing a lookup in Exchange or AD for who the other
        members of the group are.
        
        If for some reason the permissions are unable to be removed on one or more rules, the
        entire commit is aborted and no change is made. You will find error messages in the 
        PowerShell log to let you know which group didn't get modified.
        
        This script is designed to be used with the Quest cmdlets but, they are not required
        for the script to work. My pipeline is looking for a property being returned called 
        Name. You should be able to create a CSV with a Name column and pipe the output of that
        to this script, or if you have custom rolled your own functions, change the parameter
        property in this script to match the property that you are returning for groupname.
    .PARAMETER Name
        The name of the group in AD that you wish to modify permissions for.
    .EXAMPLE
        .\Set-DefaultGroupAcl.ps1 -Name MyGroup
        
        Description
        -----------
        This is the default syntax for this command. There is no output unless you
        specify verbose.
    .EXAMPLE
        Get-QadGroup -SearchRoot company/MyGroup | .\Set-DefaultGroupAcl.ps1
        
        Description
        -----------
        This example shows piping the output of Quest Cmdlet's Get-QADGroup
        to the script.
    .NOTES
        ScriptName : Set-DefaultGroupAcl.ps1
        Created By : jspatton
        Date Coded : 06/11/2012 12:58:20
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Set-DefaultGroupAcl.ps1
#>
[CmdletBinding()]
Param
    (
    [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string]$Name
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
        try
        {
            Add-PSSnapin -Name Quest.ActiveRoles.ADManagement
            }
        catch
        {
            Write-Error "Please install the Quest ActiveDirectory Cmdlets."
            break
            }
        }
Process
    {
        foreach ($GroupName in $Name)
        {
            [boolean]$Commit = $true
            try
            {
                Write-Verbose "Create an object for $($GroupName)"
                $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
                $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
                $LDAPFilter = "(&(objectCategory=Group)(name=$($GroupName)))"
                $DirectorySearcher.SearchRoot = $DirectoryEntry
                $DirectorySearcher.PageSize = 1000
                $DirectorySearcher.Filter = $LDAPFilter
                $DirectorySearcher.SearchScope = "Subtree"

                $SearchResult = $DirectorySearcher.FindOne()
                }
            catch
            {
                $Message = $Error[0].Exception
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                break
                }

            Write-Verbose "Connect to the $($GroupName) object" 
            $Group = $SearchResult.GetDirectoryEntry()
            Write-Verbose "Pull the SID from the object"
            $GroupSid = New-Object System.Security.Principal.SecurityIdentifier($Group.objectSid[0],0)

            Write-Verbose "Build the SID object for AuthenticatedUsers"
            $authUsers = New-Object System.Security.Principal.SecurityIdentifier([Security.Principal.WellKnownSidType]"AuthenticatedUserSid", $GroupSid.ToString())

            Write-Verbose "Build the SID object for SELF"
            $self = New-Object System.Security.Principal.SecurityIdentifier([Security.Principal.WellKnownSidType]"SelfSid", $GroupSid.ToString())

            Write-Verbose "Create a rule to allow Read Access for AuthenticatedUsers"
            $rule1 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($authUsers, [System.DirectoryServices.ActiveDirectoryRights]"ReadProperty", [System.Security.AccessControl.AccessControlType]"Allow")

            Write-Verbose "Create a rule to allow Read Access for SELF"
            $rule2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($self, [System.DirectoryServices.ActiveDirectoryRights]"ReadProperty", [System.Security.AccessControl.AccessControlType]"Allow")

            Write-Verbose "Remove read permissions from AuthenticatedUsers"
            $Result = $Group.ObjectSecurity.RemoveAccessRule($rule1)
            if ($Result -ne $true)
            {
                $Commit = $false
                $Message = "Unable to RemoveAccessRule from AuthenticatedUsers"
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }
            
            Write-Verbose "Remove read permissions from SELF"
            $Result = $Group.ObjectSecurity.RemoveAccessRule($rule2)
            if ($Result -ne $true)
            {
                $Commit = $false
                $Message = "Unable to RemoveAccessRule from SELF"
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }
                
            Write-Verbose "Write changes to ActiveDirectory"
            if ($Commit)
            {
                $Group.CommitChanges()
                $Message = "Removed read permissions from $($GroupName) for SELF and Authenticated Users"
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
                }
            else
            {
                $Message = "One or more rules were not removed from $($GroupName), aborting commit."
                Write-Verbose $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }
            
            Write-Verbose "Close object"
            $DirectoryEntry.Close()
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }