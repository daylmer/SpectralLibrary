# InsertDimMassChargeRel

function InsertClusteredDimension {
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
		"MassCharge" = "DimMassChargeRel";
		"RetentionTime" = "DimRetentionTimeRel";
		"DriftTime" = "DimDriftTimeRel";
		"Intensity" = "DimIntensityRel";
	}
	
	#$tablename = $TableWhiteList[$operation];
	[string]$tablename = $TableWhiteList[$operation];

	If ($tablename.length -eq 0) {
		throw "InsertClusteredDimension Error: $operation is not recognised";
		return 0;
	}
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = @"
	INSERT INTO $tablename
		(label, minrange, maxrange, center, sumofsquares)
	OUTPUT INSERTED.ID
	VALUES
		(@label, @minrange, @maxrange, @center, @sumofsquares)
"@;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@label", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@minrange",[Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@maxrange", [Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@center", [Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sumofsquares", [Data.SQLDBType]::Decimal))) | Out-Null;
	$sqlCommand.Parameters["@label"].Value = $label;
	$sqlCommand.Parameters["@minrange"].Value = $minrange;
	$sqlCommand.Parameters["@maxrange"].Value = $maxrange;
	$sqlCommand.Parameters["@center"].Value = $center;
	$sqlCommand.Parameters["@sumofsquares"].Value = $sumofsquares;
	
	Try {
		$dimclustereddimensionid = $sqlCommand.ExecuteScalar();
	} Catch {
		[string]$errormessage = $sqlCommand.CommandText + [Environment]::NewLine;
		[string]$errormessage += "Label:        " + $label + [Environment]::NewLine;
		[string]$errormessage += "minrange:     " + $minrange + [Environment]::NewLine;
		[string]$errormessage += "minrange:     " + $minrange + [Environment]::NewLine;
		[string]$errormessage += "center:       " + $center + [Environment]::NewLine;
		[string]$errormessage += "sumofsquares: " + $sumofsquares + [Environment]::NewLine;
		#$ErrorMessage = $_.Exception.Message;
		#$FailedItem = $_.Exception.ItemName;
		#write-host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
		#write-host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
		
		for ([int] $i = 0; $i -lt $error.Count; $i++) {
		
			
			$errormessage += "Type: " + $error[$i].GetType().FullName + [Environment]::NewLine;
			$errormessage += "ExType: " + $error[$i].Exception.GetType().FullName + [Environment]::NewLine;
			$errormessage += "ExMessage: " + $error[$i].Exception.Message + [Environment]::NewLine;
			$errormessage += "ExMessage: " + $error[$i].Exception | format-list -force;
			$errormessage += "ErrorDetails: " + $error[$i].ErrorDetails + [Environment]::NewLine;
			$errormessage += "InvocationInfo: " + $error[$i].InvocationInfo + [Environment]::NewLine;
			
		}
		Write-Host ($errormessage);
		
		Break
	}
	$sqlCommand.Dispose();
	return $dimclustereddimensionid;
}