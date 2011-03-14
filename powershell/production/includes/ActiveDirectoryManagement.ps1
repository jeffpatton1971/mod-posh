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
