Function Register-W32tmService
{
    <#
        .SYNOPSIS
            Register to run as a service and add default configuration to the registry.
        .DESCRIPTION
            Register to run as a service and add default configuration to the registry.
        .EXAMPLE
            Register-W32tmService
        .NOTES
            FunctionName : Register-W32tmService
            Created by   : jspatton
            Date Coded   : 03/12/2015 12:18:42
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Register-W32tmService
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        )
    Begin
    {
        Invoke-W32tm -Register
        }
    Process
    {
        }
    End
    {
        }
    }
Function Unregister-W32tmService
{
    <#
        .SYNOPSIS
            Unregister service and remove all configuration information from the registry.
        .DESCRIPTION
            Unregister service and remove all configuration information from the registry.
        .EXAMPLE
            Unregister-W32tmService
        .NOTES
            FunctionName : Unregister-W32tmService
            Created by   : jspatton
            Date Coded   : 03/12/2015 12:26:07
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Unregister-W32tmService
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        )
    Begin
    {
        Invoke-W32tm -Unregister
        }
    Process
    {
        }
    End
    {
        }
    }
Function Watch-W32tmService
{
    <#
        .SYNOPSIS
            Monitors the target computer or list of computers
        .DESCRIPTION
            Monitors the target computer or list of computers
        .PARAMETER Domain
            specifies which domain to monitor. If no domain name is given, or neither the domain nor computers option is specified, the default domain is used. This option may be used more than once.
        .PARAMETER Computers
            monitors the given list of computers. Computer names are separated by commas, with no spaces. If a name is prefixed with a '*', it is treated as an AD PDC. This option may be used more than once.
        .PARAMETER Threads
            how many computers to analyze simultaneously. The default value is 3. Allowed range is 1-50.
        .PARAMETER IpProtocol
            specify the IP protocol to use. The default is to use whatever is available.
        .PARAMETER NoWarn
            skip warning message.
        .EXAMPLE
            Watch-W32tmService -Domain company.com -Threads 2 -IpProtocol 4 -NoWarn
        .EXAMPLE
            Watch-W32tmService -Computers 'srv-01','srv-02' -Threads 4
        .NOTES
            FunctionName : Watch-W32tmService
            Created by   : jspatton
            Date Coded   : 03/12/2015 12:28:03
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Watch-W32tmService
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Domain,
        [Parameter(Mandatory=$false)]
        [string[]]$Computers,
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,50)]
        [int]$Threads = 2,
        [Parameter(Mandatory=$false)]
        [ValidateSet(4,6)]
        [int]$IpProtocol = 4,
        [Parameter(Mandatory=$false)]
        [switch]$NoWarn
        )
    Begin
    {
        if (!($Domain -and $Computers))
        {
            if ($Domain)
            {
                $Result = Invoke-W32tm -Domain $Domain -Threads $Threads -IpProtocol $IpProtocol -NoWarn $NoWarn
                }
            if ($Computers)
            {
                $Result = Invoke-W32tm -Computers $Computers -Threads $Threads -IpProtocol $IpProtocol -NoWarn $NoWarn
                }
            }
        }
    Process
    {
        Write-Verbose "Processing w32tm result"
        $Result = $Result |ForEach-Object {if ($_.Trim().Length -ne 0){$_.Trim()}}
        $Count = 0
        ForEach ($Line in $Result)
        {
            $Count ++;
            if ($Line.EndsWith(":"))
            {
                $sEntry = $Result[($Count-1)..($Count+3)]
                if ($sEntry[0].ToLower() -like "warning*")
                {
                    Write-Host -ForegroundColor Yellow $sEntry
                    }
                else
                {
                    New-Object -TypeName psobject -Property @{
                        Server = $sEntry[0];
                        ICMP = $sEntry[1].Split(":")[1].Trim();
                        NTP = $sEntry[2].Split(":")[1].Trim();
                        RefId = $sEntry[3].Split(":")[1].Trim();
                        Stratum = $sEntry[4].Split(":")[1].Trim();
                        } |Select-Object -Property Server, ICMP, NTP, RefId, Stratum
                    }
                }
            }
        }
    End
    {
        }
    }
