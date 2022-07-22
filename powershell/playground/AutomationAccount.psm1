class AutomationAccount {
 [string]$Name
 [string]$Location
 [object]$Tags = (New-Object -TypeName psobject)
 [ValidateSet('Free', 'Basic')]
 [string]$SkuName = 'Free'
 [bool]$DisableLocalAuth = $false
 [bool]$PublicNetworkAccess = $true
 hidden [string]$Type = "Microsoft.Automation/automationAccounts"
 hidden [string]$ApiVersion = "2021-06-22"
 hidden [string]$BicepName = 'AutomationAccount'
 hidden [string]$HclName = 'azurerm_automation_account'

 #
 # Constructors
 #
 AutomationAccount () {}
 AutomationAccount (
  [string]$Name,
  [string]$Location
 ) {
  $this.Name = $Name
  $this.Location = $Location
 }

 #
 # Methods
 #
 [object]GetParameters() {
  return (New-Object -TypeName psobject -Property @{
    'name'                = (New-Object -TypeName psobject -Property @{
      'type'         = 'string'
      'defaultValue' = $this.Name
     })
    'location'            = (New-Object -TypeName psobject -Property @{
      'type'         = 'string'
      'defaultValue' = $this.Location
     })
    'tags'                = (New-Object -TypeName psobject -Property @{
      'type'         = 'object'
      'defaultValue' = $this.Tags
     })
    'SkuName'             = (New-Object -TypeName psobject -Property @{
      'type'         = 'string'
      'defaultValue' = $this.SkuName
     })
    'DisableLocalAuth'    = (New-Object -TypeName psobject -Property @{
      'type'         = 'bool'
      'defaultValue' = $this.DisableLocalAuth
     })
    'PublicNetworkAccess' = (New-Object -TypeName psobject -Property @{
      'type'         = 'bool'
      'defaultValue' = $this.PublicNetworkAccess
     })
   }) | Select-Object -Property name, location, tags, SkuName, DisableLocalAuth, PublicNetworkAccess
 }
 [object]GetResource([string]$Type) {
  switch ($Type.ToLower()) {
   'arm' {
    return (New-Object -TypeName psobject -Property @{
      'type'       = $this.Type
      'apiVersion' = $this.ApiVersion
      'tags'       = $this.Tags
      'properties' = $this.GetProperties()
      'name'       = $this.Name
      'location'   = $this.Location
     }) | Select-Object -Property type, apiVersion, name, location, tags, properties
   }
   'bicep' {
    return @"
resource $($this.BicepName) '$($this.Type)@$($this.ApiVersion)' = {
 name: '$($this.Name)'
 location: '$($this.Location)'
 tags: $(if ($null -eq $this.Tags) {$null |ConvertTo-Json -Compress} else {$this.Tags |ConvertTo-Json -Compress})
 properties :{
  disableLocalAuth: $($this.DisableLocalAuth)
  publicNetworkAccess: $($this.PublicNetworkAccess)
  sku: {
   name: '$($this.SkuName)'
  }
 }
}
"@
   }
   'hcl' {
    return @"
resource `"$($this.HclName)`" `"aa`" {
 name     = '$($this.Name)'
 location = '$($this.Location)'
 sku_name = '$($this.SkuName)'
 tags     = '$($this.Tags)'
"@
   }
  }
  return $null
 }
 [object]GetProperties() {
  return (New-Object -TypeName psobject -Property @{
    'disableLocalAuth'    = $this.DisableLocalAuth
    'publicNetworkAccess' = $this.PublicNetworkAccess
    'sku'                 = (New-Object -TypeName psobject -Property @{
      'name' = $this.SkuName
     })
   }) | Select-Object -Property disableLocalAuth, publicNetworkAccess, sku
 }
 #
 # OverRides
 #
 [object]ToString([string]$Type) {
  switch ($Type.ToLower()) {
   'arm' {
    return (ConvertTo-Arm -Resource $this)
   }
   'bicep' {
    return (ConvertTo-Bicep -Resource $this)
   }
   'hcl' {
    return (ConvertTo-Hcl -Resource $this)
   }
  }
  return $null
 }
}

function ConvertTo-Arm {
 param (
  [object]$Resource
 )
 try {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();

  $armJson = New-Object -TypeName psobject -Property @{
   '$schema'        = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
   'contentVersion' = '1.0.0.0'
   'parameters'     = (New-Object -TypeName psobject)
   'variables'      = (New-Object -TypeName psobject)
   'resources'      = @()
   'outputs'        = (New-Object -TypeName psobject)
  }
  #
  # Create Parameters
  #
  $armJson.Parameters = $Resource.GetParameters();
  #
  # Create Resource
  #
  $armJson.resources += $Resource.GetResource('arm');
  #
  #
  #
  return ($armJson | Select-Object -Property '$schema', 'contentVersion', 'parameters', 'variables', 'resources', 'outputs');
 }
 catch {
  throw $_;
 }
}
function ConvertTo-Bicep {
 param (
  [object]$Resource
 )
 try {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();

  $Resource.GetResource('bicep')
 }
 catch {
  throw $_;
 }
}
function ConvertTo-Hcl {
 param (
  [object]$Resource
 )
 try {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();

  #
  # Write Terraform Section
  #
  @"
terraform {
 required_providers {
  azurerm = {
   source = `"hashicorp/azurerm`"
   version >= `"3.0`"
  }
 }
}

provider `"azurerm`" {
 # Configuration options
}

$($Resource.GetResource('hcl'))
"@
 }
 catch {
  throw $_;
 }
}