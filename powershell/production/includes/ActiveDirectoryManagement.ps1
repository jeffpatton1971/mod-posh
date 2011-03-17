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
				http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement
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
				[string]$UserDomain = ([ADSI] "").name
			}
		([ADSI]"WinNT://$Computer/$LocalGroup,group").Add("WinNT://$UserDomain/$UserName")
	}
Function Get-LocalGroupMembers
	{
		<#
			.SYNOPSIS
				Return a list of user accounts that are in a specified group.
			.DESCRIPTION
				Return a list of user accounts that are in a specified group.
			.PARAMETER ComputerName
				The name of the computer to connect to.
			.PARAMETER GroupName
				The name of the group to search in.
			.NOTES
			.EXAMPLE
				Get-LocalGroupMembers MyComputer Administrators
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/ActiveDirectoryManagement
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ComputerName,
				[Parameter(Mandatory=$true)]
				[string]$GroupName
			)
		$Computer = [ADSI]("WinNT://$ComputerName, computer")
		$Group = $Computer.PSBase.Children.Find($GroupName)
		
		$Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
	}