Function Get-WindowsUpdate
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Criteria
        .EXAMPLE
        .NOTES
            FunctionName : .\Get-WindowsUpdateLog.ps1
            Created by   : jspatton
            Date Coded   : 08/22/2013 16:40:27
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled20#.\Get-WindowsUpdateLog.ps1
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
        .DESCRIPTION
        .PARAMETER Update
        .EXAMPLE
        .NOTES
            FunctionName : Start-WindowsUpdateDownload
            Created by   : jspatton
            Date Coded   : 08/23/2013 09:07:07
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled20#Start-WindowsUpdateDownload
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
        .DESCRIPTION
        .PARAMETER Update
        .PARAMETER AcceptEULA
        .EXAMPLE
        .NOTES
            FunctionName : Accept-WindowsUpdateEULA
            Created by   : jspatton
            Date Coded   : 08/23/2013 09:27:47
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled20#Accept-WindowsUpdateEULA
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
        .DESCRIPTION
        .PARAMETER Update
        .EXAMPLE
        .NOTES
            FunctionName : Install-WindowsUpdate
            Created by   : jspatton
            Date Coded   : 08/23/2013 14:16:59
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled20#Install-WindowsUpdate
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
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
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
        $Global:WSUSUpdateServer
        try
        {
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
                $isLocal = $true
                }    
            }
        catch
        {
            }
        }
    Process
    {
        try
        {
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
            }
        $Global:WSUSUpdateServer = $UpdateServer
        }
    End
    {
        return $UpdateServer
        }
    }