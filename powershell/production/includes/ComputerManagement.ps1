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
	<#
		.SYNOPSIS
		Add a user account to the local computer.
		.DESCRIPTION
		This function will add a user account to the local computer. You will need
		to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
		add-user MyComputer MyUserAccount MyP@ssw0rd "This is my account."
		.LINK
		http://scripts.patton-tech.com/
	#>
		$objComputer = [ADSI]"WinNT://$Computer"
		$objUser = $objComputer.Create("User", $User)
		$objUser.setpassword($password)
		$objUser.SetInfo()
		$objUser.description = $Description
		$objUser.SetInfo()
	}

Function Set-Pass($Computer, $User, $Password)
	{
	<#
		.SYNOPSIS
		Change the password of an existing user account.
		.DESCRIPTION
		This function will change the password for an existing user account. You will need
		to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
		set-pass MyComputer MyUserAccount N3wP@ssw0rd
		.LINK
		http://scripts.patton-tech.com/		
	#>
		$objUser=[adsi]("WinNT://$strComputer/$User, user")
		$objUser.psbase.invoke("SetPassword", $Password)
	}
	
Function Set-Group($Computer, $User, $Group)
	{
	<#
		.SYNOPSIS
		Add an existing user to a local group.
		.DESCRIPTION
		This function will add an existing user to an existing group. You will need
		to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
		set-group MyComputer MyUserAccount Administrators
		.LINK
		http://scripts.patton-tech.com/		
	#>
		$objComputer = [ADSI]"WinNT://$Computer/$Group,group"
		$objComputer.add("WinNT://$Computer/$User")
	}