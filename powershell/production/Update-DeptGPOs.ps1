<#
    .SYNOPSIS
        Update permissions on Departmental GPO's
    .DESCRIPTION
        This script will backup all existing GPO's in the domain prior to making any changes. After the backup
        has been made Departmental GPOs will be updated based on their Dept Code.
    .PARAMETER DeptCode
        A code that uniquely identifies the GPOs for your department, this is used as a filter against the 
        name of the GPO in question.
    .PARAMETER TargetName
        The name of the user/group to assign permissions to
    .PARAMETER TargetType
        The default for this parameter is User, but if TargetName is a group, then 
        this should be set to Group.
    .PARAMETER PermissionLevel
        Valid permission levels are
            GpoRead
            GpoApply
            GpoEdit
            GpoEditDeleteModifySecurity
            None
    .PARAMETER BackupLocation
        A valid location either local or UNC to store the GPO backups.
    .PARAMETER Test
        Set to $False in order to update security and perform backup.
    .EXAMPLE
        .\Update-DeptGPOs.ps1 -DeptCode "Admin" -TargetName "MyUser" -BackupLocation "c:\temp"
        
        Description
        -----------
        This example shows basic usage, and assumes the default permissionlevel of None.
    .EXAMPLE
        .\Update-DeptGPOs.ps1 -DeptCode "Admin" -TargetName "MyUser" -PermissionLevel "GpoEditDeleteModifySecurity" -BackupLocation "c:\temp"
        
        Description
        -----------
        This example assigns GpoEditDeleteModifySecurity to the MyUser account for all GPOs tagged as Admin
    .NOTES
        ScriptName: Update-DeptGPOs
        Created By: Jeff Patton
        Date Coded: June 7, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        This script depends on PowerShell GroupPolicy modules to functino properly, the linked in 
        cmdlets are used in this script.
        
        If a backup cannot be made the script terminates.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Update-DeptGPOs
    .LINK
        http://technet.microsoft.com/en-us/library/ee461059.aspx
    .LINK
        http://technet.microsoft.com/en-us/library/ee461038.aspx
    .LINK
        http://technet.microsoft.com/en-us/library/ee461052.aspx
#>
Param
(
    $DeptCode,
    $TargetName,
    $TargetType = "User",
    [ValidateSet("GpoRead", "GpoApply", "GpoEdit", "GpoEditDeleteModifySecurity","None")]
    $PermissionLevel = "None",
    $BackupLocation,
    $Test = $True
)
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

        $ErrorActionPreference = "Stop"
        
        Try
        {
            Import-Module GroupPolicy
            $DeptGPOs = Get-GPO -All |Where-Object {$_.DisplayName -like "*$($DeptCode)*"}
            
            Foreach ($DeptGPO in $DeptGPOs)
            {
                If ($Test -eq $False)
                {
                    Backup-GPO -Guid $DeptGPO.Id -Path $BackupLocation -Comment "Updating Security on $($DeptCode) GPOs"
                    $Message = "Backed up $($DeptGPO.DisplayName) to $($BackupLocation)"
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
                    }
                Else
                {
                    Write-Host "Backed up $($DeptGPO.Displayname) to $($BackupLocation)"
                    }
                }
            }
        Catch
        {
            $Message = $Error[0].Exception.InnerException.Message.ToString().Trim()
            Write-EventLog -LogName $LogName -Source $ScriptName -EventId "102" -EntryType "Error" -Message $Message
            
            Write-Error $Message
            Break
            }
    }
Process
    {
        foreach ($DeptGPO in $DeptGPOs)
        {
            Try
            {
                If ($Test -eq $False)
                {                    
                    Set-GPPermissions -Guid $DeptGPO.Id -TargetName $TargetName -PermissionLevel $PermissionLevel -TargetType $TargetType
                    $Message = "Adding $($TargetName) to $($DeptGPO.DisplayName) with permission level $($PermissionLevel)"
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventId "101" -EntryType "Information" -Message $Message
                    }
                Else
                {
                    Set-GPPermissions -Guid $DeptGPO.Id -TargetName $TargetName -PermissionLevel $PermissionLevel -TargetType $TargetType -WhatIf
                    }
                }
            Catch
            {
                $Message = $Error[0].Exception.InnerException.Message.ToString().Trim()
                Write-EventLog -LogName $LogName -Source $ScriptName -EventId "102" -EntryType "Error" -Message $Message
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
        
        Return $?
    }
