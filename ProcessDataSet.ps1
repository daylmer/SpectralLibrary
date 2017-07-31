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

$sequencematchtypeid = @{
	# This value is for sequences that have been matched to mspeaks based on database search
	"PLGS1" = 1;
	
	# This value is for sequences that have been matched to mspeaks based on high scoring mspeakmatch links in this database
	"Algorithm1" = 2;
}

$mspeaktypeid = @{
	# This value is for peptide data
	"peptide/precursor" = 1;
	
	# This value is for fragment data
	"fragment/product" = 2;
}

$mspeakmatchtypeid = @{
	# These are peptides that have been matched to other peptides based on retention time/mass/drift time
	"Algorithm1" = 1;
	
	# These are fragments that have been matched to other fragments based on retention time and mass
	"Algorithm2" = 2;
	
	# These are peptides that have been matched to fragments based on retention time
	"PLGS1" = 3;
	
	# These are peptides that have been matched to fragments based on database search
	"PLGS2" = 4;	
}

# Include to build database connection string
. ((Resolve-Path .\).Path + "\BuildConnectionString.ps1");

# Include to insert a peak
. ((Resolve-Path .\).Path + "\InsertMSPeak.ps1");

# Include to insert peak relationships
. ((Resolve-Path .\).Path + "\InsertMSPeakX.ps1");

# Include to update fragmentfile record with processeddate
. ((Resolve-Path .\).Path + "\UpdateProcessedDate.ps1");


[int]$commandTimeout = 600;

$connectionString = BuildConnectionString -server $server -port $port -database $database -integratedSecurity $integratedSecurity -username $username -password $password

Write-Host ("Opening database connection: $server\$database on port $port");
$connection = new-object system.data.SqlClient.SQLConnection($ConnectionString);    
[void]$connection.Open();

# Quit if the SQL connection didn't open properly.
if ($connection.State -ne [Data.ConnectionState]::Open) {
    Write-Host ("Error: Connection to database is not open");
    break;
}

Write-Host ("Retrieving count of fragmentfile table");
# $sqlCommand = New-Object System.Data.SqlClient.SqlCommand;
# $sqlCommand.Connection = $connection;
$sqlCommand = $connection.CreateCommand();

$sqlCommand.CommandText = @"
	SET NOCOUNT ON;
	SELECT count(*)
	FROM fragmentFile with (nolock)
	WHERE processeddate is null
"@;

$sqlCommand.CommandTimeout = $commandTimeout;

$fragmentrows = $sqlCommand.ExecuteScalar();         
Write-Host ("$fragmentrows rows need to be processed");
$sqlCommand.Dispose();

[string]$rate = "0.0";
[int]$index = 0;
[string]$previousPeptideSequence = "";
[long]$peptidemspeakid = 0;
[long]$fragmentmspeakid = 0;
[long]$mspeakxid = 0;
[long]$updateResult = 0;
	
