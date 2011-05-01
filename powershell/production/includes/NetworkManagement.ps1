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
                http://scripts.patton-tech.com/wiki/PowerShell/NetworkManagement#Get-HostName
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
			.DESCRIPTION
			.PARAMETER
			.EXAMPLE
			.NOTES
			.LINK
                http://scripts.patton-tech.com/wiki/PowerShell/NetworkManagement#
		#>
		
		Param
			(
				[Parameter(Mandatory=$true)]
				[string]$Computer
            )
		[System.Net.Dns]::GetHostAddresses($Computer)
	}
Function Get-NetstatReport
    {
        <#
            .SYNOPSIS
            .DESCRIPTION
            .EXAMPLE
            .NOTES
            .LINK
                http://scripts.patton-tech.com/wiki/PowerShell/NetworkManagement#
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