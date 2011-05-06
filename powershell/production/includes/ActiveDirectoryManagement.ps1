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
				http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement#Get-ADObjects
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ADSPath,
				[string]$SearchFilter = "(objectCategory=computer)",
				[array]$ADProperties="name"
			)
		
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

		Return $ADObjects
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
				http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement#Add-UserToLocalGroup
		#>
		
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
		if ($UserDomain -eq $null)
			{
				$UserDomain = [string]([ADSI] "").name
			}
		([ADSI]"WinNT://$Computer/$LocalGroup,group").Add("WinNT://$UserDomain/$UserName")
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
				http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement#Get-LocalGroupMembers
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ComputerName,
				[Parameter(Mandatory=$true)]
				[string]$GroupName
			)
			
			$empty = Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue -ErrorVariable err
			
			If ($err -ne $null)
				{
					#	$ComputerName offline
				}
			Else
				{
					#	$ComputerName online
					$Group = [ADSI]("WinNT://$ComputerName/$GroupName,group")
					
					$Members = @()  
					$Group.Members() |  
						% {  
							$AdsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)
							$AccountArray = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries)
							$AccountName = $AccountArray[-1]
							$AccountDomain = $AccountArray[-2]
							$AccountClass = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
							
							$Member = New-Object PSObject  
							$Member | Add-Member -MemberType NoteProperty -Name "Name" -Value $AccountName  
							$Member | Add-Member -MemberType NoteProperty -Name "Domain" -Value $AccountDomain  
							$Member | Add-Member -MemberType NoteProperty -Name "Class" -Value $AccountClass  

							$Members += $Member  
						}
				}
		Return $Members
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
        .PARAMETER UserDomain
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
            http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement#Get-ADGroupMembers
    #>
    Param
        (
    $UserGroup = "Domain Users",
    $UserDomain = ([ADSI]"LDAP://DC=company,DC=com")
        )

    Begin
        {
            $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($UserDomain.Path)
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
                                cn = $UserObject.cn
                                distinguishedName = $UserObject.distinguishedName
                                name = $UserObject.name
                                nTSecurityDescriptor = $UserObject.nTSecurityDescriptor
                                objectCategory = $UserObject.objectCategory
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