while ($fragmentrows -gt 0) {

	# Start new transaction
	[System.Data.SqlClient.SqlTransaction]$transaction = $connection.BeginTransaction();
	#[string]$transaction = "";
	
	[long]$batchsize = 1000;

	$sqlCommand.CommandText = @"
		SET NOCOUNT ON;
		SELECT TOP $batchsize
			id,
			datasetid,
			proteinaccession,
			proteinscore,
			peptidesequence,
			peptidescore,
			precursormz,
			precursormhp,
			precursorz,
			precursorintensity,
			precursorrettime,
			precursormobility,
			precursordeltappm,
			precursorfwhm,
			fragmentsequence,
			productmz,
			productmhp,
			productz,
			productintensity,
			productrettime,
			productmobility,
			productdeltappm,
			productfwhm
		FROM fragmentfile with (nolock)
		WHERE processeddate is null
		ORDER BY id
"@;
	$sqlCommand.transaction = $transaction;
	$reader = $sqlCommand.ExecuteReader();     

	$sw = [Diagnostics.Stopwatch]::StartNew();



	# Looping through records  
	#[System.Data.SqlClient.SqlTransaction]$transaction; 
			
	While ($reader.Read())            
	{
		# Retrieve the data for the row on the fragment file
		[long]$id = $reader.GetInt64($reader.GetOrdinal("id"));
		[long]$datasetid = $reader.GetInt64($reader.GetOrdinal("datasetid"));
		[string]$proteinaccession = $reader.GetString($reader.GetOrdinal("proteinaccession"));
		[decimal]$proteinscore = $reader.GetDecimal($reader.GetOrdinal("proteinscore"));
		[string]$peptidesequence = $reader.GetString($reader.GetOrdinal("peptidesequence"));
		[decimal]$peptidescore = $reader.GetDecimal($reader.GetOrdinal("peptidescore"));
		[decimal]$precursormz = $reader.GetDecimal($reader.GetOrdinal("precursormz"));
		[decimal]$precursormhp = $reader.GetDecimal($reader.GetOrdinal("precursormhp"));
		[byte]$precursorz = $reader.GetByte($reader.GetOrdinal("precursorz"));
		[int]$precursorintensity = $reader.GetInt32($reader.GetOrdinal("precursorintensity"));
		[decimal]$precursorrettime = $reader.GetDecimal($reader.GetOrdinal("precursorrettime"));
		[decimal]$precursormobility = $reader.GetDecimal($reader.GetOrdinal("precursormobility"));
		[decimal]$precursordeltappm = $reader.GetDecimal($reader.GetOrdinal("precursordeltappm"));
		[decimal]$precursorfwhm = $reader.GetDecimal($reader.GetOrdinal("precursorfwhm"));
		[string]$fragmentsequence = $reader.GetString($reader.GetOrdinal("fragmentsequence"));
		[decimal]$productmz = $reader.GetDecimal($reader.GetOrdinal("productmz"));
		[decimal]$productmhp = $reader.GetDecimal($reader.GetOrdinal("productmhp"));
		[byte]$productz = $reader.GetByte($reader.GetOrdinal("productz"));
		[int]$productintensity = $reader.GetInt32($reader.GetOrdinal("productintensity"));
		[decimal]$productrettime = $reader.GetDecimal($reader.GetOrdinal("productrettime"));
		[decimal]$productmobility = $reader.GetDecimal($reader.GetOrdinal("productmobility"));
		[decimal]$productdeltappm = $reader.GetDecimal($reader.GetOrdinal("productdeltappm"));
		[decimal]$productfwhm = $reader.GetDecimal($reader.GetOrdinal("productfwhm"));
		
		# Write-Host ("$id $peptidesequence $fragmentsequence");
		
		try {
			#[System.Data.SqlClient.SqlTransaction]$transaction = new-object System.Data.SqlClient.SqlTransaction();    
		
			if ($peptidesequence -ne $previousPeptideSequence) {
				# Write-Host("Writing Peptide/precursor $peptidesequence");
				$peptidemspeakid = InsertMSPeak -connection $connection -transaction $transaction -datasetid $datasetid -proteinaccession "$proteinaccession" -proteinscore $proteinscore -mspeaktypeid $mspeaktypeid["peptide/precursor"] -sequencematchtypeid $sequencematchtypeid["PLGS1"] -sequence $peptidesequence -score $peptidescore  -masscharge $precursormz -mass $precursormhp -charge $precursorz -intensity $precursorintensity -retentiontime $precursorrettime -drifttime $precursormobility -ppm $precursordeltappm -fwhm $precursorfwhm		 
			}

			# Don't add empty fragment sequences
			if ($fragmentsequence -ne "") {
			
				# Write-Host("Writing fragment/product $fragmentsequence");
				$fragmentmspeakid = InsertMSPeak -connection $connection -transaction $transaction  -datasetid $datasetid -proteinaccession "$proteinaccession" -proteinscore $proteinscore -mspeaktypeid $mspeaktypeid["fragment/product"] -sequencematchtypeid $sequencematchtypeid["PLGS1"] -sequence $fragmentsequence -score $peptidescore  -masscharge $productmz -mass $productmhp -charge $productz -intensity $productintensity -retentiontime $productrettime -drifttime $productmobility -ppm $productdeltappm -fwhm $productfwhm	

				# Relate the peptide/precursor to the fragment/product
				$mspeakxid = InsertMSPeakX -connection $connection -transaction $transaction  -mspeakmatchtypeid $mspeakmatchtypeid["PLGS1"] -mspeak1id $peptidemspeakid -mspeak2id $fragmentmspeakid -score $peptidescore
			}
			
			# Update the current record of fragmentfile with the current datetime to mark as 'processed'
			$updateResult = UpdateProcessedDate -connection $connection -transaction $transaction  -id $id
			if ($updateResult -ne 1 ) {
				throw ("Could not update fragmentfile rowid $id");
			}
			
		} catch {
			[string]$errormessage = "";
			$errormessage = "Error during Processing fragmentfile row $id" + [Environment]::NewLine + `
							"Peptide mspeak id: $peptidemspeakid" + [Environment]::NewLine + `
							"Fragment mspeak id: $fragmentmspeakid" + [Environment]::NewLine + `
							"mspeakx id: $mspeakxid" + [Environment]::NewLine + `
							"Update Processed Date rows: $updateResult" + [Environment]::NewLine;
			
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
			Write-Host($errormessage);
			$transaction.Rollback();
			throw($errormessage)
			exit;
		}
		
		$index++;
		$previousPeptideSequence = $peptidesequence;
	}

	# Clean-up
	$reader.Close();
	$sqlCommand.Dispose();
	
	$sw.Stop();
	$rate = [decimal]($batchsize / $sw.Elapsed.TotalSeconds).ToString("0.##");
	$sw.Restart();
	
	try {
		$transaction.Commit();
		Write-Progress -Activity "Parsing fragment file table" -status "Processing row $id. $index of $fragmentrows ($proteinaccession) transactions: $rate / sec" -percentComplete ($index / $fragmentrows * 100);
	} catch {
		for ([int] $i = 0; $i -lt $error.Count; $i++) {
			$errormessage += "Type: " + $error[$i].GetType().FullName + [Environment]::NewLine;
			$errormessage += "ExType: " + $error[$i].Exception.GetType().FullName + [Environment]::NewLine;
			$errormessage += "ExMessage: " + $error[$i].Exception.Message + [Environment]::NewLine;
			$errormessage += "ExMessage: " + $error[$i].Exception | format-list -force;
			$errormessage += "ErrorDetails: " + $error[$i].ErrorDetails + [Environment]::NewLine;
			$errormessage += "InvocationInfo: " + $error[$i].InvocationInfo + [Environment]::NewLine;
			
		}
		Write-Host($errormessage);
		$transaction.Rollback();
		throw($errormessage)
		exit;
	}
	

}


# Close the connection.
if ($connection.State -eq [Data.ConnectionState]::Open) {
    $connection.Close()
} else {
	"error"
}



