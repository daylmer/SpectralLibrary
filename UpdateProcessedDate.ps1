# UpdateProcessedDate

function UpdateProcessedDate {
	param (
		$connection,
		$transaction,
		[long]$id
	)

	# Strict Mode
	Set-StrictMode -Version Latest;
	
	$updateSqlCommand = $connection.CreateCommand();
	$updateSqlCommand.Transaction = $transaction;
	$updateSqlCommand.CommandText = @"
		SET NOCOUNT OFF;
		UPDATE fragmentfile
		SET processeddate = @processeddate
		WHERE id = @id
"@;

	$updateSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@processeddate", [Data.SQLDBType]::DateTime))) | Out-Null;
	$updateSqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@id", [Data.SQLDBType]::BigInt))) | Out-Null;
	$updateSqlCommand.Parameters["@processeddate"].Value = Get-Date -format "yyyy-MM-dd HH:mm:ss";
	$updateSqlCommand.Parameters["@id"].Value = $id;
	$updateResult = $updateSqlCommand.ExecuteNonQuery();
	$updateSqlCommand.Dispose();
	
	return $updateResult;
}