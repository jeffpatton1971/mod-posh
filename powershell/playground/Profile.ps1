<#
	This is my custom prompt for PowerShell.
	
	It displays username@computername | current time | current date | working directory
	
	The last character will be either $ for users NOT in administrators group
	or # for users IN administrators group
	
	Download the PowerShell Community Extensions
	http://pscx.codeplex.com/
	
#>
$Global:Admin="$"
$Global:SubversionClient="svn"
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
if ($Host.Name -eq 'ConsoleHost')
{
    $Global:POSHEditor = 'c:\windows\notepad.exe'
    }

#
# Load the VMware Extensions
#
try
{
    Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop
    }
catch
{
    Write-Warning 'VMware PowerShell tools not installed'
    }
#
# Load the DPM Extensions
#
try
{
    Add-PSSnapin -Name Microsoft.DataProtectionManager.PowerShell -ErrorAction Stop
    }
catch
{
    Write-Warning 'DPM PowerShell tools not installed'
    }

#
# Move me into my code location
#
Set-Location "C:\scripts\powershell\production"

#
# Dot source in my functions
#
foreach ($file in Get-ChildItem .\includes\*.ps1){. $file.fullname}

#
# Update repo
#
Update-Repo -WorkingPath 'C:\scripts' |Out-Null

#
# Create my Credentials Object
#
$Password = Get-SecureString -FilePath C:\Users\jspatton\cred.txt
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "HOME\jspatton_a", $Password

#
# Change prompt to # if i have admin rights
#
if ($principal.IsInRole("Administrators")) 
{
    $Admin="#"
    }

#
# Setup my custom prompt
#
Function prompt 
{
    $Now = $(get-date).Tostring("HH:mm:ss | MM-dd-yyy")
    "# $env:username@$env:computername | $Now | $(Get-Location) $Admin `n"
    }

#
# SCOM console slow tabexpand fix
#
$tabExpand = (get-item function:\tabexpansion).Definition
if($tabExpand -match 'try {Resolve-Path.{49}(?=;)')
{
   $tabExpand = $tabExpand.Replace($matches[0], "if((get-location).Provider.Name -ne 'OperationsManagerMonitoring'){ $($matches[0]) }" )
   invoke-expression "function TabExpansion{$tabExpand}"
   }

#
# Display a list of appointments for today
#
C:\scripts\powershell\production\Get-ExchangeCalendar.ps1 -MailboxName jspatton@ku.edu -StartDate (Get-Date) -EndDate (Get-Date) -ErrorAction SilentlyContinue |Format-List

#
# Toggle wireless on or off
#
Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList '-command "C:\scripts\powershell\production\Toggle-Wireless.ps1"'