﻿$ErrorActionPreference = 'Stop'
$url            = 'https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.6.0.exe'
$checksum       = '390f263a4b65af6a81521e6d5998055e117571de96fe2c25b6ce6b9cab513827'
$checksumType   = 'sha256'
$referer        = 'https://www.wagnardsoft.com/forums/viewtopic.php?t=4316&sid=1b09cc3b6e31f7805cc6e0a83cab96a1'

Invoke-WebRequest -Uri $referer -OutFile "$env:TEMP/test.html" #  Required to be allowed just after

$packageArgs		        = @{
    UnzipLocation	          = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
	packageName		          = $env:ChocolateyPackageName
	url				          = $url
	checksum		          = $checksum
	fileType                  = 'exe'
	checksumType              = $checksumType
	silentArgs                = '/s'
}

Remove-Item "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\*.exe"
Remove-Item "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\DDU*" -Recurse

Install-ChocolateyZipPackage @packageArgs
