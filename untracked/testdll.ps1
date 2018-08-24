Set-StrictMode -Version Latest;

if ([Environment]::Is64BitProcess) {
	Add-Type -Path "D:\protein\ps\ManagedCKMeans.dll";
} else {
	Add-Type -Path "D:\protein\ps\x86\ManagedCKMeans.dll";
}

$ckmeans = new-object ManagedCKMeans.ManagedCKMeans(1,10);
$values = @(5, 12.3, 78, 54, 22, 23, 21, 65, 4, 4.5);
$ckmeans.AddPoints($values);

try {
    $result = $ckmeans.Calculate();
} catch {
    [string]$errormessage = "";

    for ([int] $i = 0; $i -lt $error.Count; $i++) {
        $errormessage += "Type: " + $error[$i].GetType().FullName + [Environment]::NewLine;
        $errormessage += "ExType: " + $error[$i].Exception.GetType().FullName + [Environment]::NewLine;
        $errormessage += "ExMessage: " + $error[$i].Exception.Message + [Environment]::NewLine;
        $errormessage += "ExMessage: " + $error[$i].Exception | format-list -force;
        $errormessage += "ErrorDetails: " + $error[$i].ErrorDetails + [Environment]::NewLine;
        $errormessage += "InvocationInfo: " + $error[$i].InvocationInfo + [Environment]::NewLine;
    }
    Write-Host($errormessage);
    throw($errormessage)
    exit;
}


foreach ($cluster in $result) {
	$cluster.Size;
	$cluster.MinimumValue;
	$cluster.MaximumValue;
	$cluster.Center;
	$cluster.SumOfSquares;

	foreach ($point in $cluster.Points) {
		$point.Value;
		$point.Weight;
	}
}
