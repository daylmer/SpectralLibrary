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

:: Build Dimension tables
echo Executing powershell script %cwd%BuildDimension.ps1
Powershell "%cwd%BuildDimension.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

::Build Fact table
:: echo Executing powershell script %cwd%BuildFact.ps1
:: Powershell "%cwd%BuildFact.ps1" -server "%server%" -port "%port%" -database "%database%" -integratedsecurity "%integratedsecurity%"

pause