Function ConvertTo-W32tmNtte
{
    <#
        .SYNOPSIS
            Convert a NT system time, in (10^-7)s intervals from 0h 1-Jan 1601, into a readable format.
        .DESCRIPTION
            Convert a NT system time, in (10^-7)s intervals from 0h 1-Jan 1601, into a readable format.
        .PARAMETER Time
            An NT Epoch time as a string
        .EXAMPLE
            ConvertTo-W32tmNtte -Time 128271382742968750
        .NOTES
            FunctionName : ConvertTo-W32tmNtte
            Created by   : jspatton
            Date Coded   : 03/12/2015 15:24:37
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#ConvertTo-W32tmNtte
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Time
        )
    Begin
    {
        Invoke-W32tm -NtTimeEpoch $Time
        }
    Process
    {
        }
    End
    {
        }
    }
Function ConvertTo-W32tmNtpte
{
    <#
        .SYNOPSIS
            Convert an NTP time, in (2^-32)s intervals from 0h 1-Jan 1900, into a readable format.
        .DESCRIPTION
            Convert an NTP time, in (2^-32)s intervals from 0h 1-Jan 1900, into a readable format.
        .PARAMETER TIME
            An NTP Epoch time as a string
        .EXAMPLE
            ConvertTo-W32tmNtpte -Time 128271382742968750
        .NOTES
            FunctionName : ConvertTo-W32tmNtpte
            Created by   : jspatton
            Date Coded   : 03/12/2015 15:29:47
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#ConvertTo-W32tmNtpte
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Time
        )
    Begin
    {
        Invoke-W32tm -NtpTimeEpoch $Time
        }
    Process
    {
        }
    End
    {
        }
    }
Function Sync-W32tmService
{
    <#
        .SYNOPSIS
            Tell a computer that it should resynchronize its clock as soon as possible, throwing out all accumulated error statistics.
        .DESCRIPTION
            Tell a computer that it should resynchronize its clock as soon as possible, throwing out all accumulated error statistics.
        .PARAMETER Computer
            computer that should resync. If not specified, the local computer will resync.
        .PARAMETER NoWait
            do not wait for the resync to occur; return immediately. Otherwise, wait for the resync to complete before returning.
        .PARAMETER Rediscover
            redetect the network configuration and rediscover network sources, then resynchronize.
        .PARAMETER Soft
            resync utilizing existing error statistics. Not useful, provided for compatibility.
        .EXAMPLE
            Sync-W32tmService -Computer srv-01 -NoWait -Rediscover
        .EXAMPLE
            Sync-W32tmService -NoWait -Rediscover
        .NOTES
            FunctionName : Sync-W32tmService
            Created by   : jspatton
            Date Coded   : 03/12/2015 15:34:33
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Sync-W32tmService
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$NoWait,
        [Parameter(Mandatory=$false)]
        [switch]$Rediscover,
        [Parameter(Mandatory=$false)]
        [switch]$Soft
        )
    Begin
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -NoWait $NoWait -Rediscover $Rediscover -Soft $Soft
            }
        else
        {
            Invoke-W32tm -NoWait $NoWait -Rediscover $Rediscover -Soft $Soft
            }
        }
    Process
    {
        }
    End
    {
        }
    }
Function Get-W32tmStripChart
{
    <#
        .SYNOPSIS
            Display a strip chart of the offset between this computer and another computer.
        .DESCRIPTION
            Display a strip chart of the offset between this computer and another computer.
        .PARAMETER Computer
            the computer to measure the offset against.
        .PARAMETER Period
            the time between samples, in seconds. The default is 2s
        .PARAMETER Dataonly
            display only the data, no graphics.
        .PARAMETER Samples
            collect <count> samples, then stop. If not specified, samples will be collected until Ctrl-C is pressed.
        .PARAMETER Packetinfo
            print out NTP packet response message.
        .PARAMETER IpProtocol
            specify the IP protocol to use. The default is to use whatever is available.
        .EXAMPLE
            Get-W32tmStripChart -Computer -Period 2 -Dataonly -Samples 4 -PacketInfo
        .NOTES
            FunctionName : Get-W32tmStripChart
            Created by   : jspatton
            Date Coded   : 03/12/2015 15:47:05
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmStripChart
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [int]$Period = 2,
        [Parameter(Mandatory=$false)]
        [switch]$Dataonly,
        [Parameter(Mandatory=$false)]
        [int]$Samples,
        [Parameter(Mandatory=$false)]
        [switch]$Packetinfo,
        [ValidateSet(4,6)]
        [int]$IpProtocol
        )
    Begin
    {
        Invoke-W32tm -Computer $Computer -Period $Period -Dataonly $Dataonly -Samples $Samples -Packetinfo $Packetinfo -IpProtocol $IpProtocol;
        }
    Process
    {
        }
    End
    {
        }
    }
