Function Invoke-SqlQuery
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Credential
        .PARAMETER ConnectionString
        .PARAMETER COmmand
        .PARAMETER Query
        .EXAMPLE
        .NOTES
            FunctionName : Invoke-SqlQuery
            Created by   : jspatton
            Date Coded   : 06/09/2014 12:31:07
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled9#Invoke-SqlQuery
        .LINK
            http://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.connectionstring(v=vs.110).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $false)]
        [pscredential]$Credential = $null,
        [parameter(Mandatory = $true)]
        [string]$ConnectionString = $null,
        [switch]$Command,
        [parameter(Mandatory = $true)]
        [string]$Query = $null
        )
    Begin
    {
        }
    Process
    {
        try
        {
            Write-Debug "Make sure we stop on errors";
            $ErrorActionPreference = "Stop";
            Write-Debug "Clear out any previous errors";
            $Error.Clear();
            Write-Debug "Create System.Data.SqlClient.SqlConnectionStringBuilder";
            Write-Debug "To build a proper connection string based on whats passed in";
            Write-Verbose $ConnectionString;
            $SqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($ConnectionString);
            Write-Debug "Validated ConnectionString";
            Write-Debug $SqlConnectionStringBuilder.ConnectionString;
            Write-Debug "Create System.Data.SqlClient.SqlConnection to connect to sql";
            $SqlConnection = New-Object System.Data.SqlClient.SqlConnection($SqlConnectionStringBuilder.ConnectionString);
            Write-Debug "Check if credentials are passed in";
            if ($Credential)
            {
                Write-Debug "SqlCredentials can only accept read-only passwords";
                Write-Debug "Make credential password readonly";
                $Credential.Password.MakeReadOnly();
                Write-Debug "Create a System.Data.SqlClient.SqlCredential to hold credentials";
                $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Credential.UserName, $Credential.Password);
                Write-Verbose "Assign credentials to connection object";
                $SqlConnection.Credential = $sqlCredential;
                }
            Write-Debug "Open connection";
            $SqlConnection.Open();
            if ($Command)
            {
                Write-Debug "Create a System.Data.SqlClient.SqlCommand object";
                $SqlCommand = New-Object System.Data.SqlClient.SqlCommand;
                Write-Debug "Set CommandType to 1";
                $SqlCommand.CommandType = 1;
                Write-Debug "Assign Connection object";
                $SqlCommand.Connection = $SqlConnection;
                Write-Debug "Set CommandText";
                Write-Verbose $Command;
                $SqlCommand.CommandText = $Command;
                Write-Verbose "Return SQL Data";
                $Result = $SqlCommand.ExecuteNonQuery();
                }
            else
            {
                Write-Debug "Create System.Data.Dataset object to hold result";
                $SqlDataSet = New-Object System.Data.DataSet;
                Write-Debug "Create System.Data.SqlClient.SqlDataAdpater to fill the Dataset object";
                $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($Query, $SqlConnection);
                Write-Debug "Fill the dataset object";
                $Output = $SqlAdapter.Fill($SqlDataSet);
                Write-Verbose "Return SQL Data";
                $Result = $SqlDataSet.Tables;
                }
            Return $Result;
            }
        catch
        {
            $str = (([string] $Error).Split(':'))[1]
            Write-Error ($str.Replace('"', ''))
            }
        finally
        {
            if ($SqlConnection)
            {
                $SqlConnection.Close()
                }
            }
        }
    End
    {
        }
    }
function New-SqlLogin
{
    <#
        .SYNOPSIS
            Creates a Database Engine login for SQL Server and Windows Azure SQL Database
        .DESCRIPTION
        .PARAMETER Login
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
            A credential object that represents a SQL Login that has permissions
        .EXAMPLE
            New-SqlLogin -Login "Domain\JSmith" -ComputerName (& hostname) -Database master -sqlInstance 'MSSQLSERVER'

            Description
            -----------
            This example shows how to add a windows user to a the master database on
            the default instance of Sql Server
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
        [string] $Login,
        [parameter(Mandatory = $true)]
        [string] $ComputerName,
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )
    Begin
    {
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
            }
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        $sqlCommandText = "create login [$($Login)] from windows with default_database=[$($Database)], default_language=[us_english]"
        }
    Process
    {
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Command -Query $sqlCommandText;
        }
    End
    {
        Return $Result
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
            A credential object that represents a SQL Login that has permissions
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
    Begin
    {
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
            }
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        $sqlCommandText = "create user [$($LoginName)] For Login [$($LoginName)]"
        }
    Process
    {
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Command -Query $sqlCommandText;
        }
    End
    {
        Return $Result
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
            A credential object that represents a SQL Login that has permissions
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
    Begin
    {
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
            }
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        $sqlCommandText = "exec [$($Database)]..sp_addrolemember $($Role), [$($LoginName)]"
        }
    Process
    {
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Command -Query $sqlCommandText;
        }
    End
    {
        Return $Result
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
            A credential object that represents a SQL Login that has permissions
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
    Begin
    {
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
            }
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        if ($Grant)
        {
            $sqlCommandText = "GRANT $($Permission) TO [$($LoginName)]"
            }
        else
        {
            $sqlCommandText = "DENY $($Permission) TO [$($LoginName)]"
            }
        }
    Process
    {
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Command -Query $sqlCommandText;
        }
    End
    {
        Return $Result
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
            A credential object that represents a SQL Login that has permissions
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
        [parameter(Mandatory = $false)]
        [string] $ComputerName = (& hostname),
        [parameter(Mandatory = $true)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )
    Begin
    {
        if ($Instance -eq $null)
        {
            $sqlConnString = "Server=tcp:$($ComputerName);Database=$($Database)";
            }
        else
        {
            $sqlConnString = "Server=tcp:$($ComputerName)\$($Instance);Database=$($Database)";
            }
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        }
    Process
    {
        $sqlCommandText = "select * from sys.sysusers"
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Query $sqlCommandText;
        }
    End
    {
        Return $Result
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
            A credential object that represents a SQL Login that has permissions
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
        [parameter(Mandatory = $false)]
        [string] $ComputerName = (& hostname),
        [parameter(Mandatory = $false)]
        [string] $Database,
        [parameter(Mandatory = $false)]
        [string] $Instance,
        [parameter(Mandatory = $false)]
        [PSCredential] $Credential
        )
    Begin
    {
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
        if (!($Credential))
        {
            $sqlConnString += ";trusted_connection=true";
            }
        }
    Process
    {
        $sqlCommandText = "SELECT name FROM master..sysdatabases"
        $Result = Invoke-SqlQuery -Credential $Credential -ConnectionString $sqlConnString -Query $sqlCommandText;
        }
    End
    {
        return $Result
        }
    }