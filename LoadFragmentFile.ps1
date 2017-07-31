# Process command-line parameters
# These params have global scope for all called functions
#-fragmentFile "reduced.csv" -server "%server%" -port "%port%" -database "%database%" -security "SSPI"

param (
	[string][parameter(mandatory=$true)]$fragmentFile,
	[string][parameter(mandatory=$true)]$server,
	[string]$port = "1433",
	[string][parameter(mandatory=$true)]$database = "protein",
	[string]$integratedSecurity = "SSPI",
    [string]$username = "",
	[string]$password,
	[datetime]$sampleDate = $null,
	[string]$experiment = $null,
	[int]$timepoint = $null,
	[int]$bioreplicate = $null,
	[int]$techreplicate = $null
)

# Strict Mode
Set-StrictMode -Version Latest;

# Include to insert a dataset
. ((Resolve-Path .\).Path + "\InsertDataSet.ps1");

# Include to insert a datasetcondition
. ((Resolve-Path .\).Path + "\InsertDataSetCondition.ps1");

# Include to build database connection string
. ((Resolve-Path .\).Path + "\BuildConnectionString.ps1");


$connectionString = BuildConnectionString -server $server -port $port -database $database -integratedSecurity $integratedSecurity -username $username -password $password

if (test-path $fragmentFile) {
    $fileobj = (Get-ChildItem $fragmentFile);
	$filename = $fileobj.name;
	$createDate = $fileobj.CreationTime.ToString("yyyy-MM-dd HH:mm:ss");
	$modifyDate = $fileobj.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss");
	$currentDate = Get-Date -format "yyyy-MM-dd HH:mm:ss"
	if ($sampleDate -eq $null) {
		$sampleDate = $currentDate;
	}
} else {
	Write-Host "!Error Error 1-2-3";
}


# Read in the source input file
Write-Host ("Reading input file: $fragmentFile");
$sourceContent = Get-Content ($fragmentFile);

# Like in perl, the dollar sign in powershell represents a scalar memory address and the (at) symbol defines an array reference
Write-Host ("Tokenising input file into rows");
$sourceCollection = @($sourceContent.split([string[]]"`r`n", 'None'));

#Data Source=myServerAddress;Initial Catalog=myDataBase;Integrated Security=SSPI;

# Validate the headers
Write-Host ("Validating file headers");
$FragmentFileHeader = @{
	"protein.key" = 0;
	"protein.Entry" = 1;
	"protein.Accession" = 2;
	"protein.Description" = 3;
	"protein.dataBaseType" = 4;
	"protein.score" = 5;
	"protein.falsePositiveRate" = 6;
	"protein.avgMass" = 7;
	"protein.MatchedProducts" = 8;
	"protein.matchedPeptides" = 9;
	"protein.digestPeps" = 10;
	"protein.seqCover(%)" = 11;
	"protein.MatchedPeptideIntenSum" = 12;
	"protein.top3MatchedPeptideIntenSum" = 13;
	"protein.MatchedProductIntenSum" = 14;
	"protein.fmolOnColumn" = 15;
	"protein.ngramOnColumn" = 16;
	"protein.AutoCurate" = 17;
	"protein.Key_ForHomologs" = 18;
	"peptide.Rank" = 19;
	"peptide.Pass" = 20;
	"peptide.matchType" = 21;
	"peptide.modification" = 22;
	"peptide.mhp" = 23;
	"peptide.seq" = 24;
	"peptide.OriginatingSeq" = 25;
	"peptide.seqStart" = 26;
	"peptide.seqLength" = 27;
	"peptide.pI" = 28;
	"peptide.componentID" = 29;
	"peptide.MatchedProducts" = 30;
	"peptide.UniqueProducts" = 31;
	"peptide.ConsectiveMatchedProducts" = 32;
	"peptide.ComplementaryMatchedProducts" = 33;
	"peptide.rawScore" = 34;
	"peptide.score" = 35;
	"peptide.(X)-P Bond" = 36;
	"peptide.MatchedProductsSumInten" = 37;
	"peptide.MatchedProductsTheoretical" = 38;
	"peptide.MatchedProductsString" = 39;
	"peptide.ModelRT" = 40;
	"peptide.Volume" = 41;
	"peptide.CSA" = 42;
	"peptide.ModelDrift" = 43;
	"peptide.RelIntensity" = 44;
	"peptide.AutoCurate" = 45;
	"precursor.leID" = 46;
	"precursor.mhp" = 47;
	"precursor.mhpCal" = 48;
	"precursor.retT" = 49;
	"precursor.inten" = 50;
	"precursor.calcInten" = 51;
	"precursor.charge" = 52;
	"precursor.z" = 53;
	"precursor.mz" = 54;
	"precursor.Mobility" = 55;
	"precursor.MobilitySD" = 56;
	"precursor.fwhm" = 57;
	"precursor.liftOffRT" = 58;
	"precursor.infUpRT" = 59;
	"precursor.infDownRT" = 60;
	"precursor.touchDownRT" = 61;
	"prec.rmsFWHMDelta" = 62;
	"protein.SumForTotalProteins" = 63;
	"peptide.SumForTotalPeps" = 64;
	"fragment.mhp" = 65;
	"fragment.fragmentType" = 66;
	"fragment.fragInd" = 67;
	"Neutral.LossType" = 68;
	"fragment.str" = 69;
	"fragment.seq" = 70;
	"fragment.fragSite" = 71;
	"product.rank" = 72;
	"product.isLinked" = 73;
	"product.heID" = 74;
	"product.mhp" = 75;
	"product.mhpCal" = 76;
	"product.m_z" = 77;
	"product.retT" = 78;
	"product.inten" = 79;
	"product.charge" = 80;
	"product.z" = 81;
	"product.Mobility" = 82;
	"product.MobilitySD" = 83;
	"product.fwhm" = 84;
	"product.liftOffRT" = 85;
	"product.infUpRT" = 86;
	"product.infDownRT" = 87;
	"product.touchDownRT" = 88;
	"fragmentProduct.deltaMhpPPM" = 89;
	"precursorProduct.deltaRetT" = 90;
	"peptidePrecursor.deltaMhpPPM" = 91;
}


