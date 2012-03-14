Function Get-ADObjects
{
    <#
        .SYNOPSIS
            Returns a list of objects from ActiveDirectory
        .DESCRIPTION
            This function will return a list of objects from ActiveDirectory. It will start at the provided ADSPath 
            and find each object that matches the provided SearchFilter. For each object returned only the 
            specified properties will be provided.
        .PARAMETER ADSPath
            This is the LDAP URI of the location within ActiveDirectory you would like to search. This can be an 
            OU, CN or even the root of your domain.
        .PARAMETER SearchFilter
            This parameter is specified in the same format as an LDAP Search Filter. For more information on the 
            format please visit Microsoft (http://msdn.microsoft.com/en-us/library/aa746475.aspx). If nothing is 
            specified on the command-line the default filter is used:
                (objectCategory=computer)
        .PARAMETER ADProperties
            If you want specific properties returned like name, or distinguishedName 
            provide a comma seperated list.
        .EXAMPLE
            Get-ADObjects -ADSPath "LDAP://OU=Workstations,DC=company,DC=com"

            Path                                                                  Properties                                                                           
            ----                                                                  ----------                                                                           
            LDAP://CN=Computer-pc01,OU=Workstations,DC=company,DC=com             {name, adspath}                                                                      
            LDAP://CN=Computer-pc02,OU=Workstations,DC=company,DC=com             {name, adspath}                                                                      
            LDAP://CN=Computer-pc03,OU=Workstations,DC=company,DC=com             {name, adspath}                                                                      
            LDAP://CN=Computer-pc04,OU=Workstations,DC=company,DC=com             {name, adspath}
            
            Description
            -----------
            When specifying just the ADSPath computer objects and their associated name properties are returned
            by default.
        .EXAMPLE
            Get-ADObjects -ADSPath "LDAP://OU=Workstations,DC=company,DC=com" `
            -ADProperties "name","distinguishedName"

            Path                                                                  Properties                                                                           
            ----                                                                  ----------                                                                           
            LDAP://CN=Computer-pc01,OU=Workstations,DC=company,DC=com             {name, adspath, distinguishedname}                                                   
            LDAP://CN=Computer-pc02,OU=Workstations,DC=company,DC=com             {name, adspath, distinguishedname}                                                   
            LDAP://CN=Computer-pc03,OU=Workstations,DC=company,DC=com             {name, adspath, distinguishedname}                                                   
            LDAP://CN=Computer-pc04,OU=Workstations,DC=company,DC=com             {name, adspath, distinguishedname}

            Description
            -----------
            This example shows the format for ADProperties, each property is composed of a string enclosed in quotes
            seperated by commas.
        .EXAMPLE
            Get-ADObjects -ADSPath "LDAP://OU=Groups,DC=company,DC=com" `
            -ADProperties "name","distinguishedName" -SearchFilter group

            Path                                                                  Properties                                                                           
            ----                                                                  ----------                                                                           
            LDAP://CN=Group-01,OU=Groups,DC=Company,DC=com                        {name, adspath, distinguishedname}                                                   
            LDAP://CN=Group-02,OU=Groups,DC=Company,DC=com                        {name, adspath, distinguishedname}                                                   
            LDAP://CN=Group-03,OU=Groups,DC=Company,DC=com                        {name, adspath, distinguishedname}                                                   
            LDAP://CN=Group-04,OU=Groups,DC=Company,DC=com                        {name, adspath, distinguishedname}
            
            Description
            -----------
            This example shows multiple properties as well as setting the SearchFilter to be groups that are 
            returned.
        .NOTES
            The script runs under the users context, so the user account must have permissions
            to view the objects within the domain that the function is currently running
            against.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-ADObjects
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ADSPath = (([ADSI]"").distinguishedName),
        [string]$SearchFilter = "(objectCategory=computer)",
        [array]$ADProperties="name"
        )
    Begin
    {
        if ($ADSPath -notmatch "LDAP://*")
        {
            $ADSPath = "LDAP://$($ADSPath)"
            }
        }
    Process
    {
        Try
        {
            $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
            $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
            $DirectorySearcher.SearchRoot = $DirectoryEntry
            $DirectorySearcher.PageSize = 1000
            $DirectorySearcher.Filter = $SearchFilter
            $DirectorySearcher.SearchScope = "Subtree"

            foreach ($Property in $ADProperties)
                {
                    [void]$DirectorySearcher.PropertiesToLoad.Add($Property)
                    }

            $ADObjects = $DirectorySearcher.FindAll()
            }
        Catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        Return $ADObjects
        }
    }    
