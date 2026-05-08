param(
  [Parameter(Mandatory = $true)]
  [string]$SourceModPath,

  [Parameter(Mandatory = $true)]
  [ValidateSet('client', 'server')]
  [string]$Context,

  [string]$Identifier
)

$dataRoot = Join-Path $env:LOCALAPPDATA 'Uber Entertainment\Planetary Annihilation'
$clientRoot = Join-Path $dataRoot 'client_mods'
$serverRoot = Join-Path $dataRoot 'server_mods'

$resolvedSource = (Resolve-Path -LiteralPath $SourceModPath).Path
$modInfoPath = Join-Path $resolvedSource 'modinfo.json'

if (-not (Test-Path -LiteralPath $modInfoPath)) {
  throw "modinfo.json not found in source path: $resolvedSource"
}

$modInfo = Get-Content -LiteralPath $modInfoPath -Raw | ConvertFrom-Json

if (-not $Identifier -or $Identifier.Trim().Length -eq 0) {
  $Identifier = [string]$modInfo.identifier
}

if (-not $Identifier -or $Identifier.Trim().Length -eq 0) {
  throw "Identifier is empty. Provide -Identifier or set modinfo.json.identifier."
}

$targetRoot = if ($Context -eq 'client') { $clientRoot } else { $serverRoot }
if (-not (Test-Path -LiteralPath $targetRoot)) {
  New-Item -ItemType Directory -Path $targetRoot | Out-Null
}

$targetPath = Join-Path $targetRoot $Identifier
if (Test-Path -LiteralPath $targetPath) {
  Remove-Item -LiteralPath $targetPath -Recurse -Force
}

New-Item -ItemType Directory -Path $targetPath | Out-Null
Copy-Item -Path (Join-Path $resolvedSource '*') -Destination $targetPath -Recurse -Force

Write-Output "Deployed: $resolvedSource"
Write-Output "Target:   $targetPath"
Write-Output "Context:  $Context"
Write-Output "Id:       $Identifier"
