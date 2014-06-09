function New-SqlLogin
{
    <#
        .SYNOPSIS
            Creates a Database Engine login for SQL Server and Windows Azure SQL Database
        .DESCRIPTION
        .PARAMETER LoginName
            Specifies the name of the login that is created. There are four types of
            logins: SQL Server logins, Windows logins, certificate-mapped logins, and 
            asymmetric key-mapped logins. 
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : New-SqlLogin
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#New-SqlLogin
        .LINK
            http://msdn.microsoft.com/en-us/library/ms189751.aspx
        .LINK
            http://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.connectionstring(v=vs.110).aspx
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $LoginName,
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
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
        $sqlCommandText = "create login [$($LoginName)] from windows with default_database=[$($Database)], default_language=[us_english]"
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
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LoginName
            Specifies the name of the login that is created. There are four types of
            logins: SQL Server logins, Windows logins, certificate-mapped logins, and 
            asymmetric key-mapped logins. 
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : Add-SqlUser
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#Add-SqlUser
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $LoginName,
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
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
        $sqlCommandText = "create user [$($LoginName)] For Login [$($LoginName)]"
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
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LoginName
            Specifies the name of the login that is created. There are four types of
            logins: SQL Server logins, Windows logins, certificate-mapped logins, and 
            asymmetric key-mapped logins. 
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Role
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : Add-SqlRole
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#Add-SqlRole
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $LoginName,
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $true)]
        [string] $Role,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
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
        $sqlCommandText = "exec [$($Database)]..sp_addrolemember $($Role), [$($LoginName)]"
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
function Set-ComputerNamePermission
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LoginName
            Specifies the name of the login that is created. There are four types of
            logins: SQL Server logins, Windows logins, certificate-mapped logins, and 
            asymmetric key-mapped logins. 
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Grant
        .PARAMETER Permission
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : Set-ComputerNamePermission
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#Set-ComputerNamePermission
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $LoginName,
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [switch] $Grant,
        [parameter(Mandatory = $true)]
        [string] $Permission,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
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
            $sqlCommandText = "GRANT $($Permission) TO [$($LoginName)]"
            }
        else
        {
            $sqlCommandText = "DENY $($Permission) TO [$($LoginName)]"
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
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : Get-SqlUser
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#Get-SqlUser
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
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
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER ComputerName
            The name of the SQL server to connect to
        .PARAMETER Database
            Specifies the default database to be assigned to the login
        .PARAMETER Instance
            The instance name is used to resolve to a particular TCP/IP port number on 
            which a database instance is hosted
        .PARAMETER Credential
        .EXAMPLE
        .NOTES
            FunctionName : Get-SqlDatabase
            Created by   : Jeffrey
            Date Coded   : 06/08/2014 17:32:12
        .LINK
            https://code.google.com/p/mod-posh/wiki/SqlManagement#Get-SqlDatabase
    #>
    [CmdletBinding()]
    param 
        (
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $false)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )

    $sqlConnection = $null

    try
    {
        $Error.Clear()
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance)";
            }
        if ($Database -eq $null)
        {
            $sqlConnString += ";Database=$($Database)";
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