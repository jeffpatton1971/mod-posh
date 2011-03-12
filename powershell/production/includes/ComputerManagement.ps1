#
#	Computer Management Functions
#
#	Function AddUser
#		Create's a local user account and adds
#		that account to the specified group.
#
#	Function ChangePass
#		Changes the password of a local user account
#
Function AddUser($Computer, $User, $Password, $Description, $Group)
	{
		$objComputer = [ADSI]"WinNT://$Computer"
		$objUser = $objComputer.Create("User", $User)
		$objUser.setpassword($password)
		$objUser.SetInfo()
		$objUser.description = $Description
		$objUser.SetInfo()
		$objComputer = [ADSI]"WinNT://$Computer/$Group,group"
		$objComputer.add("WinNT://$Computer/$User")
	}

Function ChangePass($Computer, $User, $Password)
	{
		$objUser=[adsi]("WinNT://$strComputer/$User, user")
		$objUser.psbase.invoke("SetPassword", $Password)
	}