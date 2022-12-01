﻿$ErrorActionPreference = 'Stop'

import-module au
$releases="https://jdownloader.org/jdownloader2"

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
			"(^[$]checksum64\s*=\s*)('.*')" 	= "`$1'$($Latest.Checksum64)'"
			"(^[$]checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
		}
		".\tools\VERIFICATION.txt" = @{
			"(?i)(\s+x32:).*"                   = "`${1} $($Latest.URL32)"
			"(?i)(Get-RemoteChecksum).*"        = "`${1} $($Latest.URL32)"
			"(?i)(\s+checksum32:).*"            = "`${1} $($Latest.Checksum32)"
			"(?i)(\s+x64:).*"                   = "`${1} $($Latest.URL64)"
			"(?i)(\s+checksum64:).*"            = "`${1} $($Latest.Checksum64)"
		}
		"$($Latest.PackageName).nuspec" = @{
			"(\<copyright\>).*?(\</copyright\>)"= "`${1}$($Latest.Copyright)`$2"
		}
	}
}

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
	$urls=(Invoke-WebRequest -uri $releases).Links
	$url32 = ($urls | Where-Object {$_.id -match "windows1"}).href
	$url64 = ($urls | Where-Object {$_.id -match "windows0"}).href
	$page=Invoke-WebRequest -uri "https://svn.jdownloader.org/build.php"
	$revision = $page.Content.Split('<|>') | Where-Object {$_ -match '^[0-9]+$'}

	megatools.exe dl $url32
	megatools.exe dl $url64

	Move-Item .\*.exe tools\

	$File = Get-Item tools\*-x32_jre17.exe
	$version=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($File).FileVersion.trim()
	$File64 = Get-Item tools\*-x64_jre17.exe
	$checksumtype = 'SHA256'
	$checksum32 = (Get-FileHash -Path $File -Algorithm SHA256).hash
	$checksum64 = (Get-FileHash -Path $File64 -Algorithm SHA256).hash

	if($version -eq '2.0') {
		$version = "2.0.0.$($revision)"
	}
	$copyright = (Get-Item($File)).VersionInfo.LegalCopyright

	$Latest = @{ URL32 = $url32; URL64 = $url64; Checksum32 = $checksum32; Checksum64 = $checksum64; ChecksumType32 = $checksumtype; ChecksumType64 = $checksumtype; Version = $version; Copyright = $copyright }
	return $Latest
}

update -ChecksumFor none