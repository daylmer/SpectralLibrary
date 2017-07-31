# Process command-line parameters
#-server "%server%" -port "%port%" -database "%database%" -security "SSPI"

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

# Quit if the SQL connection didn't open properly.
if ($connection.State -ne [Data.ConnectionState]::Open) {
    Write-Host ("Error: Connection to database is not open");
    break;
}

Write-Host ("Building data for OLAP dimension: Data Set");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimDataSet (label, loaddate, sampledate, filename) 
	SELECT title, loaddate, sampledate, filename
	FROM dataset
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Time");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimTime (label, SampleDate) 
	SELECT distinct FORMAT (sampledate, 'D', 'en-gb'), sampledate
	FROM dataset
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Time point");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimTimePoint (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Timepoint'
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();


Write-Host ("Building data for OLAP dimension: Biological Replicate");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimBioReplicate (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Biological replicate'
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Technical Replciate");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimTechReplicate (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Technical replicate'
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Sequence");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimSequence (sequence)
	SELECT sequence 
	FROM sequence
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: SequenceType");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimSequenceType (label)
	SELECT title 
	FROM sequencematchtype
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Protein");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimProtein (label)
	SELECT accession 
	FROM protein
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Charge");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimCharge (label)
	SELECT DISTINCT charge
	FROM mspeak
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Experiment");
$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO DimExperiment (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Experiment'
"@;
[void]$sqlCommand.ExecuteNonQuery();
$sqlCommand.Dispose();

Write-Host ("Building data for OLAP dimension: Mass/Charge (absolute)");
$return = AbsoluteDimension -connection $connection -operation "MassCharge" -interval 100;

Write-Host ("Building data for OLAP dimension: Retention Time (absolute)");
$return = AbsoluteDimension -connection $connection -operation "RetentionTime" -interval 1;

Write-Host ("Building data for OLAP dimension: Drift Time (absolute)");
$return = AbsoluteDimension -connection $connection -operation "DriftTime" -interval 1;

Write-Host ("Building data for OLAP dimension: Intensity (absolute)");
$return = AbsoluteDimension -connection $connection -operation "Intensity" -interval 100000;

Write-Host ("Building data for OLAP dimension: Mass/Charge (clustered)");
[string]$massChargeQuery = @"
	SELECT TOP 1000 mc.masscharge
	FROM (
		SELECT distinct masscharge
		FROM mspeak
	) mc
	ORDER BY mc.masscharge
"@;
$return = ClusterDimension -connection $connection -operation "MassCharge" -query $massChargeQuery;

Write-Host ("Building data for OLAP dimension: Retention Time (clustered)");
[string]$retentionTimeQuery = @"
	SELECT TOP 1000 rt.retentiontime
	FROM (
		SELECT distinct retentiontime
		FROM mspeak
	) rt
	ORDER BY rt.retentiontime
"@;
$return = ClusterDimension -connection $connection -operation "RetentionTime" -query $retentionTimeQuery;

Write-Host ("Building data for OLAP dimension: Drift Time (clustered)");
[string]$driftTimeQuery = @"
	SELECT TOP 1000 dt.drifttime
	FROM (
		SELECT distinct drifttime
		FROM mspeak
	) dt
	ORDER BY dt.drifttime
"@;
$return = ClusterDimension -connection $connection -operation "DriftTime" -query $driftTimeQuery;

Write-Host ("Building data for OLAP dimension: Intensity (clustered)");
[string]$intensityQuery = @"
	SELECT TOP 1000 i.intensity
	FROM (
		SELECT distinct intensity
		FROM mspeak
		WHERE intensity is NOT NULL
	) i
	ORDER BY i.intensity
"@;
$return = ClusterDimension -connection $connection -operation "Intensity" -query $intensityQuery;

# Close the connection.
if ($connection.State -eq [Data.ConnectionState]::Open) {
    $connection.Close();
} else {
	throw "error";
}