<#
CN=Computer,CN=Schema,CN=Configuration,DC=home,DC=ku,DC=edu
CN=Group,CN=Schema,CN=Configuration,DC=home,DC=ku,DC=edu
CN=Organizational-Unit,CN=Schema,CN=Configuration,DC=home,DC=ku,DC=edu
CN=Person,CN=Schema,CN=Configuration,DC=home,DC=ku,DC=edu
#>
$ComputerArray = @()
$GroupArray = @()
$OrganizationalUnitArray = @()
$PersonArray = @()
$ErrorObjects = @()
$Objects = Get-ADObjects -ADSPath "ou=school of engineering,dc=home,dc=ku,dc=edu" -SearchFilter "(objectClass=*)"
foreach ($Object in $Objects)
{
    $switchValue = ([string]$Object.Properties.Item('objectCategory')).Split(',')[0]

    switch ($switchValue.ToLower())
    {
        'CN=Computer'
        {
            try
            {
                $Fields = @()
                $Object.Properties.PropertyNames |foreach {if ($_){$Fields += $_}}
                $MyObject = New-Object -TypeName PSobject
                for ($i=0;$i -lt $Fields.Count;$i++)
                {
                    Add-Member -InputObject $MyObject -MemberType NoteProperty -Name $Fields[$i] -Value ($Object.Properties.Item($Fields[$i])).Item(0) -ErrorAction Stop
                    }
                $ComputerArray += $MyObject
                }
            catch
            {
                $myError = New-Object -TypeName psobject -Property @{
                    samAccountName = $Object.Properties.Item('samaccountname')
                    objectCategory = $Object.Properties.Item('objectCategory')
                    }
                $ErrorObjects += $myError
                }
            }
        'CN=Group'
        {
            try
            {
                $Fields = @()
                $Object.Properties.PropertyNames |foreach {if ($_){$Fields += $_}}
                $MyObject = New-Object -TypeName PSobject
                for ($i=0;$i -lt $Fields.Count;$i++)
                {
                    Add-Member -InputObject $MyObject -MemberType NoteProperty -Name $Fields[$i] -Value ($Object.Properties.Item($Fields[$i])).Item(0) -ErrorAction Stop
                    }
                $GroupArray += $MyObject
                }
            catch
            {
                $myError = New-Object -TypeName psobject -Property @{
                    samAccountName = $Object.Properties.Item('samaccountname')
                    objectCategory = $Object.Properties.Item('objectCategory')
                    }
                $ErrorObjects += $myError
                }
            }
        'CN=Organizational-Unit'
        {
            try
            {
                $Fields = @()
                $Object.Properties.PropertyNames |foreach {if ($_){$Fields += $_}}
                $MyObject = New-Object -TypeName PSobject
                for ($i=0;$i -lt $Fields.Count;$i++)
                {
                    Add-Member -InputObject $MyObject -MemberType NoteProperty -Name $Fields[$i] -Value ($Object.Properties.Item($Fields[$i])).Item(0) -ErrorAction Stop
                    }
                $OrganizationalUnitArray += $MyObject
                }
            catch
            {
                $myError = New-Object -TypeName psobject -Property @{
                    samAccountName = $Object.Properties.Item('samaccountname')
                    objectCategory = $Object.Properties.Item('objectCategory')
                    }
                $ErrorObjects += $myError
                }
            }
        'CN=Person'
        {
            try
            {
                $Fields = @()
                $Object.Properties.PropertyNames |foreach {if ($_){$Fields += $_}}
                $MyObject = New-Object -TypeName PSobject
                for ($i=0;$i -lt $Fields.Count;$i++)
                {
                    Add-Member -InputObject $MyObject -MemberType NoteProperty -Name $Fields[$i] -Value ($Object.Properties.Item($Fields[$i])).Item(0) -ErrorAction Stop
                    }
                $PersonArray += $MyObject
                }
            catch
            {
                $myError = New-Object -TypeName psobject -Property @{
                    samAccountName = $Object.Properties.Item('samaccountname')
                    objectCategory = $Object.Properties.Item('objectCategory')
                    }
                $ErrorObjects += $myError
                }
            }
        default
        {
            Write-Error 'found a thing'
            }
        }
    }
if ($ErrorObjects)
{
    $ErrorObjects |Format-List
    }