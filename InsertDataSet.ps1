# InsertDataSet

function InsertDataSet {
	param (
		$connection,
		[string]$title,
		[string]$description,
		[DateTime]$loaddate,
		[DateTime]$sampleDate,
		[string]$filename,
		[DateTime]$createdate,
		[DateTime]$modifydate
	)

	# Strict Mode
	Set-StrictMode -Version Latest;
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = @"
	INSERT INTO dataset
		(title, description, loaddate, sampledate, filename, createdate, modifydate)
	OUTPUT INSERTED.ID
	VALUES
		(@title, @description, @loaddate, @sampledate, @filename, @createdate, @modifydate)
"@;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@title", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@description",[Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@loaddate", [Data.SQLDBType]::DateTime))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sampledate", [Data.SQLDBType]::DateTime))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@filename", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@createdate", [Data.SQLDBType]::DateTime))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@modifydate", [Data.SQLDBType]::DateTime))) | Out-Null;
	$sqlCommand.Parameters["@title"].Value = $title;
	$sqlCommand.Parameters["@description"].Value = $description;
	$sqlCommand.Parameters["@loaddate"].Value = $currentDate;
	$sqlCommand.Parameters["@sampledate"].Value = $sampleDate;
	$sqlCommand.Parameters["@filename"].Value = $filename;
	$sqlCommand.Parameters["@createdate"].Value = $createdate;
	$sqlCommand.Parameters["@modifydate"].Value = $modifydate;
	$datasetid = $sqlCommand.ExecuteScalar();
	Write-Host("Inserted datasetid $datasetid");
	$sqlCommand.Dispose();
	return $datasetid;
}