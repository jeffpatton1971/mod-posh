<#
    .SYNOPSIS
        Schema for licensing AD users for Office365
    .DESCRIPTION
        This schema will setup Dirsycn with the proper objects and properties 
        to provision or de-provision a user with an Office365 License. For details
        on how to setup your schema please see 
    .NOTES
        ScriptName : New-Schema.ps1
        Created By : Jeffrey
        Date Coded : 12/29/2014 11:49:45

        This script is only run when a Management Agent is created or refreshed
    .LINK
        https://github.com/jeffpatton1971/mod-posh/wiki/Production/New-Schema.ps1
    .LINK
        http://blog.goverco.com/p/powershell-management-agent.html
    .LINK
        http://blog.goverco.com/p/psmaschema.html
 #>
[CmdletBinding()]
Param
(
)
Begin
{
    try
    {
        Import-Module C:\Scripts\LogFiles.psm1
        }
    catch
    {
        Write-Error $Error[0]
        break
        }
    }
Process
{
    try
    {
        $LogName = "PMA-Office365-Schema"
        $Source = "Setup"
        $EntryType = "Information"
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setting up schema for use with dirsync"
    
        $obj = New-Object -TypeName psobject
        @(
            @{Name = "Anchor-id"; Type = "Binary"; Value = 1}
            @{Name = "objectClass"; Type = "String"; Value = "person"}
            @{Name = "objectguidstring"; Type = "String"; Value = ""}
            @{Name = "objectsidstring"; Type = "String"; Value = ""}
            @{Name = "samaccountname"; Type = "String"; Value = ""}
            @{Name = "msds-cloudextensionattribute1"; Type = "String"; Value = ""}
        )| ForEach-Object {
                Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Adding $($_.Name)|$($_.Type) with Value $($_.Value) to the schema"
                $obj |Add-Member -MemberType NoteProperty -Name "$($_.Name)|$($_.Type)" -Value $_.Value
            }
        }
    catch
    {
        Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType "Error" -Message $Error[0].Exception
        break
        }
    }
End
{
    if ($obj.'Anchor-id|Binary')
    {
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setup complete"
        return $obj
        }
    else
    {
        Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType "Error" -Message "Object empty, please see earlier error message"
        }
    }