Function Set-W32tmManualPeerList
{
    <#
        .SYNOPSIS
            Sets the manual peer list to <peers>, which is a space-delimited list of DNS and/or IP addresses.
        .DESCRIPTION
            Sets the manual peer list to <peers>, which is a space-delimited list of DNS and/or IP addresses.
        .PARAMETER Computer
            adjusts the configuration of <target>. If not specified, the default is the local computer.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER ManualPeerlist
            sets the manual peer list to <peers>, which is a space-delimited list of DNS and/or IP addresses. When specifying multiple peers, this switch must be enclosed in quotes.
        .EXAMPLE
            Set-W32tmManualPeerList -Update -ManualPeerlist 'time.windows.com,0x1','tock.usno.navy.mil,0x1'
        .NOTES
            FunctionName : Set-W32tmManualPeerList
            Created by   : jspatton
            Date Coded   : 03/13/2015 09:32:52
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Set-W32tmManualPeerList
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$Update,
        [Parameter(Mandatory=$true)]
        [string[]]$ManualPeerlist
        )
    Begin
    {
        $Peerlist = [string]::Join(" ",$ManualPeerlist)
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Update $Update -ManualPeerlist $Peerlist
            }
        else
        {
            Invoke-W32tm -Update $Update -ManualPeerlist $Peerlist
            }
        }
    End
    {
        }
    }
Function Set-W32tmSyncFromFlags
{
    <#
        .SYNOPSIS
            Sets what sources the NTP client should sync from. <source> should be a comma separated list of these keywords (not case sensitive):
        .DESCRIPTION
            Sets what sources the NTP client should sync from. <source> should be a comma separated list of these keywords (not case sensitive):
        .PARAMETER Computer
            adjusts the configuration of <target>. If not specified, the default is the local computer.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER SyncFromFlags
            sets what sources the NTP client should sync from. <source> should be a comma separated list of these keywords (not case sensitive):
            MANUAL - sync from peers in the manual peer list
            DOMHIER - sync from an AD DC in the domain hierarchy
            NO - sync from none
            ALL - sync from both manual and domain peers
        .EXAMPLE
            Set-W32tmSyncFromFlags -SyncFromFlags 'DOMHIER','NO'
        .NOTES
            FunctionName : Set-W32tmSyncFromFlags
            Created by   : jspatton
            Date Coded   : 03/13/2015 09:56:32
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Set-W32tmSyncFromFlags
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$Update,
        [Parameter(Mandatory=$true)]
        [validateset('MANUAL','DOMHIER','NO','ALL')]
        [string[]]$SyncFromFlags
        )
    Begin
    {
        $Flags = [string]::Join(",",$SyncFromFlags)
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Update $Update -SyncFromFlags $Flags.ToUpper()
            }
        else
        {
            Invoke-W32tm -Update $Update -SyncFromFlags $Flags.ToUpper()
            }
        }
    End
    {
        }
    }
