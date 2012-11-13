import-module ActiveDirectory
Get-ADGroup -SearchBase "ou=hidden,ou=ku_groups,dc=home,dc=ku,dc=edu" -searchscope OneLevel -filter { GroupCategory -eq "Security" } | .\Set-DefaultGroupAcl.ps1
