<#
	This is my custom prompt for PowerShell.
	
	It displays username@computername | current time | current date | working directory
	
	The last character will be either $ for users NOT in administrators group
	or # for users IN administrators group
	
#>
$Global:Admin="$"
$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Global:principal = new-object System.Security.principal.windowsprincipal($Global:CurrentUser)
if ($Host.Name -eq 'ConsoleHost') {
    #
    # Set default editor
    #
    $Global:POSHEditor = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
    
    #
    # Start transcription
    #
    Start-Transcript
}
#
# Import posh-git
#
Import-Module -Name posh-git;
#
# Move me into my code location
#
Set-Location "C:\projects\mod-posh\powershell\production"
#
# Dot source in my functions
#
Get-ChildItem .\includes\*.psm1 |ForEach-Object {Import-Module $_.FullName}
#
# Change prompt to # if i have admin rights
#
if ($Global:principal.IsInRole("Administrators")) 
{
    $Admin="#"
    }

#
# Setup my custom prompt
#
Function prompt {
    $Now = $(get-date).Tostring("HH:mm:ss | MM-dd-yyy")
    $FreeSpace = [math]::Round(((Get-PSDrive ((pwd).drive |Select-Object -ExpandProperty name) |Select-Object -ExpandProperty Free)/1gb),2)
    #
    # I use GIT now for most everything and this allows my prompt to have nifty colors that represent
    # the status of various files
    #
    # $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    Write-Host "# $($env:username)@$($env:computername) | $($Now) | [$($FreeSpace)GB] $(Get-Location) $Global:Admin " -NoNewLine
    #
    # This writes the actual status of the repo (if i'm in one) at the tail end of the cmdline
    #
    Write-VcsStatus
    #
    # The return is the bit that removes the PS>
    #
    return "`n"
}