Function Get-ADObjects
	{
	<#
		.SYNOPSIS
			Returns a list of objects from ActiveDirectory
		.DESCRIPTION
			This function will return a list of objects from ActiveDirectory. It will
			start at the provided ADSPath and search for objectCategory. For each
			objectCategory it finds it stores the ADProperty that was requested.
		.PARAMETER objOU
			This is the LDAP URI of the location within ActiveDirectory you would like to
			search. This can be an OU, CN or even the root of your domain.
		.PARAMETER objectCategory
			This is the kind of object that you would like the search to return. Typical
			values are; computer (default), user and group.
		.PARAMETER ADProperty
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
			http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement
	#>	
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$objOU,
				[string]$objectCategory="computer",
				[array]$ADProperty="name"
			)
		
		$objSearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$objOU)
		$objSearcher.SearchScope = "subtree"
		$objSearcher.PageSize = 1000
		$objSearcher.Filter = ("(objectCategory=$objectCategory)")
		foreach ($i in $ADProperty)
			{
				[void]$objSearcher.PropertiesToLoad.Add($i)
			}
		$objSearcher.FindAll()
	}	
