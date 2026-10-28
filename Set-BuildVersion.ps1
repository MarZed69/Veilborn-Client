[CmdletBinding()]
param(
    [ValidatePattern('^v\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$')][string]$Version,
    [string]$Project = 'C:\Users\marti\Documents\Unreal Projects\Veilborn\Veilborn.uproject'
)
$ErrorActionPreference = 'Stop'
if (-not $Version) {
    $Version = git -C $PSScriptRoot describe --tags --exact-match HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or $Version -notmatch '^v\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$') {
        throw 'Check out the intended release tag, or supply -Version vX.Y.Z when preparing a new release.'
    }
}
$projectRoot = Split-Path (Resolve-Path -LiteralPath $Project).Path -Parent
$header = Join-Path $projectRoot 'Source\Veilborn\VeilbornReleaseVersion.h'
if (-not (Test-Path -LiteralPath (Split-Path $header -Parent))) { throw 'Veilborn source folder is missing.' }
$content = "#pragma once`n// Stamped from the selected repository release version. Do not change while a build is running.`n#define VEILBORN_RELEASE_VERSION TEXT(`"$Version`")`n"
if (-not (Test-Path -LiteralPath $header) -or [IO.File]::ReadAllText($header) -ne $content) {
    [IO.File]::WriteAllText($header,$content,[Text.UTF8Encoding]::new($false))
}
Write-Host "Veilborn build version: $Version"