Function Set-W32tmLocalClockDispersion
{
    <#
        .SYNOPSIS
            Configures the accuracy of the internal clock that w32time will assume when it can't acquire time from its configured sources.
        .DESCRIPTION
            Configures the accuracy of the internal clock that w32time will assume when it can't acquire time from its configured sources.
        .PARAMETER Computer
            adjusts the configuration of <target>. If not specified, the default is the local computer.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER LocalClockDispersion
            configures the accuracy of the internal clock that w32time will assume when it can't acquire time from its configured sources.
        .EXAMPLE
            Set-W32tmLocalClockDispersion -Update -LocalClockDispersion 5
        .NOTES
            FunctionName : Set-W32tmLocalClockDispersion
            Created by   : jspatton
            Date Coded   : 03/13/2015 10:06:34
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Set-W32tmLocalClockDispersion
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$Update,
        [Parameter(Mandatory=$true)]
        [int]$LocalClockDispersion
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Update $Update -LocalClockDispersion $LocalClockDispersion
            }
        else
        {
            Invoke-W32tm -Update $Update -LocalClockDispersion $LocalClockDispersion
            }
        }
    End
    {
        }
    }
Function Set-W32tmReliable
{
    <#
        .SYNOPSIS
            Set whether this machine is a reliable time source. This setting is only meaningful on domain controllers.
        .DESCRIPTION
            Set whether this machine is a reliable time source. This setting is only meaningful on domain controllers.
        .PARAMETER Computer
            adjusts the configuration of <target>. If not specified, the default is the local computer.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER Reliable
            set whether this machine is a reliable time source. This setting is only meaningful on domain controllers.
            YES - this machine is a reliable time service
            NO - this machine is not a reliable time service
        .EXAMPLE
            Set-W32tmReliable -Update -Reliable Yes
        .NOTES
            FunctionName : Set-W32tmReliable
            Created by   : jspatton
            Date Coded   : 03/13/2015 10:08:30
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Set-W32tmReliable
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$Update,
        [Parameter(Mandatory=$true)]
        [validateset('YES','NO')]
        [string]$Reliable
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Update $Update -Reliable $Reliable
            }
        else
        {
            Invoke-W32tm -Update $Update -Reliable $Reliable
            }
        }
    End
    {
        }
    }
Function Set-W32tmLargePhaseOffset
{
    <#
        .SYNOPSIS
            Sets the time difference between local and network time which w32time will consider a spike.            
        .DESCRIPTION
            Sets the time difference between local and network time which w32time will consider a spike.            
        .PARAMETER Computer
            adjusts the configuration of <target>. If not specified, the default is the local computer.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER LargPhaseOffset
            sets the time difference between local and network time which w32time will consider a spike.
        .EXAMPLE
            Set-W32tmLargePhaseOffset -Update -LargePhaseOffset 10
        .NOTES
            FunctionName : Set-W32tmLargePhaseOffset
            Created by   : jspatton
            Date Coded   : 03/13/2015 10:14:26
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Set-W32tmLargePhaseOffset
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [switch]$Update,
        [Parameter(Mandatory=$true)]
        [int]$LargPhaseOffset
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Update $Update -LargPhaseOffset $LargPhaseOffset
            }
        else
        {
            Invoke-W32tm -Update $Update -LargPhaseOffset $LargPhaseOffset
            }
        }
    End
    {
        }
    }
Function Get-W32tmTimeZone
{
    <#
        .SYNOPSIS
            Display the current time zone settings.
        .DESCRIPTION
            Display the current time zone settings.
        .EXAMPLE
            Get-W32tmTimeZone
        .NOTES
            FunctionName : Get-W32tmTimeZone
            Created by   : jspatton
            Date Coded   : 03/13/2015 10:16:55
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmTimeZone
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        )
    Begin
    {
        Invoke-W32tm -TimeZone $true
        }
    Process
    {
        }
    End
    {
        }
    }
Function Export-W32tmRegistry
{
    <#
        .SYNOPSIS
            Display the values associated with a given registry key.
        .DESCRIPTION
            Display the values associated with a given registry key. The default key is HKLM\System\CurrentControlSet\Services\W32Time (the root key for the time service).
        .PARAMETER Computer
            queries registry settings for computer <target>.
        .PARAMETER Subkey
            displays the values associated with subkey <key> of the default key.
        .EXAMPLE
            Export-W32tmRegistry -Subkey Root
        .EXAMPLE
            Export-W32tmRegistry -Subkey Parameters
        .NOTES
            FunctionName : Export-W32tmRegistry
            Created by   : jspatton
            Date Coded   : 03/13/2015 10:18:07
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Export-W32tmRegistry
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$true)]
        [validateset('Root','Config','Parameters','Security','TimeProviders','TriggerInfo')]
        [string]$Subkey = 'Root'
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Subkey $Subkey
            }
        else
        {
            Invoke-W32tm -Subkey $Subkey
            }
        }
    End
    {
        }
    }
