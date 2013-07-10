$SiteCode = "sms"
$Source = "\\server1\APPS"
$Destination = "\\server2\APPS"

$Packages = Get-WMIObject -namespace "root\sms\site_$($SiteCode)" -class SMS_Package
foreach ($Package in $Packages) 
{
    $Id = $Package.PackageID
    $ThisPackage = Get-WMIObject -namespace "root\sms\site_$($SiteCode)" -class SMS_Package -filter "PackageID=$($Id)"

    foreach ($Item in $ThisPackage) 
    {
        $Path = $Item.PkgSourcePath.Replace($Source, $Destination)
        $Item.PkgSourcePath = $Path
        $Item.Put()
        }
    }