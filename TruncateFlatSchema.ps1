
param (
	[string][parameter(mandatory=$true)]$server,
	[string]$port = "1433",
	[string][parameter(mandatory=$true)]$database = "protein",
	[string]$integratedSecurity = "SSPI",
    [string]$username = "",
	[string]$password
)

# Strict Mode
Set-StrictMode -Version Latest;

# Include to build database connection string
. ((Resolve-Path .\).Path + "\BuildConnectionString.ps1");

$connectionString = BuildConnectionString -server $server -port $port -database $database -integratedSecurity $integratedSecurity -username $username -password $password

Write-Host ("Opening database connection: $server\$database on port $port");
$connection = new-object system.data.SqlClient.SQLConnection($ConnectionString);    
[void]$connection.Open();

# Truncate the rows in the fragmentfile table and reset the identity
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
DELETE FROM fragmentfile;
DBCC CHECKIDENT ('fragmentfile', RESEED, 0);
"@;

Write-Host ("Truncating flatfile table and reseting identity");
$result = $sqlCommand.ExecuteNonQuery();
Write-Host ("$result rows truncated from previous run");

$sqlCommand.Dispose();

# Close the connection.
if ($connection.State -eq [Data.ConnectionState]::Open) {
    $connection.Close()
} else {
	"error"
}