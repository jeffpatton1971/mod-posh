<#
    .SYNOPSIS
        Full or Delta user import
    .DESCRIPTION
        This script is run on either a full (first time)import or delta import.
    .PARAMETER Username
        A user with rights in AD
    .PARAMETER Password
        User password
    .PARAMETER OperationType
        Default to full
    .PARAMETER UsePagedImport
        A true/false value passed in at runtime
    .PARAMETER PageSize
        A value passed in at runtime
    .NOTES
        ScriptName : Import-User.ps1
        Created By : Jeffrey
        Date Coded : 12/29/2014 12:22:22

        This script is run on a full or delta import run profile
    .LINK
        https://github.com/jeffpatton1971/mod-posh/wiki/Production/Import-User.ps1
    .LINK
        http://blog.goverco.com/p/powershell-management-agent.html
    .LINK
        http://blog.goverco.com/p/psmaimport.html
 #>
[CmdletBinding()]
Param
(
    [string]$Username,
    [string]$Password,
    [string]$OperationType = "Full",
    [bool]$UsePagedImport,
    $PageSize
)
Begin
{
    try
    {
        Import-Module C:\Scripts\LogFiles.psm1
        Import-Module C:\Scripts\ActiveDirectoryManagement.psm1
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
        $ErrorActionPreference = "Stop"
        $Error.Clear()
        $LogName = "PMA-Office365-Import"
        $Source = "Import"
        $EntryType = "Information"

        $Credential = New-Object System.Management.Automation.PSCredential ($Username, (ConvertTo-SecureString -String $Password -AsPlainText -Force))
        Write-LogFile -LogPath $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Creating Credential object to connect to AD"

        $DeltaPropertiesToLoad = @("msds-cloudextensionattribute1")
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setting DeltaProperties $($DeltaPropertiesToLoad)"

        $MASchemaProperties = @("objectguidstring","objectsidstring","sAMAccountName","msDS-cloudExtensionAttribute1")
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setting up Schema Properties $($MASchemaProperties)"

        $RootDSE = (([ADSI]"").distinguishedName)
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setting RootDSE : $($RootDSE)"

        $SearchFilter = "(&(objectClass=user)(objectCategory=person))"
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Setting searchfilter : $($SearchFilter)"

        if (($OperationType -eq "Full") -or ($RunStepCustomData -match '^$'))
        {
            $Results = Get-ADObjects -ADSPath $RootDSE -SearchFilter $SearchFilter -SearchScope Subtree -ADProperties $DeltaPropertiesToLoad -Credential $Credential -DirSync $null
            Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Reset the directory synchronization cookie for full imports (or no watermark)"
            }
        else
        {
            $Cookie = [System.Convert]::FromBase64String($RunStepCustomData)
            Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Get watermark from last run and pass to searcher object"
            $SyncCookie = ,$Cookie
            $Results = Get-ADObjects -ADSPath $RootDSE -SearchFilter $SearchFilter -SearchScope Subtree -ADProperties $DeltaPropertiesToLoad -Credential $Credential -DirSync $SyncCookie
            }

        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Query AD for objects, found : $($Results.Count)"

        foreach ($Result in $Results)
        {
            if ($Result)
            {
                Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message "Setting up object"
                $obj = @{}
                $obj.id = ([guid]$Result.PSBase.Properties.objectguid[0]).ToByteArray()
                $obj."[DN]" = $Result.PSBase.path -replace '^LDAP\://'
                $obj.objectClass = "person"
                if ($Result.Properties.Contains("isdeleted"))
                {
                    Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message "Found deleted object, set changetype to delete; default is add"
                    $obj.changeType = "Delete"
                    if ($OperationType -ne "Full")
                    {
                        $obj
                        }
                    }
                else
                {
                    $DirEntry = $Result.GetDirectoryEntry()
                    Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message "Connect to the Directory Entry for the object to get at all properties"

                    $obj.objectguidstring = [string]([guid]$Result.PSBase.Properties.objectguid[0])
                    Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message "Get User GUID : $([guid]$Result.PSBase.Properties.objectguid[0])"
                    $obj.objectsidstring = [string](New-Object System.Security.Principal.SecurityIdentifier($DirEntry.Properties["objectSid"][0],0))
                    $MASchemaProperties |ForEach-Object {
                        if ($DirEntry.Properties.Contains($_))
                        {
                            $obj.$_ = $DirEntry.Properties[$_][0]
                            }
                        }
                    Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message $obj.Keys
                    Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message $obj.Values
                    $obj
                    }
                }
            else
            {
                Write-LogFile -LogName $LogName -Source $Source -EventID 104 -EntryType "Waring" -Message "Empty result encountered"
                }
            }
        #$Global:RunStepCustomData = [System.Convert]::ToBase64String($Searcher.DirectorySynchronization.GetDirectorySynchronizationCookie())
        #Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType $EntryType -Message "Updating cookie : $(($Searcher.DirectorySynchronization.GetDirectorySynchronizationCookie()))"
        }
    catch
    {
        Write-LogFile -LogName $LogName -Source $Source -EventID 103 -EntryType "Error" -Message $Error[0].Exception
        }
    }
End
{
    Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Finished Import"
    }