# Process the header line
$header = $sourceCollection[0].Split(",");
for ([int]$i=0; $i -lt $header.count; $i++) {
	#Write-Host ("Validating headers on: $fragmentFile Validating column name $header[$i]");
	[string]$status = "Validating column name " + $header[$i];
	Write-Progress -Activity "Validating headers on: $fragmentFile" -status $status -percentComplete ($i / $header.Count * 100);
	if ($i -ne $FragmentFileHeader[$header[$i]]) {
		throw("Could not validate headers in fragment file");
	}
}

Write-Host ("Opening database connection: $server\$database on port $port");
$connection = new-object system.data.SqlClient.SQLConnection($ConnectionString);    
[void]$connection.Open();

# Quit if the SQL connection didn't open properly.
if ($connection.State -ne [Data.ConnectionState]::Open) {
    Write-Host ("Error: Connection to database is not open");
    break;
}

# Initialise SqlCommand object
# $sqlCommand = New-Object System.Data.SqlClient.SqlCommand;
# $sqlCommand.Connection = $connection;

[string]$title = "";
[string]$description = "";

# InsertDataSet
Write-Host ("Inserting dataset record for $filename`r`n`tExperiment:`t$experiment`r`n`ttitle:`t $title`r`n`tdescription:`t $description");
$datasetid = InsertDataSet -connection $connection -title $title -description $description -loaddate $currentDate -sampledate $sampleDate -filename $filename -createdate $createdate -modifydate $modifydate

# Retrieve or create if not exists, datasetconditionid for Experiment category
$datasetconditionexperimentid = InsertDataSetCondition -connection $connection -datasetid $datasetid -category "Experiment" -title $experiment

#Insert Timepoint here
if ($timepoint -ne $null) {
	$datasetconditionid = InsertDataSetCondition -connection $connection -datasetid $datasetid -category "Timepoint" -title $timepoint
}
#Insert Technical Replicate here.
if ($bioreplicate -ne $null) {
	$datasetconditionid = InsertDataSetCondition -connection $connection -datasetid $datasetid -category "Biological replicate" -title $bioreplicate
}
#Insert Biological Replicate here.
if ($timepoint -ne $null) {
	$datasetconditionid = InsertDataSetCondition -connection $connection -datasetid $datasetid -category "Technical replicate" -title $techreplicate
}

$sqlCommand = $connection.CreateCommand();
$sqlCommand.CommandText = @"
INSERT INTO fragmentfile (
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
) 
VALUES (
	@datasetid,
	@proteinaccession, 
	@proteinscore,
	@peptidesequence,
	@peptidescore, 
	@precursormz, 
	@precursormhp, 
	@precursorz, 
	@precursorintensity, 
	@precursorrettime, 
	@precursormobility, 
	@precursordeltappm, 
	@precursorfwhm, 
	@fragmentsequence, 
	@productmz, 
	@productmhp, 
	@productz, 
	@productintensity, 
	@productrettime, 
	@productmobility, 
	@productdeltappm, 
	@productfwhm
)
"@;

$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@datasetid",[Data.SQLDBType]::BigInt))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinaccession",[Data.SQLDBType]::NVarChar, 10))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@proteinscore",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@peptidesequence",[Data.SQLDBType]::NVarChar, 128))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@peptidescore",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursormz",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursormhp",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursorz",[Data.SQLDBType]::TinyInt))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursorintensity",[Data.SQLDBType]::Int))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursorrettime",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursormobility",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursordeltappm",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@precursorfwhm",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@fragmentsequence",[Data.SQLDBType]::NVarChar, 128))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productmz",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productmhp",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productz",[Data.SQLDBType]::TinyInt))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productintensity",[Data.SQLDBType]::Int))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productrettime",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productmobility",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productdeltappm",[Data.SQLDBType]::Decimal))) | Out-Null;
$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productfwhm",[Data.SQLDBType]::Decimal))) | Out-Null;

