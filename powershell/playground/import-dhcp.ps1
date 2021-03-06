Get-Content .\dhcpd.leases~ |Select-String "hardware ethernet" |foreach {$_.ToString().Replace("hardware ethernet ","").Replace(":","-").Replace(";","").Trim()} |Sort-Object
$Classes = Get-Content .\admin.class
foreach ($line in $Classes)
{
    if (($line.Trim()).StartsWith("hardware ethernet"))
    {
        Write-Verbose "Found a mac address"
        $Mac = ($line.Replace("hardware ethernet ","")).Replace(";","").Trim()
        $FoundMac = $true
        }
    if ($line.Trim().StartsWith("subclass"))
    {
        Write-Verbose "Found a mac address"
        if ($line.EndsWith(";"))
        {
            $Mac = $line.Substring(($line.Length)-18,17).Trim()
            }
        else
        {
            $Mac = $line.Substring(($line.Length)-19,18).Trim()
            }
        $FoundMac = $true
        }
    }