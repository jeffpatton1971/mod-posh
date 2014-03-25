Function Get-WindowsUpdate
{
    <#
        .SYNOPSIS
            Get a list of updates from an update server
        .DESCRIPTION
            This function will return a list of updates from either a local WSUS update
            server, or via switch from Microsoft Windows Updates.

            This function leverages the Microsoft.Update comobjects in order to provide
            an easy way for administrators to script update management.
        .PARAMETER Criteria
            This is a specialized query for getting a list of updates. The default setting
            will return a list of software updates that are not installed. Pleae see the 
            Link section for a URL that documents that syntax for you.
        .PARAMETER FromMicrosoft
            This switch if present will force the WUA agent to talk directly to 
            Microsoft Update servers.
        .EXAMPLE
            Get-WindowsUpdate

            Description
            -----------
            This shows the basic syntax, the function will return an UpdateCollection object
            containing one or more available updates based on your criteria.
        .EXAMPLE
            Get-WindowsUpdate -FromMicrosoft

            Description
            -----------
            This shows the syntax for using the FromMicrosoft switch, the collection returned
            from this example will be direct from Microsoft. You can verify by checking the
            log file, C:\Windows\WindowsUpdate.log
        .EXAMPLE
            Get-WindowsUpdate -FromMicrosoft -Criteria "(IsInstalled=0 AND 
                                                         CategoryIDs contains 'E6CF1350-C01B-414D-A61F-263D14D133B4') 
                                                     OR (IsInstalled=0 AND 
                                                         CategoryIDs contains '0FA1201D-4330-4FA8-8AE9-B877473B6441')"

            Description
            -----------
            This example shows how to query Microsoft for a list of Critical and Security updates
            that are not already installed on the local computer. I have grouped not installed 
            critical updates together and not installled security updates together. Then tied
            both of those with an OR, so it will find not installed criticals OR not installed
            security updates.

            See the help in LINKS for more details.
        .NOTES
            FunctionName : Get-WindowsUpdate
            Created by   : jspatton
            Date Coded   : 08/22/2013 16:40:27
        .LINK
            https://code.google.com/p/mod-posh/wiki/WindowsUpdateLibrary#Get-WindowsUpdate
        .LINK
            http://msdn.microsoft.com/en-us/library/windows/desktop/aa386526(v=vs.85).aspx
        .LINK
            http://msdn.microsoft.com/en-us/library/ff357803(VS.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        $Criteria="IsInstalled=0 and Type='Software'",
        [switch]$FromMicrosoft
        )
    Begin
    {
        }
    Process
    {
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        if ($FromMicrosoft)
        {
            $UpdateSearcher.ServerSelection = 2
            }
        $SearchResult = $UpdateSearcher.Search($Criteria)
        }
    End
    {
        Return $SearchResult.Updates
        }
    }
Function Start-WindowsUpdateDownload
{
    <#
        .SYNOPSIS
            Start downloading available updates from an update server
        .DESCRIPTION
            This function takes an UpdateCollection and proceeds to download those updates
            from the server.

            This function leverages the Microsoft.Update comobjects in order to provide
            an easy way for administrators to script update management.
        .PARAMETER Update
            This is a collection of updates as returned from an update server.
        .EXAMPLE
            Get-WindowsUpdate |Start-WindowsUpdateDownload

            Description
            -----------
            This example shows the best way to use this function. The output of Get-WindowsUpdate
            as passed along the pipeline to Start-WindowsUpdateDownload. This will get the most
            recent list of updates and download them to the local computer.
        .NOTES
            FunctionName : Start-WindowsUpdateDownload
            Created by   : jspatton
            Date Coded   : 08/23/2013 09:07:07
        .LINK
            https://code.google.com/p/mod-posh/wiki/WindowsUpdateLibrary#Start-WindowsUpdateDownload
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Update
        )
    Begin
    {
        $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
        $Downloader = $UpdateSession.CreateUpdateDownloader()
        }
    Process
    {
        if ($Update.EulaAccepted -and !($Update.InstallationBehavior.CanRequestUserInput))
        {
            $UpdatesToDownload.Add($Update) |Out-Null
            $Downloader.Updates = $UpdatesToDownload
            $Downloader.Download()
            }
        }
    End
    {
        return $UpdatesToDownload
        }
    }
Function Accept-WindowsUpdateEULA
{
    <#
        .SYNOPSIS
            Accept the EULA for updates
        .DESCRIPTION
            This function accepts an UpdateCollection and allows you to accept the EULA 
            on each update passed in.

            This function leverages the Microsoft.Update comobjects in order to provide
            an easy way for administrators to script update management.
        .PARAMETER Update
            This is a collection of updates as returned from an update server.
        .PARAMETER AcceptEULA
            A switch that if present will accept the EULA
        .EXAMPLE
            Get-WindowsUpdate |Accept-WindowsUpdateEULA -AcceptEULA $true

            Description
            -----------
            This example shows how to pass a collection of updates into the function on the
            pipeline and accept the EULA for each update.
        .NOTES
            FunctionName : Accept-WindowsUpdateEULA
            Created by   : jspatton
            Date Coded   : 08/23/2013 09:27:47
        .LINK
            https://code.google.com/p/mod-posh/wiki/WindowsUpdateLibrary#Accept-WindowsUpdateEULA
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Update,
        [bool]$AcceptEULA = $false
        )
    Begin
    {
        }
    Process
    {
        if (!($Update.EulaAccepted))
        {
            if ($AcceptEULA)
            {
                $Update.AcceptEula()
                }
            }
        }
    End
    {
        }
    }
