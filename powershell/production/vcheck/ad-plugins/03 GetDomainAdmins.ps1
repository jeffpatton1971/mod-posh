$Title = "Active Directory: Domain Admins"
$Header ="Domain Admin Accounts"
$Comments = "Get a listing of current Domain Administrators."
$Display = "List"
$Author = "Jeff Patton"
$PluginVersion = 1
$PluginCategory = "AD"

$DomainAdmins = Get-ADGroupMembers -UserGroup 'Domain Admins' |Select-Object -Property Name

$Report = New-Object -TypeName PSObject
$Count = 0
foreach ($DomainAdmin in $DomainAdmins)
{
    $Count ++
    Add-Member -InputObject $Report -Value $DomainAdmin.name -MemberType 'NoteProperty' -Name "Admin $($Count)"
    }
    
$Report