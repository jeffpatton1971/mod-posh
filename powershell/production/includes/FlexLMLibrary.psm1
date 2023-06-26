Function Get-FlexLMStatus {
 <#
 .SYNOPSIS
 Get FlexLM Status from server
 .DESCRIPTION
 This function wraps the lmutil utility and returns an object
 that can be used to get the status of the flex license on
 the queried port.
 This function will return the port as specified in the license
 as opposed to what is passed in, it will return the licenseserver
 as defined in the license. Additionally it will return the
 daemon and it's status.
 .PARAMETER QueryPort
 The port that the license is listening on. These are TCP ports
 that are open on the server and can be viewed with nstat -an. If
 not specified it will default to the standard Flex port 27000
 .PARAMETER LicenseServer
 This is the NetBios, FQDN or IP of the license server. If not
 specified it will default to the local host.
 .EXAMPLE
 Get-FlexLMStatus -QueryPort 2701 -LicenseServer lic1 -Verbose
 VERBOSE: License server status: 1055@license1.soecs.ku.edu
 VERBOSE: License file(s) on license1.soecs.ku.edu: C:\Program Files\ANSYS Inc\Shared Files\Licensing\license.dat:
 VERBOSE: ansyslmd: UP v11.8


 LicensePath   : C:\Program Files\ANSYS Inc\Shared Files\Licensing\license.dat
 Daemon        : ansyslmd
 DaemonStatus  : UP
 LicenseServer : lic1.compny.com
 LicensePort   : 2701

 Description
 -----------
 This is the basic syntax of the command, this is showing using the -verbose switch
 to see the data as it's being processed from lmutil.
 .EXAMPLE
 Get-FlexLMStatus
 LMUTIL not found. Please visit
 http://www.globes.com/support/fnp_utilities_download.htm

 The term 'lmutil' is not recognized as the name of a cmdlet, function, script fi
 le, or operable program. Check the spelling of the name, or if a path was includ
 ed, verify that the path is correct and try again.

 Description
 -----------
 This example shows the output when lmutil is not available on the system.
 .NOTES
 FunctionName : Get-FlexLMStatus
 Created by   : jspatton
 Date Coded   : 12/07/2011 12:01:29
 .LINK
 https://code.google.com/p/mod-posh/wiki/FlexLMLibrary#Get-FlexLMStatus
 .LINK
 http://www.globes.com/support/fnp_utilities_download.htm
 #>
 [cmdletbinding()]
 Param
 (
  $QueryPort = 27000,
  $LicenseServer = (&hostname)
 )
 Begin {
  try {
   $Expression = "(&lmutil lmstat -c $($QueryPort)@$($LicenseServer))"
   $lmstat = Invoke-Expression $Expression -ErrorAction Stop
  }
  catch [System.Management.Automation.CommandNotFoundException] {
   Write-Host "LMUTIL not found. Please visit"
   Write-Host "http://www.globes.com/support/fnp_utilities_download.htm"
   Write-Host
   Write-Host $Error[0].Exception.Message

   break
  }
  if (($lmstat | Select-String Error -Quiet) -eq $true) {
   [string]$MyError = $lmstat | Select-String 'Error'
   Write-Error $MyError
   break
  }
 }
 Process {
  [string]$LicenseServerStatus = $lmstat | Select-String '^License server status'
  $LicenseServerStatus = $LicenseServerStatus.Trim()
  Write-Verbose $LicenseServerStatus

  [string]$LicenseFile = $lmstat | Select-String 'License file'
  $LicenseFile = $LicenseFile.Trim()
  Write-Verbose $LicenseFile

  [string]$VendorDaemon = $lmstat[$lmstat.Count - 2]
  $VendorDaemon = $VendorDaemon.Trim()
  Write-Verbose $VendorDaemon

  <#
  The several +1 and -1 are for removing extraneous data usually
  a colon or @ sign from the variable.
  #>
  $FlexLMStatus = New-Object -TypeName PSObject -Property @{
   LicensePort   = $LicenseServerStatus.Substring($LicenseServerStatus.IndexOfAny(":") + 1, $LicenseServerStatus.IndexOf("@") - $LicenseServerStatus.IndexOfAny(":") - 1).Trim()
   LicenseServer = $LicenseServerStatus.Substring($LicenseServerStatus.IndexOfAny("@") + 1, $LicenseServerStatus.Length - $LicenseServerStatus.IndexOfAny("@") - 1)
   LicensePath   = $LicenseFile.Substring($LicenseFile.IndexOfAny(":") + 1, $LicenseFile.Length - $LicenseFile.IndexOfAny(":") - 2).Trim()
   Daemon        = $VendorDaemon.Substring(0, $VendorDaemon.IndexOfAny(":")).Trim()
   DaemonStatus  = $VendorDaemon.Substring($VendorDaemon.IndexOfAny(":") + 1, $VendorDaemon.Length - $VendorDaemon.IndexOfAny("v") - 1).Trim()
  }
 }
 End {
  Return $FlexLMStatus
 }
}

Export-ModuleMember *