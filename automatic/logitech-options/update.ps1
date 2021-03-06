import-module au

. $PSScriptRoot\..\..\scripts\all.ps1

$releases    = 'http://support.logitech.com/en_gb/software/options'

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            '(^\s*url\s*=\s*)(''.*'')'            = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksumType\s*=\s*)('.*')"   = "`$1'$($Latest.ChecksumType32)'"
        }
    }
}

function global:au_BeforeUpdate() {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.Url32
    $Latest.ChecksumType32 = 'SHA256'
}

function global:au_AfterUpdate { 
    Set-DescriptionFromReadme -SkipFirst 2 
}

function global:au_GetLatest {
    $page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $regex = '(?ms)Software Version:\s*<span>(?<version>\d+\.\d+\.\d+)</span>'
    if ($page.content -match $regex) {
        $version = $matches.version
    }
    $url = "https://download01.logi.com/web/ftp/pub/techsupport/options/Options_$version.exe"

    return @{
        URL32        = $url
        Version      = $version
    }
}

Update-Package -ChecksumFor none
