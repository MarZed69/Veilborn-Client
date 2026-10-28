[CmdletBinding()]
param(
    [ValidatePattern('^v\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$')][string]$Version,
    [string]$Project = 'C:\Users\marti\Documents\Unreal Projects\Veilborn\Veilborn.uproject',
    [string]$Engine = 'E:\UE5.8.1'
)
$ErrorActionPreference = 'Stop'
if (-not $Version) {
    $Version = git -C $PSScriptRoot describe --tags --exact-match HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or $Version -notmatch '^v\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$') { throw 'Check out a release tag or supply -Version vX.Y.Z.' }
}
$output = Join-Path $PSScriptRoot "out\$Version"
if (Test-Path -LiteralPath $output) { throw "Output already exists: $output. Use a new version or inspect the previous build." }
& (Join-Path $PSScriptRoot 'Set-BuildVersion.ps1') -Version $Version -Project $Project
$projectFile = (Resolve-Path -LiteralPath $Project).Path
& (Join-Path $Engine 'Engine\Build\BatchFiles\Build.bat') VeilbornEditor Win64 Development "-Project=$projectFile" -WaitMutex -NoHotReloadFromIDE -NoEngineChanges
if ($LASTEXITCODE -ne 0) { throw 'Editor project build failed. Nothing was uploaded.' }
& (Join-Path $Engine 'Engine\Build\BatchFiles\RunUAT.bat') BuildCookRun "-project=$projectFile" -map=/Game/Veilborn/Maps/VeilbornTestingMap -nop4 -utf8output -build -cook -stage -pak -iostore -package -clientconfig=Development -platform=Win64 -nocompileeditor -skipbuildeditor -archive "-archivedirectory=$output"
if ($LASTEXITCODE -ne 0) { throw 'Client packaging failed. Nothing was uploaded.' }
Write-Host "Client $Version is ready in $output. Publish it under the same version as the Linux server."
