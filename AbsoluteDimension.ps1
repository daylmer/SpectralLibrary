# AbsoluteDimension

function AbsoluteDimension {
	param (
		[system.data.SqlClient.SQLConnection]$connection,
		[string]$operation,
		[decimal]$interval,
		[decimal]$multiplier = 1
	)

	# Strict Mode
	Set-StrictMode -Version Latest;

	$OrdinalWhiteList = @{
		"MassCharge" = "masscharge";
		"RetentionTime" = "retentiontime";
		"DriftTime" = "drifttime";
		"Intensity" = "intensity";
		"Score"		= "score";
	}

	[string]$ordinal = $OrdinalWhiteList[$operation];
	
	If ($ordinal.length -eq 0) {
		throw "AbsoluteDimension Error: $operation is not recognised";
		return 0;
	}
	
	$TableWhiteList = @{
		"MassCharge" = "mspeak";
		"RetentionTime" = "mspeak";
		"DriftTime" = "mspeak";
		"Intensity" = "mspeak";
		"Score"		= "mspeaksequence";
	}
	
	[string]$table = $TableWhiteList[$operation];

	If ($table.length -eq 0) {
		throw "AbsoluteDimension Error: $table is not recognised";
		return 0;
	}
	
	# Include to insert clustered mass/charge dimensions
	. ((Resolve-Path .\).Path + "\InsertAbsoluteDimension.ps1");

	[decimal]$minvalue = 0;
	[decimal]$maxvalue = 0;

	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = "SELECT min($ordinal) from $table with (nolock)";
	#Write-Host($sqlCommand.CommandText);
	[decimal]$minvalue = $sqlCommand.ExecuteScalar() * $multiplier;         
	$sqlCommand.Dispose();

	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = "SELECT max($ordinal) from $table with (nolock)";
	#Write-Host($sqlCommand.CommandText);
	[decimal]$maxvalue = $sqlCommand.ExecuteScalar() * $multiplier;         
	$sqlCommand.Dispose();

	[int]$iterations = [int]($maxvalue / $interval);
	#Write-Host ("interations between $minvalue and $maxvalue is $iterations");
	
	# Floor min value to the nearest interval
	$minvalue = [int]($minvalue / $interval) * $interval;
	for ([int]$count = 0; $count -lt $iterations; $count++) {

		$minrange = $minvalue + $count * $interval;
		$maxrange = $minrange + $interval;
		$label = [string]$minrange + " to " + [string]$maxrange;
	
		$dimabsolutedimensionid = InsertAbsoluteDimension -connection $connection -operation $operation `
			-label $label -minrange $minrange -maxrange $maxrange;
			
		Write-Progress -Activity "Building $operation (absolute)" -status "Adding range $label" -percentComplete ($count / $iterations * 100);
	}
	Write-Progress -Completed -Activity "Building $operation (absolute)"

}