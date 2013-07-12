<#
Usage: C:\Windows\system32\setspn.exe [modifiers switch] [accountname]
  Where "accountname" can be the name or domain\name
  of the target computer or user account

  Edit Mode Switches:
   -R = reset HOST ServicePrincipalName
    Usage:   setspn -R accountname
   -A = add arbitrary SPN
    Usage:   setspn -A SPN accountname
   -S = add arbitrary SPN after verifying no duplicates exist
    Usage:   setspn -S SPN accountname
   -D = delete arbitrary SPN
    Usage:   setspn -D SPN accountname
   -L = list SPNs registered to target account
    Usage:   setspn [-L] accountname

  Edit Mode Modifiers:
   -C = specify that accountname is a computer account
   -U = specify that accountname is a user account

    Note: -C and -U are exclusive.  If neither is specified, the tool
     will interpret accountname as a computer name if such a computer
     exists, and a user name if it does not.

  Query Mode Switches:
   -Q = query for existence of SPN
    Usage:   setspn -Q SPN
   -X = search for duplicate SPNs
    Usage:   setspn -X

    Note: searching for duplicates, especially forestwide, can take
     a long period of time and a large amount of memory.  -Q will execute
     on each target domain/forest.  -X will return duplicates that exist
     across all targets. SPNs are not required to be unique across forests,
     but duplicates can cause authentication issues when authenticating
     cross-forest.

  Query Mode Modifiers:
   -P = suppresses progress to the console and can be used when redirecting
    output to a file or when used in an unattended script.  There will be no
    output until the command is complete.
   -F = perform queries at the forest, rather than domain level
   -T = perform query on the speicified domain or forest (when -F is also used)
    Usage:   setspn -T domain (switches and other parameters)
     "" or * can be used to indicate the current domain or forest.

    Note: these modifiers can be used with the -S switch in order to specify
     where the check for duplicates should be performed before adding the SPN.
    Note: -T can be specified multiple times.

Examples:
setspn -R daserver1
   It will register SPN "HOST/daserver1" and "HOST/{DNS of daserver1}"
setspn -A http/daserver daserver1
   It will register SPN "http/daserver" for computer "daserver1"
setspn -D http/daserver daserver1
   It will delete SPN "http/daserver" for computer "daserver1"
setspn -F -S http/daserver daserver1
   It will register SPN "http/daserver" for computer "daserver1"
    if no such SPN exists in the forest
setspn -U -A http/daserver dauser
   It will register SPN "http/daserver" for user account "dauser"
setspn -T * -T foo -X
   It will report all duplicate registration of SPNs in this domain and foo
setspn -T foo -F -Q */daserver
   It will find all SPNs of the form */daserver registered in the forest to
    which foo belongs
#>
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
        .PARAMETER AccountName
            the actual host name of the computer object that you want to update
        .EXAMPLE
            Reset-Spn -AccountName server-03
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
        [string]$AccountName
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
            Invoke-Expression "$($SpnPath) -R $($AccountName)"
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
        .DESCRIPTION
        .PARAMETER Service
        .PARAMETER Spn
        .PARAMETER AccountName
        .PARAMETER NoDupes
        .EXAMPLE
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
        [string]$Spn,
        [string]$AccountName,
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
                Invoke-Expression "$($SpnPath) -S $($Service)/$($Spn) $($AccountName)"
                }
            else
            {
                Invoke-Expression "$($SpnPath) -A $($Service)/$($Spn) $($AccountName)"
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
        .DESCRIPTION
        .PARAMETER Service
        .PARAMETER Spn
        .PARAMETER AccountName
        .EXAMPLE
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
        [string]$Spn,
        [string]$AccountName
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
            Invoke-Expression "$($SpnPath) -D $($Service)/$($Spn) $($AccountName)"
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
        .DESCRIPTION
        .PARAMETER AccountName
        .EXAMPLE
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
        [string]$AccountName
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
            Invoke-Expression "$($SpnPath) -L $($AccountName)"
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
        .DESCRIPTION
        .PARAMETER AccountName
        .EXAMPLE
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
        [string]$AccountName
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
            Invoke-Expression "$($SpnPath) -Q $($AccountName)"
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
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Find-DuplicateSpn
            Created by   : jspatton
            Date Coded   : 07/10/2013 15:53:46
        .LINK
            https://code.google.com/p/mod-posh/wiki/SpnLibrary#Find-DuplicateSpn
        .LINK
            http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
    #>
    [CmdletBinding()]
    Param
        (
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
            if ($AccountName)
            {
                Invoke-Expression "$($SpnPath) -X -P *"
                }
            else
            {
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