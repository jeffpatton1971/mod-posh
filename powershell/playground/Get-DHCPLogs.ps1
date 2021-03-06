Function Get-DHCPLogs
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LogLocation
        .PARAMETER Version
        .PARAMETER MACFilter
        .EXAMPLE
        .NOTES
            FunctionName : Get-DHCPLogs
            Created by   : jspatton
            Date Coded   : 01/06/2012 13:47:32
        .LINK
            http://scripts.patton-tech.com/wiki/PowerShell/Untitled1#Get-DHCPLogs
    #>
    Param
        (
            $LogLocation = 'C:\Windows\System32\dhcp',
            $Version = 'v4',
            $MACFilter = ''
        )
    Begin
    {
        $Headers = "ID","Date","Time","Description","IP Address","Host Name","MAC Address","User Name","TransactionID","QResult","Probationtime","CorrelationID","Dhcid"
        $DHCPLogs = @()
        }
    Process
    {
        if ($Version -eq 'v4')
        {
            $LogFiles = Get-ChildItem "$($LogLocation)\DhcpSrvLog-*.log"
            }
        else
        {
            $LogFiles = Get-ChildItem "$($LogLocation)\DhcpV6SrvLog-*.log"
            }
        foreach ($LogFile in $LogFiles)
        {
            $ThisLog = Import-Csv $LogFile.FullName -Header $Headers
            $DHCPLogs += $ThisLog[33..($ThisLog.Count)]
            }
        }
    End
    {
        if ($MACFilter -ne '')
        {
            
            Return $DHCPLogs |Where-Object {$_."MAC Address" -eq $MACFilter}
            }
        else
        {
            Return $DHCPLogs
            }
        }
    }