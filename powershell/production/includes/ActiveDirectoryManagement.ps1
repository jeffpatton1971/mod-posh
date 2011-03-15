#
#	Active Directory Functions
#
#	Function Get-ADObjects:
#		Returns a list of objects from ActiveDirectory.
#		$ADProperty is a list of properties you want returned
#			and is accessible via .properties.propertyName
#
Function Get-ADObjects($objOU, $objectCategory, $ADProperty)
	{
	<#
		.SYNOPSIS
		Returns a list of objects from ActiveDirectory
		.DESCRIPTION
		This function will return a list of objects from ActiveDirectory. It will
		start at the provided ADSPath and search for objectCategory. For each
		objectCategory it finds it stores the ADProperty that was requested.
		.EXAMPLE
		get-adobjects "LDAP://OU=Workstations,DC=company,DC=com" computer name
		.EXAMPLE
		get-adobjects "LDAP://CN=Users,DC=company,DC=com" user distinguishedName
		.LINK
		http://scripts.patton-tech.com/
	#>	
		if($objOU -eq $Null) 
			{
				$objOU = ""
			}		
		$objSearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$objOU)
		$objSearcher.SearchScope = "subtree"
		$objSearcher.PageSize = 1000
		$objSearcher.Filter = ("(objectCategory=$objectCategory)")	
		foreach ($i in $ADProperty)
			{
				$objSearcher.PropertiesToLoad.Add($i)
			}
		$objSearcher.FindAll()
	}	
