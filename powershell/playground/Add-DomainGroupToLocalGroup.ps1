Function Add-DomainGroupToLocalGroup
{
	<#
		.SYNOPSIS
            Add a Domain security group to a local computer group
		.DESCRIPTION
            This function will add a Domain security group to a local computer group.
		.PARAMETER ComputerName
            The NetBIOS name of the computer to update
        .PARAMETER DomainGroup
            The name of the Domain security group
        .PARAMETER LocalGroup
            The name of the local group to update, if not provided Administrators is assumed.
        .PARAMETER UserDomain
            The NetBIOS domain name.
		.EXAMPLE
		.NOTES
		.LINK
	#>
	
	Param
	(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$DomainGroup,
        [string]$LocalGroup="Administrators",
        [string]$UserDomain	
	)
	
	Begin
	{
        $ComputerObject = [ADSI]("WinNT://$($ComputerName),computer")
        $GroupObject = $ComputerObject.PSBase.Children.Find("$($LocalGroup)")
	}
	
	Process
	{
		$GroupObject.Add("WinNT://$UserDomain/$DomainGroup")
	}
	
	End
	{
	}
}