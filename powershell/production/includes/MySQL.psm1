try
{
    $ErrorActionPreference = "Stop";
    [System.Reflection.Assembly]::LoadWithPartialName("MySql.Data") |Out-Null;
    }
catch
{
    Write-Error "MySQL Connector for .NET not installed, please visit http://dev.mysql.com/downloads/connector/net/6.4.html";
    break
    }
Function Connect-MySqlServer
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER ComputerName
        .PARAMETER Port
        .PARAMETER Credential
        .PARAMETER Database
        .EXAMPLE
        .NOTES
            FunctionName : Connect-MySqlServer
            Created by   : jspatton
            Date Coded   : 02/11/2015 09:19:10
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Connect-MySqlServer
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ComputerName = "localhost",
        [int]$Port = 3306,
        [System.Management.Automation.PSCredential]$Credential,
        [string]$Database
        )
    Begin
    {
        Write-Verbose "Build connection string";
        if ($Database)
        {
            $ConnectionString = "server=$($ComputerName);port=$($Port);uid=$($Credential.UserName);pwd=$($Credential.GetNetworkCredential().Password);database=$($Database);";
            }
        else
        {
            $ConnectionString = "server=$($ComputerName);port=$($Port);uid=$($Credential.UserName);pwd=$($Credential.GetNetworkCredential().Password);";
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = "Stop";
            Write-Verbose "Create connection object";
            [MySql.Data.MySqlClient.MySqlConnection]$Connection = New-Object MySql.Data.MySqlClient.MySqlConnection($ConnectionString);
            Write-Verbose "Open connection";
            $Connection.Open();
            if ($Database)
            {
                Write-Verbose "Using $($Database)";
                [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $($Database)", $Connection);
                }
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        return $Connection;
        }
    }
Function Disconnect-MySqlServer
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Disconnect-MySqlServer
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:16:24
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Disconnect-MySqlServer
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection
        )
    Begin
    {
        }
    Process
    {
        $Connection.Close();
        }
    End
    {
        }
    }
Function New-MySqlDatabase
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : New-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 09:35:02
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlDatabase
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Name
        )
    Begin
    {
        $Query = "CREATE DATABASE $($Name);";
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            Write-Verbose "Getting newly created database";
            Get-MySqlDatabase -Connection $Connection -Name $Name;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Get-MySqlDatabase
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:05:20
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlDatabase
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Name
        )
    Begin
    {
        if ($Name)
        {
            $Query = "SHOW DATABASES WHERE ``Database`` LIKE '$($Name)';";
            }
        else
        {
            $Query = "SHOW DATABASES;";
            }
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function New-MySqlUser
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : New-MySqlUser
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:28:35
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlUser
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Database,
        [System.Management.Automation.PSCredential]$Credential
        )
    Begin
    {
        $Query = "CREATE USER '$($Credential.UserName)'@'$($Connection.DataSource)' IDENTIFIED BY '$($Credential.GetNetworkCredential().Password)';";
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            Write-Verbose "Getting newly created user";
            Get-MySqlUser -Connection $Connection -User $Credential.UserName;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Get-MySqlUser
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-MySqlUser
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:45:50
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlUser
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$User
        )
    Begin
    {
        if ($User)
        {
            $Query = "SELECT * FROM mysql.user WHERE ``User`` LIKE '$($User)';";
            }
        else
        {
            $Query = "SELECT * FROM mysql.user;"
            }
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function New-MySqlTable
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : New-MySqlTable
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:31:18
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlTable
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Table
        )
    Begin
    {
        $Query = "CREATE TABLE $($Table) (id int);"
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            Write-Verbose "Getting newly created table";
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Get-MySqlTable
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-MySqlTable
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:47:03
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlTable
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Database,
        [string]$Table
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = "Stop";
            if ($Database)
            {
                if (Get-MySqlDatabase -Connection $Connection -Name $Database)
                {
                    $Connection.ChangeDatabase($Database);
                    }
                else
                {
                    throw "Unknown database $($Database)";
                    }
                }
            else
            {
                if (!($Connection.Database))
                {
                    throw "Please connect to a specific database";
                    }
                }
            }
        catch
        {
            $Error[0];
            break
            }
        $db = $Connection.Database;
        if ($Table)
        {
            $Query = "SHOW TABLES FROM $($db) WHERE ``Tables_in_$($db)`` LIKE '$($Table)';"
            }
        else
        {
            $Query = "SHOW TABLES FROM $($db);"
            }
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Get-MySqlColumn
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-MySqlField
            Created by   : jspatton
            Date Coded   : 02/11/2015 13:17:25
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlField
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Database,
        [string]$Table
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = "Stop";
            if ($Database)
            {
                if (Get-MySqlDatabase -Connection $Connection -Name $Database)
                {
                    $Connection.ChangeDatabase($Database);
                    }
                else
                {
                    throw "Unknown database $($Database)";
                    }
                }
            else
            {
                if (!($Connection.Database))
                {
                    throw "Please connect to a specific database";
                    }
                }
            }
        catch
        {
            $Error[0];
            break
            }
        $Query = "DESC $($Table);";
        }
    Process
    {
        try
        {
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Add-MySqlColumn
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Add-MySqlColumn
            Created by   : jspatton
            Date Coded   : 02/11/2015 13:21:29
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Add-MySqlColumn
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Database,
        [string]$Table,
        [string]$Name,
        [string]$Definition
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = "Stop";
            if ($Database)
            {
                if (Get-MySqlDatabase -Connection $Connection -Name $Database)
                {
                    $Connection.ChangeDatabase($Database);
                    }
                else
                {
                    throw "Unknown database $($Database)";
                    }
                }
            else
            {
                if (!($Connection.Database))
                {
                    throw "Please connect to a specific database";
                    }
                }
            $Query = "ALTER TABLE $($Table) ADD ($($Name) $($Definition));";
            }
        catch
        {
            $Error[0];
            break
            }
        }
    Process
    {
        try
        {
            Write-Host $VerbosePreference
            Write-Verbose "Invoking SQL";
            Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        }
    }
Function Invoke-MySqlQuery
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Connection
        .PARAMETER Query
        .EXAMPLE
        .NOTES
            FunctionName : Invoke-MySqlQuery
            Created by   : jspatton
            Date Coded   : 02/11/2015 11:09:26
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Invoke-MySqlQuery
    #>
    [CmdletBinding()]
    Param
        (
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$Query
        )
    Begin
    {
        }
    Process
    {
        try
        {
            $ErrorActionPreference = "Stop";
            Write-Verbose "Creating the Command object";
            [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand;
            Write-Verbose "Assigning Connection object to Command object";
            $Command.Connection = $Connection;
            Write-Verbose "Assigning Query to Command object";
            $Command.CommandText = $Query;
            Write-Verbose $Query;
            Write-Verbose "Creating DataAdapter with Command object";
            [MySql.Data.MySqlClient.MySqlDataAdapter]$DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command);
            Write-Verbose "Creating Dataset object to hold records";
            [System.Data.DataSet]$DataSet = New-Object System.Data.DataSet;
            Write-Verbose "Filling Dataset";
            $RecordCount = $DataAdapter.Fill($DataSet);
            Write-Verbose "$($RecordCount) records found";
            }
        catch
        {
            $Error[0];
            break
            }
        }
    End
    {
        Write-Verbose "Returning Tables object of Dataset";
        return $DataSet.Tables;
        }
    }


Export-ModuleMember *