@echo off
:: Written by Benny Lo
:: This is a script to install filebeat on windows machine
:: https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html

:: catch the URL pass into the script if there is any, otherwise manually set the url
set source=%1
if [%source%]==[] (
set source="https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.4.3-windows-x86_64.zip"
)

:: Set the working directory for this script
set workdir=%~dp0
cd /d %workdir%

:: Download the package
set destination="filebeat.zip"
echo "Downloading %source%"
powershell.exe -ExecutionPolicy Bypass -file wget.ps1 -source %source% %destination%

:: Extract the zip file, we expect winrar is installed on the system as this is baseline config for intouch server
:: Check the Winrar path
set winrar1="C:\Program Files\WinRAR\WinRAR.exe"
set winrar2="C:\Program Files (x86)\WinRAR\WinRAR.exe"
set winrarexist=0
if exist %winrar1% (
    set winrar=%winrar1%
    set winrarexist=1
)
if exist %winrar2% (
    set winrar=%winrar2%
    set winrarexist=1
)

echo "Extracting the filebeat package"
set zipfile=%destination%
set beatsbasepath="C:\Beats"

:: If winrar is found
if %winrarexist% equ 1 (
	%winrar% x -ibck %zipfile% temp\
)
:: If winrar is not found, use the windows built in extract file from zip
if %winrarexist% equ 0 (	
	powershell.exe -ExecutionPolicy UnRestricted -File unzip.ps1 -zipfile %zipfile% -destination temp
)


for /f %%i in ('dir temp\ /ad /b') do set tempfolder=%%i 
if not exist %beatsbasepath% (
    echo "%beatsbasepath% does not exist, creating the folder"
    mkdir %beatsbasepath%
)
move temp\%tempfolder% %beatsbasepath%\Filebeat
RMDIR /S /Q temp

:: Install Filebeat as a windows service
echo "Installing Filebeat as a services"
PowerShell.exe -ExecutionPolicy UnRestricted -File %beatsbasepath%\Filebeat\install-service-filebeat.ps1