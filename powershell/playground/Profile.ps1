<#
	This is my custom prompt for PowerShell.
	
	It displays username@computername | current time | current date | working directory
	
	The last character will be either $ for users NOT in administrators group
	or # for users IN administrators group
	
#>
$Global:Admin="$"
$Global:SubversionClient="svn"
$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Global:principal = new-object System.Security.principal.windowsprincipal($Global:CurrentUser)
if ($Host.Name -eq 'ConsoleHost')
{
    #
    # Set default editor
    #
    $Global:POSHEditor = 'c:\windows\notepad.exe'
    
    #
    # Start transcription
    #
    Start-Transcript

    try
    {
        #
        # Load up GitHub Shell Extensions
        #
        . (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
        #
        # Have we cloned posh-git
        #
        if (!(Test-Path C:\GitHub\posh-git))
        {
            #
            # Nope, clone it!
            #
            Set-Location C:\GitHub
            git clone https://github.com/dahlbyk/posh-git.git
            }
        else
        {
            #
            # Yup, import it!
            #
            Import-Module C:\GitHub\posh-git\posh-git.psm1
            }
        #
        # Have we cloned CShell
        #
        if (!(Test-Path C:\GitHub\CShell))
        {
            #
            # Nope, clone it!
            #
            Set-Location C:\GitHub
            git clone https://github.com/lukebuehler/CShell.git
            #
            # This needs to be set to true in order to build
            #
            $env:EnableNuGetPackageRestore = $True
            #
            # Build the CShell Release
            #
            C:\GitHub\CShell\Build\build-release.cmd
            #
            # Start it so we can pin it
            #
            C:\GitHub\CShell\Bin\Release\CShell.exe
            }
        }
    catch
    {
        Write-Error $Error[0]
        }
    }

#
# Move me into my code location
#
Set-Location "C:\projects\mod-posh\powershell\production"

#
# Dot source in my functions
#
foreach ($file in Get-ChildItem .\includes\*.psm1){Import-Module $file.fullname}

#
# Create my Credentials Object
#
$Password = Get-SecureString -FilePath C:\Users\$($env:USERNAME)\cred.txt
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($env:USERDOMAIN)\$($env:USERNAME)_a", $Password
#
# Don't keep this in memory please!
#
Remove-Variable Password
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
Function prompt 
{
    $Now = $(get-date).Tostring("HH:mm:ss | MM-dd-yyy")
    #
    # I use GIT now for most everything and this allows my prompt to have nifty colors that represent
    # the status of various files
    #
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    Write-Host "# $($env:username)@$($env:computername) | $($Now) | $(Get-Location) $Global:Admin " -NoNewLine
    #
    # This writes the actual status of the repo (if i'm in one) at the tail end of the cmdline
    #
    Write-VcsStatus
    return "`n"
    }