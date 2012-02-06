Function Get-HostName
	{
		<#
			.SYNOPSIS
				Returns the hostname from the provided IP
			.DESCRIPTION
				Reutrns an object that contains the hostname from a DNS server query
			.PARAMETER ComputerName
				The IP Address of a computer
			.EXAMPLE
                Get-HostName -ComputerName 127.0.0.1

                HostName                          Aliases                          AddressList
                --------                          -------                          -----------
                MyPC                              {}                               {fe80::d5af:b64e:c661:9202%18...

                Description
                -----------
                The output of the function.
			.NOTES
			.LINK
                https://code.google.com/p/mod-posh/wiki/NetworkManagement#Get-HostName
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ComputerName
            )
		[System.Net.Dns]::GetHostEntry($ComputerName)
	}
Function Get-HostIp
	{
		<#
			.SYNOPSIS
                Returns a list of IP's for the specified host.
			.DESCRIPTION
                Returns a list of IP's for the specified host.
			.PARAMETER ComputerName
                NetBIOS name of a computer
			.EXAMPLE
                Get-HostIp -Computer MyPC |Format-Table

                Address      AddressFamil      ScopeId IsIPv6Multic IsIPv6LinkL IsIPv6SiteL IPAddressTo SortableAdd
                                        y                       ast        ocal        ocal String             ress
                -------      ------------      ------- ------------ ----------- ----------- ----------- -----------
                             ...NetworkV6           18        False        True       False fe80::d5... ...7261E+38
                             ...NetworkV6           19        False        True       False fe80::95... ...7261E+38
                             ...NetworkV6           11        False        True       False fe80::48... ...7261E+38
                             ...NetworkV6           12        False        True       False fe80::20... ...7261E+38
                16820416     InterNetwork                     False       False       False 192.168.0.1  3232235521
                31631552     InterNetwork                     False       False       False 192.168....  3232293377
                553717932    InterNetwork                     False       False       False 172.16.1.33  2886730017
                             ...NetworkV6            0        False       False       False 2001:0:4... ...1596E+37

                Description
                -----------
                This example shows the output of the function.
			.NOTES
			.LINK
                https://code.google.com/p/mod-posh/wiki/NetworkManagement#Get-HostIp
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$ComputerName
            )
		[System.Net.Dns]::GetHostAddresses($ComputerName)
	}
Function Get-NetstatReport
    {
        <#
            .SYNOPSIS
                Returns the output of netstat -anop TCP|UDP
            .DESCRIPTION
                Returns the output of netstat -anop TCP|UDP in a format that can be processed by the built-in
                PowerShell commands.
            .EXAMPLE
                Get-NetstatReport |Format-Table

                PID       ProcessNa LocalAddr State     User      ProcessPa RemoteAdd LocalPort Protocol  RemotePor
                          me        ess                           th        ress                          t
                ---       --------- --------- -----     ----      --------- --------- --------- --------  ---------
                792       svchost   0.0.0.0   LISTENING                     0.0.0.0   135       TCP       0
                4         System    0.0.0.0   LISTENING                     0.0.0.0   445       TCP       0
                2324      vmware... 0.0.0.0   LISTENING                     0.0.0.0   912       TCP       0
                2992      svchost   0.0.0.0   LISTENING                     0.0.0.0   990       TCP       0
                468       wininit   0.0.0.0   LISTENING                     0.0.0.0   1025      TCP       0
                976       svchost   0.0.0.0   LISTENING                     0.0.0.0   1026      TCP       0

                Description
                -----------
                Sample output of the function after being piped into Format-Table
            .NOTES
                Functionized the get-netstat code found on http://poshcode.org/get/592. The version on poshcode 
                objectified each line and returned that line. This version creates an object above the for and adds the 
                noteproperties inside the loop.
            .LINK
                https://code.google.com/p/mod-posh/wiki/NetworkManagement#Get-NetstatReport
        #>
        $netstat = netstat -a -n -o | where-object { $_ -match "(UDP|TCP)" }
        [regex]$regexTCP = '(?<Protocol>\S+)\s+((?<LAddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<LAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<Lport>\d+)\s+((?<Raddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<RAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<RPort>\d+)\s+(?<State>\w+)\s+(?<PID>\d+$)'

        [regex]$regexUDP = '(?<Protocol>\S+)\s+((?<LAddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<LAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<Lport>\d+)\s+(?<RAddress>\*)\:(?<RPort>\*)\s+(?<PID>\d+)'
        $Report = @()

        foreach ($Line in $Netstat)
        {
            switch -regex ($Line.Trim())
            {
                $RegexTCP
                {
                    $MyProtocol = $Matches.Protocol
                    $MyLocalAddress = $Matches.LAddress
                    $MyLocalPort = $Matches.LPort
                    $MyRemoteAddress = $Matches.Raddress
                    $MyRemotePort = $Matches.RPort
                    $MyState = $Matches.State
                    $MyPID = $Matches.PID
                    $MyProcessName = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).ProcessName
                    $MyProcessPath = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).Path
                    $MyUser = (Get-WmiObject -Class Win32_Process -Filter ("ProcessId = "+$Matches.PID)).GetOwner().User
                }
                $RegexUDP
                {
                    $MyProtocol = $Matches.Protocol
                    $MyLocalAddress = $Matches.LAddress
                    $MyLocalPort = $Matches.LPort
                    $MyRemoteAddress = $Matches.Raddress
                    $MyRemotePort = $Matches.RPort
                    $MyState = $Matches.State
                    $MyPID = $Matches.PID
                    $MyProcessName = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).ProcessName
                    $MyProcessPath = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).Path
                    $MyUser = (Get-WmiObject -Class Win32_Process -Filter ("ProcessId = "+$Matches.PID)).GetOwner().User
                }
            }
            $LineItem = New-Object -TypeName PSobject -Property @{
                Protocol = $MyProtocol
                LocalAddress = $MyLocalAddress
                LocalPort = $MyLocalPort
                RemoteAddress = $MyRemoteAddress
                RemotePort = $MyRemotePort
                State = $MyState
                PID = $MyPID
                ProcessName = $MyProcessName
                ProcessPath = $MyProcessPath
                User = $MyUser
            }
            $Report += $LineItem
        }
        Return $Report
    }
