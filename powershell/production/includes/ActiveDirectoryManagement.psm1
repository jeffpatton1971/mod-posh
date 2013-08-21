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
        [ValidateSet("Base","OneLevel","Subtree")]
        [string]$SearchScope = "Subtree",
        [array]$ADProperties
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
            $DirectorySearcher.SearchScope = $SearchScope

            if ($ADProperties -ne $null)
            {
                foreach ($Property in $ADProperties)
                    {
                        [void]$DirectorySearcher.PropertiesToLoad.Add($Property)
                        }
                $ADObjects = @()
                foreach ($ADObject in $DirectorySearcher.FindAll())
                {
                    $objResult = New-Object -TypeName PSObject
                    foreach ($ADProperty in $ADProperties)
                    {
                        Add-Member -InputObject $objResult -MemberType NoteProperty -Name $ADProperty -Value $ADObject.Properties.($ADProperty.ToLower())
                        }
                    Add-Member -InputObject $objResult -MemberType NoteProperty -Name 'adsPath' -Value $ADObject.Properties.adspath
                    $ADObjects += $objResult
                    }
                }
            else
            {
                $ADObjects = $DirectorySearcher.FindAll()
                }
            }
        Catch
        {
            Return $Error[0].Exception
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
        [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$ComputerName,
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
        foreach ($Computer in $ComputerName)
        {
            Try
            {
                ([ADSI]"WinNT://$Computer/$LocalGroup,group").Add("WinNT://$UserDomain/$UserName")
                if ($? -eq $true)
                {
                    New-Object -TypeName PSObject -Property @{
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
                New-Object -TypeName PSObject -Property @{
                    Computer = $Computer
                    Group = $LocalGroup
                    Domain = $UserDomain
                    User = $UserName
                    Success = $Error[0].Exception.InnerException.Message.ToString().Trim()
                    }
                }
            }
        }
    End
    {
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
        [string]$TargetDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
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
        .PARAMETER GpoID
            The GUID of the GPO you are looking for.
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
        .EXAMPLE
            Get-GPO -GpoID '31B2F340-016D-11D2-945F-00C04FB984F9'

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
            This example shows passing the GUID of a gpo into the function.
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
        [string]$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name,
        [string]$GpoID
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
        $GpoGuid = "{$($GpoID.Replace('{','').Replace('}',''))}"
        }
    Process
    {
        try
        {
            $GpoConstants = $GpoMgmt.GetConstants()
            $GpoDomain = $GpoMgmt.GetDomain($Domain,$null,$GpoConstants.UseAnyDC)
            $GpoSearchCriteria = $GpoMgmt.CreateSearchCriteria()
            if ($GpoID)
            {
                $GpoSearchCriteria.Add($GpoConstants.SearchPropertyGPOID, $GpoConstants.SearchOpEquals, $GpoGuid)
                }
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
        [string]$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
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
Function Get-DomainInfo
{
    <#
        .SYNOPSIS
            Get basic information about the current domain
        .DESCRIPTION
            Get basic information about the current domain, or from an external domain
            that you have rights to by setting TargetDomain to it's FQDN.
        .PARAMETER TargetDomain
            The FQDN of the domain to return information from.
        .EXAMPLE
            Get-DomainInfo

            Forest                  : company.com
            DomainControllers       : {dc1.company.com,dc2.company.com}
            Children                : {}
            DomainMode              : Windows2003Domain
            Parent                  : 
            PdcRoleOwner            : dc1.company.com
            RidRoleOwner            : dc1.company.com
            InfrastructureRoleOwner : dc1.company.com
            Name                    : company.com
            
            Description
            -----------
            Show the basic syntax of the command.
        .NOTES
            FunctionName : Get-DomainInfo
            Created by   : jspatton
            Date Coded   : 03/14/2012 15:56:20
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-DomainInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string]$TargetDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
        )
    Begin
    {
        $ContextType = "Domain"
        Write-Verbose "Creating the Domain context to pass to the GetDomain method"
        $DomainContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($ContextType,$TargetDomain)
        }
    Process
    {
        Write-Verbose "Call GetDomain to return information aobut the specified TargetDomain: $($TargetDomain)"
        $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
        }
    End
    {
        Return $Domain
        }
    }
Function Get-ForestInfo
{
    <#
        .SYNOPSIS
            Get basic information aobut the current forest.
        .DESCRIPTION
            Get basic information about the current forest, or from an external domain
            that you have rights to by setting TargetDomain to it's FQDN.
        .PARAMETER TargetDomain
            The FQDN of the domain to return information from.
        .EXAMPLE
            Get-ForestInfo

            Name                  : company.com
            Sites                 : 
            Domains               : {company.com}
            GlobalCatalogs        : {dc1.company.com}
            ApplicationPartitions : {DC=DomainDnsZones,DC=company,DC=com, DC=ForestDnsZones,DC=company,DC=com}
            ForestMode            : Windows2003Forest
            RootDomain            : company.com
            Schema                : CN=Schema,CN=Configuration,DC=company,DC=com
            SchemaRoleOwner       : dc1.company.com
            NamingRoleOwner       : dc1.company.com
            
            Description
            -----------
            Show the basic syntax of the command.
        .NOTES
            FunctionName : Get-ForestInfo
            Created by   : jspatton
            Date Coded   : 03/14/2012 15:56:29
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-ForestInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string]$TargetDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
        )
    Begin
    {
        $ContextType = "Forest"
        Write-Verbose "Creating the Forest context to pass to the GetForest method"
        $ForestContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($ContextType,$TargetDomain)
        }
    Process
    {
        Write-Verbose "Call GetForest to return information aobut the specified TargetDomain: $($TargetDomain)"
        $Forest = [system.directoryservices.activedirectory.Forest]::GetForest($ForestContext) 
        }
    End
    {
        Return $Forest
        }
    }
Function ConvertFrom-Sid
{
    <#
        .SYNOPSIS
            Convert a Sid byte array to a string
        .DESCRIPTION
            This function takes the Sid as a byte array and returns it as an
            object that has the Sid as a string.
        .PARAMETER ObjectSid
            This is a Sid object, these are usually stored in a binary form inside 
            the object in Active Directory. When displayed they typically appear to
            be a column of numbers like this:

                1
                5
                0
                0
                0
                0
                0
                5
                21
                0
                0
                0
                209
                218
                116
                3
                253
                55
                66
                64
                130
                139
                166
                40
                196
                109
                2
                0
                0
            This is converted to an object of type System.Security.Principal.IdentityReference.
        .EXAMPLE
            ConvertFrom-Sid -ObjectSid $Sid
            
            BinaryLength AccountDomainSid                       Value                                        
            ------------ ----------------                       -----                                        
                      28 S-1-5-21-57989841-1078081533-682003330 S-1-5-21-57989841-1078081533-682003330-159172

            Description
            -----------
            This is the basic syntax of the command and shows the default output.
            
        .EXAMPLE
            (ConvertFrom-Sid -ObjectSid $Computer.objectSid).Value

            S-1-5-21-57989841-1078081533-682003330-159172
            
            Description
            -----------
            This example shows how to display just the Sid as a string.

        .NOTES
            FunctionName : ConvertFrom-Sid
            Created by   : jspatton
            Date Coded   : 06/26/2012 09:41:02
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertFrom-Sid
    #>
    [CmdletBinding()]
    Param
        (
        $ObjectSid        
        )
    Begin
    {
        $ErrorActionPreference = 'Stop'
        }
    Process
    {
        try
        {
            $Sid = New-Object System.Security.Principal.SecurityIdentifier($ObjectSid[0],0)
            Return $Sid
            }
        catch
        {
            $Message = $Error[0].Exception
            Return $Message
            }
        }
    End
    {
        }
    }
Function ConvertTo-Sid
{
    <#
        .SYNOPSIS
            Convert a string Sid back to a byte array
        .DESCRIPTION
            This function takes the Sid as a string and converts it back to a byte array
            that can be used by other functions which may be looking for the Sid as
            a byte.
        .PARAMETER StringSid
            A string representation of a Sid object, for example:
            
                S-1-5-21-57989841-1078081533-682003330
        .EXAMPLE
            ConvertTo-Sid -StringSid S-1-5-21-57989841-1078081533-682003330
            
            1
            4
            0
            0
            0
            0
            0
            5
            21
            0
            0
            0
            209
            218
            116
            3
            253
            55
            66
            64
            130
            139
            166
            40

            Description
            -----------
            
        .NOTES
            FunctionName : ConvertTo-Sid
            Created by   : jspatton
            Date Coded   : 06/26/2012 09:41:06
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Sid
    #>
    [CmdletBinding()]
    Param
        (
        [string]$StringSid
        )
    Begin
    {
        $ErrorActionPreference = 'Stop'
        }
    Process
    {
        try
        {
            $Sid = New-Object System.Security.Principal.SecurityIdentifier($StringSid)
            [byte[]]$ObjectSid = ,0 * $Sid.BinaryLength
            $Sid.GetBinaryForm($ObjectSid,0)
            Return $ObjectSid
            }
        catch
        {
            $Message = $Error[0].Exception
            Return $Message
            }
        }
    End
    {
        }
    }
Function ConvertTo-Accountname
{
    <#
        .SYNOPSIS
            Return the accountname from the SID
        .DESCRIPTION
            This function returns the accountname from the underlying SID of an object
            in Active Directory.
        .PARAMETER ObjectSid
            This needs to ne a security principal object
        .EXAMPLE
            ConvertTo-Accountname -ObjectSID (ConvertFrom-Sid -ObjectSid $me.objectsid)

            Value
            -----
            HOME\jspatton
            
            Description
            -----------
            This example shows how to use the function to convert a security principal object
            to the underlying account name.
        .NOTES
            FunctionName : ConvertTo-Accountname
            Created by   : jspatton
            Date Coded   : 06/26/2012 14:24:49
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Accountname
    #>
    [CmdletBinding()]
    Param
        (
        [System.Security.Principal.IdentityReference]$ObjectSid
        )
    Begin
    {
        $ErrorActionPreference = 'Stop'
        }
    Process
    {
        try
        {
            $AccountName = $ObjectSid.Translate([System.Security.Principal.NTAccount])
            Return $AccountName
            }
        catch
        {
            $Message = $Error[0].Exception
            Return $Message
            }
        }
    End
    {
        }
    }
Function Get-Fqdn
{
    <#
        .SYNOPSIS
            A simple function to return the FQDN from a distinguishedName
        .DESCRIPTION
            This function converts the distinguishedName into a proper
            FQDN (Fully Qualified Domain Name).
        .PARAMETER DistinguishedName
            A proper dn, for example:
                DC=Company,DC=com
        .EXAMPLE
            Get-Fqdn -DistinguishedName 'DC=Company,DC=com'
            Company.com
            
            Description
            -----------
            This is the only syntax for this command.
        .NOTES
            FunctionName : Get-Fqdn
            Created by   : jspatton
            Date Coded   : 06/29/2012 16:32:23
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-Fqdn
    #>
    [CmdletBinding()]
    Param
        (
        [string]$DistinguishedName = ([adsi]"").DistinguishedName
        )
    Begin
    {
        }
    Process
    {
        $DnPart = $DistinguishedName.Split(',')
        foreach ($Attrib in $DnPart)
        {
            if ($Counter -ne ($DnPart.Count) -1)
            {
                $Fqdn += $Attrib.Substring(3,$Attrib.Length -3) + '.'
                }
            else
            {
                $Fqdn += $Attrib.Substring(3,$Attrib.Length -3)
                }
            $Counter += 1
            }
        }
    End
    {
        Return $Fqdn
        }
    }
Function ConvertTo-Rfc1779
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Rfc1779
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:06:10
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Rfc1779
        .LINK
            http://msdn.microsoft.com/en-us/library/aa706049(v=vs.85)
        .LINK
            http://msdn.microsoft.com/en-us/library/aa772267(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 1

        if ($Name.IndexOf('cn=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_1779 = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_1779
        }
    }
Function ConvertTo-Canonical
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Canonical
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:57:11
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Canonical
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 2

        if ($Name.IndexOf('dc=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_CANONICAL = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_CANONICAL
        }
    }
Function ConvertTo-Nt4
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Nt4
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:57:30
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Nt4
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 3

        if ($Name.IndexOf('cn=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_NT4 = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_NT4
        }
    }
Function ConvertTo-Upn
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Upn
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:58:06
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Upn
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 9

        if ($Name.IndexOf('cn=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_USER_PRINCIPAL_NAME = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_USER_PRINCIPAL_NAME
        }
    }
Function ConvertTo-Guid
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Guid
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:58:46
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Guid
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 7

        if ($Name.IndexOf('cn=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_GUID = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_GUID
        }
    }
Function ConvertTo-Display
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : ConvertTo-Display
            Created by   : jspatton
            Date Coded   : 07/24/2012 16:58:55
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#ConvertTo-Display
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet(1,2,3)]
        [int]$InitType = 3,
        [string]$ConnectionObject
        )
    Begin
    {
        $AdsNameType = 4
        $ReturnType = 4

        if ($Name.IndexOf('cn=') -ne -1){$AdsNameType = 1}
        if ($Name.IndexOf('/') -ne -1){$AdsNameType = 2}
        if ($Name.IndexOf('\') -ne -1){$AdsNameType = 3}
        if ($Name.IndexOf('@') -ne -1){$AdsNameType = 5}
        if ($Name.IndexOf('{') -ne -1){$AdsNameType = 7}

        if (($InitType -eq 1) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to domain'
            $ConnectionObject = ([adsi]"").Name
            }
        if (($InitType -eq 2) -and ($ConnectionObject -eq ""))
        {
            Write-Host 'setting connectionobject to dc'
            $Forest = [system.directoryservices.activedirectory.forest]::GetCurrentForest()
            $ConnectionObject = $Forest.SchemaRoleOwner.Name
            }
        if ($InitType -eq 3){$ConnectionObject = $null}
        }
    Process
    {
        $NameTranslate = New-Object -ComObject NameTranslate
        $type = $NameTranslate.GetType()
        $type.InvokeMember("Init","InvokeMethod",$null,$NameTranslate,($InitType,$ConnectionObject))
        $type.InvokeMember("Set","InvokeMethod",$null,$NameTranslate,($AdsNameType, $Name))
        try
        {
            $NameTranslated = $type.InvokeMember("Get","InvokeMethod",$null,$NameTranslate,$ReturnType)
            $ADS_NAME_TYPE_DISPLAY = New-Object -TypeName PSObject -Property @{
                Name = $Name
                ADS_NAME_TYPE = $AdsNameType
                Value = $NameTranslated
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Return $ADS_NAME_TYPE_DISPLAY
        }
    }
Function Get-GpoLink
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-GpoLink
            Created by   : jspatton
            Date Coded   : 08/20/2012 14:44:26
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-GpoLink
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Gpo,
        [switch]$Path
        )
    Begin
    {
        $AdsPath = "LDAP://"+([adsi]"").distinguishedName
        if ($Path)
        {
            if ($Gpo -notmatch "LDAP://*")
            {
                $SearchFilter = "(gPlink=[LDAP://$($GPO);0])"
                }
            else
            {
                $SearchFilter = "(gPlink=[$($GPO);0])"
                }
            }
        else
        {
            $SearchFilter = "(gplink=[*$($Gpo)*;0])"
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
            
            $GpoLink = $DirectorySearcher.FindAll()
            }
        catch
        {
            }

        }
    End
    {
        Return $GpoLink
        }
    }
Function Get-NetlogonLog
{
    <#
        .SYNOPSIS
            Parse the netlogon.log file
        .DESCRIPTION
            This function will read in the netlogon.log file and return a properly 
            formatted object. A regex is used to split up each line of the file and
            build fields for the returned output.

            Some entries in the log will have an octal code, this code if found is 
            processed and a definition is returned as part of the object.
        .PARAMETER Logpath
            The path to where netlogon.log can be found, this is set to the default
            location

            C:\Windows\Debug\netlogon.log
        .PARAMETER DebugLog
            This switch if present directs the script to parse the debug version of
            the log as opposed to what normally shows up in the log.
        .EXAMPLE
            Get-NetlogonLog
            Date  Time     Message         Computer        Address
            ----  ----     -------         --------        -------
            10/13 15:08:30 NO_CLIENT_SITE: EBL2006         169.147.3.25
            10/13 15:38:30 NO_CLIENT_SITE: EBL2006         169.147.3.25
            10/13 16:08:30 NO_CLIENT_SITE: EBL2006         169.147.3.25

            Description
            -----------
            This example shows the basic syntax of the command when parsing a regular
            log file.
        .EXAMPLE
            Get-NetlogonLog -DebugLog

            Date  Time     Type  Message                                                                                                                                           
            ----  ----     ----  -------                                                                                                                                           
            11/08 12:23:01 LOGON HOME: NlPickDomainWithAccount: WORKGROUP\Administrator:...
            11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...
            11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...
            11/08 12:23:01 LOGON HOME: NlPickDomainWithAccount: WORKGROUP\Administrator:...
            11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...

            Description
            -----------
            This example shows using the command with the DebugLog switch to parse
            the debug version of the netlogon.log file.
        .NOTES
            FunctionName : Get-NetlogonLog
            Created by   : jspatton
            Date Coded   : 11/08/2012 15:24:47

            You will need to be at an elevated prompt in order for this to work properly.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Get-NetlogonLog
    #>
    [CmdletBinding()]
    Param
        (
        [string]$LogPath = "C:\Windows\Debug\netlogon.log",
        [switch]$DebugLog
        )
    Begin
    {
        $Codes = @{
            "0x0"="Successful Login"
            "0xC0000064"="The specified user does not exist"
            "0xC000006A"="The value provided as the current password is not correct"
            "0xC000006C"="Password policy not met"
            "0xC000006D"="The attempted logon is invalid due to bad user name"
            "0xC000006E"="User account restriction has prevented successful login"
            "0xC000006F"="The user account has time restrictions and may not be logged onto at this time"
            "0xC0000070"="The user is restricted and may not log on from the source workstation"
            "0xC0000071"="The user account's password has expired"
            "0xC0000072"="The user account is currently disabled"
            "0xC000009A"="Insufficient system resources"
            "0xC0000193"="The user's account has expired"
            "0xC0000224"="User must change his password before he logs on the first time"
            "0xC0000234"="The user account has been automatically locked"
            }

        if ($DebugLog)
        {
            [regex]$regex = "^(?<Date>\d{1,2}/\d{1,2})\s{1}(?<Time>\d{1,2}:\d{1,2}:\d{1,2})\s{1}(?<Type>\[[A-Z]*\])\s{1}(?<Message>.*)"
            [regex]$Code = "(?<Code>(\d{1}[x]\d{1})|(\d{1}[x]{1}[C]{1}\d{1,}))"
            }
        else
        {
            [regex]$regex = "^(?<Date>\d{1,2}/\d{1,2})\s{1}(?<Time>\d{1,2}:\d{1,2}:\d{1,2})\s{1}(?<Message>.*[:])\s{1}(?<Computer>[-a-zA-Z0-9_']{1,15})\s{1}(?<Address>(?:\d{1,3}\.){3}\d{1,3})"
            }        $Object = @()
        }
    Process
    {
        foreach ($Line in (Get-Content $LogPath))
        {
            Write-Verbose "Parse each line of the file to build object"
            $Line -match $regex |Out-Null
            if ($DebugLog)
            {
                $Item = New-Object -TypeName psobject -Property @{
                    Date = $Matches.Date
                    Time = $Matches.Time
                    Type = $Matches.Type.Replace('[','').Replace(']','')
                    Message = $Matches.Message
                    }

                Write-Verbose "Check to see if the Message contains a code"
                $Item.Message -match $Code |Out-Null
                if ($Matches.Code)
                {
                    Write-Verbose "Code found, adding definition to message"
                    $Item.Message += " : $($Codes.Item($Matches.Code))"
                    }
                $Object += $Item |Select-Object -Property Date, Time, Type, Message
                }
            else
            {
                $Item = New-Object -TypeName psobject -Property @{
                    Date = $Matches.Date
                    Time = $Matches.Time
                    Message = $Matches.Message.Replace(':','')
                    Computer = $Matches.Computer
                    Address = $Matches.Address
                    }
                $Object += $Item |Select-Object -Property Date, Time, Message, Computer, Address
                }
            }
        }
    End
    {
        Write-Verbose "Returning parse logfile"
        Return $Object
        }
    }
Function Set-NetlogonDebugging
{
    <#
        .SYNOPSIS
            This function enables/disables debugging on the netlogon service
        .DESCRIPTION
            This function enables/disables debugging on the netlogon service when passed the
            Enable switch. When not present this has the effect of turning off debugging.

            Please see the support article under the related links section.
        .PARAMETER Enable
            This parameter if present will enable debugging.
        .EXAMPLE
            Set-NetlogonDebugging -Enable

            Description
            -----------
            This example shows how to turn on debugging.
        .EXAMPLE
            Set-NetlogonDebugging

            Description
            -----------
            This example shows how to turn off debugging.
        .NOTES
            FunctionName : Set-NetlogonDebugging
            Created by   : jspatton
            Date Coded   : 11/08/2012 15:51:51

            You may need to run this from an elevated prompt.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Set-NetlogonDebugging
        .LINK
            http://support.microsoft.com/kb/109626
    #>
    [CmdletBinding()]
    Param
         (
         [switch]$Enable
         )
    Begin
    {
        }
    Process
    {
        try
        {
            if ($Enable)
            {
                Write-Verbose "Running : nltest /dbflag:0x2080ffff"
                (& nltest /dbflag:0x2080ffff)
                Restart-Service -Name netlogon -Force
                }
            else
            {
                Write-Verbose "Running : nltest /dbflag:0x0"
                (& nltest /dbflag:0x0)
                Restart-Service -Name netlogon -Force
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        }
    }
Function Enable-OUProtectedMode
{
    <#
        .SYNOPSIS
            Turn on the protect object from accidental deletion bit
        .DESCRIPTION
            This function will accept one or more ldap OU path's from the pipline and set its and its
            childrens accidental deletetion bit to on. It does this by setting the Delete and Deletetree
            right to Deny for the group Everyone.

            The end result is that you should see once this function runs, that the checkbox on the object
            property page for the OU is checked for, protect this object from accidental deletion.

            This function will only set security for the ou passed in and any of its child ou's. It will 
            not recurse through tree.
        .PARAMETER OU
            This is one or more paths in the form of LDAP://OU=Servers,DC=company,DC=com, if LDAP:// is not
            specified in the path it is added, if it is sent in lowercase it is upper cased so the 
            function will work properly.
        .EXAMPLE
            "LDAP://OU=Servers,DC=company,DC=com","OU=Workstations,DC=company,DC=com" |Enable-OUProtectedMode

            Description
            -----------
            This example shows how to pass in multiple OU's on the pipeline.
        .NOTES
            FunctionName : Enable-OUProtectedMode
            Created by   : jspatton
            Date Coded   : 08/21/2013 14:17:46
        .LINK
            https://code.google.com/p/mod-posh/wiki/ActiveDirectoryManagement#Enable-OUProtectedMode
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$OU
        )
    Begin
    {
        $Deny = [System.Security.AccessControl.AccessControlType]::Deny
        $Delete = [System.DirectoryServices.ActiveDirectoryRights]::Delete
        $DeleteTree = [System.DirectoryServices.ActiveDirectoryRights]::DeleteTree

        $Everyone = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList "", "Everyone"
        }
    Process
    {
        try
        {
            if ($OU -notmatch "LDAP://*")
            {
                $OU = "LDAP://$($OU)"
                }
            $ldapUrl = $OU.ToString().ToUpper()
        
            $ldapPath = [ADSI]$ldapUrl
            $Security = $ldapPath.psbase.ObjectSecurity

            $DeleteRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList $Everyone, $Delete, $Deny
            $Security.AddAccessRule($DeleteRule)
            $ldapPath.CommitChanges()

            $DeleteTreeRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList $Everyone, $DeleteTree, $Deny
            $Security.AddAccessRule($DeleteTreeRule)
            $ldapPath.CommitChanges()

            foreach ($ChildOU in $ldapPath.Children)
            {
                $ChildSecurity = $ChildOU.psbase.ObjectSecurity

                $ChildSecurity.AddAccessRule($DeleteRule)
                $ChildOU.CommitChanges()

                $ChildSecurity.AddAccessRule($DeleteTreeRule)
                $ChildOU.CommitChanges()
                }
            }
        catch
        {
            $MyError = $Error[0]
            }
        }
    End
    {
        if ($MyError)
        {
            Write-Error $MyError
            return
            }
        }
    }

Export-ModuleMember *