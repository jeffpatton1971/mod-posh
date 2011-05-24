Function Add-DomainGroupToLocalGroup
{
	<#
		.SYNOPSIS
		.DESCRIPTION
		.PARAMETER
		.EXAMPLE
		.NOTES
		.LINK
	#>
	
	Param
	(
	)
	
	Begin
	{
	}
	
	Process
	{
		([ADSI]"WinNT://Server/Administrators,group").add("WinNT://Domain/Group,group")
	}
	
	End
	{
	}
}