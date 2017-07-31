# InsertDimMassChargeRel

function InsertAbsoluteDimension {
	param (
		$connection,
		[string]$operation,
		[string]$label,
		[Decimal]$minrange,
		[Decimal]$maxrange,
		[Decimal]$center,
		[Decimal]$sumofsquares
	)

	# Strict Mode
	Set-StrictMode -Version Latest;
	
	$TableWhiteList = @{
		"MassCharge" = "DimMassChargeAbs";
		"RetentionTime" = "DimRetentionTimeAbs";
		"DriftTime" = "DimDriftTimeAbs";
		"Intensity" = "DimIntensityAbs";
		"Score" = "DimScore";
	}
	
	#$tablename = $TableWhiteList[$operation];
	[string]$tablename = $TableWhiteList[$operation];

	If ($tablename.length -eq 0) {
		throw "InsertAbsoluteDimension Error: $operation is not recognised";
		return 0;
	}
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = @"
	INSERT INTO $tablename
		(label, minrange, maxrange)
	OUTPUT INSERTED.ID
	VALUES
		(@label, @minrange, @maxrange)
"@;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@label", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@minrange",[Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@maxrange", [Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters["@label"].Value = $label;
	$sqlCommand.Parameters["@minrange"].Value = $minrange;
	$sqlCommand.Parameters["@maxrange"].Value = $maxrange;
	#Write-Host("label: $label minrange: $minrange maxrange: $maxrange");
	$dimabsolutedimensionid = $sqlCommand.ExecuteScalar();
	$sqlCommand.Dispose();
	return $dimabsolutedimensionid;
}