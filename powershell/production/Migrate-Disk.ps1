<#
    .SYNOPSIS
        This script will copy user profiles from an old disk to a new disk
    .DESCRIPTION
        This script is used to migrate user profile folders from an old
        disk to a new disk. This script assumes that no users will be accessing
        the data while the copy is ongoing.
        
        The script will get a list of usernames from the profile folder
        directly and use this to copy each user folder to it's new location. After
        the folder has been copied, the user is set as the folder's owner. This
        is a bit flip operation, ownership won't actually get set until the user
        actually logs into the folder the first time.
        
        Please make sure that share is stopped prior to running this script. If 
        not it is possible to lose data, as there is no post-validation to see
        if a user logged in after the script started.
    .PARAMETER SourceDrive
        This is the drive letter and profile folder name of the old disk.
    .PARAMETER DestDrive
        This is the drive letter and profile folder name of the new disk.
    .PARAMETER Testing
        This is True by default to prevent accidental usage.
    .EXAMPLE 
        .\Migrate-Disk.ps1 -SourceDrive 'H:\a' -DestDrive 'E:\a'
        
        Description
        -----------
        This example shows basic usage of the script. Note we didn't
        specify the Testing parameter, so this runs in test mode.
    .EXAMPLE
        .\Migrate-Disk.ps1 -SourceDrive 'H:\a' -DestDrive 'E:\a' -Testing $False
        
        Description
        -----------
        This example shows basic usage of the script. Note that we
        set Testing to False, this puts the script into run mode.
    .NOTES
        ScriptName : Migrate-Disk.ps1
        Created By : jspatton
        Date Coded : 05/23/2012 22:18:26
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://trac.soecs.ku.edu/powershell/browser/Private/Migrate-Disk.ps1
    .LINK
        http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
#>
[CmdletBinding()]
Param
    (
    [Parameter(Mandatory=$true)]
    [string]$SourceDrive,
    [Parameter(Mandatory=$true)]
    [string]$DestDrive,
    $Testing = $true
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.

        Write-Verbose 'Check if we`re logged into HOME.'
        if ($env:USERDOMAIN -eq 'HOME')
        {
            Write-Verbose 'Source in the script that allows us to run as SYSTEM'
            . C:\scripts\enable-priv-shhhhh.ps1
            
            Write-Verbose 'Grant seBackupPrivilege to our HOME account'
            enable-privilege -Privilege SeBackupPrivilege |out-null
            Write-Verbose 'Grant seTakeOwnerShipPrivilege to our HOME account'
            enable-privilege -Privilege SeTakeOwnershipPrivilege |out-null

            Write-Verbose "Get a folder listing from the $($SourceDrive)"
            $Users = Get-ChildItem $SourceDrive |Where-Object {$_.Name -ne 'ATTIC'}
            
            $RobocopyError = @()
            $SetAclError = @()
            }
        else
        {
            $Message = "Your current UserDomain is $($env:USERDOMAIN). You need to be logged in to HOME to run this script."
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            exit	
            }
        }
Process
    {
        foreach ($User in $Users)
        {
            $ThisUser = New-Object -TypeName PSobject -Property @{
                Source = $User.FullName
                Dest = $User.Name
                }
            
            Write-Verbose 'Create the destination path to copy to'
            $DestPath = "$($DestDrive)\$($ThisUser.Dest)"
            
            if ($Testing -eq $true)
            {
                Write-Verbose 'Running in Test Mode'
                Write-Verbose 'We will output the intended command-line for each operation'
                Write-Host "Testing - The following command will copy data"
                Write-Host "RoboCopy /R:0 /W:0 /b /e $($ThisUser.Source) $($DestPath)"
                Write-Host "Testing - The following command will copy permissions"
                Write-Host "RoboCopy /R:0 /W:0 /b /e /sec /secfix $($ThisUser.Source) $($DestPath)"
                Write-Host "Testing - The following command will set folder ownership"
                Write-Host "C:\scripts\SetACL.exe -on `"$DestPath`" -ot file -actn setowner -ownr `"n:$($ThisUser.Dest)@HOME`" -rec cont_obj"
                }
            else
            {
                Write-Verbose 'Do the initial copy of data'
                Write-Verbose "RoboCopy /R:0 /W:0 /b /e $($ThisUser.Source) $($DestPath)"
                & RoboCopy /R:0 /W:0 /b /e $ThisUser.Source $DestPath
                If ($LASTEXITCODE -ge 8)
                {
                    $ThisError = New-Object -TypeName PSObject -Property @{
                        UserName = $ThisUser.Dest
                        Message = "ROBOCOPY FAIL"
                        Status = $LASTEXITCODE
                        }
                    $RobocopyError += $ThisError
                    continue
                    }

                Write-Verbose 'Copy file permissions'
                Write-Verbose "RoboCopy /R:0 /W:0 /b /e /sec /secfix $($ThisUser.Source) $($DestPath)"
                & RoboCopy /R:0 /W:0 /b /e /sec /secfix $ThisUser.Source $DestPath

                Write-Verbose 'Set ownership of the user folder $($DestPath) to the user $($ThisUser.Dest)'
                Write-Verbose "C:\scripts\SetACL.exe -on `"$DestPath`" -ot file -actn setowner -ownr `"n:$($ThisUser.Dest)@HOME`" -rec cont_obj"
                & C:\scripts\SetACL.exe -on `"$DestPath`" -ot file -actn setowner -ownr `"n:$($ThisUser.Dest)@HOME`" -rec cont_obj
                If ($LASTEXITCODE -ge 8)
                {
                    $ThisError = New-Object -TypeName PSObject -Property @{
                        UserName = $ThisUser.Dest
                        Message = "SetAcl FAIL"
                        Status = $LASTEXITCODE
                        }
                    $SetAclError += $ThisError
                    continue
                    }
                }
            }
        }
End
    {
        if ($RobocopyError.Count)
        {
            $RobocopyError |Export-Csv -Path C:\LogFiles\RoboCopyErrors.CSV
            Write-Host "$($RobocopyError.Count) error(s) were encountered please view the log in C:\LogFiles\RoboCopyErrors.CSV"
            }
        if ($SetAclError.Count)
        {
            $SetAclError |Export-Csv -Path C:\LogFiles\SetAclError.CSV
            Write-Host "$($SetAclError.Count) error(s) were encountered please view the log in C:\LogFiles\SetAclError.CSV"
            }        
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }