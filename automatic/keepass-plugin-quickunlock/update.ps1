import-module au

$releases = 'https://github.com/JanisEst/KeePassQuickUnlock/releases'

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
		}
	}
}

function global:au_GetLatest {
	cup -y keepass
	$url32 = "https://gitbub.com$(((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_.href -match ".plgx"})[0].href)"
	$version = $url32.split('/')[-2]

	$Latest = @{ URL32 = $url32; Version = $version }
	return $Latest
}

update -ChecksumFor 32