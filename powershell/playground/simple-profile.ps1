$Global:Admin="$"
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
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
    }
