<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-ExchangeCalendar.ps1
        Created By : jspatton
        Date Coded : 06/14/2012 11:51:52
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-ExchangeCalendar.ps1
#>
[CmdletBinding()]
Param
    (
    $MailboxName = 'jspatton@ku.edu',
    $StartDate = (Get-Date),
    $EndDate = (Get-Date).AddDays(7)
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
        $DllPath = 'C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll'
        [void][Reflection.Assembly]::LoadFile($DllPath)
        $Service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010)
        $Service.AutodiscoverUrl($MailboxName)
        $FolderID = New-Object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar,$MailboxName)
        $CalendarFolder = [Microsoft.Exchange.WebServices.Data.CalendarFolder]::Bind($Service,$FolderID)
        $CalendarView = New-Object Microsoft.Exchange.WebServices.Data.CalendarView($StartDate,$EndDate,2012)
        $Calendarview.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
        $CalendarResult = $CalendarFolder.FindAppointments($CalendarView)

        $Appointments = @()
        }
Process
    {
        foreach ($Appointment in $CalendarResult.Items)
        {
            $Propset = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
            $Appointment.load($Propset)
            $ThisAppointment = New-Object -TypeName PSObject -Property @{
                Appointment = $Appointment.Subject.ToString()
                Start = $Appointment.Start.ToString()
                End = $Appointment.End.ToString()
                Organizer = $Appointment.Organizer.ToString()
                }
            $Appointments += $ThisAppointment
            }
        }
End
    {
        Return $Appointments
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }