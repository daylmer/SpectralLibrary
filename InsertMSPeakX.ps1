# InsertMsPeakX

function InsertMSPeakX {
	param (
		$connection,
		$transaction,
		$mspeakmatchtypeid,
		$mspeak1id,
		$mspeak2id,
		$score
	)

	# Strict Mode
	Set-StrictMode -Version Latest;

	
	# Insert into mspeak
	$mspeakxSqlCommand = $connection.CreateCommand();
	$mspeakxSqlCommand.Transaction = $transaction;
	$mspeakxSqlCommand.CommandText = @"
		SET NOCOUNT ON;
		INSERT INTO mspeakx (
			mspeak1id,
			mspeak2id,
			mspeakmatchtype,
			score
		)
		OUTPUT INSERTED.ID
		VALUES (
			@mspeak1id,
			@mspeak2id,
			@mspeakmatchtype,
			@score
		)
"@;

	$mspeakxSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mspeak1id", [Data.SQLDBType]::BigInt))) | Out-Null;
	$mspeakxSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mspeak2id",[Data.SQLDBType]::BigInt))) | Out-Null;
	$mspeakxSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@mspeakmatchtype", [Data.SQLDBType]::TinyInt))) | Out-Null;
	$mspeakxSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@score", [Data.SQLDBType]::DEcimal))) | Out-Null;
	$mspeakxSqlCommand.Parameters["@mspeak1id"].Value = $mspeak1id;
	$mspeakxSqlCommand.Parameters["@mspeak2id"].Value = $mspeak2id;
	$mspeakxSqlCommand.Parameters["@mspeakmatchtype"].Value = $mspeakmatchtypeid;
	$mspeakxSqlCommand.Parameters["@score"].Value = $score;
	$mspeakxid = $mspeakxSqlCommand.ExecuteScalar();
	$mspeakxSqlCommand.Dispose();

	return $mspeakxid;
}