Function Get-W32tmSource
{
    <#
        .SYNOPSIS
            Display the time source.
        .DESCRIPTION
            Display the time source.
        .PARAMETER Computer
            query the information of <target>. If not specified, the default is the local computer.
        .PARAMETER Ver
            set the verbose mode to display more information.
        .EXAMPLE
            Get-W32tmSource -Computer srv-01
        .NOTES
            FunctionName : Get-W32tmSource
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:16:23
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmSource
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [bool]$Ver
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Source $true -Ver $Ver
            }
        else
        {
            Invoke-W32tm -Source $true -Ver $Ver
            }
        }
    End
    {
        }
    }
Function Get-W32tmConfiguration
{
    <#
        .SYNOPSIS
            Display the configuration of run-time and where the setting comes from.
        .DESCRIPTION
            Display the configuration of run-time and where the setting comes from. In verbose mode, display the undefined or unused setting too.
        .PARAMETER Computer
            query the information of <target>. If not specified, the default is the local computer.
        .PARAMETER Ver
            set the verbose mode to display more information.
        .EXAMPLE
            Get-W32tmConfiguration -Computer srv-01
        .NOTES
            FunctionName : Get-W32tmConfiguration
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:19:14
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmConfiguration
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [bool]$Ver
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Configuration $true -Ver $Ver
            }
        else
        {
            Invoke-W32tm -Configuration $true -Ver $Ver
            }
        }
    End
    {
        }
    }
Function Get-W32tmPeers
{
    <#
        .SYNOPSIS
            Display a list of peers and their status.
        .DESCRIPTION
            Display a list of peers and their status.
        .PARAMETER Computer
            query the information of <target>. If not specified, the default is the local computer.
        .PARAMETER Ver
            set the verbose mode to display more information.
        .EXAMPLE
            Get-W32tmPeers -Computer srv-01 -Ver
        .NOTES
            FunctionName : Get-W32tmPeers
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:21:02
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmPeers
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [bool]$Ver
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Peers $true -Ver $Ver
            }
        else
        {
        Invoke-W32tm -Peers $true -Ver $Ver
            }
        }
    }
Function Get-W32tmStatus
{
    <#
        .SYNOPSIS
            Display windows time service status.
        .DESCRIPTION
            Display windows time service status.
        .PARAMETER Computer
            query the information of <target>. If not specified, the default is the local computer.
        .PARAMETER Ver
            set the verbose mode to display more information.
        .EXAMPLE
            Get-W32tmStatus -Ver
        .NOTES
            FunctionName : Get-W32tmStatus
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:22:14
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Get-W32tmStatus
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false)]
        [bool]$Ver
        )
    Begin
    {
        }
    Process
    {
        if ($Computer)
        {
            Invoke-W32tm -Computer $Computer -Status $true -Ver $Ver
            }
        else
        {
            Invoke-W32tm -Status $true -Ver $Ver
            }
        }
    }
Function Disable-W32tmPrivateLog
{
    <#
        .SYNOPSIS
            Disable local computer windows time service private log.
        .DESCRIPTION
            Disable local computer windows time service private log.
        .EXAMPLE
            Disable-W32tmPrivateLog
        .NOTES
            FunctionName : Disable-W32tmDebugLog
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:29:21
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Disable-W32tmDebugLog
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        )
    Begin
    {
        Invoke-W32tm -Disable $true
        }
    Process
    {
        }
    End
    {
        }
    }
