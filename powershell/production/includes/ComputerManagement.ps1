#
#	Computer Management Functions
#
#	Function Add-User
#		Create's a local user account and adds
#		that account to the specified group.
#
#	Function Set-Pass
#		Changes the password of a local user account
#
#	Function Set-Group
#		Changes group membership of local user account
#
Function Add-User($Computer, $User, $Password, $Description)
	{
		$objComputer = [ADSI]"WinNT://$Computer"
		$objUser = $objComputer.Create("User", $User)
		$objUser.setpassword($password)
		$objUser.SetInfo()
		$objUser.description = $Description
		$objUser.SetInfo()
	}

Function Set-Pass($Computer, $User, $Password)
	{
		$objUser=[adsi]("WinNT://$strComputer/$User, user")
		$objUser.psbase.invoke("SetPassword", $Password)
	}
	
Function Set-Group($Computer, $User, $Group)
	{
		$objComputer = [ADSI]"WinNT://$Computer/$Group,group"
		$objComputer.add("WinNT://$Computer/$User")
	}