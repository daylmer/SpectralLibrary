# ClusterDimension

function ClusterDimension {
	param (
		[system.data.SqlClient.SQLConnection]$connection,
		[string]$operation,
		[string]$query,
		[int]$minclusters,
		[int]$maxClusters,
		[decimal]$increment
	)

	# Strict Mode
	Set-StrictMode -Version Latest;

	$OrdinalWhiteList = @{
		"MassCharge" = "masscharge";
		"RetentionTime" = "retentiontime";
		"DriftTime" = "drifttime";
		"Intensity" = "intensity";
	}

	[string]$ordinal = $OrdinalWhiteList[$operation];

	If ($ordinal.length -eq 0) {
		throw "ClusterDimension Error: $operation is not recognised";
		return 0;
	}

	# Incude .NET assembly for calculating univariate kmeans
	[string]$ManagedCKMeans = "";
	if ([Environment]::Is64BitProcess) {
		#Write-Host ("Running under a 64 Bit Process");
		$ManagedCKMeans = (Resolve-Path .\).Path + "\ManagedCKMeans.dll";	
	} else {
		#Write-Host ("Running under a 32 Bit Process");
		$ManagedCKMeans = (Resolve-Path .\).Path + "\x86\ManagedCKMeans.dll";	
	}
	Add-Type -Path $ManagedCKMeans;

	# Include to insert clustered mass/charge dimensions
	. ((Resolve-Path .\).Path + "\InsertClusteredDimension.ps1");

	#Write-Host ("Building data for OLAP dimension: $operation");

	# Get count
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = "SELECT count(*) FROM ($query) querycount"
	[int]$count = $sqlCommand.ExecuteScalar();         
	$sqlCommand.Dispose();
	
	# Get the weighting normalisation
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = "select max(Frequency) MaxFrequency FROM ($query) mf WHERE mf.$ordinal <> 0";
	[int]$maxFrequency = $sqlCommand.ExecuteScalar();         
	$sqlCommand.Dispose();
	
	# Add ordering
	$query += " ORDER BY $ordinal ASC";
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = $query;
	$result = $sqlCommand.ExecuteReader();      

	#Write-Host ("count: " + $count);
	#[int]$maxClusters = $count;
	#[int]$minclusters = $maxClusters / 2;

	#Write-Host ("Start Init");
	$ckmeans = new-object ManagedCKMeans.ManagedCKMeans($minclusters, $maxClusters);
	#Write-Host ("Stop Init");
	#Write-Host ($query);
	# Looping through records
	[int]$recordIndex = 0;
	While ($result.Read())            
	{	
		if ($ordinal -eq "intensity"){
			[int64]$ordinalValue = $result.GetInt64($result.GetOrdinal($ordinal));
		} else {
			#GetInt32 GetDecimal
			#[decimal]$ordinalValue = $result.GetDecimal($result.GetOrdinal($ordinal));
			[int]$ordinalValue = $result.GetInt32($result.GetOrdinal($ordinal));
			
		}
		#[int]$frequency = $result.GetInt32($result.GetOrdinal("Frequency"));
		#if ($frequency -gt 1000) {
		#	$weight = 1;
		#} else {
			#$weight = 0.5;
		#}

		#[double]$weight = 0.8 + $frequency / $maxFrequency / 5;
		#if ($weight -gt 1) { $weight = 1; }
		#if ($weight -lt 0) { $weight = 0; }
		[double]$weight = 1;
		
		$ckmeans.AddPoint($ordinalValue, $weight);
		# Write-Host("Added point $ordinalValue at weight $weight.");
		
		if ($recordIndex % [int]($count / 1000) -eq 0) {
			Write-Progress -Activity "Reading $ordinal From database" -status "Adding point $ordinalValue" -percentComplete ($recordIndex / $count * 100);
		}
		$recordIndex = $recordIndex + 1;
		
	}
	$result.Close();
	$sqlCommand.Dispose();


	Write-Progress -Completed -Activity "Reading $ordinal From database"
	Write-Host ("Clustering $count records between $minclusters and $maxClusters clusters. Please be patient.");
	$sw = [Diagnostics.Stopwatch]::StartNew();
	Write-Host ("Start Calculate");
	Try {
		$clustering = $ckmeans.Calculate();
		Write-Host ("Stop Calculate 1");
	} Catch {
		[string]$errormessage = "";
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
	Write-Host ("Stop Calculate 2");
	$sw.Stop();
	Write-Host ("`tCompleted calculating " + $clustering.Count + " clusters in " + $sw.Elapsed.Tostring());

	# Quit if the SQL connection didn't open properly.
	if ($connection.State -ne [Data.ConnectionState]::Open) {
		[void]$connection.Open();
		if ($connection.State -ne [Data.ConnectionState]::Open) {
			Write-Host ("Error: Connection to database is not open");
			break;
		}
	}
	
	[int]$clusterIndex = 0;
	[string]$clusterLabel = "";
	foreach ($cluster in $clustering) {
		[decimal]$maxrange = $cluster.MaximumValue; # + $increment;
		$clusterLabel = [string]$cluster.MinimumValue + " to " + $maxrange;
		if ([int]$clustering.Count -ne 0) {
			if ($clusterIndex % [int]($clustering.Count / 100) -eq 0) {
				Write-Progress -Activity "Building relative $operation Dimension" -status "Adding cluster $clusterLabel" -percentComplete ($clusterIndex / $clustering.Count * 100);
			}
		}
		
		Write-Host(
			"Cluster " + ($clusterIndex+1) + " of " + $clustering.Count + `
			"`tSize: " + $cluster.Size + `
			"`tMin: " + $cluster.MinimumValue + `
			"`tMax: " + $cluster.MaximumValue + `
			"`tCenter: " + $cluster.Center `
		);
		#"`tSumSquares: " + $cluster.SumOfSquares;
		#[int]$pointIndex = 0;
		#foreach ($point in $cluster.Points) {
		#	"`tPoint " + $pointIndex + " of " + $cluster.Points.Count;
		#	"`t`tValue " + $point.Value;
		#	"`t`tWeight " + $point.Weight;
		#	$pointIndex++
		#}
		
		
		
		if ($cluster.Size -gt 0) {
			$dimclustermidensionid = InsertClusteredDimension -connection $connection -operation $operation `
				-label $clusterLabel -minrange $cluster.MinimumValue -maxrange $maxrange `
				-center $cluster.Center -sumofsquares $cluster.SumOfSquares;
		}
			
		$clusterIndex++;
	}
	Write-Progress -Completed -Activity "Building relative $operation Dimension"

}