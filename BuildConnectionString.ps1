function BuildConnectionString {
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

	# Build database connection string
	if ($integratedSecurity -eq "SSPI" -or $integratedSecurity -eq "True" ) {
		# Build connection string
		$connectionString =  "Data Source=$server, $port; " +
								"Initial catalog=$database; " +
								"Integrated Security=$integratedSecurity; " + 
								"MultipleActiveResultSets=true;";
	} else {

		# If a plaintext password wasn't passed as a argument  then prompt for a masked password
		if ($password.length -eq 0) {
			[System.Security.SecureString]$password = Read-Host "Input password for $username on $server $database" -AsSecureString;

			# Unsecure masked password to plaintext string
			[string]$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password));
		}
		
		# Build connection string
		$connectionString =  "Data Source=$server, $port; " +
								"Initial catalog=$database; " +
								"Integrated Security=$integratedSecurity; " + 
								"uid=$username; " +
								"pwd=$password; " + 
								"MultipleActiveResultSets=true;";
	}

	return $connectionString;
}