[long]$batchsize = 1000;
[string]$rate = "0.0";

$sw = [Diagnostics.Stopwatch]::StartNew();

# Process each line
for ([int]$index = 1; $index -lt ($sourceCollection.Count); $index++) {
	
	$cell = $sourceCollection[$index].Split(",");
	[string]$proteinaccession = $cell[$FragmentFileHeader["protein.Accession"]];
	[decimal]$proteinscore = $cell[$FragmentFileHeader["protein.score"]];
	[string]$peptidesequence = $cell[$FragmentFileHeader["peptide.seq"]];
	[decimal]$peptidescore = $cell[$FragmentFileHeader["peptide.score"]];
	[decimal]$precursormz = $cell[$FragmentFileHeader["precursor.mz"]];
	[decimal]$precursormhp = $cell[$FragmentFileHeader["precursor.mhp"]];
	[byte]$precursorz = $cell[$FragmentFileHeader["precursor.z"]];
	[int]$precursorintensity = $cell[$FragmentFileHeader["precursor.inten"]];
	[decimal]$precursorrettime = $cell[$FragmentFileHeader["precursor.retT"]];
	[decimal]$precursormobility = $cell[$FragmentFileHeader["precursor.Mobility"]];
	[decimal]$precursordeltappm = $cell[$FragmentFileHeader["peptidePrecursor.deltaMhpPPM"]];
	[decimal]$precursorfwhm = $cell[$FragmentFileHeader["precursor.fwhm"]];
	[string]$fragmentsequence = $cell[$FragmentFileHeader["fragment.seq"]];
	[decimal]$productmz = $cell[$FragmentFileHeader["product.m_z"]];
	[decimal]$productmhp = $cell[$FragmentFileHeader["product.mhp"]];
	[byte]$productz = $cell[$FragmentFileHeader["product.z"]];
	[int]$productintensity = $cell[$FragmentFileHeader["product.inten"]];
	[decimal]$productrettime = $cell[$FragmentFileHeader["product.retT"]];
	[decimal]$productmobility = $cell[$FragmentFileHeader["product.Mobility"]];
	[decimal]$productdeltappm = $cell[$FragmentFileHeader["fragmentProduct.deltaMhpPPM"]];
	[decimal]$productfwhm = $cell[$FragmentFileHeader["product.fwhm"]];
	
	#Update the progress bar, batch every 200
	if ($index % $batchsize -eq 0) {
	
		$sw.Stop();
		$rate = [decimal]($batchsize / $sw.Elapsed.TotalSeconds).ToString("0.##");
		$sw.Restart();
	
		$progressMessage = "Processing row $index of " + [string]($sourceCollection.Count) + " (" + $proteinaccession + ") transactions: $rate / sec";
		Write-Progress -Activity "Parsing source file: $fragmentFile" -status $progressMessage -percentComplete ($index / $sourceCollection.Count * 100);
	}
	
	$sqlCommand.Parameters["@datasetid"].Value = $datasetid;
	$sqlCommand.Parameters["@proteinaccession"].Value = $proteinaccession;
	$sqlCommand.Parameters["@proteinscore"].Value = $proteinscore;
	$sqlCommand.Parameters["@peptidesequence"].Value = $peptidesequence;
	$sqlCommand.Parameters["@peptidescore"].Value = $peptidescore;
	$sqlCommand.Parameters["@precursormz"].Value = $precursormz;
	$sqlCommand.Parameters["@precursormhp"].Value = $precursormhp;
	$sqlCommand.Parameters["@precursorz"].Value = $precursorz;
	$sqlCommand.Parameters["@precursorintensity"].Value = $precursorintensity;
	$sqlCommand.Parameters["@precursorrettime"].Value = $precursorrettime;
	$sqlCommand.Parameters["@precursormobility"].Value = $precursormobility;
	$sqlCommand.Parameters["@precursordeltappm"].Value = $precursordeltappm;
	$sqlCommand.Parameters["@precursorfwhm"].Value = $precursorfwhm;
	$sqlCommand.Parameters["@fragmentsequence"].Value = $fragmentsequence;
	$sqlCommand.Parameters["@productmz"].Value = $productmz;
	$sqlCommand.Parameters["@productmhp"].Value = $productmhp;
	$sqlCommand.Parameters["@productz"].Value = $productz;
	$sqlCommand.Parameters["@productintensity"].Value = $productintensity;
	$sqlCommand.Parameters["@productrettime"].Value = $productrettime;
	$sqlCommand.Parameters["@productmobility"].Value = $productmobility;
	$sqlCommand.Parameters["@productdeltappm"].Value = $productdeltappm;
	$sqlCommand.Parameters["@productfwhm"].Value = $productfwhm;
	
	try {
		[void]$sqlCommand.ExecuteNonQuery();
	} catch {
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
		throw($errormessage);
	}
}

$sqlCommand.Dispose();

Write-Progress -Completed -Activity "Parsing source file: $fragmentFile";

# Close the connection.
if ($connection.State -eq [Data.ConnectionState]::Open) {
    $connection.Close()
} else {
	"error"
}