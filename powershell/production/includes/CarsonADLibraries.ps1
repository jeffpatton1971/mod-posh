function Convert-ObjectSID
{
    <#
        .SYNOPSIS
            Convert a string SID to an object
        .DESCRIPTION
            This function returns an object
        .PARAMETER ObjectSID
            The SID of the account
        .EXAMPLE
            Convert-ObjectSID -ObjectSID S-1-5-21-57989841-1078081533-682003330-187082 |Format-Table -AutoSize

            BinaryLength AccountDomainSid                       Value
            ------------ ----------------                       -----
                      28 S-1-5-21-57989841-1078081533-682003330 S-1-5-21-57989841-1078081533-682003330-187082

            Description
            -----------
            Showing the basic syntax and output of the function.
        .NOTES
            This function was originall written by Carson Gee (http://carsongee.com)
        .LINK
            https://code.google.com/p/mod-posh/wiki/CarsonADLibraries#Convert-ObjectSID
    #>
    [CmdletBinding()]    
    Param
        (
        $ObjectSID
        )
	return New-Object System.Security.Principal.SecurityIdentifier($ObjectSID)
}
function Convert-SIDToUser
{
    <#
        .SYNOPSIS
            Convert SID to a user object
        .DESCRIPTION
            This function takes a SID object and converts it to a user object
        .PARAMETER ObjectSID
            The SID object of the user account, this cannot be the string. Use
            Convert-ObjectSID to get the objectified SID from a string.
        .EXAMPLE
            Convert-SIDToUser -ObjectSID (Convert-ObjectSID -ObjectSID S-1-5-21-57989841-1078081533-682003330-18
            7082)

            Value
            -----
            HOME\s071b751

            Description
            -----------
            Shows the basic usage of the command.
        .NOTES
            This function was originall written by Carson Gee (http://carsongee.com)
        .LINK
            https://code.google.com/p/mod-posh/wiki/CarsonADLibraries#Convert-SIDToUser
    #>
    [CmdletBinding()]   
    Param
        (
        $ObjectSID
        )
    return $ObjectSID.Translate([System.Security.Principal.NTAccount])
}