Function Enable-W32tmPrivateLog
{
    <#
        .SYNOPSIS
            Enable local computer windows time service private log.
        .DESCRIPTION
            Enable local computer windows time service private log.
        .PARAMETER File
            specify the absolute filename.
        .PARAMETER Size
            specify the maximum size for circular logging.
        .PARAMETER Entries
            contains a list of flags, specified by number and separated by commas, that specify the types of information that should be logged. Valid numbers are 0 to 300. A range of numbers is valid, in addition to single numbers, such as 0-100,103,106. Value 0-300 is for logging all information.
        .PARAMETER Truncate
            truncate the file if it exists.
        .EXAMPLE
            Enable-W32tmPrivateLog -File C:\temp\priv.log.NOTES
            FunctionName : Enable-W32tmDebugLog
            Created by   : jspatton
            Date Coded   : 03/13/2015 11:30:25
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Enable-W32tmDebugLog
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [System.IO.FileSystemInfo]$File,
        [Parameter(Mandatory=$true)]
        [int]$Size,
        [Parameter(Mandatory=$true)]
        [validaterange(0,300)]
        [int]$Entries,
        [Parameter(Mandatory=$true)]
        [bool]$Truncate
        )
    Begin
    {
        Invoke-W32tm -Enable $true -File $File.FullName -Size $Size -Entries $Entries -Truncate $Truncate
        }
    Process
    {
        }
    End
    {
        }
    }
