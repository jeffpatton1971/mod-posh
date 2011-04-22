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

Import-Module Pscx

#$MyIncludes = Get-ChildItem "$env:HOMEDRIVE$env:HOMEPATH\My Repositories\scripts\powershell\production\includes"
#foreach ($file in $MyIncludes)
#    {
#        $ThisFile = $file.fullname |Where-Object {$_ -notmatch "bak"}
#        . "$thisfile"
#        }
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\ActiveDirectoryManagement.ps1"
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\ComputerManagement.ps1"
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\FileManagement.ps1"
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\MueggeLogParser.ps1"
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\SharePointManagement.ps1"
. "C:\Users\jspatton\My Repositories\scripts\powershell\production\includes\PerformanceTesting.ps1"

$Password = Get-Content C:\Users\jspatton\cred.txt |ConvertTo-SecureString
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "SOECS\jeffpatton.admin", $Password

#	Import the PoshCode functions 
. "C:\Users\jspatton\PoshCode.3.8.ps1"

Set-Location $env:HOMEDRIVE$env:HOMEPATH"\My Repositories\scripts\powershell\production"

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