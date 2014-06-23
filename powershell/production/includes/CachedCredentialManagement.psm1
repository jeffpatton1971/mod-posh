Function Get-CachedCredential
 {
    <#
        .SYNOPSIS
            Return a list of cached credentials
        .DESCRIPTION
            This function wraps cmdkey /list and returns an object that contains
            the Targetname, user and type of cached credentials.
        .PARAMETER Type
            To filter the list provide one of the basic types of 
            cached credentials
                Domain
                Generic
        .EXAMPLE
            Get-CachedCredential

            Target                         Type            User                 
            ------                         ----            ----                 
            Domain:target=server-02        Domain Password COMPANY\Administrator
            Domain:target=server-01        Domain Password COMPANY\Administrator
            LegacyGeneric:target=server-04 Generic         COMPANY\Administrator
            LegacyGeneric:target=server-03 Generic         COMPANY\Administrator

            Description
            -----------
            This example shows using the syntax without passing a type parameter, which is
            the same as passing -Type All
        .EXAMPLE
            Get-CachedCredential -Type Domain

            Target                         Type            User                 
            ------                         ----            ----                 
            Domain:target=server-02        Domain Password COMPANY\Administrator
            Domain:target=server-01        Domain Password COMPANY\Administrator

            Description
            -----------
            This example shows using type with one of the valid types available
        .NOTES
            FunctionName : Get-CachedCredential
            Created by   : jspatton
            Date Coded   : 06/23/2014 10:11:42

            **
            This function does not return a cached credential that doesn't hold
            a value for user
            **
        .LINK
            https://code.google.com/p/mod-posh/wiki/CachedCredentialManagement#Get-CachedCredential
        .LINK
            http://technet.microsoft.com/en-us/library/cc754243.aspx
        .LINK
            http://www.powershellmagazine.com/2014/04/18/automatic-remote-desktop-connection/
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("Generic","Domain","Certificate","All")]
        [string]$Type
        )
    Begin
    {
        $Result = cmdkey /list
        }
    Process
    {
        $Return = @()
        $Temp = New-Object -TypeName psobject
        foreach ($Entry in $Result)
        {
            if ($Entry)
            {
                $Line = $Entry.Trim();
                if ($Line.Contains('Target: '))
                {
                    Write-Verbose $Line
                    $Target = $Line.Replace('Target: ','');
                    }
                if ($Line.Contains('Type: '))
                {
                    Write-Verbose $Line
                    $TargetType = $Line.Replace('Type: ','');
                    }
                if ($Line.Contains('User: '))
                {
                    Write-Verbose $Line
                    $User = $Line.Replace('User: ','');
                    Add-Member -InputObject $Temp -MemberType NoteProperty -Name Target -Value $Target
                    Add-Member -InputObject $Temp -MemberType NoteProperty -Name Type -Value $TargetType
                    Add-Member -InputObject $Temp -MemberType NoteProperty -Name User -Value $User
                    $Return += $Temp;
                    Write-Verbose $Temp;
                    $Temp = New-Object -TypeName psobject
                    }
                }
            }
        }
    End
    {
        if ($Type -eq "All" -or $Type -eq "")
        {
            Write-Verbose "ALL"
            return $Return;
            }
        else
        {
            Write-Verbose "FILTERED"
            if ($Type -eq "Domain")
            {
                $myType = "Domain Password"
                }
            if ($Type -eq "Certificate")
            {
                $myType = "Generic Certificate"
                }
            return $Return |Where-Object -Property Type -eq $myType
            }
        }
    }
Function Add-CachedCredential
{
    <#
        .SYNOPSIS
            Add a cached credential to the vault
        .DESCRIPTION
            This function wraps cmdkey /add and stores a TargetName and
            user/pass combination in the vault
        .PARAMETER TargetName
            The name of the object to store credentials for, typically
            this would be a computer name
        .PARAMETER Type
            Add credentials in one of the few valid types of
            cached credentials
                Domain
                Generic
        .PARAMETER Credential
            A PSCredential object used to securely store user and 
            password information
        .EXAMPLE
            Add-CachedCredential -TartName server-01 -Type Domain -Credential (Get-Credential)

            CMDKEY: Credential added successfully.

            Description
            -----------
            The basic syntax of the command
        .EXAMPLE
            "server-04","server-05" |Add-CachedCredential -Type Domain -Credential $Credential

            CMDKEY: Credential added successfully.

            CMDKEY: Credential added successfully.

            Description
            -----------
            This example shows passing in Targetnames on the pipeline
        .NOTES
            FunctionName : Add-CachedCredential
            Created by   : jspatton
            Date Coded   : 06/23/2014 12:13:21
        .LINK
            https://code.google.com/p/mod-posh/wiki/CachedCredentialManagement#Add-CachedCredential
        .LINK
            http://technet.microsoft.com/en-us/library/cc754243.aspx
        .LINK
            http://www.powershellmagazine.com/2014/04/18/automatic-remote-desktop-connection/
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$TargetName,
        [ValidateSet("Generic","Domain")]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
        )
    Begin
    {
        $Username = $Credential.UserName;
        $Password = $Credential.GetNetworkCredential().Password;
        }
    Process
    {
        foreach ($Target in $TargetName)
        {
            switch ($Type)
            {
                "Generic"
                {
                    $Result = cmdkey /generic:$Target /user:$Username /pass:$Password
                    if ($LASTEXITCODE -eq 0)
                    {
                        Return $Result;
                        }
                    {
                        Write-Error $Result
                        Write-Error $LASTEXITCODE
                        }
                    }
                "Domain"
                {
                    $Result = cmdkey /add:$Target /user:$Username /pass:$Password
                    if ($LASTEXITCODE -eq 0)
                    {
                        Return $Result;
                        }
                    {
                        Write-Error $Result
                        Write-Error $LASTEXITCODE
                        }
                    }
                }
            }
        }
    End
    {
        }
    }
Function Remove-CachedCredential
{
    <#
        .SYNOPSIS
            Remove a target from the vault
        .DESCRIPTION
            This function wraps cmdkey /delete to remove a specific
            target from the vault
        .PARAMETER TargetName
            The target to remove
        .EXAMPLE
            Remove-CachedCredential -TargetName server-04

            CMDKEY: Credential deleted successfully.

            Description
            -----------
            This example shows the only usage for this command
        .NOTES
            FunctionName : Remove-CachedCredential
            Created by   : jspatton
            Date Coded   : 06/23/2014 12:27:18
        .LINK
            https://code.google.com/p/mod-posh/wiki/CachedCredentialManagement#Remove-CachedCredential
        .LINK
            http://technet.microsoft.com/en-us/library/cc754243.aspx
        .LINK
            http://www.powershellmagazine.com/2014/04/18/automatic-remote-desktop-connection/
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$TargetName
        )
    Begin
    {
        }
    Process
    {
        $Result = cmdkey /delete:$TargetName
        }
    End
    {
        if ($LASTEXITCODE -eq 0)
        {
            Return $Result;
            }
        {
            Write-Error $Result
            Write-Error $LASTEXITCODE
            }
        }
    }