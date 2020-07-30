﻿$ErrorActionPreference = 'Stop';
$PackageParameters = Get-PackageParameters

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = "https://download5.veeam.com/VeeamAgentWindows_4.0.1.2169.zip"
$checksumZip = "0251f7c65ce854b5239212d86bdbfff59ab2168582b416216620311547cad2dfefa9e2c25ad7dbbec603a55dabe14f001a4b3a483fd633a31ab680e8b17f24c4"
$checksumTypeZip = 'SHA512'

Import-Module -Name "$($toolsDir)\helpers.ps1"

$zipArgs = @{
	packageName   = $env:ChocolateyPackageName
	url           = $url
	unzipLocation = $ENV:TMP
	checksum      = $checksumZip
	checksumType  = $checksumTypeZip
}

$packageArgs = @{
	packageName    = $env:ChocolateyPackageName
	fileType       = 'EXE'
	file           = "$($ENV:TMP)\VeeamAgentWindows_$($packageVersion).exe"
	silentArgs     = '/silent /accepteula /acceptthirdpartylicenses'
	validExitCodes = @(0, 1000, 1101)
}

Install-ChocolateyZipPackage @zipArgs

Install-ChocolateyInstallPackage @packageArgs

if ($PackageParameters.NoAutostartHard) {
	Update-RegistryValue `
		-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
		-Name "Veeam.EndPoint.Tray.exe" `
		-Type Binary `
		-Value ([byte[]](0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
		-Message "Disable Veeam Agent Autostart"
}
else {
	Update-RegistryValue `
		-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
		-Name "Veeam.EndPoint.Tray.exe" `
		-Type Binary `
		-Value ([byte[]](0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
		-Message "Default Veeam Agent Autostart"
}
	
if ($PackageParameters.CleanStartmenu) {
	Remove-FileItem `
		-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam\"
	Install-ChocolateyShortcut `
		-ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam Agent.lnk" `
		-TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.Tray.exe"
	Install-ChocolateyShortcut `
		-ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam File Level Restore.lnk" `
		-TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.FLR.exe"
}	
