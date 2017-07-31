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

# Include to build absolute dimensions
. ((Resolve-Path .\).Path + "\AbsoluteDimension.ps1");

# Include to build clustered dimensions
. ((Resolve-Path .\).Path + "\ClusterDimension.ps1");

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
INSERT INTO DimDataSet (extid, label, loaddate, sampledate, filename) 
	SELECT id, title, loaddate, sampledate, filename
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
	FROM SequenceMatchType
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
#>
Write-Host ("Building data for OLAP dimension: Retention Time (absolute)");
$return = AbsoluteDimension -connection $connection -operation "RetentionTime" -interval 60 -multiplier 60;

Write-Host ("Building data for OLAP dimension: Drift Time (absolute)");
$return = AbsoluteDimension -connection $connection -operation "DriftTime" -interval 1;

Write-Host ("Building data for OLAP dimension: Intensity (absolute)");
$return = AbsoluteDimension -connection $connection -operation "Intensity" -interval 100000;

Write-Host ("Building data for OLAP dimension: Score");
$return = AbsoluteDimension -connection $connection -operation "Score" -interval 1;

<#
Write-Host ("Building data for OLAP dimension: Mass/Charge (clustered)");
[string]$massChargeQuery = @"
	SELECT masscharge, count(masscharge) Frequency
	FROM mspeak
	GROUP BY masscharge
"@;
[string]$massChargeQuery = @"
	SELECT cast(masscharge as int) as masscharge, count(masscharge) Frequency
	FROM mspeak
	GROUP BY cast(masscharge as int)
"@;
[string]$massChargeQuery = @"
	SELECT cast(masscharge * 100 as int) / 100 as masscharge, count(masscharge) Frequency
	FROM mspeak
	GROUP BY cast(masscharge * 100 as int)
"@;

$return = ClusterDimension -connection $connection -operation "MassCharge" -query $massChargeQuery -minClusters 1400 -maxClusters 1865 -increment 1;

Write-Host ("Building data for OLAP dimension: Retention Time (clustered)");
[string]$retentionTimeQuery = @"
	SELECT cast(retentiontime*60 as int) as retentiontime, count(retentiontime) Frequency
	FROM mspeak
	GROUP BY  cast(retentiontime*60 as int)
"@;

$return = ClusterDimension -connection $connection -operation "RetentionTime" -query $retentionTimeQuery -minClusters 250 -maxClusters 4964 -increment 60;

Write-Host ("Building data for OLAP dimension: Drift Time (clustered)");
[string]$driftTimeQuery = @"
	SELECT cast(drifttime*60 as int) as drifttime, count(drifttime) Frequency
	FROM mspeak
	GROUP BY  cast(drifttime*60 as int)
"@;
$return = ClusterDimension -connection $connection -operation "DriftTime" -query $driftTimeQuery -minClusters 1000 -maxClusters 9239 -increment 60;

Write-Host ("Building data for OLAP dimension: Intensity (clustered)");
[string]$intensityQuery = @"
	SELECT cast(intensity/10 as bigint)*10 as intensity, count(intensity) Frequency
	FROM mspeak
	GROUP BY cast(intensity/10 as bigint)
"@;
$return = ClusterDimension -connection $connection -operation "Intensity" -query $intensityQuery -minClusters 3000 -maxClusters 10000 -increment 0;
#>
# Close the connection.
if ($connection.State -eq [Data.ConnectionState]::Open) {
    $connection.Close();
} else {
	throw "error";
}