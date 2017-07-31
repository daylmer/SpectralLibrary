@echo off
:: Extract.bat simply executes the powershell script Extract.ps1 in the current directory

:: Declare database and credentials here
set server=MSI
set port=1433
set database=protein

:: Integrated Security can be one of the following values:
:: TRUE (or SSPI)
:: FALSE (or unset)
:: When false or unset, User ID and Password must be  specified in the connection.
:: When true or SSPI, the current Windows account credentials are used for authentication.
set integratedsecurity=SSPI

set username=

:: If Integrated Security is not being used and the user password is not set here, it will be prompted on the command line
set password=

set cwd=%~dp0

set datadir=D:\protein\AB

:: Truncating flat schema. Run this script if all 'Loaded' data has been 'processed', and you want to 'load' more data
:: echo Executing powershell script %cwd%TruncateFlatSchema.ps1
:: Powershell "%cwd%TruncateFlatSchema_nooooooo.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

:: "yyyy-MM-dd HH:mm:ss"
:: Load Data from fragment file
echo Executing powershell script %cwd%LoadFragmentFile.ps1
:: Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "UCL_015_IA_final_fragment.csv" -timepoint 1 -bioreplicate 1 -techreplicate 1 -sampleDate "2015-08-01" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
:: Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "reduced.csv" -timepoint 1 -bioreplicate 1 -techreplicate 1 -sampleDate "10/04/2015 11:24" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_004.msE\UCL_004_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 2 -techreplicate 1 -sampleDate "10/04/2015 11:24" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_008.msE\UCL_008_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 2 -techreplicate 1 -sampleDate "10/04/2015 11:57" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_012.msE\UCL_012_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 3 -techreplicate 1 -sampleDate "10/04/2015 12:11" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_014.msE\UCL_014_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 4 -techreplicate 1 -sampleDate "10/04/2015 12:21" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_017.msE\UCL_017_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 1 -techreplicate 1 -sampleDate "10/04/2015 12:32" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_020.msE\UCL_020_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 1 -techreplicate 1 -sampleDate "10/04/2015 12:40" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_021.msE\UCL_021_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 3 -techreplicate 1 -sampleDate "10/04/2015 12:49" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_022.msE\UCL_022_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 3 -techreplicate 1 -sampleDate "10/04/2015 12:56" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_026.msE\UCL_026_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 3 -techreplicate 1 -sampleDate "10/04/2015 13:07" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_028.msE\UCL_028_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 2 -techreplicate 1 -sampleDate "10/04/2015 13:24" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_029.msE\UCL_029_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 1 -techreplicate 1 -sampleDate "10/04/2015 13:32" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_034.msE\UCL_034_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 4 -techreplicate 1 -sampleDate "10/04/2015 13:39" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_038.msE\UCL_038_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 2 -techreplicate 1 -sampleDate "10/04/2015 13:48" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_039.msE\UCL_039_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 1 -techreplicate 1 -sampleDate "10/04/2015 14:03" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_040.msE\UCL_040_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 4 -techreplicate 1 -sampleDate "10/04/2015 14:17" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_045.msE\UCL_045_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 2 -techreplicate 2 -sampleDate "10/04/2015 14:28" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_049.msE\UCL_049_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 2 -techreplicate 2 -sampleDate "10/04/2015 14:42" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_053.msE\UCL_053_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 3 -techreplicate 2 -sampleDate "10/04/2015 14:54" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_055.msE\UCL_055_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 4 -techreplicate 2 -sampleDate "10/04/2015 15:08" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_058.msE\UCL_058_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 1 -techreplicate 2 -sampleDate "10/04/2015 15:30" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_061.msE\UCL_061_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 1 -techreplicate 2 -sampleDate "10/04/2015 15:42" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_062.msE\UCL_062_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 3 -techreplicate 2 -sampleDate "10/04/2015 16:01" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_063.msE\UCL_063_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 3 -techreplicate 2 -sampleDate "10/04/2015 16:14" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_067.msE\UCL_067_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 3 -techreplicate 2 -sampleDate "10/04/2015 16:28" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_069.msE\UCL_069_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 2 -techreplicate 2 -sampleDate "10/04/2015 17:01" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_070.msE\UCL_070_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 1 -techreplicate 2 -sampleDate "10/04/2015 17:12" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_075.msE\UCL_075_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 4 -techreplicate 2 -sampleDate "10/04/2015 17:26" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_079.msE\UCL_079_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 2 -techreplicate 2 -sampleDate "10/04/2015 17:42" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_080.msE\UCL_080_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 1 -techreplicate 2 -sampleDate "10/04/2015 18:10" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_081.msE\UCL_081_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 4 -techreplicate 2 -sampleDate "10/04/2015 18:35" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_086.msE\UCL_086_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 2 -techreplicate 3 -sampleDate "10/04/2015 18:54" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_090.msE\UCL_090_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 2 -techreplicate 3 -sampleDate "10/04/2015 19:13" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_094.msE\UCL_094_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 3 -techreplicate 3 -sampleDate "10/04/2015 19:31" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_096.msE\UCL_096_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 4 -techreplicate 3 -sampleDate "10/04/2015 19:52" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_099.msE\UCL_099_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 1 -techreplicate 3 -sampleDate "10/04/2015 20:20" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_103.msE\UCL_103_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 3 -techreplicate 3 -sampleDate "10/04/2015 20:51" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_110.msE\UCL_110_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 2 -techreplicate 3 -sampleDate "10/04/2015 21:19" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_111.msE\UCL_111_IA_final_fragment.csv" -experiment "AB" -timepoint 1 -bioreplicate 1 -techreplicate 3 -sampleDate "10/04/2015 21:19" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_116.msE\UCL_116_IA_final_fragment.csv" -experiment "AB" -timepoint 3 -bioreplicate 4 -techreplicate 3 -sampleDate "10/04/2015 21:19" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_120.msE\UCL_120_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 2 -techreplicate 3 -sampleDate "10/04/2015 21:37" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_121.msE\UCL_121_IA_final_fragment.csv" -experiment "AB" -timepoint 4 -bioreplicate 1 -techreplicate 3 -sampleDate "10/04/2015 21:47" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"
Powershell "%cwd%LoadFragmentFile.ps1" -fragmentFile "%datadir%\UCL_122.msE\UCL_122_IA_final_fragment.csv" -experiment "AB" -timepoint 2 -bioreplicate 4 -techreplicate 3 -sampleDate "10/04/2015 21:59" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

:: Load Data from fragment file
:: echo Executing powershell script %cwd%ProcessDataSet.ps1
:: Powershell "%cwd%ProcessDataSet.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

:: Build Dimension tables
:: echo Executing powershell script %cwd%BuildDimension.ps1
:: Powershell "%cwd%BuildDimension.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

::Build Fact table
:: echo Executing powershell script %cwd%BuildFact.ps1
:: Powershell "%cwd%BuildFact.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

pause