Function Install-WindowsUpdate
{
    <#
        .SYNOPSIS
            Install an update that has been downloaded
        .DESCRIPTION
            This function will install a list of updates that have been downloaded to the 
            local computer.

            This function leverages the Microsoft.Update comobjects in order to provide
            an easy way for administrators to script update management.
        .PARAMETER Update
            This is a collection of updates as returned from an update server.
        .EXAMPLE
            Get-WindowsUpdate |Install-WindowsUpdate

            Description
            -----------
            This example shows passing a collection of updates, and then isntalling them.
        .NOTES
            FunctionName : Install-WindowsUpdate
            Created by   : jspatton
            Date Coded   : 08/23/2013 14:16:59
        .LINK
            https://code.google.com/p/mod-posh/wiki/WindowsUpdateLibrary#Install-WindowsUpdate
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Update
        )
    Begin
    {
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
        $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
        [bool]$RebootRequired = $false
        }
    Process
    {
        if ($Update.IsDownloaded)
        {
            $UpdatesToInstall.Add($Update) |Out-Null
            if ($Update.InstallationBehavior.RebootBehavior -gt 0)
            {
                $RebootRequired = $true
                }
            $Installer = $UpdateSession.CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            $InstallationResult = $Installer.Install()
            }
        }
    End
    {
        if ($RebootRequired)
        {
            return $RebootRequired
            }
        }
    }
Function Connect-WindowsUpdateServer
{
    <#
        .SYNOPSIS
            Connect to a local or remote Windows Update Server
        .DESCRIPTION
            This function allows you to retreive information about updates on the local
            or remote update server. This information is stored in a global variable
            that can be accessed later as $Global:WSUSUpdateServer.

            You will need the WSUS management bits installed in order for this cmdlet
            to work properly.

            This function leverages the Microsoft.UpdateServices comobjects in order to provide
            an easy way for administrators to script update management.
        .PARAMETER Server
            If specified the function will attempt to connect to that server. The default port
            of 8530 is used. If you use a different port, specify it on the command line.
        .PARAMETER UseSecureConnection
            If present will force the function to connect over ssl to the udpate server.
        .EXAMPLE
            Connect-WindowsUpdateServer

            Description
            -----------
            This example shows the basic syntax of the command.
        .EXAMPLE
            Connect-WindowsUpdateServer -Server updates.company.com:80
        .NOTES
            FunctionName : Connect-WindowsUpdateServer
            Created by   : jspatton
            Date Coded   : 08/28/2013 17:13:56
        .LINK
            https://code.google.com/p/mod-posh/wiki/WindowsUpdateLibrary#Connect-WindowsUpdateServer
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Server,
        [switch]$UseSecureConnection
        )
    Begin
    {
        $isLocal = $false
        $Global:WSUSUpdateServer = ""
        try
        {
            $ErrorActionPreference = "Stop"
            $Assembly = [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
            if ($Server)
            {
                if ($Server.ToUpper() -eq (& hostname).ToUpper())
                {
                    $isLocal = $true
                    }
                else
                {
                    if ($Server.Contains(":"))
                    {
                        # found a port
                        $PortNumber = $Server.Substring($Server.IndexOf(":"),$Server.Length-$Server.IndexOf(":")).Replace(":","")
                        $ServerName = $Server.Substring(0,$Server.IndexOf(":"))
                        }
                    else
                    {
                        $PortNumber = 8530
                        $ServerName = $Server
                        }
                    }
                }
            else
            {
                $ServerName = (& hostname)
                $isLocal = $true
                $PortNumber = 8530
                }    
            }
        catch
        {
            Write-Error $Error[0]
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = "Stop"
            $AdminProxy = New-Object Microsoft.UpdateServices.Administration.AdminProxy
            if ($isLocal)
            {
                $UpdateServer = $AdminProxy.GetUpdateServerInstance()
                }
            else
            {
                if ($UseSecureConnection)
                {
                    $UpdateServer = $AdminProxy.GetRemoteUpdateServerInstance($ServerName,$UseSecureConnection,$PortNumber)
                    }
                else
                {
                    $UpdateServer = $AdminProxy.GetRemoteUpdateServerInstance($ServerName,$false,$PortNumber)
                    }
                }
            }
        catch
        {
            Write-Error $Error[0]
            }
        $Global:WSUSUpdateServer = $UpdateServer
        }
    End
    {
        return $UpdateServer
        }
    }

Export-ModuleMember *