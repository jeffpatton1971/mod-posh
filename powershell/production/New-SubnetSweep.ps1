<#
    .SYNOPSIS
        A script to sweep the local subnet.
    .DESCRIPTION
        This script will sweep the local subnet for active computers. If a computer
        responds to a ping request, it is considered active and a portscan is done
        on some common Windows TCP ports.
        
        The following data is returned as part of the script.
            Name      : The hostname of the computer
            IPAddress : The IP address of the computer
            MAC       : The Mac Address of the computer
            PortList  : The list of open ports
        
        This data is all returned as an object suitable for piping into and out
        of various cmdlets.
    .PARAMETER Range
        This is the 4th octect in the range of IP's to sweep.
    .PARAMETER Subnet
        This is the Subnet ID portion of the IP range.
    .PARAMETER Ports
        This is a listing of ports to check on the remote machine to see if a
        connection can be established.
    .EXAMPLE
        .\New-SubnetSweep.ps1 -Range 1..10 -Subnet 192.168.1 -Ports 135,139, 80
        
        Name                 PortList       MAC          IP
        ----                 --------       ---          --
        Router               {135, 139, 80}              192.168.1.1
        192.168.1            {80}           AABBCCDDEEFF 192.168.1.7
        webserver1           {80}           BBCCDDEEFF00 192.168.1.8
        webserver2           {80}           CCDDEEFF0011 192.168.1.9

    .NOTES
        ScriptName : New-SubnetSweep.ps1
        Created By : jspatton
        Date Coded : 04/17/2012 16:05:22
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/New-SubnetSweep.ps1
#>
[CmdletBinding()]
Param
    (
    $Range = 1..25,
    $Subnet = '10.133.3',
    $Ports = @(135,139,445,67,68,53,143,993,389,636,110,995,25,119,563,21,20,80,443,531,2053,543,464,88,544)
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        $Report = @()
        }
Process
    {
    foreach ($Octet in $Range)
        {
            Write-Verbose "Building the IP address $($Subnet).$($Octet)"
            $IPAddress = "$($Subnet).$($Octet)"
            Write-Verbose "Resetting variables"
            $IP = $null
            $Mac = $null
            $MacAddress = $null
            $PortList = @()
            try
            {
                Write-Verbose "Attempting to connect to $($IPAddress)"
                $IP = Test-Connection -ComputerName $IPAddress -Count 1 -ErrorAction Stop
                Write-Verbose "Get MAC address informatino from Arp"
                $Mac = (& arp -a $IP.Address)
                Write-Verbose "Strip Arp data down to just a MAC"
                $MacAddress = ($mac | ? { $_ -match $IP.Address } ) -match "([0-9A-F]{2}([:-][0-9A-F]{2}){5})"
                if ($Matches)
                {
                    try
                    {
                        Write-Verbose "Validate that $($MacAddress) is a properly formatted MAC address"
                        $mac = [system.net.networkinformation.physicaladdress]::parse($Matches[0].ToUpper())
                        }
                    catch
                    {
                        Write-Verbose "$($MacAddress) is not a proper Mac address"
                        $mac = ''
                        }
                    }
                foreach ($Port in $Ports)
                {
                    Write-Verbose "Create a TCP client"
                    $Socket = New-Object System.Net.Sockets.TcpClient
                    Write-Verbose "Define timeouts, 1000ms for Receive and 2000ms for Send"
                    $Socket.Client.ReceiveTimeout = 1000
                    $Socket.Client.SendTimeout = 2000
                    try
                    {
                        Write-Verbose "Attempt to connect to Port: $($Port) on IP: $($IP.Address)"
                        $Socket.Connect($IP.Address, $port)
                        $Result = $Socket.Connected
                        if ($Result -eq $true)
                        {
                            Write-Verbose "Established a connection, TCP port $($Port) open"
                            $Portlist += $Port
                            }
                        }
                    catch
                    {
                        }
                    Write-Verbose "Close TCP client"
                    $Socket.Close()
                    }
                Write-Verbose "Resolve hostname for $($IP.Address)"
                $Name = [System.Net.Dns]::GetHostEntry($IP.Address).Hostname
                Write-Verbose "Creating return object for output"
                $ThisHost = New-Object -TypeName PSObject -Property @{
                    IP = $IP.Address
                    Name = $Name
                    MAC = $Mac
                    PortList = $PortList
                    }
                $Report += $ThisHost
                }
            catch
            {
                $Message = $Error[0].Exception
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                $IP = $null
                $Mac = $null
                $MacAddress = $null
                }
            }
        }
End
    {
        Return $Report
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }