# InsertMsPeak

function InsertMSPeak {
	param (
		$connection,
		$transaction,
		$datasetid,
		$proteinaccession,
		$proteinscore,
		$mspeaktypeid,
		$sequencematchtypeid,
		$sequence,
		$score,
		$masscharge,
		$mass,
		$charge,
		$intensity,
		$retentiontime,
		$drifttime,
		$ppm,
		$fwhm
	)

	# Strict Mode
	Set-StrictMode -Version Latest;

	$sequence = $sequence.ToUpper();
	
	# Insert into mspeak
	$mspeakSqlCommand = $connection.CreateCommand();
	$mspeakSqlCommand.Transaction = $transaction;
	$mspeakSqlCommand.CommandText = @"
		SET NOCOUNT ON;
		INSERT INTO mspeak (
			datasetid,
			mspeaktypeid,
			masscharge,
			mass,
			charge,
			intensity,
			retentiontime,
			drifttime,
			ppm,
			fwhm
		)
		OUTPUT INSERTED.ID
		VALUES (
			@datasetid,
			@mspeaktypeid,
			@masscharge,
			@mass,
			@charge,
			@intensity,
			@retentiontime,
			@drifttime,
			@ppm,
			@fwhm
		)
"@;

	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@datasetid", [Data.SQLDBType]::BigInt))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mspeaktypeid", [Data.SQLDBType]::TinyInt))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@masscharge", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mass", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@charge", [Data.SQLDBType]::TinyInt))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@intensity", [Data.SQLDBType]::Int))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@retentiontime", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@drifttime", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ppm", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@fwhm", [Data.SQLDBType]::Decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters["@datasetid"].Value = $datasetid;
	$mspeakSqlCommand.Parameters["@mspeaktypeid"].Value = $mspeaktypeid;
	$mspeakSqlCommand.Parameters["@masscharge"].Value = $masscharge;
	$mspeakSqlCommand.Parameters["@mass"].Value = $mass;
	$mspeakSqlCommand.Parameters["@charge"].Value = $charge;
	$mspeakSqlCommand.Parameters["@intensity"].Value = $intensity;
	$mspeakSqlCommand.Parameters["@retentiontime"].Value = $retentiontime;
	$mspeakSqlCommand.Parameters["@drifttime"].Value = $drifttime;
	$mspeakSqlCommand.Parameters["@ppm"].Value = $ppm;
	$mspeakSqlCommand.Parameters["@fwhm"].Value = $fwhm;
	$result = $mspeakSqlCommand.ExecuteScalar();
	$mspeakid = $result;
	# Write-Host ("Inserted mspeak id $mspeakid");
	$mspeakSqlCommand.Dispose();


	#Protein
	$mspeakSqlCommand = $connection.CreateCommand();
	$mspeakSqlCommand.Transaction = $transaction;
	# select id from sequence where sequence = $peptidesequence
	$mspeakSqlCommand.CommandText = @"
		SET NOCOUNT ON;
		SELECT id
		FROM [dbo].[protein]
		WHERE accession = @proteinaccession
"@;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinaccession", [Data.SQLDBType]::nvarchar, 10))) | Out-Null;
	$mspeakSqlCommand.Parameters["@proteinaccession"].Value = $proteinaccession;
	$proteinid = $mspeakSqlCommand.ExecuteScalar();
	#Write-Host ("Selected protein id for $proteinaccession is $proteinid");
	$mspeakSqlCommand.Dispose();

	if (-not $proteinid) {
		# If no rows then insert
		# Either way, $proteinid is populated with a bigint
		# Insert into protein
		$mspeakSqlCommand = $connection.CreateCommand();
		$mspeakSqlCommand.Transaction = $transaction;
		$mspeakSqlCommand.CommandText = @"
			SET NOCOUNT ON;
			INSERT INTO [dbo].[protein] (accession)
			OUTPUT INSERTED.ID
			VALUES (@proteinaccession)
"@;
	
		$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinaccession", [Data.SQLDBType]::nvarchar, 10))) | Out-Null;
		$mspeakSqlCommand.Parameters["@proteinaccession"].Value = $proteinaccession;
		$proteinid = $mspeakSqlCommand.ExecuteScalar();
		#Write-Host ("Inserted protein id $proteinid");
		$mspeakSqlCommand.Dispose();
	}	
		
	#Sequence		
	$mspeakSqlCommand = $connection.CreateCommand();
	$mspeakSqlCommand.Transaction = $transaction;
	# select id from sequence where sequence = $peptidesequence
	$mspeakSqlCommand.CommandText = @"
		SET NOCOUNT ON;
		SELECT id
		FROM sequence
		WHERE sequence = @sequence
"@;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sequence", [Data.SQLDBType]::nvarchar, 128))) | Out-Null;
	$mspeakSqlCommand.Parameters["@sequence"].Value = $sequence;
	$sequenceid = $mspeakSqlCommand.ExecuteScalar();
	$mspeakSqlCommand.Dispose();

	if (-not $sequenceid) {
		# If no rows then insert
		# Either way, $sequenceid is populated with a bigint
		# Insert into sequence
		$mspeakSqlCommand = $connection.CreateCommand();
		$mspeakSqlCommand.Transaction = $transaction;
		$mspeakSqlCommand.CommandText = @"
			SET NOCOUNT ON;
			INSERT INTO sequence (sequence)
			OUTPUT INSERTED.ID
			VALUES (@sequence)
"@;
	
		$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sequence", [Data.SQLDBType]::nvarchar, 128))) | Out-Null;
		$mspeakSqlCommand.Parameters["@sequence"].Value = $sequence;
		$sequenceid = $mspeakSqlCommand.ExecuteScalar();
		# Write-Host ("Inserted sequence id $sequenceid");
		$mspeakSqlCommand.Dispose();
	}
	# Insert into mspeaksequence
	$mspeakSqlCommand = $connection.CreateCommand();
	$mspeakSqlCommand.Transaction = $transaction;
	$mspeakSqlCommand.CommandText = @"
		SET NOCOUNT ON;
		INSERT INTO mspeaksequence (
			mspeakid,
			proteinid,
			sequenceid,
			sequencematchtype,
			proteinscore,
			score
		)
		VALUES (
			@mspeakid,
			@proteinid,
			@sequenceid,
			@sequencematchtype,
			@proteinscore,
			@score
		)
"@;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mspeakid", [Data.SQLDBType]::bigint))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinid", [Data.SQLDBType]::bigint))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sequenceid", [Data.SQLDBType]::bigint))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sequencematchtype", [Data.SQLDBType]::tinyint))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinscore", [Data.SQLDBType]::decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@score", [Data.SQLDBType]::decimal))) | Out-Null;
	$mspeakSqlCommand.Parameters["@mspeakid"].Value = $mspeakid;
	$mspeakSqlCommand.Parameters["@proteinid"].Value = $proteinid;
	$mspeakSqlCommand.Parameters["@sequenceid"].Value = $sequenceid;
	$mspeakSqlCommand.Parameters["@sequencematchtype"].Value = $sequencematchtypeid;
	$mspeakSqlCommand.Parameters["@proteinscore"].Value = $proteinscore;
	$mspeakSqlCommand.Parameters["@score"].Value = $score;
	$result = $mspeakSqlCommand.ExecuteNonQuery();
	$mspeakSqlCommand.Dispose();

	return $mspeakid;
}