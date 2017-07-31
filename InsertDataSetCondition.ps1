# InsertDataSetCondition

function InsertDataSetCondition {
	param (
		$connection,
		[int]$datasetid,
		[string]$category,
		[string]$title,
		[string]$userstring = $null,
		[decimal]$usernumeric = $null
	)

	# Strict Mode
	Set-StrictMode -Version Latest;
	$categoryid = @{
		"Disulphide bond capping" = 1;
		"Timepoint" = 2;
		"Biological replicate" = 3;
		"Technical replicate" = 4;
		"Experiment" = 5;
	}
	
	$timepointid = @{
		"1st TimePoint" = 1;
		"2nd TimePoint" = 2;
		"3rd TimePoint" = 3;
		"4th TimePoint" = 4;
		"5th TimePoint" = 5;
	}

	$biologicalreplicateid = @{
		"1st biological replicate" = 1;
		"2nd biological replicate" = 2;
		"3rd biological replicate" = 3;
		"4th biological replicate" = 4;
		"5th biological replicate" = 5;
	}

	$technicalreplicateid = @{
		"1st technical replicate" = 1;
		"2nd technical replicate" = 2;
		"3rd technical replicate" = 3;
		"4th technical replicate" = 4;
		"5th technical replicate" = 5;
	}
	
	#Validate timepoint integer
	[bool]$categoryvalidated = $false;
	
	foreach($key in $categoryid.keys) {
		if ($category -eq $key) {
			$categoryvalidated = $true;
		}
	}
	if ($categoryvalidated  -ne $true) {
		throw("Could not validate provided category");
	}
	
	<#Validate timepoint integer
	[bool]$timepointvalidated = $false;
	
	foreach($key in $timepointid) {
		if ($timepoint -eq $key.Value) {
			$timepointvalidated = $true;
		}
	}
	if ($timepointvalidated  -ne $true) {
		throw("Could not validate provided timepoint");
	}#>
	
	if ($title -eq "Experiment") {
	Write-Host("Trace 1");
	
		$sqlCommand = $connection.CreateCommand();
		$sqlCommand.CommandText = @"
		SELECT dsc.id
		FROM condition c
		INNER JOIN conditioncategory cc on c.conditioncategoryid = cc.id and cc.title = @category
		INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
		WHERE c.title = @title
"@;
		$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@category", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
		$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@title", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
		$sqlCommand.Parameters["@category"].Value = $category;
		$sqlCommand.Parameters["@title"].Value = $title;
		$datasetconditionid = $sqlCommand.ExecuteScalar();
		$sqlCommand.Dispose();
		
		if (-not $datasetconditionid.Length -ne 0) {
		Write-Host("Trace 2");
			return $datasetconditionid;
		}
		Write-Host("Trace 3");
	
	}
	
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = @"
	SELECT c.id
	FROM condition c
	INNER JOIN conditioncategory cc on c.conditioncategoryid = cc.id and cc.title = @category
	WHERE c.title = @title
"@;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@category", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@title", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
	$sqlCommand.Parameters["@category"].Value = $category;
	$sqlCommand.Parameters["@title"].Value = $title;
	$conditionid = $sqlCommand.ExecuteScalar();
	$sqlCommand.Dispose();
	
	$sqlCommand = $connection.CreateCommand();
	$sqlCommand.CommandText = @"
	INSERT INTO datasetcondition
		(datasetid, conditionid)
	OUTPUT INSERTED.ID
	VALUES
		(@datasetid, @conditionid)
"@;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@datasetid", [Data.SQLDBType]::bigint))) | Out-Null;
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@conditionid",[Data.SQLDBType]::bigint))) | Out-Null;

	$sqlCommand.Parameters["@datasetid"].Value = $datasetid;
	$sqlCommand.Parameters["@conditionid"].Value = $conditionid;
	$datasetconditionid = $sqlCommand.ExecuteScalar();
	$sqlCommand.Dispose();
	
	if ($userstring -ne $null -or $usernumeric -ne $null) {
		$sqlCommand = $connection.CreateCommand();
		$sqlCommand.CommandText = @"
		INSERT INTO datasetconditionuserdata
			(datasetconditionid, userstring, usernumeric)
		OUTPUT INSERTED.ID
		VALUES
			(@datasetconditionid, @userstring, @usernumeric)
"@;
		$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@datasetconditionid", [Data.SQLDBType]::bigint))) | Out-Null;
		$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@userstring", [Data.SQLDBType]::NVarChar, 512))) | Out-Null;
		$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@usernumeric", [Data.SQLDBType]::Decimal))) | Out-Null;
		$sqlCommand.Parameters["@datasetconditionid"].Value = $datasetconditionid;
		$sqlCommand.Parameters["@userstring"].Value = $userstring;
		$sqlCommand.Parameters["@usernumeric"].Value = $usernumeric;
		$datasetconditionid = $sqlCommand.ExecuteScalar();
		$sqlCommand.Dispose();
	}

	return $datasetconditionid;
}