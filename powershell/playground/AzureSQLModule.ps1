$Global:ConnectAzureSqlDatabase;

function Connect-AzureSqlDatabase
{
    [CmdletBinding()]
    param
    (
        [pscredential]$SqlCredential,
        [string]$Servername,
        [string]$Database
    )
    try 
    {
        $ErrorActionPreference = 'Stop';
        $Error.Clear();

        $ConnectionString = "Server=tcp:$($Servername),1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$($sqlCredential.Username);Password=$($SqlCredential.GetNetworkCredential().Password);MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
        $SqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($ConnectionString);
        Write-Verbose $SqlConnectionStringBuilder.ConnectionString;
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection($SqlConnectionStringBuilder.ConnectionString);
        $Global:ConnectAzureSqlDatabase = $SqlConnection;
        $SqlConnection.Open();
    }
    catch 
    {
        throw $_;
    }
}

