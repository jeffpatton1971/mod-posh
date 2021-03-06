Function Get-SQLServer
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-SQLServer
            Created by   : jspatton
            Date Coded   : 09/19/2011 16:36:49
        .LINK
    #>
    Param
        (
        [string]$ComputerName = "sql",
        $Credentials = (Get-Credential)
        )
    Begin
    {
        try
        {
            [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")
            }
        catch
        {
            Write-Warning $Error[0].Exception
            }

        $Server = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server -argumentlist $ComputerName
        $Server.ConnectionContext.LoginSecure = $false
        $Server.ConnectionContext.set_Login($Credentials.UserName)
        $Server.ConnectionContext.set_SecurePassword($Credentials.Password)
        }
    Process
    {
        }
    End
    {
        }
}