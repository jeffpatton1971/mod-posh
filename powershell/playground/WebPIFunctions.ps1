$RemoteList = ".\srv1-remote-installed.txt"
$WebPICmd = "& .\WebpiCmdLine.exe"

$WebPIList = "$($WebPICmd) /List:Installed"
$WebPIInstall = "$($WebPICmd) /Products:"

$RemoteWebPIList = Get-Content $RemoteList
$LocalWebPIList = Invoke-Expression $WebPIList

foreach ($Item in $RemoteWebPIList)
{
    if ($LocalWebPIList -contains $Item)
    {}
    else
    {
        $WebPIInstall = "$($WebPICmd) /Products:$($Item.Substring(0,$item.IndexOf(" "))) /MySQLPassword:N^msjc4d /AcceptEula /SuppressReboot"
        $WebPIInstall
        Invoke-Expression $WebPIInstall
        }
    }

$Top = $True
Foreach ($Item in $WebPIList)
{
    if ($Top -eq $True)
    {
        if ($Item.IndexOf("ID") -eq 0)
        # Application listing begins after this line
        {
            $Top = $False
            }
        }
    else
    {
        If ($Item -ne "----------------------------------------")
        # This skips the line after ID
        {
            $WebPIFeature = $Item.Substring(0,$item.IndexOf(" "))
            $WebPIFeature
            }
        }
    }    