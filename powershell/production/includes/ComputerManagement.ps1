Function Add-User
	{
	<#
		.SYNOPSIS
			Add a user account to the local computer.
		.DESCRIPTION
			This function will add a user account to the local computer.
		.PARAMETER Computer
			The NetBIOS name of the computer that you will add the account to.
		.PARAMETER User
			The user name of the account that will be created.
		.PARAMETER Password
			The password for the account, this must follow password policies enforced
			on the destination computer.
		.PARAMETER Description
			A description of what this account will be used for.
		.NOTE
			You will need to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
			add-user MyComputer MyUserAccount MyP@ssw0rd "This is my account."
		.LINK
			http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
	#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Password,
				[string]$Description
			)
			
		$objComputer = [ADSI]"WinNT://$Computer"
		$objUser = $objComputer.Create("User", $User)
		$objUser.setpassword($password)
		$objUser.SetInfo()
		$objUser.description = $Description
		$objUser.SetInfo()
	}

Function Set-Pass
	{
	<#
		.SYNOPSIS
			Change the password of an existing user account.
		.DESCRIPTION
			This function will change the password for an existing user account. 
		.PARAMETER Computer
			The NetBIOS name of the computer that you will add the account to.
		.PARAMETER User
			The user name of the account that will be created.
		.PARAMETER Password
			The password for the account, this must follow password policies enforced
			on the destination computer.
		.NOTE
			You will need to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
			set-pass MyComputer MyUserAccount N3wP@ssw0rd
		.LINK
			http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
	#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Password
			)
			
		$objUser=[adsi]("WinNT://$strComputer/$User, user")
		$objUser.psbase.invoke("SetPassword", $Password)
	}
	
Function Set-Group
	{
	<#
		.SYNOPSIS
			Add an existing user to a local group.
		.DESCRIPTION
			This function will add an existing user to an existing group.
		.PARAMETER Computer
			The NetBIOS name of the computer that you will add the account to.
		.PARAMETER User
			The user name of the account that will be created.
		.PARAMETER Group
			The name of an existing group to add this user to.
		.NOTE
			You will need to run this with either UAC disabled or from an elevated prompt.
		.EXAMPLE
			set-group MyComputer MyUserAccount Administrators
		.LINK
			http://scripts.patton-tech.com/wiki/PowerShell/ComputerManagement
	#>
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer,
				[Parameter(Mandatory=$true)]
				[string]$User,
				[Parameter(Mandatory=$true)]
				[string]$Group
			)
			
		$objComputer = [ADSI]"WinNT://$Computer/$Group,group"
		$objComputer.add("WinNT://$Computer/$User")
	}