Function Get-DellDownloadURL
{
    <#
    #>
    Param
        (
            $ServiceTag,
            $DellCategory
        )
    Begin
    {
        $Client = New-Object System.Net.WebClient
        $Client.Headers.Add("user-agent","PowerShell")
        $DellSupportPage = "http://support.dell.com/support/downloads/driverslist.aspx?c=us&cs=RC956904&l=en&s=hied&os=WLH&osl=en&ServiceTag=$($ServiceTag)"
    }
    
    Process
    {
        $Data = $Client.OpenRead($DellSupportPage)
        $Reader = New-Object System.IO.StreamReader $Data
        [string]$Page = $Reader.ReadToEnd()
        
        switch ($DellCategory)
        {
            BIOS
            {
                $marker = ($Page.Substring($Page.IndexOf("Dell - BIOS"),($Page.Length)-($Page.IndexOf("Dell - BIOS"))))
                $marker = $marker.Remove(0,$marker.IndexOf("http"))
                $DellDownloadURL = $marker.Substring(0,$marker.IndexOf("`""))            
            }
        }
    }
    
    End
    {
        $DownloadURL = New-Object PSobject -Property @{
            URL = $DellDownloadURL
        }
        Return $DownloadURL
    }
}

Function Get-DellCurrentBIOSRev
{
    <#
    #>
    
    Param
        (
            $ServiceTag
        )
    
    Begin
    {
        $DellBIOSPage = Get-DellDownloadURL -ServiceTag $ServiceTag -DellCategory BIOS
        $DellPageVersionString = "<span id=`"Version`" class=`"para`">"
    }
    
    Process
    {
        $DellPage = (New-Object -TypeName net.webclient).DownloadString($DellBIOSPage.URL)
        $DellCurrentBios = $DellPage.Substring($DellPage.IndexOf($DellPageVersionString)+$DellPageVersionString.Length,3)
    }
    
    End
    {
         $LatestBIOS = New-Object PSobject -Property @{
            BIOS = $DellCurrentBios
         }
        Return $LatestBIOS
    }
}

Function Get-DellWarranty
{
    <#
    .SYNOPSIS
    Quick script to invoke the Dell Jigsaw asset service.

    .PARAMETER ServiceTag
    One or more valid Dell Service Tag codes, separated by commas

    .INPUTS
    None. You cannot pipe to this script

    .OUTPUTS
    PS Objects containing warranty support entitlements for the provided service tag
    #>

    Param
        (
            [parameter(Mandatory=$true, HelpMessage="Enter one or more valid Dell Service Tags, separated by commas")]
            [String]$ServiceTag
        )
    $DummyGUID = New-Object GUID('11111111-1111-1111-1111-111111111111')
    $AppName = 'Jigsaw Test'
    $proxy = New-WebServiceProxy -URI 'http://xserv.dell.com/services/assetservice.asmx'
    $Data = $proxy.GetAssetInformation($DummyGUID, $AppName, $ServiceTag)

    $Entitlements = @()
    foreach ($item in ($Data |Select-Object -ExpandProperty Entitlements))
    {
        $ThisEntitlement = New-Object PSobject -Property @{
            Entitlement = $item.EntitlementType
            Provider = $item.Provider
            ServiceLevelCode = $item.ServiceLevelCode
            ServiceLevelDescription = $item.ServiceLevelDescription
            StartDate = $item.StartDate
            EndDate = $item.EndDate
        }
        $Entitlements += $ThisEntitlement
    }
    Return $Entitlements
}

Function Get-DellBIOSReport
{
    <#

    #>

    Param
        (
            $ComputerName
        )

    Begin
        {
            $ErrorActionPreference = "stop"
            Try
            {
                $BiosRev = Get-WmiObject -Class Win32_BIOS -ComputerName $ComputerName -Credential $Credentials
            }
            Catch
            {
                $BIOSInfo = New-Object PSobject -Property @{
                    ComputerName = $ComputerName
                    ServiceTag = "OFFLINE"
                    CurrentBIOSRev = "OFFLINE"
                    LatestBIOSrev = "OFFLINE"
                    BIOSURL = "OFFLINE"
                }
            }
            Finally
            {
                
            }
        }

    Process
        {
            If ($BiosRev.Manufacturer -match "Dell")
            {
                $DellPage = (New-Object -TypeName net.webclient).DownloadString((Get-DellDownloadURL -ServiceTag $BiosRev.SerialNumber -DellCategory BIOS).URL)

                $DellCurrentBios = Get-DellCurrentBIOSRev -ServiceTag $BiosRev.SerialNumber
                If ($BiosRev.SMBIOSBIOSVersion -eq $DellCurrentBios.BIOS -eq $false)
                    {
                        $marker = $DellPage.Substring($DellPage.IndexOf("http://ftp"),($DellPage.Length)-($DellPage.IndexOf("http://ftp")))
                        $BIOSDownloadURL = $marker.Substring(0,$marker.IndexOf("`'"))
                    }

                $BIOSInfo = New-Object PSobject -Property @{
                    ComputerName = $ComputerName
                    ServiceTag = $($BiosRev.SerialNumber)
                    CurrentBIOSRev = $($BiosRev.SMBIOSBIOSVersion)
                    LatestBIOSrev = $DellCurrentBios.BIOS
                    BIOSURL = $BIOSDownloadURL
                }
            }
        }

    End
        {
            Return $BIOSInfo
        }
}


Export-ModuleMember *