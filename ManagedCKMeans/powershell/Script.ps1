#
# Script.ps1
#


Add-Type -Path "D:\protein\ManagedCKMeans\powershell\ManagedCKMeans.dll";
$ckmeans = new-object [ManagedCKMeans.ManagedCKMeans](1,10);
$ckmeans;