Function Add-UserToLocalGroup
{
    <#
        .SYNOPSIS
            Add a domain user to a local group.
        .DESCRIPTION
            Add a domain user to a local group on a computer.
        .PARAMETER Computer
            The NetBIOS name of the computer where the local group resides.
        .PARAMETER UserName
            The name of the user to add to the group.
        .PARAMETER LocalGroup
            The name of the group to add the user to.
        .PARAMETER UserDomain
            The NetBIOS name of the domain where the user object is.
        .EXAMPLE
            Add-UserToLocalGroup -Computer server -UserName myuser -LocalGroup administrators

            Description
            -----------
            Adds a user from the local domain to the specified computer.
        .EXAMPLE
            Add-UserToLocalGroup -Computer server -UserName myuser -LocalGroup administrators -UserDomain company

            Description
            -----------
            Adds a user from the company domain to the specified computer's local Administrators group.
        .NOTES
            The script runs under the users context, so the user account must have permissions
            to view the objects within the domain that the function is currently running
            against.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Add-UserToLocalGroup
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Computer,
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$LocalGroup,
        [string]$UserDomain
        )
    Begin
    {
        if ($UserDomain -eq $null)
        {
            $UserDomain = [string]([ADSI] "").name
            }
        }        
    Process
    {
        Try
        {
            ([ADSI]"WinNT://$Computer/$LocalGroup,group").Add("WinNT://$UserDomain/$UserName")
            if ($? -eq $true)
            {
                $Result = New-Object -TypeName PSObject -Property @{
                    Computer = $Computer
                    Group = $LocalGroup
                    Domain = $UserDomain
                    User = $UserName
                    Success = $?
                    }
                }
            }
        Catch
        {
            $Result = New-Object -TypeName PSObject -Property @{
                Computer = $Computer
                Group = $LocalGroup
                Domain = $UserDomain
                User = $UserName
                Success = $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        Return $Result
        }
    }
Function Get-LocalGroupMembers
{
    <#
        .SYNOPSIS
            Return a list of user accounts that are in a specified group.
        .DESCRIPTION
            This function returns a list of accounts from the provided group. The
            object returned holds the Name, Domain and type of account that is a member,
            either a user or group.
        .PARAMETER ComputerName
            The name of the computer to connect to.
        .PARAMETER GroupName
            The name of the group to search in.
        .NOTES
        .EXAMPLE
            Get-LocalGroupMembers -ComputerName mypc -GroupName Administrators

            Name                              Domain                          Class
            ----                              ------                          -----
            Administrator                     mypc                            User
            My Account                        mypc                            User
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-LocalGroupMembers
    #>
    [CmdletBinding()]        
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$GroupName
        )
    Begin
    {
        }
    Process
    {
        Try
        {
            $Group = [ADSI]("WinNT://$($ComputerName)/$($GroupName),group")

            $Members = @()  
            $Group.Members() |foreach `
            {
                $AdsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)
                $AccountArray = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries)
                [string]$AccountName = $AccountArray[-1]
                [string]$AccountDomain = $AccountArray[-2]
                [string]$AccountClass = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
                        
                $Member = New-Object PSObject -Property @{
                    Name = $AccountName
                    Domain = $AccountDomain
                    Class = $AccountClass
                    }

                $Members += $Member  
                }
            }
        Catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        Return $Members
        }
    }
Function Get-ADGroupMembers
{
    <#
        .SYNOPSIS
            Return a collection of users in an ActiveDirectory group.
        .DESCRIPTION
            This function returns an object that contains all the properties of a user object. This function
            works for small groups as well as groups in excess of 1000.
        .PARAMETER UserGroup
            The name of the group to get membership from.
        .PARAMETER ADSPath
            The LDAP URL of the domain that the group resides in.
        .EXAMPLE
            Get-ADGroupMembers -UserGroup Managers |Format-Table -Property name, distinguishedName, cn

            name                             distinguishedName                cn                              
            ----                             -----------------                --                              
            {Steve Roberts}                  {CN=Steve Roberts,CN=Users,DC... {Steve Roberts}                 
            {S-1-5-21-57989841-1078081533... {CN=S-1-5-21-57989841-1078081... {S-1-5-21-57989841-1078081533...
            {S-1-5-21-57989841-1078081533... {CN=S-1-5-21-57989841-1078081... {S-1-5-21-57989841-1078081533...
            {Matt Temple}                    {CN=Matt Temple,CN=Users,DC=c... {Matt Temple}                   
            ...
            Description
            -----------
            This example shows passing in a group name, but leaving the default domain name in place.
        .NOTES
            The context under which this script is run must have rights to pull infromation from ActiveDirectory.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-ADGroupMembers
    #>
    [CmdletBinding()]
    Param
        (
        [string]$UserGroup = "Managers",
        [string]$ADSPath = (([ADSI]"").distinguishedName)
        )
    Begin
    {
        if ($ADSPath -notmatch "LDAP://*")
        {
            $ADSPath = "LDAP://$($ADSPath)"
            }

        $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher

        $LDAPFilter = "(&(objectCategory=Group)(name=$($UserGroup)))"

        $DirectorySearcher.SearchRoot = $DirectoryEntry
        $DirectorySearcher.PageSize = 1000
        $DirectorySearcher.Filter = $LDAPFilter
        $DirectorySearcher.SearchScope = "Subtree"

        $SearchResult = $DirectorySearcher.FindAll()
            
        $UserAccounts = @()
        }
    Process
    {
        foreach ($Item in $SearchResult)
        {
            $Group = $Item.GetDirectoryEntry()
            $Members = $Group.member
                
            If ($Members -ne $Null)
            {
                foreach ($User in $Members)
                {
                    $UserObject = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($User)")
                    If ($UserObject.objectCategory.Value.Contains("Group"))
                    {
                        }
                    Else
                    {
                        $ThisUser = New-Object -TypeName PSObject -Property @{
                            cn = [string]$UserObject.cn
                            distinguishedName = [string]$UserObject.distinguishedName
                            name = [string]$UserObject.name
                            nTSecurityDescriptor = $UserObject.nTSecurityDescriptor
                            objectCategory = [string]$UserObject.objectCategory
                            objectClass = $UserObject.objectClass
                            objectGUID = $UserObject.objectGUID
                            objectSID = $UserObject.objectSID
                            showInAdvancedViewOnly = $UserObject.showInAdvancedViewOnly
                            }
                        }
                    $UserAccounts += $ThisUser
                    }
                }
            }
        }
    End
    {
        Return $UserAccounts
        }
    }
Function Get-StaleComputerAccounts
{
    <#
        .SYNOPSIS
            Return a collection of computer accounts older than a set number of days.
        .DESCRIPTION
            This function can be used to get a list of computer accounts within your Active Directory
            that are older than a certain number of days. Typically a computer account will renew it's
            own password every 90 days, so any account where the 'whenChanged' attribute is older than 
            90 would be considered old.
        .PARAMETER ADSPath
            This is an LDAP url that will become the base of your search.
        .PARAMETER DayOffset
            Am integer that represents the number of days in which an account is considered stale.
        .EXAMPLE
            Get-StaleComputerAccounts -ADSPath "LDAP://DC=company,DC=com" -DayOffset 90

            name                             adspath                          whenchanged
            ----                             -------                          -----------
            {desktop1}                       {LDAP://CN=desktop1,OU=Sales ... {11/17/2010 9:19:01 AM}
            {workstation}                    {LDAP://CN=workstation,OU=Ser... {2/10/2011 7:05:28 PM}
            {computer09}                     {LDAP://CN=computer09,OU=Admi... {10/25/2010 3:40:32 PM}
            {workstation01}                  {LDAP://CN=workstation01,OU=S... {6/2/2010 4:29:08 PM}

            Description
            -----------
            This is the typical usage from the command-line as well as sample output.
        .NOTES
            90 is a default value, when run in production you should use the number of days that you
            consider an account to be stale.
            The If statement that checks if adsPath contains OU=Servers is specifically for our production
            environment. All "servers", regardless of OS, are placed in the Servers OU in their respective 
            hierarchy. I treat server accounts slightly differently than I do workstations accounts, so I 
            wanted a way to differentiate the two.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-StaleComputerAccounts
    #>
    [CmdletBinding()]    
    Param
        (
        [string]$ADSPath = (([ADSI]"").distinguishedName),
        [int]$DayOffset = 90
        )
    Begin
    {
        if ($ADSPath -notmatch "LDAP://*")
        {
            $ADSPath = "LDAP://$($ADSPath)"
            }
            
        $DateOffset = (Get-Date).AddDays(-$DayOffset)
        [string]$SearchFilter = "(objectCategory=computer)"
        [array]$ADProperties= "name", "whenChanged", "whenCreated"

        $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
        $DirectorySearcher.SearchRoot = $DirectoryEntry
        $DirectorySearcher.PageSize = 1000
        $DirectorySearcher.Filter = $SearchFilter
        $DirectorySearcher.SearchScope = "Subtree"

        foreach ($Property in $ADProperties)
            {
                [void]$DirectorySearcher.PropertiesToLoad.Add($Property)
                }

        $ADObjects = $DirectorySearcher.FindAll()
        }
    Process
    {
        $StaleComputerAccounts = @()

        foreach ($ADObject in $ADObjects)
        {
            $WhenChanged = $ADObject.Properties.whenchanged
            $WhenCreated = $ADObject.Properties.whencreated
            if ($WhenChanged -lt $DateOffset -and $ADObject.Properties.adspath -notlike "*OU=Servers*")
            {
                $ThisComputer = New-Object PSObject -Property @{
                    name = [string]$ADObject.Properties.name
                    adspath = [string]$ADObject.Properties.adspath
                    whenchanged = [string]$WhenChanged
                    whencreated = [string]$WhenCreated
                    }
                $StaleComputerAccounts += $ThisComputer
                }
            }
        }    
    End
    {
        Return $StaleComputerAccounts
        }
    }
Function Set-AccountDisabled
{
    <#
        .SYNOPSIS
            Disable an account object in Active Directory
        .DESCRIPTION
            This function will disable an object in Active Directory, regardless of whether the object
            is a user or computer.
        .PARAMETER ADSPath
            The full LDAP URI of the object to disable.
        .EXAMPLE
            Set-AccountDisabled -ADSPath "LDAP://CN=Desktop-01,OU=Workstations,DC=Company,DC=com"
        .NOTES
            The context under which this function is run needs to have rights to modify the object in 
            Active Directory. The error I catch is specifically an Access is Denied message.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Set-AccountDisabled
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$ADSPath
        )
    Begin
    {
        $DisableComputer = [ADSI]$ADSPath
        }
    Process
    {
        Try
        {
            $DisableComputer.psbase.invokeset("AccountDisabled","True")
            $DisableComputer.psbase.CommitChanges()
            if ($? -eq $true)
            {
                $Result = New-Object -TypeName PSObject -Property @{
                    DisabledComputer = $DisabledComputer
                    Success = $?
                    }
                }
            }
        Catch
        {
            $Result = New-Object -TypeName PSObject -Property @{
                DisabledComputer = $DisabledComputer
                Success = $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        Return $Result
        }
    }
Function Reset-ComputerAccount
{
    <#
        .SYNOPSIS
            Reset computer account password
        .DESCRIPTION
            This function will reset the computer account password for a single computer
            or for an OU of computers.
        .PARAMETER ADSPath
            The ADSPath of the computer account, or containing OU.
        .EXAMPLE
            Reset-ComputerAccount -ADSPath "LDAP://CN=Desktop-PC01,OU=Workstations,DC=company,DC=com"
            
            Description
            -----------
            Example usage showing single computer account reset.
        .NOTES
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Reset-ComputerAccount
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [String]$ADSPath
        )
    Begin
    {
        $Computer = [ADSI]$ADSPath
        }
    Process
    {
        Try
        {
            $Computer.SetPassword($($Computer.name)+"$")
            if ($? -eq $true)
            {
                $Result = New-Object -TypeName PSObject -Property @{
                    Computer = $Computer
                    Success = $?
                    }
                }
            }
        Catch
        {
            $Result = New-Object -TypeName PSObject -Property @{
                Computer = $Computer
                Success = $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        Return $Result
        }
    }
Function Add-DomainGroupToLocalGroup
{
    <#
        .SYNOPSIS
            Add a Domain security group to a local computer group
        .DESCRIPTION
            This function will add a Domain security group to a local computer group.
        .PARAMETER ComputerName
            The NetBIOS name of the computer to update
        .PARAMETER DomainGroup
            The name of the Domain security group
        .PARAMETER LocalGroup
            The name of the local group to update, if not provided Administrators is assumed.
        .PARAMETER UserDomain
            The NetBIOS domain name.
        .EXAMPLE
            Add-DomainGroupToLocalGroup -ComputerName "Desktop-PC01" -DomainGroup "StudentAdmins" -UserDomain "COMPANY"
            
            Description
            ===========
            Showing the default syntax to add a student admin group to a local computer account.
        .NOTES
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Add-DomainGroupToLocalGroup
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$DomainGroup,
        [string]$LocalGroup="Administrators",
        [string]$UserDomain    
        )
    Begin
    {
        $ComputerObject = [ADSI]("WinNT://$($ComputerName),computer")
        }
    Process
    {
        Try
        {
            $GroupObject = $ComputerObject.PSBase.Children.Find("$($LocalGroup)")
            $GroupObject.Add("WinNT://$UserDomain/$DomainGroup")
            if ($? -eq $true)
            {
                $Result = New-Object -TypeName PSobject -Property @{
                    Computer = $ComputerName
                    DomainGroup = $DomainGroup
                    LocalGroup = $LocalGroup
                    Domain = $UserDomain
                    Result = $?
                    }
                }
            }
        Catch
        {
            $Result = New-Object -TypeName PSobject -Property @{
                Computer = $ComputerName
                DomainGroup = $DomainGroup
                LocalGroup = $LocalGroup
                Domain = $UserDomain
                Result = $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        Return $Result
        }
    }
Function Get-FSMORoleOwner 
{
    <#  
        .SYNOPSIS  
            Retrieves the list of FSMO role owners of a forest and domain  
        .DESCRIPTION  
            Retrieves the list of FSMO role owners of a forest and domain
        .PARMETER TargetDomain
            The FQDN of the domain to query on
        .NOTES  
            Name: Get-FSMORoleOwner
            Author: Boe Prox
            DateCreated: 06/9/2011  
        .EXAMPLE
            Get-FSMORoleOwner

            DomainNamingMaster  : dc1.rivendell.com
            Domain              : rivendell.com
            RIDOwner            : dc1.rivendell.com
            Forest              : rivendell.com
            InfrastructureOwner : dc1.rivendell.com
            SchemaMaster        : dc1.rivendell.com
            PDCOwner            : dc1.rivendell.com

            Description
            -----------
            Retrieves the FSMO role owners each domain in a forest. Also lists the domain and forest.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-FSMORoleOwner
    #>
    [CmdletBinding()]
    Param
        (
        [string]$TargetDomain = $env:userdnsdomain
        )
    Begin
    {
        $ForestContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Forest",$TargetDomain)
        $Forest = [system.directoryservices.activedirectory.Forest]::GetForest($ForestContext)
        }
    Process
    {
        Try 
        {
            ForEach ($domain in $forest.domains) 
            {
                $forestproperties = @{
                    Forest = $Forest.name
                    Domain = $domain.name
                    SchemaMaster = $forest.SchemaRoleOwner
                    DomainNamingMaster = $forest.NamingRoleOwner
                    RIDOwner = $Domain.RidRoleOwner
                    PDCOwner = $Domain.PdcRoleOwner
                    InfrastructureOwner = $Domain.InfrastructureRoleOwner
                    }
                $ForestObject = New-Object PSObject -Property $forestproperties
                $ForestObject.PSTypeNames.Insert(0,"ForestRoles")
                }
            }
        Catch 
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        Return $ForestObject
        }
    }
Function Convert-FspToUsername
{
    <#
        .SYNOPSIS
            Convert a FSP to a sAMAccountName
        .DESCRIPTION
            This function converts FSP's to sAMAccountName's.
        .PARAMETER UserSID
            This is the SID of the FSP in the form of S-1-5-20. These can be found
            in the ForeignSecurityPrincipals container of your domain.
        .EXAMPLE
            Convert-FspToUsername -UserSID "S-1-5-11","S-1-5-17","S-1-5-20"

            sAMAccountName                      Sid
            --------------                      ---
            NT AUTHORITY\Authenticated Users    S-1-5-11
            NT AUTHORITY\IUSR                   S-1-5-17
            NT AUTHORITY\NETWORK SERVICE        S-1-5-20

            Description
            ===========
            This example shows passing in multipe sids to the function
        .EXAMPLE
            Get-ADObjects -ADSPath "LDAP://CN=ForeignSecurityPrincipals,DC=company,DC=com" -SearchFilter "(objectClass=foreignSecurityPrincipal)" |
            foreach {$_.Properties.name} |Convert-FspToUsername

            sAMAccountName                      Sid
            --------------                      ---
            NT AUTHORITY\Authenticated Users    S-1-5-11
            NT AUTHORITY\IUSR                   S-1-5-17
            NT AUTHORITY\NETWORK SERVICE        S-1-5-20

            Description
            ===========
            This example takes the output of the Get-ADObjects function, and pipes it through foreach to get to the name
            property, and the resulting output is piped through Convert-FspToUsername.
        .NOTES
            This function currently expects a SID in the same format as you see being displayed
            as the name property of each object in the ForeignSecurityPrincipals container in your
            domain. 
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Convert-FspToUsername
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        $UserSID
        )
    Begin
    {
        }
    Process
    {
        foreach ($Sid in $UserSID)
        {
            try
            {
                $SAM = (New-Object System.Security.Principal.SecurityIdentifier($Sid)).Translate([System.Security.Principal.NTAccount])
                $Result = New-Object -TypeName PSObject -Property @{
                    Sid = $Sid
                    sAMAccountName = $SAM.Value
                    }
                Return $Result
                }
            catch
            {
                $Result = New-Object -TypeName PSObject -Property @{
                    Sid = $Sid
                    sAMAccountName = $Error[0].Exception.InnerException.Message.ToString().Trim()
                    }
                Return $Result
                }
            }
        }
    End
    {
        }
    }
Function Set-ComputerName
{
    <#
        .SYNOPSIS
            Change the name of the computer
        .DESCRIPTION
            This function will rename the local or optionally remote computer to the
            computername of your choice. In addition you can force the computer to
            reboot to finish the change.
        .PARAMETER NewName
            The new 15 character NetBIOS for the computer
        .PARAMETER ComputerName
            The NetBIOS name of the computer
        .PARAMETER Credentials
            Provide administrator credentials 
        .PARAMETER Reboot
            True to reboot
        .EXAMPLE
            Set-ComputerName -NewName 'Desktop-PC02' -ComputerName 'Desktop-PC01' -Reboot $True

            OldName : Desktop-PC01
            NewName : Desktop-PC02
            Reboot  : 0
            Success : 0

            Description
            -----------
            This example shows the basic usage on a local computer. The 0 indicates success, so
            the computer rebooted, and the name changed.
        .NOTES
            FunctionName : Set-ComputerName
            Created by   : Jeff Patton
            Date Coded   : 09/21/2011 10:59:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Set-ComputerName
    #>
    [CmdletBinding()]
    Param
        (
        [string]$NewName,
        [string]$ComputerName = (hostname),
        $Credentials = (Get-Credential),
        [boolean]$Reboot
        )
    Begin
    {
        if ($ComputerName -eq (hostname))
        {
            Write-Verbose "Using ComputerName as a switch to determine if we run wmi local or remote"
            try
            {
                Write-Verbose "Grab the Win32_ComputerSystem class, this holds the rename method"
                $ThisComputer = Get-WmiObject -Class Win32_ComputerSystem
                Write-Verbose "Grab the Win32_OperatingSystem class, this holds the reboot method"
                $RebootComputer = Get-WmiObject -Class Win32_OperatingSystem
                }
            catch
            {
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        else
        {
            try
            {
                Write-Verbose "Grab the Win32_ComputerSystem class, this holds the rename method"
                $ThisComputer = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName -Credential $Credentials -Authentication 6
                Write-Verbose "Grab the Win32_OperatingSystem class, this holds the reboot method"
                $RebootComputer = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -Credential $Credentials -Authentication 6
                }
            catch
            {
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    Process
    {
        try
        {
            if ($ComputerName -eq (hostname))
            {
                Write-Verbose "Renaming $($ComputerName) to $($NewName)"
                $RetVal = $ThisComputer.Rename($NewName)
                }
            else
            {
                Write-Verbose "Renaming remote $($ComputerName) to $($NewName) requires credentials."
                $RetVal = $ThisComputer.Rename($NewName,$Credentials.GetNetworkCredential().Password,$Credentials.UserName)
                }
            }
        catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        if ($Reboot -eq $true)
        {
            try
            {
                Write-Verbose "Rebooting $($ComputerName)"
                $Reboot = $RebotComputer.InvokeMethod("Win32Shutdown",0)
                }
            catch
            {
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        $ReturnObject = New-Object -TypeName PSObject -Property @{
            OldName = $ComputerName
            NewName = $NewName
            Reboot = $Reboot
            Success = $RetVal.ReturnValue
            }
        Return $ReturnObject
        }
    }
Function Get-DomainName
{
    <#
        .SYNOPSIS
            Get the FQDN of the domain from an LDAP Url
        .DESCRIPTION
            This function returns the FQDN of a domain based on the LDAP Url.
        .PARAMETER LdapUrl
            The LDAP URL for whatever object you need the FQDN for.
        .EXAMPLE
            Get-DomainName -LdapUrl 'LDAP://CN=UserAccount,OU=Employees,DC=company,DC=com'

            LdapUrl    : LDAP://CN=UserAccount,OU=Employees,DC=company,DC=com
            DomainName : company.com

            Description
            -----------
            This example shows the basic syntax of the commnand.
        .NOTES
            FunctionName : Get-DomainName
            Created by   : Jeff Patton
            Date Coded   : 09/22/2011 09:42:38
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-DomainName
    #>
    [CmdletBinding()]
    Param
        (
        $LdapUrl
        )
    Begin
    {
        if ($LdapUrl.GetType().Name -eq "String")
        {
            Write-Verbose "LDAP Url is a string"
            $tempUrl = $LdapURL.ToUpper()
            }
        elseif ($LdapUrl.GetType().Name -eq "DirectoryEntry")
        {
            Write-Verbose "LDAP Url is an directory object"
            $tempUrl = $LdapUrl.Path.ToString().ToUpper()
            }
        }
    Process
    {
        Write-Verbose "Finding the first DC= and replacing it with a dot."
        $DomainName = ($tempUrl.SubString($tempUrl.IndexOf(",DC=")+4)).Replace(",DC=",".")
        $RetVal = New-Object -TypeName PSObject -Property @{
            LdapUrl = $LdapUrl
            DomainName = $DomainName.ToLower()
            }
        }
    End
    {
        Return $RetVal
        }
    }
Function Get-UserGroupMembership
{
    <#
        .SYNOPSIS
            Get a list of groups as displayed on the user objects Member of tab
        .DESCRIPTION
            This function returns a listing of groups that the user is a direct
            member of. This is the same list that should appear in the Member Of
            tab in Active Directory Users and Computers.
        .PARAMETER UserDN
            The DistinguishedName of the user object
        .EXAMPLE
            Get-UserGroupMembership -UserDN "CN=useraccount,OU=employees,DC=company,DC=com"

            GroupDN
            -------
            CN=AdminStaff,OU=Groups,DC=company,DC=com
            CN=ServerAdmin,OU=Groups,DC=Company,DC=com

            Description
            -----------
            This shows the basic syntax of a user in the local domain.
        .EXAMPLE
            Get-UserGroupMembership -UserDN "CN=S-1-5-17,CN=ForeignSecurityPrincipals,DC=company,DC=com"

            GroupDN
            -------
            CN=IIS_IUSRS,CN=Builtin,DC=company,DC=com

            Description
            -----------
            This function also works against FSP's in your domain.
        .NOTES
            FunctionName : Get-UserGroupMembership
            Created by   : Jeff Patton
            Date Coded   : 09/22/2011 12:53:23

            This script runs in the context of the user and as such the user
            will need to have the requisite permissions to view the group membership
            of a given user object.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-UserGroupMembership
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        $UserDN
        )
    Begin
    {
        if ($UserDN -notmatch "LDAP://*")
        {
            $UserDN = "LDAP://$($UserDN)"
            }
        try
        {
            Write-Verbose "Attempting to connect to $($UserDN) to return a list of groups."
            $Groups = ([adsi]$UserDN).MemberOf
            }
        Catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    Process
    {
        if ($Groups)
        {
            Write-Verbose "Object has group membership."
            $GroupMembership = @()
            foreach ($Group in $Groups)
            {
                Write-Verbose "Adding $($Group) to the collection to return."
                $GroupEntry = New-Object -TypeName PSObject -Property @{
                    GroupDN = $Group
                    }
                $GroupMembership += $GroupEntry
                }
            }
        }
    End
    {
        Return $GroupMembership
        }
    }
Function Add-UserToGroup
{
    <#
        .SYNOPSIS
            Add a domain user to a domain group
        .DESCRIPTION
            This function adds a domain user account to a domain group.
        .PARAMETER GroupDN
            The distinguishedName of the group to add to
        .PARAMETER UserDN
            The distinguishedName of the user account to add
        .EXAMPLE
            Add-UserToGroup -GroupDN 'CN=AdminStaff,OU=Groups,DC=company,DC=com' -UserDN 'CN=UserAccount,OU=Employees,DC=company,DC=com'

            GroupDN : LDAP://CN=AdminStaff,OU=Groups,DC=company,DC=com
            UserDN  : LDAP://CN=UserAccount,OU=Employees,DC=company,DC=com
            Added   : True

            Description
            -----------
            This example shows the syntax of the command.
        .NOTES
            FunctionName : Add-UserToGroup
            Created by   : Jeff Patton
            Date Coded   : 09/22/2011 14:18:33
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Add-UserToGroup
    #>
    [CmdletBinding()]
    Param
        (
        $GroupDN,
        $UserDN
        )
    Begin
    {
        if ($GroupDN -notmatch "LDAP://*")
        {
            $GroupDN = "LDAP://$($GroupDN)"
            }
        if ($UserDN -notmatch "LDAP://*")
        {
            $UserDN = "LDAP://$($UserDN)"
            }
        }
    Process
    {
        try
        {
            ([adsi]$GroupDN).Add($UserDN)
            $RetVal = $?
            }
        catch
        {
            $RetVal = $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        $GroupUpdated = New-Object -TypeName PSObject -Property @{
            GroupDN = $GroupDN
            UserDN = $UserDN
            Added = $RetVal
            }
        Return $GroupUpdated
        }
    }
Function Set-ADObjectProperties
{
    <#
        .SYNOPSIS
            Set the properties of a given object in AD
        .DESCRIPTION
            This function will set the properties of a given object in AD. The
            function takes a comma seperated Propertyname, PropertyValue and sets
            the value of that property on the object.
        .PARAMETER ADObject
            The object within AD to be modified
        .PARAMETER PropertyPairs
            The PropertyName and PropertyValue to be set. This can be an array
            of values as such:
                "Description,UserAccount","Office,Building 1"
            The PropertyName should always be listed first, followed by the
            values of the property.
        .EXAMPLE
            Set-ADObjectProperties -ADObject 'LDAP://CN=UserAccount,CN=Users,DC=company,DC=com' -PropertyPairs "Description,New User Account"

            Description
            -----------
            This is the basic syntax of this function.
        .NOTES
            FunctionName : Set-ADObjectProperties
            Created by   : Jeff Patton
            Date Coded   : 09/23/2011 14:27:19
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Set-ADObjectProperties
    #>
    [CmdletBinding()]
    Param
        (
        $ADObject,
        $PropertyPairs
        )
    Begin
    {
        if ($ADObject -notmatch "LDAP://*")
        {
            $ADObject = "LDAP://$($UserDN)"
            }
        Write-Verbose "Storing the object as a Directory Entry so we can modify it."
        $ADObject = New-Object DirectoryServices.DirectoryEntry $ADObject
        }
    Process
    {
        Write-Verbose "Work through an array of 0 or more PropertyPairs."
        foreach ($PropertyPair in $PropertyPairs)
        {
            Write-Verbose "Split this PropertyPair on comma."
            $PropertyPair = $PropertyPair.Split(",")
            if ($PropertyPair.Count -eq 2)
            {
                Write-Verbose "Assign PropertyName to PropertyPair[0]"
                $PropertyName = $PropertyPair[0]
                Write-Verbose "Assign PropertyValue to PropertyPair[1]"
                $PropertyValue = $PropertyPair[1]

                Write-Verbose "Assign the property of the object, the value"
                $ADObject.Put($PropertyName,$PropertyValue)
                }
            elseif ($PropertyPair.Count -gt 2)
            {
                Write-Verbose "Multi-valued property detected"
                Write-Verbose "Assign PropertyName to PropertyPair[0]"
                $PropertyName = $PropertyPair[0]
                Write-Verbose "Assign remaining values to PropertyValues"
                $PropertyValues = $PropertyPair[1..(($PropertyPair.Count)-1)]

                Write-Verbose "Assign the property of the object, the values"
                $ADObject.PutEx(2,$PropertyName,$PropertyValues)
                }
            Write-Verbose "Save property changes to object"
            try
            {
                $ADObject.SetInfo()
                }
            catch
            {
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
        }
    End
    {
        }
    }
Function Get-GPO
{
    <#
        .SYNOPSIS
            Return a list of all GPO's in a domain.
        .DESCRIPTION
            This function returns a list of all GPO's in the specified domain.
        .PARAMETER Domain
            The FQDN of the domain to search
        .EXAMPLE
            Get-GPO

            DisplayName                 : Default Domain Policy
            Path                        : cn={31B2F340-016D-11D2-945F-00C04FB984F9},cn=policies,cn=system,DC=COMPANY,DC=COM
            ID                          : {31B2F340-016D-11D2-945F-00C04FB984F9}
            DomainName                  : COMPANY.COM
            CreationTime                : 9/1/2004 10:49:52 AM
            ModificationTime            : 6/14/2011 10:21:20 AM
            UserDSVersionNumber         : 33
            ComputerDSVersionNumber     : 255
            UserSysvolVersionNumber     : 33
            ComputerSysvolVersionNumber : 255
            Description                 :

            Description
            -----------
            This example shows the basic syntax of the command.
        .EXAMPLE
            Get-GPO -Domain COMPANY.NET

            DisplayName                 : Default Domain Policy
            Path                        : cn={31B2F340-016D-11D2-945F-00C04FB984F9},cn=policies,cn=system,DC=COMPANY,DC=NET
            ID                          : {31B2F340-016D-11D2-945F-00C04FB984F9}
            DomainName                  : COMPANY.NET
            CreationTime                : 9/1/2004 10:49:52 AM
            ModificationTime            : 6/14/2011 10:21:20 AM
            UserDSVersionNumber         : 33
            ComputerDSVersionNumber     : 255
            UserSysvolVersionNumber     : 33
            ComputerSysvolVersionNumber : 255
            Description                 :

            Description
            -----------
            This example shows using the domain parameter to specify an alternate domain.
        .NOTES
            FunctionName : Get-GPO
            Created by   : Jeff Patton
            Date Coded   : 03/13/2012 18:37:08

            You will need the Group Policy Managment console or RSAT installed.
        .LINK
            http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement#Get-GPO
        .LINK
            http://blogs.technet.com/b/grouppolicy/archive/2011/06/10/listing-all-gpos-in-the-current-forest.aspx
        .LINK
            http://www.microsoft.com/download/en/search.aspx?q=gpmc
        .LINK
            http://www.microsoft.com/download/en/search.aspx?q=remote%20server%20administration%20tools
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Domain = $env:userDNSdomain
        )
    Begin
    {
        Try
        {
            Write-Verbose "Instantiating GroupPolicy Management API"
            $GpoMgmt = New-Object -ComObject gpmgmt.gpm
            }
        catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    Process
    {
        try
        {
            $GpoConstants = $GpoMgmt.GetConstants()
            $GpoDomain = $GpoMgmt.GetDomain($Domain,$null,$GpoConstants.UseAnyDC)
            $GpoSearchCriteria = $GpoMgmt.CreateSearchCriteria()
            $GroupPolicyObjects = $GpoDomain.SearchGPOs($GpoSearchCriteria)
            }
        catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        Return $GroupPolicyObjects
        }
    }
Function Get-UnlinkedGPO
 {
    <#
        .SYNOPSIS
            Return a list of unlinked Group Policy Objects
        .DESCRIPTION
            This function will return a list of unlinked Group Policy Objects from
            the specified domain.
        .PARAMETER Domain
            The FQDN of the domain to search
        .EXAMPLE
            Get-UnlinkedGPO

            DisplayName                 : No Offline Files GPO
            Path                        : cn={7BE5802A-3A76-411E-B685-C2DE9A8DE8B9},cn=policies,cn=system,DC=COMPANY,DC=COM
            ID                          : {7BE5802A-3A76-411E-B685-C2DE9A8DE8B9}
            DomainName                  : COMPANY.COM
            CreationTime                : 11/2/2005 11:06:34 AM
            ModificationTime            : 6/14/2011 10:21:38 AM
            UserDSVersionNumber         : 0
            ComputerDSVersionNumber     : 14
            UserSysvolVersionNumber     : 0
            ComputerSysvolVersionNumber : 14
            Description                 :

            Description
            -----------
            This shows the basic syntax of the command.
        .EXAMPLE
            Get-UnlinkedGPO -Domain COMPANY.NET

            DisplayName                 : PartialPath
            Path                        : cn={D074F8A6-CA41-464F-96A6-9155C96B486B},cn=policies,cn=system,DC=COMPANY,DC=NET
            ID                          : {D074F8A6-CA41-464F-96A6-9155C96B486B}
            DomainName                  : COMPANY.NET
            CreationTime                : 1/11/2010 11:11:14 AM
            ModificationTime            : 6/14/2011 10:21:40 AM
            UserDSVersionNumber         : 0
            ComputerDSVersionNumber     : 4
            UserSysvolVersionNumber     : 0
            ComputerSysvolVersionNumber : 4
            Description                 :

            Description
            -----------
            This example shows using the domain parameter to specify an alternate domain.
        .NOTES
            FunctionName : Get-UnlinkedGPO
            Created by   : Jeff Patton
            Date Coded   : 03/13/2012 18:54:38

            You will need the Group Policy Management Console or RSAT installed
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-UnlinkedGPO
        .LINK
            http://blogs.technet.com/b/heyscriptingguy/archive/2009/02/10/how-can-get-a-list-of-all-my-orphaned-group-policy-objects.aspx
        .LINK
            http://www.microsoft.com/download/en/search.aspx?q=gpmc
        .LINK
            http://www.microsoft.com/download/en/search.aspx?q=remote%20server%20administration%20tools
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Domain = $env:userDNSdomain
        )
    Begin
    {
        Try
        {
            Write-Verbose "Instantiating GroupPolicy Management API"
            $GpoMgmt = New-Object -ComObject gpmgmt.gpm
            }
        catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        
        $unlinkedGPO = @()
        }
    Process
    {
        try
        {
            $GpoConstants = $GpoMgmt.GetConstants()
            $GpoDomain = $GpoMgmt.GetDomain($Domain,$null,$GpoConstants.UseAnyDC)
            $GpoSearchCriteria = $GpoMgmt.CreateSearchCriteria()
            $GroupPolicyObjects = $GpoDomain.SearchGPOs($GpoSearchCriteria)

            foreach ($GroupPolicyObject in $GroupPolicyObjects)
            {
                $GpoSearchCriteria = $GpoMgmt.CreateSearchCriteria()
                $GpoSearchCriteria.Add($GpoConstants.SearchPropertySomLinks, $GpoConstants.SearchOpContains, $GroupPolicyObject)
                $GpoSomLinks = $GpoDomain.SearchSoms($GpoSearchCriteria)
                if ($GpoSomLinks.Count -eq 0)
                {
                    $unlinkedGPO += $GroupPolicyObject
                    }
                }
            }
        catch
        {
            Return $Error[0].Exception.InnerException.Message.ToString().Trim()
            }
        }
    End
    {
        Return $unlinkedGPO
        }
    }