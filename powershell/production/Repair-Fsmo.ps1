<#
    .SYNOPSIS
        The following script modifies the fSMORoleOwner attribute on the 
        infrastructure object of the specified Non-Domain Naming Context (NDNC) 
        to an active, or contactable, server
    .DESCRIPTION
        The following script modifies the fSMORoleOwner attribute on the 
        infrastructure object of the specified Non-Domain Naming Context (NDNC) 
        to an active, or contactable, server

        To determine the infrastructure master for a partition, query the 
        fSMORoleOwner attribute on the infrastructure object under the naming 
        context root in question. For example, query the fSMORoleOwner attribute 
        on the CN=Infrastructure,DC=DomainDnsZones,DC=contoso,DC=com naming 
        context root to determine the infrastructure master for the DC=DomainDnsZones,
        DC=contoso,DC=com partition. 
        
        Similarly, query the fSMORoleOwner attribute on the CN=Infrastructure,
        DC=ForestDnsZones,DC=contoso,DC=com naming context root to determine the 
        infrastructure master for the DC=ForestDnsZones,DC=contoso,DC=com partition.
    .PARAMETER NonDomainNamingContext
        A string representing the Non-Domain Naming context such as
            DC=DomainDnsZones,DC=contoso,DC=com
    .EXAMPLE
        .\Repair-Fsmo.ps1 -NonDomainNamingContext "DC=DomainDnsZones,DC=contoso,DC=com"
    .NOTES
        ScriptName : Repair-Fsmo.ps1
        Created By : jspatton
        Date Coded : 07/25/2012 08:45:21
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Repair-Fsmo.ps1
    .LINK
        http://support.microsoft.com/kb/949257
    .LINK
        http://blogs.technet.com/b/the_9z_by_chris_davis/archive/2011/12/20/forestdnszones-or-domaindnszones-fsmo-says-the-role-owner-attribute-could-not-be-read.aspx
#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
Param
    (
    [string]$NonDomainNamingContext
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
        Try
        {
            Import-Module .\includes\ActiveDirectoryManagement.psm1
            }
        Catch
        {
            Write-Warning "Must have the ActiveDirectoryManagement Module available."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ActiveDirectoryManagement Module Not Found"
            Break
            }
        }
Process
    {
        Write-Verbose 'Convert the DN form of the NDNC into DNS dotted form.'
        $TempDn = ConvertTo-Canonical -Name $NonDomainNamingContext |Select-Object -Property Value
        $DomainDns = $TempDn.Value.Substring(0,$TempDn.Value.Length -1)
        Write-Verbose "DNS name: $($DomainDns)"
        
        Write-Verbose 'Find a domain controller that hosts this NDNC and that is online.'
        $RootDSE = [adsi]"LDAP://$($DomainDns)/RootDSE"
        $DomainController = $RootDSE.Get('dnsHostName')
        $DsServiceName = $RootDSE.Get('dsServiceName')
        Write-Verbose "Using DC $($DomainController)"
        
        Write-Verbose 'Get the current infrastructure fsmo.'
        $InfrastructureDN = "CN=Infrastructure,$($NonDomainNamingContext)"
        $Infrastructure = [adsi]"LDAP://$($InfrastructureDN)"
        Write-Verbose "Infrastructure FSMO is $($Infrastructure.fSMORoleOwner)"
        
        Write-Verbose "If the current fsmo holder is deleted, set the fsmo holder to this domain controller."
        if ($Infrastructure.fSMORoleOwner.Value.IndexOf("\0ADEL:") -gt 0)
        {
            try
            {
                if ($pscmdlet.ShouldProcess($Infrastructure.fSMORoleOwner.Value, "Change role owner to $($DsServiceName)"))
                {
                    Write-Verbose 'Set the fsmo holder to this domain controller.'
                    $Infrastructure.Put("fSMORolwOner", $DsServiceName)
                    $Infrastructure.SetInfo()
                    
                    Write-Verbose 'Read the fsmo holder back.'
                    $Infrastructure = [adsi]"LDAP://$($InfrastructureDN)"
                    Write-Verbose "Infrastructure FSMO changed to: $($Infrastructure.fSMORoleOwner)"
                    }
                }
            catch
            {
                Write-Error $Error[0]
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }