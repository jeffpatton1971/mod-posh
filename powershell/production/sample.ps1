$PolicyFiles = Get-ChildItem \\home.ku.edu\SYSVOL\home.ku.edu\Policies -Filter "{*}"
$Report = @()
foreach ($PofilePath in $PolicyFiles)
{
    $Guid = $PofilePath.Name.Replace('{','').Replace('}','')
    foreach ($File in (Get-ChildItem $PofilePath.FullName -Recurse))
    {
        if ($File.Extension -eq ".xml")
        {
            if ($File.Name -eq 'groups.xml')
            {
                $groupFile = ([xml](Get-Content $File.fullname)).Groups.User.Properties
                if ($groupFile.cpassword)
                {
                    $item = New-Object -TypeName PSobject -Property @{
                        GpoGuid = (Get-GPO -GpoID $Guid -Domain 'home.ku.edu').DisplayName
                        username = $groupFile.username
                        newname = $groupFile.newname
                        cpassword = $groupFile.cpassword
                        }
                    }
                $Report += $Item
                }
            }
        }
    }