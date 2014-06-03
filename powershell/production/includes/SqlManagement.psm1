function New-SqlLogin
{
    param 
    (
        [parameter(Mandatory = $true)][string] $loginName,
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandType = 1
        $sqlCommand.Connection = $sqlConnection
        $sqlCommandText = "create login [$($loginName)] from windows with default_database=[$($Database)], default_language=[us_english]"
        Write-Verbose $sqlCommandText
        $sqlCommand.CommandText = $sqlCommandText;
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlCommand.ExecuteNonQuery()
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }
function Add-SqlUser
{
    param 
    (
        [parameter(Mandatory = $true)][string] $loginName,
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandType = 1
        $sqlCommand.Connection = $sqlConnection
        $sqlCommandText = "create user [$($loginName)] For Login [$($loginName)]"
        Write-Verbose $sqlCommandText
        $sqlCommand.CommandText = $sqlCommandText;
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlCommand.ExecuteNonQuery()
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }
function Add-SqlRole
{
    param 
    (
        [parameter(Mandatory = $true)][string] $loginName,
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [parameter(Mandatory = $true)][string] $Role,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandType = 1
        $sqlCommand.Connection = $sqlConnection
        $sqlCommandText = "exec [$($Database)]..sp_addrolemember $($Role), [$($loginName)]"
        Write-Verbose $sqlCommandText
        $sqlCommand.CommandText = $sqlCommandText;
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlCommand.ExecuteNonQuery()
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }
function Set-SqlServerPermission
{
    param 
    (
        [parameter(Mandatory = $true)][string] $loginName,
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [switch] $Grant,
        [parameter(Mandatory = $true)][string] $Permission,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandType = 1
        $sqlCommand.Connection = $sqlConnection
        if ($Grant)
        {
            $sqlCommandText = "GRANT $($Permission) TO [$($loginName)]"
            }
        else
        {
            $sqlCommandText = "DENY $($Permission) TO [$($loginName)]"
            }
        Write-Verbose $sqlCommandText
        $sqlCommand.CommandText = $sqlCommandText;
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlCommand.ExecuteNonQuery()
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }
function Get-SqlUser
{
    param 
    (
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommandText = "select * from sys.sysusers"
        Write-Verbose $sqlCommandText
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlDataSet = New-Object System.Data.DataSet
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ($sqlCommandText, $sqlConnection)
        $Result = $sqlAdapter.Fill($sqlDataSet)
        $sqlDataSet.Tables;
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }
function Get-SqlDatabase
{
    param 
    (
        [parameter(Mandatory = $true)][string] $sqlServer,
        [parameter(Mandatory = $true)][string] $Database,
        [parameter(Mandatory = $false)][string] $sqlInstance,
        [parameter(Mandatory = $false)][PSCredential] $Credential
    )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($sqlInstance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($sqlServer);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($sqlServer)\$($sqlInstance);Database=$($Database)";
            }
        if ($Credential)
        {
            $Credential.Password.MakeReadOnly();
            $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
            }
        else
        {
            $sqlConnString += ";trusted_connection=true";
            }
        Write-Verbose $sqlConnString
        $sqlConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($sqlConnString);
        Write-Verbose $sqlConnBuilder.ConnectionString
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnBuilder.ConnectionString);
        $sqlCommandText = "SELECT name FROM master..sysdatabases"
        Write-Verbose $sqlCommandText
        if ($sqlCredential)
        {
            $sqlConnection.Credential = $sqlCredential;
            }
        $sqlConnection.Open()
        $sqlDataSet = New-Object System.Data.DataSet
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ($sqlCommandText, $sqlConnection)
        $Result = $sqlAdapter.Fill($sqlDataSet)
        $sqlDataSet.Tables;
        }
    catch
    {
        $str = (([string] $Error).Split(':'))[1]
        Write-Error ($str.Replace('"', ''))
        }
    finally
    {
        if ($sqlConnection)
        {
            $sqlConnection.Close()
            }
        }
    }