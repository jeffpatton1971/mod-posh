<#
	This is my custom prompt for PowerShell.
	
	It displays username@computername | current time | current date | working directory
	
	The last character will be either $ for users NOT in administrators group
	or # for users IN administrators group
	
	Download the PowerShell Community Extensions
	http://pscx.codeplex.com/
	
#>
$Global:Admin="$"
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)

# Load up the extra love
Import-Module Pscx

Add-PSSnapin -Name VMware.VimAutomation.Core

Set-Location $env:HOMEDRIVE$env:HOMEPATH"\My Repositories\scripts\powershell\production"

#   Dot source in my functions
foreach ($file in Get-ChildItem .\includes\*.ps1){. $file.fullname}

$Password = Get-Content C:\Users\jspatton\cred.txt |ConvertTo-SecureString
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "SOECS\jeffpatton.admin", $Password

#	Import the PoshCode functions 
. "C:\Users\jspatton\PoshCode.ps1"

if ($principal.IsInRole("Administrators")) 
	{
		$Admin="#"
	}

Function prompt 
	{
		$Now = $(get-date).Tostring("HH:mm:ss | MM-dd-yyy")
		"$env:username@$env:computername | $Now | $(get-location) $Admin `n"
	}

$Pscx:Preferences['TextEditor'] = 'Notepad++'