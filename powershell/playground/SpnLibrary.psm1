Function Reset-Spn
{
    <#
        .SYNOPSIS
            Reset the SPN for a given account
        .DESCRIPTION
            If the SPNs that you see for your server display what seems to be 
            incorrect names; consider resetting the computer to use the default 
            SPNs. 
            
            To reset the default SPN values, use the setspn -r hostname 
            command at a command prompt, where hostname is the actual host name 
            of the computer object that you want to update.

            For example, to reset the SPNs of a computer named server2, type 
            setspn -r server2, and then press ENTER. You receive confirmation 
            if the reset is successful. To verify that the SPNs are displayed 
            correctly, type setspn -l server2, and then press ENTER.
        .PARAMETER HostName
            The actual hostname of the computer object that you want to reset
        .EXAMPLE
            Reset-Spn -HostName server-03
            Registering ServicePrincipalNames for CN=server-03,OU=Servers,DC=company,DC=com
	            HOST/server-03.company.com
	            HOST/server-03

            Description
            -----------

            This example shows how to reset the spn of a given account. This would
            be used if you were experiencing issues with service account logins.
            See the Link section for relevant URL's.
        .NOTES
            FunctionName : Reset-Spn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:07:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Reset-Spn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
        .LINK
            http://technet.microsoft.com/en-us/library/579246c8-2e32-4282-bce7-3209d1ea8bf1
    #>
    [CmdletBinding()]
    Param
        (
        [string]$HostName
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            Invoke-Expression "$($SpnPath) -R $($HostName)"
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Function Add-Spn
{
    <#
        .SYNOPSIS
            Adds a Service Principal Name to an account
        .DESCRIPTION
            To add an SPN, use the setspn -s service/name hostname command at a 
            command prompt, where service/name is the SPN that you want to add 
            and hostname is the actual host name of the computer object that 
            you want to update. 
            
            For example, if there is an Active Directory domain controller with
            the host name server1.contoso.com that requires an SPN for the 
            Lightweight Directory Access Protocol (LDAP), type 
            setspn -s ldap/server1.contoso.com server1, and then press ENTER 
            to add the SPN.
        .PARAMETER Service
            The name of the service to add
        .PARAMETER Name
            The name that will be associated with this service on this account
        .PARAMETER HostName
            The actual hostname of the computer object that you want to update
        .PARAMETER NoDupes
            Checks the domain for duplicate SPN's
        .EXAMPLE
            Add-Spn -Service foo -Name server-01 -HostName server-01
            Checking domain DC=company,DC=com

            Registering ServicePrincipalNames for CN=server-01,OU=Servers,DC=company,DC=com
                    foo/server-01
            Updated object

            Description
            -----------

            This example shows how to add an spn to an account
        .EXAMPLE
            Add-Spn -Service foo -Name server-01 -HostName server-01 -NoDupes
            Checking domain DC=company,DC=com

            Registering ServicePrincipalNames for CN=server-01,OU=Servers,DC=company,DC=com
                    foo/server-01
            Updated object

            Description
            -----------

            This example shows how to add an spn to an account while making sure it's
            unique within the domain.
        .NOTES
            FunctionName : Add-Spn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:07:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Add-Spn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Service,
        [string]$Name,
        [string]$HostName,
        [switch]$NoDupes
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            if ($NoDupes)
            {
                Invoke-Expression "$($SpnPath) -S $($Service)/$($Name) $($HostName)"
                }
            else
            {
                Invoke-Expression "$($SpnPath) -A $($Service)/$($Name) $($HostName)"
                }
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Function Remove-Spn
{
    <#
        .SYNOPSIS
            Removes a Service Principal Name from an account
        .DESCRIPTION
            To remove an SPN, use the setspn -d service/namehostname command at 
            a command prompt, where service/name is the SPN that is to be 
            removed and hostname is the actual host name of the computer object 
            that you want to update. 
            
            For example, if the SPN for the Web service on a computer named 
            Server3.contoso.com is incorrect, you can remove it by typing 
            setspn -d http/server3.contoso.com server3, and then pressing ENTER.
        .PARAMETER Service
            The name of the service to add
        .PARAMETER Name
            The name that will be associated with this service on this account
        .PARAMETER HostName
            The actual hostname of the computer object that you want to change
        .EXAMPLE
            Remove-Spn -Service foo -Name server-01 -HostName server-01
            Unregistering ServicePrincipalNames for CN=server-01,OU=Servers,DC=company,DC=com
                    foo/server-01
            Updated object

            Description
            -----------

            This example shows how to remove an SPN from an account.
        .NOTES
            FunctionName : Remove-Spn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:07:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Remove-Spn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Service,
        [string]$Name,
        [string]$HostName
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            Invoke-Expression "$($SpnPath) -D $($Service)/$($Name) $($HostName)"
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Function Get-Spn
{
    <#
        .SYNOPSIS
            List Service Principal Name for an account
        .DESCRIPTION
            To view a list of the SPNs that a computer has registered with 
            Active Directory from a command prompt, use the setspn –l hostname 
            command, where hostname is the actual host name of the computer 
            object that you want to query.
            
            For example, to list the SPNs of a computer named WS2003A, at the 
            command prompt, type setspn -l S2003A, and then press ENTER.
        .PARAMETER HostName
            The actual hostname of the computer object that you want to get
        .EXAMPLE
            Get-Spn -HostName server-01
            Registered ServicePrincipalNames for CN=server-01,OU=Servers,DC=company,DC=com:
                    foo/server-01
                    CmRcService/server-01.company.com
                    CmRcService/server-01
                    TERMSRV/server-01
                    TERMSRV/server-01.company.com
                    WSMAN/server-01
                    WSMAN/server-01.company.com
                    RestrictedKrbHost/server-01
                    HOST/server-01
                    RestrictedKrbHost/server-01.company.com
                    HOST/server-01.company.com

            Description
            -----------

            This example lists the SPN(s) of the given account
        .NOTES
            FunctionName : Get-Spn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:07:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Get-Spn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$HostName
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            Invoke-Expression "$($SpnPath) -L $($HostName)"
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Function Find-Spn
{
    <#
        .SYNOPSIS
            Find all occurrences of a given service and or name
        .DESCRIPTION
            To find a list of the SPNs that a computer has registered with 
            Active Directory from a command prompt, use the setspn –Q hostname 
            command, where hostname is the actual host name of the computer 
            object that you want to query.
            
            For example, to list the SPNs of a computer named WS2003A, at the 
            command prompt, type setspn -Q WS2003A, and then press ENTER.
        .PARAMETER Service
            The name of the service to find
        .PARAMETER Name
            The name that will be associated with this service on this account
        .EXAMPLE
            Find-Spn -Service foo
            Checking domain DC=company,DC=com
            CN=server-01,OU=Servers,DC=company,DC=com
	            foo/server-01
	            CmRcService/server-01.company.com
	            CmRcService/server-01
	            WSMAN/server-01.company.com
	            WSMAN/server-01
	            TERMSRV/server-01.company.com
	            TERMSRV/server-01
	            RestrictedKrbHost/server-01
	            HOST/server-01
	            RestrictedKrbHost/server-01.company.com
	            HOST/server-01.company.com

            Existing SPN found!

            Description
            -----------

            Find all occurrences of the given service
        .EXAMPLE
            Find-Spn -Name server-01
            Checking domain DC=company,DC=com
            CN=server-01,OU=Servers,DC=company,DC=com
	            foo/server-01
	            CmRcService/server-01.company.com
	            CmRcService/server-01
	            WSMAN/server-01.company.com
	            WSMAN/server-01
	            TERMSRV/server-01.company.com
	            TERMSRV/server-01
	            RestrictedKrbHost/server-01
	            HOST/server-01
	            RestrictedKrbHost/server-01.company.com
	            HOST/server-01.company.com

            Existing SPN found!

            Description
            -----------

            Find all occurrences of the given name
        .NOTES
            FunctionName : Find-Spn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:07:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Find-Spn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Service,
        [string]$Name
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        if ($Service -and $Name)
        {
            $Spn = "$($Service)/$($Name)"
            }
        if ($Service -and (!($Name)))
        {
            $Spn = "$($Service)/*"
            }
        if ($Name -and (!($Service)))
        {
            $Spn = "*/$($Name)"
            }
        if (!($Name) -and !($Service))
        {
            Write-Error "Must have at least one value for Service or Name"
            break
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            Invoke-Expression "$($SpnPath) -Q $($Spn)"
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Function Find-DuplicateSpn
{
    <#
        .SYNOPSIS
            Find duplicate Service Principal Names across the Domain or Forest
        .DESCRIPTION
            To find a list of duplicate SPNs that have been registered with 
            Active Directory from a command prompt, use the 
            setspn –X -P command, where hostname is the actual host name of the 
            computer object that you want to query.
        .PARAMETER ForestWide
            A switch that if present searches the entire forest for duplicates
        .EXAMPLE
            Find-DuplicateSpn
            Checking domain DC=company,DC=com

            found 0 group of duplicate SPNs.

            Description
            -----------

            This example searches for duplicate SPNs in the current domain
                    .EXAMPLE
            Find-DuplicateSpn -ForestWide
            Checking forest DC=company,DC=com
            Operation will be performed forestwide, it might take a while.

            found 0 group of duplicate SPNs.

            Description
            -----------

            This example searches for duplicate SPNs across the entire forest
        .NOTES
            FunctionName : Find-DuplicateSpn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:53:46

            Searching for duplicates, especially forest-wide, can take a long 
            period of time and a large amount of memory.

            Service Principal Names (SPNs) are not required to be unique across 
            forests, but duplicate SPNs can cause authentication issues during 
            cross-forest authentication.
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Find-DuplicateSpn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [switch]$ForestWide
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            $Binary = 'setspn.exe'
            $Type = 'Leaf'
            [string[]]$paths = @($pwd);
            $paths += "$pwd;$env:path".split(";")
            $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
            if($paths.Length -gt 0)
            {
                $SpnPath = $paths[0]
                }
            }
        catch
        {
            $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            if ($ForestWide)
            {
                Invoke-Expression "$($SpnPath) -X -P -F"
                }
            else
            {
                Invoke-Expression "$($SpnPath) -X -P"
                }
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    End
    {
        }
    }
Export-ModuleMember *