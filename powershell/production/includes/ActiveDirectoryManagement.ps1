#
#	Active Directory Functions
#
#	Function QueryAD:
#		Returns a list of objects from ActiveDirectory
#
Function QueryAD($objectCategory, $ADProperty)
	{
		$objDomain = New-Object System.DirectoryServices.DirectoryEntry
		$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
		$objSearcher.SearchRoot = $objDomain
		$objSearcher.Filter = ("(objectCategory=$objectCategory)")
		
		foreach ($i in $ADProperty){$objSearcher.PropertiesToLoad.Add($i)}
		
		$ADObjects = $objSearcher.FindAll()
	}