Export-ModuleMember *
Function Invoke-W32tm
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Register
            register to run as a service and add default configuration to the registry
        .PARAMETER Unregister
            unregister service and remove all configuration information from the registry.
        .PARAMETER Domain
            specifies which domain to monitor. If no domain name is given, or neither the domain nor computers option is specified, the default domain is used. This option may be used more than once.
        .PARAMETER Computers
            monitors the given list of computers. Computer names are separated by commas, with no spaces. If a name is prefixed with a '*', it is treated as an AD PDC. This option may be used more than once.
        .PARAMETER Threads
            how many computers to analyze simultaneously. The default value is 3. Allowed range is 1-50.
        .PARAMETER IpProtocol
            specify the IP protocol to use. The default is to use whatever is available.
        .PARAMETER NoWarn
            skip warning message.
        .PARAMETER NtTimeEpoch
            Convert a NT system time, in (10^-7)s intervals from 0h 1-Jan 1601, into a readable format.
        .PARAMETER NtpTimeEpoch
            Convert an NTP time, in (2^-32)s intervals from 0h 1-Jan 1900, into a readable format.
        .PARAMETER Computer
            computer that should resync. If not specified, the local computer will resync.
        .PARAMETER NoWait
            do not wait for the resync to occur; return immediately. Otherwise, wait for the resync to complete before returning.
        .PARAMETER Rediscover
            redetect the network configuration and rediscover network sources, then resynchronize.
        .PARAMETER Soft
            resync utilizing existing error statistics. Not useful, provided for compatibility.
        .PARAMETER Period
            the time between samples, in seconds. The default is 2s
        .PARAMETER Dataonly
            display only the data, no graphics.
        .PARAMETER Samples
            collect <count> samples, then stop. If not specified, samples will be collected until Ctrl-C is pressed.
        .PARAMETER Packetinfo
            print out NTP packet response message.
        .PARAMETER Update
            notifies the time service that the configuration has changed, causing the changes to take effect.
        .PARAMETER ManualPeerlist
            sets the manual peer list to <peers>, which is a space-delimited list of DNS and/or IP addresses. When specifying multiple peers, this switch must be enclosed in quotes.
        .PARAMETER SyncFromFlags
            sets what sources the NTP client should sync from. <source> should be a comma separated list of these keywords (not case sensitive):
            MANUAL - sync from peers in the manual peer list
            DOMHIER - sync from an AD DC in the domain hierarchy
            NO - sync from none
            ALL - sync from both manual and domain peers
        .PARAMETER LocalClockDispersion
            configures the accuracy of the internal clock that w32time will assume when it can't acquire time from its configured sources.
        .PARAMETER Reliable
            set whether this machine is a reliable time source. This setting is only meaningful on domain controllers.
            YES - this machine is a reliable time service
            NO - this machine is not a reliable time service
        .PARAMETER LargPhaseOffset
            sets the time difference between local and network time which w32time will consider a spike.
        .PARAMETER TimeZone
            Display the current time zone settings.
        .PARAMETER Subkey
            displays the values associated with subkey <key> of the default key.
        .PARAMETER Source
            display the time source.
        .PARAMETER Configuration
            display the configuration of run-time and where the setting comes from. In verbose mode, display the undefined or unused setting too.
        .PARAMETER Peers
            display a list of peers and their status.
        .PARAMETER Status
            display windows time service status.
        .PARAMETER Ver
            set the verbose mode to display more information.
        .PARAMETER Disable
            disable the private log.
        .PARAMETER Enable
            enable the private log.
        .PARAMETER File
            specify the absolute filename.
        .PARAMETER Size
            specify the maximum size for circular logging.
        .PARAMETER Entries
            contains a list of flags, specified by number and separated by commas, that specify the types of information that should be logged. Valid numbers are 0 to 300. A range of numbers is valid, in addition to single numbers, such as 0-100,103,106. Value 0-300 is for logging all information.
        .PARAMETER Truncate
            truncate the file if it exists.
        .NOTES
            FunctionName : Invoke-W32tm
            Created by   : jspatton
            Date Coded   : 03/12/2015 12:19:24
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/W32tm#Invoke-W32tm
        .LINK
            https://technet.microsoft.com/en-us/library/bb491016.aspx
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true, ParameterSetName='Register')]
        [switch]$Register,
        [Parameter(Mandatory=$true, ParameterSetName='UnRegister')]
        [switch]$Unregister,
        [Parameter(Mandatory=$false, ParameterSetName='Monitor')]
        [string]$Domain,
        [Parameter(Mandatory=$false, ParameterSetName='Monitor')]
        [string[]]$Computers,
        [Parameter(Mandatory=$false, ParameterSetName='Monitor')]
        [ValidateRange(1,50)]
        [int]$Threads,
        [Parameter(Mandatory=$false)]
        [ValidateSet(4,6)]
        [int]$IpProtocol,
        [Parameter(Mandatory=$false, ParameterSetName='Monitor')]
        [bool]$NoWarn,
        [Parameter(Mandatory=$true, ParameterSetName='Ntte')]
        [string]$NtTimeEpoch,
        [Parameter(Mandatory=$true, ParameterSetName='Ntpte')]
        [string]$NtpTimeEpoch,
        [Parameter(Mandatory=$false)]
        [string]$Computer,
        [Parameter(Mandatory=$false, ParameterSetName='Resync')]
        [bool]$NoWait,
        [Parameter(Mandatory=$false, ParameterSetName='Resync')]
        [bool]$Rediscover,
        [Parameter(Mandatory=$false, ParameterSetName='Resync')]
        [bool]$Soft,
        [Parameter(Mandatory=$false, ParameterSetName='Stripchart')]
        [int]$Period,
        [Parameter(Mandatory=$false, ParameterSetName='Stripchart')]
        [bool]$Dataonly,
        [Parameter(Mandatory=$false, ParameterSetName='Stripchart')]
        [int]$Samples,
        [Parameter(Mandatory=$false, ParameterSetName='Stripchart')]
        [bool]$Packetinfo,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [bool]$Update,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [string]$ManualPeerlist,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [string]$SyncFromFlags,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [int]$LocalClockDispersion,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [string]$Reliable,
        [Parameter(Mandatory=$false, ParameterSetName='Config')]
        [int]$LargPhaseOffset,
        [Parameter(Mandatory=$false, ParameterSetName='TZ')]
        [bool]$TimeZone,
        [Parameter(Mandatory=$false, ParameterSetName='dumpreg')]
        [string]$Subkey,
        [Parameter(Mandatory=$false, ParameterSetName='query')]
        [bool]$Source,
        [Parameter(Mandatory=$false, ParameterSetName='query')]
        [bool]$Configuration,
        [Parameter(Mandatory=$false, ParameterSetName='query')]
        [bool]$Peers,
        [Parameter(Mandatory=$false, ParameterSetName='query')]
        [bool]$Status,
        [Parameter(Mandatory=$false, ParameterSetName='query')]
        [bool]$Ver,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [bool]$Disable,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [bool]$Enable,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [string]$File,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [int]$Size,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [int]$Entries,
        [Parameter(Mandatory=$false, ParameterSetName='debug')]
        [bool]$Truncate
        )
    Begin
    {
        $W32tm = "W32tm /$($PSCmdlet.ParameterSetName.ToLower()) ";
        }
    Process
    {
        switch ($PSCmdlet.ParameterSetName.ToLower())
        {
            'register'
            {
                }
            'unregister'
            {
                }
            'monitor'
            {
                if (!($Domain -and $Computers))
                {
                    if ($Domain)
                    {
                        $W32tm += "/domain:$($Domain) "
                        }
                    if ($Computers)
                    {
                        $W32tm += "/computers:$($Computers) "
                        }
                    }
                if ($Threads)
                {
                    $W32tm += "/threads:$($Threads) "
                    }
                if ($IpProtocol)
                {
                    $W32tm += "/ipprotocol:$($IpProtocol) "
                    }
                if ($NoWarn)
                {
                    $W32tm += "/nowarn"
                    }
                }
            'ntte'
            {
                $W32tm += "$($NtTimeEpoch)"
                }
            'ntpte'
            {
                $W32tm += "$($NtpTimeEpoch)"
                }
            'resync'
            {
                if ($Computer)
                {
                    $W32tm += "/computer:$($Computer) "
                    }
                if ($NoWait)
                {
                    $W32tm += "/nowait "
                    }
                if ($Rediscover)
                {
                    $W32tm += "/rediscover "
                    }
                if ($Soft)
                {
                    $W32tm += "/soft"
                    }
                }
            'stripchart'
            {
                $W32tm += "/computer:$($Computer) "
                if ($Period)
                {
                    $W32tm += "/period:$($Period) "
                    }
                if ($Dataonly)
                {
                    $W32tm += "/dataonly "
                    }
                if ($Samples)
                {
                    $W32tm += "/samples:$($Samples) "
                    }
                if ($Packetinfo)
                {
                    $W32tm += "/packetinfo "
                    }
                if ($IpProtocol)
                {
                    $W32tm += "/ipprotocol:$($IpProtocol)"
                    }
                }
            'config'
            {
                $W32tm += "/computer:$($Computer) "
                if ($Update)
                {
                    $W32tm += "/update "
                    }
                if ($ManualPeerlist)
                {
                    $W32tm += "/manualpeerlist:$($ManualPeerlist) "
                    }
                if ($SyncFromFlags)
                {
                    $W32tm += "/syncfromflags:$($SyncFromFlags) "
                    }
                if ($LocalClockDispersion)
                {
                    $W32tm += "/localclockdispersion:$($LocalClockDispersion) "
                    }
                if ($Reliable -eq 'yes')
                {
                    $W32tm += "/reliable:yes "
                    }
                if ($Reliable -eq 'no')
                {
                    $W32tm += "/reliable:no "
                    }
                if ($LargPhaseOffset)
                {
                    $W32tm += "/largephaseoffset:$($LargPhaseOffset) "
                    }
                }
            'tz'
            {
                }
            'dumpreg'
            {
                if ($Subkey)
                {
                    if (!($Subkey -eq 'Root'))
                    {
                        $W32tm += "/subkey:$($Subkey) "
                        }
                    }
                if ($Computer)
                {
                    $W32tm += "/computer:$($Computer) "
                    }
                }
            'query'
            {
                if ($Computer)
                {
                    $W32tm += "/computer:$($Computer) "
                    }
                if ($Source)
                {
                    $W32tm += "/source "
                    }
                if ($Configuration)
                {
                    $W32tm += "/configuration "
                    }
                if ($Peers)
                {
                    $W32tm += "/peers "
                    }
                if ($Status)
                {
                    $W32tm += "/status "
                    }
                if ($Ver)
                {
                    $W32tm += "/verbose"
                    }
                }
            'debug'
            {
                if ($Disable)
                {
                    $W32tm += "/disable"
                    }
                if ($Enable)
                {
                    $W32tm += "/enable /file:$($File) /size:$($Size) /entries:$($Entries) "
                    if ($Truncate)
                    {
                        $W32tm += "/truncate "
                        }                        
                    }
                }
            }
        Write-Verbose $W32tm
        Invoke-Expression -Command $W32tm.Trim();
        }
    End
    {
        }
    }
