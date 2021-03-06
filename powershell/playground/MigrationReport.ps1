Function Get-NonMigratedUsers
{
    $NonMigCSV = Get-ChildItem -Path '\\node2.soecs.ku.edu\c$\scripts\LogFiles\*NonMigrated.csv'
    $HitList = @()
    foreach($NonMig in $NonMigCSV)
    {
        $ThisList = $null
        $ThisList = Import-Csv -Path $NonMig.FullName |Sort-Object -Property UserName
        $HitList += $ThisList |Get-Unique -AsString
        }
    $HitList = $HitList |Sort-Object -Property UserName -Unique
    Return $HitList
}

Function Get-UserBreakdown
{
    $Members = Get-ADGroupMembers -UserGroup "ENGR Lab Users" -UserDomain "LDAP://DC=home,DC=ku,DC=edu"

    $alphabet = @()
    $Breakdown = @()  
    for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)
    {
        $alphabet += [char]$c
        }
    foreach($Letter in $alphabet)
    {
        $Counter=$null
        foreach($Member in $Members |Where-Object {$_.name -like "$($Letter)*"})
        {
            $Counter++
            }
        $ThisLetter = New-Object -TypeName PSObject -Property @{
            Letter = $Letter
            Count = $Counter
            }
        # Write-Output "$($Letter)'s: $($Counter)"
        $Breakdown += $ThisLetter
        }
    Return $Breakdown
}
#$Letter = Read-Host "Please enter a letter"
#$UserBreakdown = Get-UserBreakdown
#Write-Host "There are " ($UserBreakdown |Where-Object {$_.Letter -eq $Letter}).Count " Letter $($Letter)`'s to process"
$LegacyUsers = Get-ADGroupMembers -UserGroup LegacyProfile -UserDomain "LDAP://DC=soecs,DC=ku,DC=edu"
Write-Host "There are $($LegacyUsers.Count) left to migrate."
$NonMigratedUsers = Get-NonMigratedUsers
Write-Host "There are $($NonMigratedUsers.Count) that were not migrated due to error or connection state."