@echo off


set cwd=%~dp0

echo Executing powershell script %cwd%testdll.ps1
Powershell "%cwd%testdll.ps1"

pause