Function Reset-Spn {
 <#
 .SYNOPSIS
 Reset the SPN for a given account
 .DESCRIPTION
 If the SPNs that you see for your server display what seems to be
 incorrect names; consider resetting the computer to use the default
 SPNs.

 To reset the default SPN values, use the setspn -r hostname
 command at a command prompt, where hostname is the actual host name
 of the computer object that you want to update.

 For example, to reset the SPNs of a computer named server2, type
 setspn -r server2, and then press ENTER. You receive confirmation
 if the reset is successful. To verify that the SPNs are displayed
 correctly, type setspn -l server2, and then press ENTER.
 .PARAMETER AccountName
 The actual hostname of the computer object that you want to update,
 if blank we default to the value of parameter Namem.
 .EXAMPLE
 Reset-Spn -AccountName server-01

 Service           Name                  Hostname  SPN
 -------           ----                  --------  ---
 HOST              server-01.company.com server-01 HOST/server-01.company.com
 HOST              server-01             server-01 HOST/server-01
 RestrictedKrbHost server-01.company.com server-01 RestrictedKrbHost/server-01.company.com
 RestrictedKrbHost server-01             server-01 RestrictedKrbHost/server-01
 WSMAN             server-01.company.com server-01 WSMAN/server-01.company.com
 WSMAN             server-01             server-01 WSMAN/server-01
 TERMSRV           server-01.company.com server-01 TERMSRV/server-01.company.com
 TERMSRV           server-01             server-01 TERMSRV/server-01
 CmRcService       server-01             server-01 CmRcService/server-01
 CmRcService       server-01.company.com server-01 CmRcService/server-01.company.com

 Description
 -----------

 This example shows how to reset the spn of a given account. This would
 be used if you were experiencing issues with service account logins.
 See the Link section for relevant URL's.
 .NOTES
 FunctionName : Reset-Spn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:07:12
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Reset-Spn
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 .LINK
 http://technet.microsoft.com/en-us/library/579246c8-2e32-4282-bce7-3209d1ea8bf1
 #>
 [CmdletBinding()]
 Param
 (
  [string]$AccountName
 )
 Begin {
  if ($AccountName.IndexOfAny(".") -gt 0) {
   Write-Verbose "Found FQDN name, stripping down to hostname"
   $AccountName = $AccountName.Substring(0, $AccountName.IndexOfAny("."))
  }
  try {
   Write-Verbose "Bind to AD"
   [string]$SearchFilter = "(&(objectCategory=computer)(cn=$($AccountName)))"
   $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
   $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
   $DirectorySearcher.SearchRoot = $DirectoryEntry
   $DirectorySearcher.PageSize = 1000
   $DirectorySearcher.Filter = $SearchFilter
   $DirectorySearcher.SearchScope = "Subtree"

   Write-Verbose "Find $($AccountName)"
   $Account = $DirectorySearcher.FindOne()
  }
  catch {
   Write-Error $Error[0]
   Return
  }
 }
 Process {
  try {
   $Account = $Account.GetDirectoryEntry()
   $HostSpns = $Account.servicePrincipalName | Where-Object { $_ -like "host/$($AccountName)*" }
   if ($HostSpns.Count -ne 2) {
    Write-Verbose "Host SPN count is $($HostSpns.Count)"
    foreach ($HostSpn in $HostSpns) {
     Write-Verbose "Removing $($HostSpn)"
     $Account.servicePrincipalName.Remove($HostSpn)
    }
    Write-Verbose "Adding HOST/$($AccountName)"
    $Account.servicePrincipalName += "HOST/$($AccountName)"
    Write-Verbose "Adding HOST/$($Account.dNSHostName)"
    $Account.servicePrincipalName += "HOST/$($Account.dNSHostName)"
    $Account.CommitChanges()
   }
   else {
    Return "Nothing to do"
   }
  }
  catch {
   Write-Error $Error[0]
   Return
  }
 }
 End {
  $SpnReport = @()
  foreach ($Item in $Account.servicePrincipalName) {
   $spn = $Item.Split("/")
   $SpnItem = New-Object -TypeName PSobject -Property @{
    Service  = $Spn[0]
    Name     = $Spn[1]
    Hostname = $AccountName
    SPN      = $Item
   }
   $SpnReport += $SpnItem
  }
  Return $SpnReport | Select-Object -Property Service, Name, Hostname, SPN
 }
}
Function Add-Spn {
 <#
 .SYNOPSIS
 Adds a Service Principal Name to an account
 .DESCRIPTION
 To add an SPN, use the setspn -s service/name hostname command at a
 command prompt, where service/name is the SPN that you want to add
 and hostname is the actual host name of the computer object that
 you want to update.

 For example, if there is an Active Directory domain controller with
 the host name server1.contoso.com that requires an SPN for the
 Lightweight Directory Access Protocol (LDAP), type
 setspn -s ldap/server1.contoso.com server1, and then press ENTER
 to add the SPN.
 .PARAMETER Service
 The name of the service to add
 .PARAMETER Name
 The name that will be associated with this service on this account
 .PARAMETER AccountName
 The actual hostname of the computer object that you want to update,
 if blank we default to the value of parameter Namem.
 .PARAMETER UserAccount
 A switch to add SPN's to a user object
 .PARAMETER NoDupes
 Checks the domain for duplicate SPN's
 .PARAMETER ForestWide
 A switch to check for duplicate SPN's across the entire forest
 .EXAMPLE
 Add-Spn -Service foo -Name server-01

 Service           Name                  Hostname  SPN
 -------           ----                  --------  ---
 foo               server-01             server-01 foo/server-01
 HOST              server-01             server-01 HOST/server-01
 CmRcService       server-01.company.com server-01 CmRcService/server-01.company.com
 CmRcService       server-01             server-01 CmRcService/server-01
 TERMSRV           server-01             server-01 TERMSRV/server-01
 TERMSRV           server-01.company.com server-01 TERMSRV/server-01.company.com
 WSMAN             server-01             server-01 WSMAN/server-01
 WSMAN             server-01.company.com server-01 WSMAN/server-01.company.com
 RestrictedKrbHost server-01             server-01 RestrictedKrbHost/server-01
 RestrictedKrbHost server-01.company.com server-01 RestrictedKrbHost/server-01.company.com
 HOST              server-01.company.com server-01 HOST/server-01.company.com

 Description
 -----------

 This example shows how to add an spn to an account
 .EXAMPLE
 Add-Spn -Service bar -Name server-01 -NoDupes

 Service           Name                  Hostname  SPN
 -------           ----                  --------  ---
 bar               server-01             server-01 bar/server-01
 HOST              server-01.company.com server-01 HOST/server-01.company.com
 RestrictedKrbHost server-01.company.com server-01 RestrictedKrbHost/server-01.company.com
 RestrictedKrbHost server-01             server-01 RestrictedKrbHost/server-01
 WSMAN             server-01.company.com server-01 WSMAN/server-01.company.com
 WSMAN             server-01             server-01 WSMAN/server-01
 TERMSRV           server-01.company.com server-01 TERMSRV/server-01.company.com
 TERMSRV           server-01             server-01 TERMSRV/server-01
 CmRcService       server-01             server-01 CmRcService/server-01
 CmRcService       server-01.company.com server-01 CmRcService/server-01.company.com
 HOST              server-01             server-01 HOST/server-01
 foo               server-01             server-01 foo/server-01

 Description
 -----------

 This example shows how to add an spn to an account while making sure it's
 unique within the domain. Add the -ForestWide switch to check across all
 domains in the forest.
 .NOTES
 FunctionName : Add-Spn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:07:12
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Add-Spn
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Service,
  [string]$Name,
  [string]$AccountName = $Name,
  [switch]$UserAccount,
  [switch]$NoDupes ,
  [switch]$ForestWide
 )
 Begin {
  if ($AccountName.IndexOfAny(".") -gt 0) {
   Write-Verbose "Found FQDN name, stripping down to hostname"
   $AccountName = $AccountName.Substring(0, $AccountName.IndexOfAny("."))
  }
  $DupeFound = $false
  if ($NoDupes) {
   $SearchFilter = "(servicePrincipalName=$($Service)/$($Name))"
   try {
    if ($ForestWide) {
     $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
     $Domains = $Forest.Domains
    }
    else {
     $Domains = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    }
    foreach ($Domain in $Domains) {
     Write-Verbose "Bind to $($Domain.Name)"
     $DirectoryEntry = $Domain.GetDirectoryEntry()
     $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
     $DirectorySearcher.SearchRoot = $DirectoryEntry
     $DirectorySearcher.PageSize = 1000
     $DirectorySearcher.Filter = $SearchFilter
     $DirectorySearcher.SearchScope = "Subtree"

     Write-Verbose "Find $($AccountName)"
     $Account = $DirectorySearcher.FindAll()

     if ($Account.Count -gt 0) {
      Write-Host "Duplicate SPN ($($Service)/$($Name)) found for $($AccountName)"
      $DupeFound = $true
     }
    }
   }
   catch {
    Write-Error $Error[0]
    Return
   }
  }
  if (!($DupeFound)) {
   if ($UserAccount) {
    Write-Verbose "Setting the SearchFilter to objectCategory user"
    [string]$SearchFilter = "(&(objectCategory=user)(cn=$($AccountName)))"
   }
   else {
    Write-Verbose "Setting the SearchFilter to objectCategory computer"
    [string]$SearchFilter = "(&(objectCategory=computer)(cn=$($AccountName)))"
   }

   try {
    Write-Verbose "Bind to AD"
    $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
    $DirectorySearcher.SearchRoot = $DirectoryEntry
    $DirectorySearcher.PageSize = 1000
    $DirectorySearcher.Filter = $SearchFilter
    $DirectorySearcher.SearchScope = "Subtree"

    Write-Verbose "Find $($AccountName)"
    $Account = $DirectorySearcher.FindOne()
   }
   catch {
    Write-Error $Error[0]
    Return
   }
  }
  else {
   break
  }
 }
 Process {
  try {
   Write-Verbose "Connect to $($AccountName)"
   $Account = $Account.GetDirectoryEntry()
   $Spn = "$($Service)/$($Name)"
   Write-Verbose "Add SPN ($($Service)/$($Name)) to the list of existing SPNs"
   $Account.servicePrincipalName += $Spn
   $Account.CommitChanges()
  }
  catch {
   Write-Error $Error[0]
   Return
  }
 }
 End {
  foreach ($Item in $Account.servicePrincipalName) {
   $spn = $Item.Split("/")
   New-Object -TypeName PSobject -Property @{
    Service  = $Spn[0]
    Name     = $Spn[1]
    Hostname = $AccountName
    SPN      = $Item
   } | Select-Object -Property Service, Name, Hostname, SPN
  }
 }
}
Function Remove-Spn {
 <#
 .SYNOPSIS
 Removes a Service Principal Name from an account
 .DESCRIPTION
 To remove an SPN, use the setspn -d service/namehostname command at
 a command prompt, where service/name is the SPN that is to be
 removed and hostname is the actual host name of the computer object
 that you want to update.

 For example, if the SPN for the Web service on a computer named
 Server3.contoso.com is incorrect, you can remove it by typing
 setspn -d http/server3.contoso.com server3, and then pressing ENTER.
 .PARAMETER Service
 The name of the service to add
 .PARAMETER Name
 The name that will be associated with this service on this account
 .PARAMETER AccountName
 The actual hostname of the computer object that you want to update,
 if blank we default to the value of parameter Namem.
 .PARAMETER UserAccount
 A switch to add SPN's to a user object
 .EXAMPLE
 Remove-Spn -Service foo -Name server-01

 Service           Name                  Hostname  SPN
 -------           ----                  --------  ---
 HOST              server-01.company.com server-01 HOST/server-01.company.com
 RestrictedKrbHost server-01.company.com server-01 RestrictedKrbHost/server-01.company.com
 RestrictedKrbHost server-01             server-01 RestrictedKrbHost/server-01
 WSMAN             server-01.company.com server-01 WSMAN/server-01.company.com
 WSMAN             server-01             server-01 WSMAN/server-01
 TERMSRV           server-01.company.com server-01 TERMSRV/server-01.company.com
 TERMSRV           server-01             server-01 TERMSRV/server-01
 CmRcService       server-01             server-01 CmRcService/server-01
 CmRcService       server-01.company.com server-01 CmRcService/server-01.company.com
 HOST              server-01             server-01 HOST/server-01

 Description
 -----------

 This example shows how to remove an SPN from an account.
 .NOTES
 FunctionName : Remove-Spn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:07:12
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Remove-Spn
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Service,
  [string]$Name,
  [string]$AccountName = $Name,
  [switch]$UserAccount
 )
 Begin {
  if ($AccountName.IndexOfAny(".") -gt 0) {
   Write-Verbose "Found FQDN name, stripping down to hostname"
   $AccountName = $AccountName.Substring(0, $AccountName.IndexOfAny("."))
  }
  if ($UserAccount) {
   Write-Verbose "Setting the SearchFilter to objectCategory user"
   [string]$SearchFilter = "(&(objectCategory=user)(cn=$($AccountName)))"
  }
  else {
   Write-Verbose "Setting the SearchFilter to objectCategory computer"
   [string]$SearchFilter = "(&(objectCategory=computer)(cn=$($AccountName)))"
  }
  try {
   Write-Verbose "Bind to AD"
   $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
   $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
   $DirectorySearcher.SearchRoot = $DirectoryEntry
   $DirectorySearcher.PageSize = 1000
   $DirectorySearcher.Filter = $SearchFilter
   $DirectorySearcher.SearchScope = "Subtree"

   Write-Verbose "Find $($AccountName)"
   $Account = $DirectorySearcher.FindOne()
  }
  catch {
   Write-Error $Error[0]
   Return
  }
  [bool]$NotFound = $false
 }
 Process {
  if ($Account.Properties.Contains("servicePrincipalName")) {
   try {
    $Account = $Account.GetDirectoryEntry()
    $Account.servicePrincipalName.Remove("$($Service)/$($Name)")
    $Account.CommitChanges()
   }
   catch {
    Write-Error $Error[0]
    Return
   }
  }
  else {
   $NotFound = $true
  }
 }
 End {
  if ($NotFound) {
   Write-Host "No SPN found for $($AccountName)"
  }
  else {
   $SpnReport = @()
   foreach ($Item in $Account.servicePrincipalName) {
    $spn = $Item.Split("/")
    $SpnItem = New-Object -TypeName PSobject -Property @{
     Service  = $Spn[0]
     Name     = $Spn[1]
     Hostname = $AccountName
     SPN      = $Item
    }
    $SpnReport += $SpnItem
   }
   Return $SpnReport | Select-Object -Property Service, Name, Hostname, SPN
  }
 }
}
Function Get-Spn {
 <#
 .SYNOPSIS
 List Service Principal Name for an account
 .DESCRIPTION
 To view a list of the SPNs that a computer has registered with
 Active Directory from a command prompt, use the setspn �l hostname
 command, where hostname is the actual host name of the computer
 object that you want to query.

 For example, to list the SPNs of a computer named WS2003A, at the
 command prompt, type setspn -l S2003A, and then press ENTER.
 .PARAMETER AccountName
 The actual hostname of the object that you want to get
 .PARAMETER UserAccount
 A switch to test for SPN's against user objects. If not specified
 we default to computer objects.
 .EXAMPLE
 Get-Spn -AccountName cm12-test

 Service           Name                  Hostname   SPN
 -------           ----                  --------   ---
 CmRcService       SERVER-01.company.com SERVER-01$ CmRcService/SERVER-01.company.com
 CmRcService       SERVER-01             SERVER-01$ CmRcService/SERVER-01
 TERMSRV           SERVER-01             SERVER-01$ TERMSRV/SERVER-01
 TERMSRV           SERVER-01.company.com SERVER-01$ TERMSRV/SERVER-01.company.com
 WSMAN             SERVER-01             SERVER-01$ WSMAN/SERVER-01
 WSMAN             SERVER-01.company.com SERVER-01$ WSMAN/SERVER-01.company.com
 RestrictedKrbHost SERVER-01             SERVER-01$ RestrictedKrbHost/SERVER-01
 HOST              SERVER-01             SERVER-01$ HOST/SERVER-01
 RestrictedKrbHost SERVER-01.company.com SERVER-01$ RestrictedKrbHost/SERVER-01.company.com
 HOST              SERVER-01.company.com SERVER-01$ HOST/SERVER-01.company.com

 Description
 -----------

 This example lists the SPN(s) of the given account
 .EXAMPLE
 Get-Spn -AccountName Administrator -UserAccount

 Service  Name                       Hostname      SPN
 -------  ----                       --------      ---
 MSSQLSvc SERVER-01.company.com:1433 Administrator MSSQLSvc/SERVER-01.company.com:1433

 Description
 -----------

 This example shows using the -UserAccount switch
 .NOTES
 FunctionName : Get-Spn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:07:12
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Get-Spn
 .LINK
 http://msdn.microsoft.com/en-us/library/vstudio/system.servicemodel.configuration.identityelement.serviceprincipalname(v=vs.100).aspx
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 #>
 [CmdletBinding()]
 Param
 (
  [string]$AccountName,
  [switch]$UserAccount
 )
 Begin {
  if ($AccountName.IndexOfAny(".") -gt 0) {
   Write-Verbose "Found FQDN name, stripping down to hostname"
   $AccountName = $AccountName.Substring(0, $AccountName.IndexOfAny("."))
  }
  if ($UserAccount) {
   Write-Verbose "Setting the SearchFilter to objectCategory user"
   [string]$SearchFilter = "(&(objectCategory=user)(cn=$($AccountName)))"
  }
  else {
   Write-Verbose "Setting the SearchFilter to objectCategory computer"
   [string]$SearchFilter = "(&(objectCategory=computer)(cn=$($AccountName)))"
  }

  try {
   Write-Verbose "Bind to AD"
   $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
   $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
   $DirectorySearcher.SearchRoot = $DirectoryEntry
   $DirectorySearcher.PageSize = 1000
   $DirectorySearcher.Filter = $SearchFilter
   $DirectorySearcher.SearchScope = "Subtree"

   Write-Verbose "Find $($AccountName)"
   $Account = $DirectorySearcher.FindOne()
  }
  catch {
   Write-Error $Error[0]
   Return
  }

  $SpnReport = @()
  [bool]$NotFound = $false
 }
 Process {
  if ($Account.Properties.Contains("servicePrincipalName")) {
   Write-Verbose "Found servicePrincipalName property"
   $Spns = $Account.Properties.serviceprincipalname
   foreach ($Entry in $Spns) {
    $Spn = $Entry.Split("/")
    $SpnItem = New-Object -TypeName PSobject -Property @{
     Service  = $Spn[0]
     Name     = $Spn[1]
     Hostname = [string]$Account.Properties.samaccountname
     SPN      = $Entry
    }
    $SpnReport += $SpnItem
   }
  }
  else {
   Write-Verbose "Missing servicePrincipalName property"
   $NotFound = $true
  }
 }
 End {
  if ($NotFound) {
   Write-Host "No registered ServicePrincipalNames for $($Account.Path)"
  }
  else {
   Return $SpnReport | Select-Object -Property Service, Name, Hostname, SPN
  }
 }
}
Function Find-Spn {
 <#
 .SYNOPSIS
 Find all occurrences of a given service and or name
 .DESCRIPTION
 To find a list of the SPNs that a computer has registered with
 Active Directory from a command prompt, use the setspn �Q hostname
 command, where hostname is the actual host name of the computer
 object that you want to query.

 For example, to list the SPNs of a computer named WS2003A, at the
 command prompt, type setspn -Q WS2003A, and then press ENTER.
 .PARAMETER Service
 The name of the service to find
 .PARAMETER Name
 The name that will be associated with this service on this account
 .PARAMETER ForestWide
 A switch to check for duplicate SPN's across the entire forest
 .EXAMPLE
 Find-Spn -Service goo

 Service           Name                  Hostname   SPN
 -------           ----                  --------   ---
 goo               server-01             server-01$ goo/server-01
 HOST              server-01             server-01$ HOST/server-01
 HOST              server-01.company.com server-01$ HOST/server-01.company.com
 RestrictedKrbHost server-01.company.com server-01$ RestrictedKrbHost/server-01.company.com
 RestrictedKrbHost server-01             server-01$ RestrictedKrbHost/server-01
 WSMAN             server-01.company.com server-01$ WSMAN/server-01.company.com
 WSMAN             server-01             server-01$ WSMAN/server-01
 TERMSRV           server-01.company.com server-01$ TERMSRV/server-01.company.com
 TERMSRV           server-01             server-01$ TERMSRV/server-01
 CmRcService       server-01             server-01$ CmRcService/server-01
 CmRcService       server-01.company.com server-01$ CmRcService/server-01.company.com

 Description
 -----------

 Find all occurrences of the given service
 .EXAMPLE
 Find-Spn -Name server-01

 Service           Name                  Hostname   SPN
 -------           ----                  --------   ---
 goo               server-01             server-01$ goo/server-01
 HOST              server-01             server-01$ HOST/server-01
 HOST              server-01.company.com server-01$ HOST/server-01.company.com
 RestrictedKrbHost server-01.company.com server-01$ RestrictedKrbHost/server-01.company.com
 RestrictedKrbHost server-01             server-01$ RestrictedKrbHost/server-01
 WSMAN             server-01.company.com server-01$ WSMAN/server-01.company.com
 WSMAN             server-01             server-01$ WSMAN/server-01
 TERMSRV           server-01.company.com server-01$ TERMSRV/server-01.company.com
 TERMSRV           server-01             server-01$ TERMSRV/server-01
 CmRcService       server-01             server-01$ CmRcService/server-01
 CmRcService       server-01.company.com server-01$ CmRcService/server-01.company.com

 Description
 -----------

 Find all occurrences of the given name
 .NOTES
 FunctionName : Find-Spn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:07:12
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Find-Spn
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Service,
  [string]$Name,
  [switch]$ForestWide
 )
 Begin {
  if (!($Service)) {
   $Service = "*"
  }
  if (!($Name)) {
   $Name = "*"
  }
  if ("$($Service)/$($Name))" -eq "*/*") {
   Write-Error "You will need to enter a value for either Service or Name"
   Return
  }
 }
 Process {
  $SearchFilter = "(servicePrincipalName=$($Service)/$($Name))"
  Write-Verbose $SearchFilter
  try {
   if ($ForestWide) {
    $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $Domains = $Forest.Domains
   }
   else {
    $Domains = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    Write-Verbose $Domains.Name
   }
   foreach ($Domain in $Domains) {
    Write-Verbose "Bind to $($Domain.Name)"
    $DirectoryEntry = $Domain.GetDirectoryEntry()
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
    $DirectorySearcher.SearchRoot = $DirectoryEntry
    $DirectorySearcher.PageSize = 1000
    $DirectorySearcher.Filter = $SearchFilter
    $DirectorySearcher.SearchScope = "Subtree"

    Write-Verbose "Find $($AccountName)"
    $Account = $DirectorySearcher.FindAll()
    Write-Verbose $Account.Count
   }
  }
  catch {
   Write-Error $Error[0]
   Return
  }
  if ($Account.Count -gt 0) {
   $Account = $Account.GetDirectoryEntry()
   Write-Verbose "Existing SPN ($($Service)/$($Name)) found for $($Account.Properties.samaccountname)"
  }
 }
 End {
  $SpnReport = @()
  foreach ($Item in $Account.servicePrincipalName) {
   $spn = $Item.Split("/")
   $SpnItem = New-Object -TypeName PSobject -Property @{
    Service  = $Spn[0]
    Name     = $Spn[1]
    Hostname = [string]($Account.samAccountName)
    SPN      = $Item
   }
   $SpnReport += $SpnItem
  }
  Return $SpnReport | Select-Object -Property Service, Name, Hostname, SPN
 }
}
Function Find-DuplicateSpn {
 <#
 .SYNOPSIS
 Find duplicate Service Principal Names across the Domain or Forest
 .DESCRIPTION
 To find a list of duplicate SPNs that have been registered with
 Active Directory from a command prompt, use the
 setspn �X -P command, where hostname is the actual host name of the
 computer object that you want to query.
 .PARAMETER ForestWide
 A switch that if present searches the entire forest for duplicates
 .EXAMPLE
 Find-DuplicateSpn
 Checking domain DC=company,DC=com

 found 0 group of duplicate SPNs.

 Description
 -----------

 This example searches for duplicate SPNs in the current domain
 .EXAMPLE
 Find-DuplicateSpn -ForestWide
 Checking forest DC=company,DC=com
 Operation will be performed forestwide, it might take a while.

 found 0 group of duplicate SPNs.

 Description
 -----------

 This example searches for duplicate SPNs across the entire forest
 .NOTES
 FunctionName : Find-DuplicateSpn
 Created by   : jspatton
 Date Coded   : 07/10/2013 15:53:46

 Searching for duplicates, especially forest-wide, can take a long
 period of time and a large amount of memory.

 Service Principal Names (SPNs) are not required to be unique across
 forests, but duplicate SPNs can cause authentication issues during
 cross-forest authentication.
 .LINK
 https://code.google.com/p/mod-posh/wiki/SpnLibrary#Find-DuplicateSpn
 .LINK
 http://technet.microsoft.com/en-us/library/cc731241(WS.10).aspx
 #>
 [CmdletBinding()]
 Param
 (
  [switch]$ForestWide
 )
 Begin {
  try {
   $ErrorActionPreference = 'Stop'
   $Binary = 'setspn.exe'
   $Type = 'Leaf'
   [string[]]$paths = @($pwd);
   $paths += "$pwd;$env:path".split(";")
   $paths = Join-Path $paths $(Split-Path $Binary -leaf) | ? { Test-Path $_ -Type $type }
   if ($paths.Length -gt 0) {
    $SpnPath = $paths[0]
   }
  }
  catch {
   $Error[0]
  }
 }
 Process {
  try {
   $ErrorActionPreference = 'Stop'
   if ($ForestWide) {
    Invoke-Expression "$($SpnPath) -X -P -F"
   }
   else {
    Invoke-Expression "$($SpnPath) -X -P"
   }
  }
  catch {
   Write-Error $Error[0]
  }
 }
 End {
 }
}
Export-ModuleMember *