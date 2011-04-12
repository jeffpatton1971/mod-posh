Function Get-ADObjects
	{
		<#
			.SYNOPSIS
				Returns a list of objects from ActiveDirectory
			.DESCRIPTION
				This function will return a list of objects from ActiveDirectory. It will
				start at the provided ADSPath and search for objectCategory. For each
				objectCategory it finds it stores the ADProperty that was requested.
			.PARAMETER ADSPath
				This is the LDAP URI of the location within ActiveDirectory you would like to
				search. This can be an OU, CN or even the root of your domain.
			.PARAMETER objectCategory
				This is the kind of object that you would like the search to return. Typical
				values are; computer (default), user and group.
			.PARAMETER ADProperties
				If you want specific properties returned like name, or distinguishedName 
				provide a comma seperated list.
			.EXAMPLE
				This exmaple returns a list of computers found in this OU
				get-adobjects "LDAP://OU=Workstations,DC=company,DC=com"
			.EXAMPLE
				This example returns a list of user in this container
				get-adobjects "LDAP://CN=Users,DC=company,DC=com" user distinguishedName
			.EXAMPLE
				This example returns the objectSid of the named computer
				get-adobjects "LDAP://CN=MyComputer,OU=Workstations,DC=company,DC=com" computer objectSid
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
				[string]$objectCategory,
				[array]$ADProperties="name"
			)
            
        Switch ($objectCategory)
            {
                computer
                    {
                        $objectCategory = "(&(objectCategory=computer))"
                    }
                user
                    {
                        $objectCategory = "(&(objectCategory=user))"
                    }
                group
                    {
                        "(&(objectCategory=group))"
                    }
                default
                    {
                        $objectCategory = "(&(objectCategory=computer))"
                    }                
            }
		
        $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
        $DirectorySearcher.SearchRoot = $DirectoryEntry
        $DirectorySearcher.PageSize = 1000
        $DirectorySearcher.Filter = $objectCategory
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
				add-usertolocalgroup server myuser administrators
			.EXAMPLE
				add-usertolocalgroup server myuser administrators company
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
				Get-LocalGroupMembers MyComputer Administrators
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