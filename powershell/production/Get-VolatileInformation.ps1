<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-VolatileInformation.ps1
        Created By : jspatton
        Date Coded : 04/24/2012 15:51:59
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-VolatileInformation.ps1
#>
[CmdletBinding()]
Param
    (
    $ComputerName = '.',
    $FilePath = 'C:\LogFiles'
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        Try
        {
            Import-Module .\includes\ComputerManagement.psm1
            }
        Catch
        {
            Write-Warning "Must have the ComputerManagement Module available."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ComputerManagement Module Not Found"
            Break
            }

        $TimeStamp = Get-Date -f MMddyyy
        $LogPath = "$($FilePath)\$($TimeStamp)"
        
        if ((Test-Path $LogPath) -ne $true)
        {
            Write-Verbose "Creating $($LogPath)"
            New-Item -Path $LogPath -ItemType Directory -Force |Out-Null
            }
        }
Process
    {
        Foreach ($Computer in $ComputerName)
        {
            Try
            {
                Write-Verbose "Get a list of running process on $($Computer)"
                $Processes = Get-WmiObject -Class Win32_Process -ComputerName $Computer `
                    |Select-Object -Property Caption, CommandLine, ExecutablePath, ProcessId, Handles, ThreadCount, VM, WS
                    
                Write-Verbose "Get a list of open files on $($Computer)"
                $Files = Get-OpenFiles -ComputerName $Computer |Select-Object -Property User, Path, LockCount
                
                Write-Verbose "Get a list of open sessions on $($Computer)"
                $Sessions = Get-OpenSessions -ComputerName $Computer |Select-Object -Property User, Computer, ConnectTime, IdleTime
                
                Write-Verbose "Establish a remote connection to $($Computer)"
                if ($Computer -eq '.')
                {
                    Write-Verbose "Get the output of netstat"
                    $Computer = (& hostname)
                    $NetstatReport = .\Get-NetstatReport.ps1
                    }
                else
                {
                    $RemoteSession = New-PSSession -ComputerName $Computer
                    Write-Verbose "Get the output of netstat"
                    $NetStatReport = Invoke-Command -Session $RemoteSession -FilePath .\Get-NetstatReport.ps1
                    Write-Verbose "Exit the session"
                    Exit-PSSession 
                    }
                if ((Test-Path "$($LogPath)\$($Computer)") -ne $true)
                {
                    Write-Verbose "$($LogPath)\$($Computer) not found, creating."
                    New-Item -Path "$($LogPath)\$($Computer)" -ItemType Directory -Force |Out-Null
                    }
                    
                Write-Verbose "Export process list"
                $FileName = "Running-Processes.$((get-date -format "yyyMMdd")).csv"
                if ($Processes)
                {
                    $Processes |Export-Csv -Path "$($LogPath)\$($Computer)\$($FileName)" -NoTypeInformation -ErrorAction Stop
                    }
                
                Write-Verbose "Export open files"
                $FileName = "Open-Files.$((get-date -format "yyyMMdd")).csv"
                if ($Files)
                {
                    $Files |Export-Csv -Path "$($LogPath)\$($Computer)\$($FileName)" -NoTypeInformation -ErrorAction Stop
                    }
                
                Write-Verbose "Export open sessions"
                $FileName = "Open-Sessions.$((get-date -format "yyyMMdd")).csv"
                if ($Sessions)
                {
                    $Sessions |Export-Csv -Path "$($LogPath)\$($Computer)\$($FileName)" -NoTypeInformation -ErrorAction Stop
                    }
                
                Write-Verbose "Export netstat report"
                $FileName = "Netstat-Report.$((get-date -format "yyyMMdd")).csv"
                if ($NetstatReport)
                {
                    $NetStatReport |Export-Csv -Path "$($LogPath)\$($Computer)\$($FileName)" -NoTypeInformation -ErrorAction Stop
                    }
                }
            Catch
            {
                $Message = $Error[0].Exception
                Write-Verbose $Message
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
