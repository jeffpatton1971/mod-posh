<#

    Networking
    ----------

    Get a list of all IPEnabled Network adapters, for each adapter get the
    following details

    1. IP
    2. Subnet
    3. Gateway
    4. DNS
    5. Suffix search order

    Required
    --------

    This function needs to know the name of the server in order to process
    the network.xml file or create it.

    Notes
    -----
    
    By default only some items will be logged, in order to log everything
    set $OverRide = $True. The following items will be logged by default:
        IPAddress
        IPSubnet
        DefaultIPGateway
        DNSServerSearchOrder

#>

$OverRide = $False

# Connect over WinRM to the named server to collect this information
$DiscoveredNetwork = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IpEnabled = '$true'" `
    |Select-Object -Property Caption, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder, DNSDomainSuffixSearchOrder

$Message = "`r`nThe following item was changed on $(Get-Date)"

if ((Test-Path .\network.xml))
{
    # File exists, load it up
    $PreviousNetwork = Import-Clixml .\network.xml

    # Need to account for an added network card
    # DiscoveredNetwork.Count -gt 0 if more than one card exists
    # .Count -eq $null when only one nic installed
    if ($PreviousNetwork.Count -eq $null)
    {
        $Previous = 0
        }
    else
    {
        $Previous = $PreviousNetwork.Count
        }
    if ($DiscoveredNetwork.Count -eq $null)
    {
        $Discovered = 0
        }
    else
    {
        $Discovered = $DiscoveredNetwork.Count
        }
    if ($Previous -ne $Discovered)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        if ($Previous -gt $Discovered)
        {
            "Network Adapter Removed" |Out-File .\changelog -Append
            }
        if ($Previous -lt $Discovered)
        {
            "Network Adapter Added" |Out-File .\changelog -Append
            }
        }

    # Compare Previous to Discovered
    $Caption = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property Caption
    $IPAddress = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property IPAddress
    $IPSubnet = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property IPSubnet
    $DefaultIPGateway = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property DefaultIPGateway
    $DNSServerSearchOrder = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property DNSServerSearchOrder
    $DNSDomainSuffixSearchOrder = Compare-Object $PreviousNetwork $DiscoveredNetwork -Property DNSDomainSuffixSearchOrder

    # Look to see what changed
    if ($Caption)
    {
        if ($OverRide)
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            $Caption |Format-List |Out-File .\changelog -Append
            }
        }
    if ($IPAddress)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $IPAddress |Format-List |Out-File .\changelog -Append
        }
    if ($IPSubnet)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $IPSubnet |Format-List |Out-File .\changelog -Append
        }
    if ($DefaultIPGateway)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $DefaultIPGateway |Format-List |Out-File .\changelog -Append
        }
    if ($DNSServerSearchOrder)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $DNSServerSearchOrder |Format-List |Out-File .\changelog -Append
        }
    if ($DNSDomainSuffixSearchOrder)
    {
        if ($OverRide)
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            $DNSDomainSuffixSearchOrder |Format-List |Out-File .\changelog -Append
            }
        }

    # Replace existing network.xml file
    $DiscoveredNetwork |Export-Clixml .\network.xml -Force
    }
else
{
    # File doesn't exist, new server, create it
    $DiscoveredNetwork |Export-Clixml .\network.xml -Force
    }