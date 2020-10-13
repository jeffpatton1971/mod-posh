<#
 .SYNOPSIS
  Add one or more access rules to a web app
 .DESCRIPTION
  This script allows you to pass in an array of ip addresses to add to an
  Azure Webapp Access Restriction. All passed in Addresses will be added with
  the same Action Allow|Deny, so you will need to pass in a group of Allows or
  a group of Denys. The priority is auto-incremented by 5 for each address the
  script iterates over.
 .PARAMETER ResourceGroupName
  This is the Azure ResourceGroup where the Web App can be found
 .PARAMETER WebAppName
  The name of the Web App to add the rule(s) to
 .PARAMETER AllowedRange
  The CIDR range to add
 .PARAMETER Priotrity
  The priority to start at
 .PARAMETER Action
  This is either Allow or Deny
 .NOTES
  You will need to be authenticated into the subscription you want to run this
  against.
#>
[CmdletBinding(PositionalBinding = $true)]
[OutputType([Object])]
param (
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true, Position = 1)]
  [string]$WebAppName,
  [Parameter(ValueFromPipeline, Position = 2)]
  [string]$AllowedRange,
  [Parameter(Mandatory = $true, Position = 3)]
  [int]$Priority,
  [ValidateSet("Allow", "Deny")]
  [Parameter(Position = 4)]
  [string]$Action = 'Allow'
)
begin {
  $newPriority = $Priority;
}
process {
  try {

    #$ErrorActionPreference = $MyInvocation.BoundParameters.ContainsKey('ErrorAction');
    $Error.Clear();

    Write-Verbose "Check for existing rules in $($WebAppName)";
    $ExistingRules = Get-AzWebAppAccessRestrictionConfig -ResourceGroupName $ResourceGroupName -Name $WebAppName -Debug:$false;
    Write-Debug $ExistingRules;

    Write-Verbose "Setup rule";

    $Rule = [Microsoft.Azure.Commands.WebApps.Models.PSAccessRestriction]::new();
    $Rule.RuleName = "$($Action)_$($AllowedRange)";
    $Rule.Description = "$($Action) $($AllowedRange)";
    $Rule.Priority = $newPriority;
    $Rule.Action = $Action;
    $Rule.IpAddress = $AllowedRange;

    Write-Debug $Rule;
    Write-Verbose "Adding $($Rule.Rulename)";

    if ($ExistingRules.MainSiteAccessRestrictions | Where-Object -Property Priority -eq $newPriority) {
      $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
          ([System.Exception]"Existing rule with that priority found"),
          'AccessRule',
          [System.Management.Automation.ErrorCategory]::OpenError,
          $MyObject
        )
      )
    }
    else {
      Add-AzWebAppAccessRestrictionRule `
        -ResourceGroupName $ResourceGroupName `
        -WebAppName $WebAppName `
        -Name $Rule.RuleName `
        -Description $Rule.Description `
        -Priority $Rule.Priority `
        -Action $Rule.Action `
        -IpAddress $Rule.IpAddress `
        -ErrorAction $ErrorActionPreference;
    }

    Write-Verbose "Incrementing Priority by 5"
    $newPriority += 5;
  }
  catch {
    throw $_;
  }
}