$groups = Get-ADObjects -SearchFilter "(objectCategory=group)" -ADSPath "LDAP://OU=Undergraduate,OU=Security Groups,DC=soecs,DC=ku,DC=edu"
foreach ($group in $groups)
    {
        $groupitem = $group.Properties
        $members = Get-ADObjects -ADProperties "member" -SearchFilter "(objectCategory=group)" -ADSPath $groupitem.adspath 
        $groupitem.adspath
        foreach ($member in $members)
            {
                $memberitem = $member.Properties
                foreach ($item in $memberitem.member)
                    {
                        $users = Get-ADObjects -ADProperties "samAccountName" -SearchFilter "(objectCategory=user)" -adspath $item
                        foreach ($user in $users)
                            {
                                $useritem = $user.Properties
                                $userItem.samaccountname
                                }
                        }
                }
        }