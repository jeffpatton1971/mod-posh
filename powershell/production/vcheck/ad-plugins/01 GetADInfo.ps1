$Title = "Active Directory: Basic Active Directory Information"
$Header ="Basic AD Information"
$Comments = "Get basic information about the Domain, Domain Mode, Domain Controlelrs, User and Computer Count."
$Display = "List"
$Author = "Jeff Patton"
$PluginVersion = 1
$PluginCategory = "AD"

$Computers = Get-ADObjects -ADSPath (([ADSI]"").distinguishedName)
$TotalComputerCount = $Computers.Count

$Users = Get-ADObjects -ADSPath (([ADSI]"").distinguishedName) -SearchFilter '(objectCategory=user)'
$TotalUserCount = $Users.Count

$StaleComputers = Get-StaleComputerAccounts -ADSPath (([ADSI]"").distinguishedName) -DayOffset 90
$TotalStaleComputers = $StaleComputers.Count

$myDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

$Report = New-Object -TypeName PSOBject -Property @{
    "Total Computer Count" = $TotalComputerCount
    "Total User Count" = $TotalUserCount
    "Total Stale Computers" = $TotalStaleComputers
    "Domain Name" = $myDomain.Name
    "Domain Mode" = $myDomain.DomainMode
    "Num Domain Contollers" = ($myDomain.DomainControllers).Count
    "Num Forest Domains" = ($myDomain.Forest.Domains).Count
    }

$Report