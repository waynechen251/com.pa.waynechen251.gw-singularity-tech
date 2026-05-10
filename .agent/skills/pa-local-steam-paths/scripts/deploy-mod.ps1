param(
  [string]$SourceModPath,

  [Parameter(Mandatory = $true)]
  [ValidateSet('client', 'server')]
  [string]$Context,

  [string]$Identifier,

  [string]$EnvFilePath = '.agent/env/pa-local.env',

  [string]$SourceModsRoot = 'mods'
)

$ErrorActionPreference = 'Stop'

function Resolve-InputPath {
  param(
    [string]$Path,
    [string]$ArgumentName
  )

  if (-not $Path -or $Path.Trim().Length -eq 0) {
    return $null
  }

  if ($Path -match '[<>]') {
    throw "$ArgumentName contains placeholder markers '<' or '>'. Replace it with an actual path or omit -SourceModPath to auto-discover mods under '$SourceModsRoot'."
  }

  try {
    return (Resolve-Path -LiteralPath $Path).Path
  }
  catch {
    throw "Cannot resolve ${ArgumentName}: $Path"
  }
}

function Get-DotEnvMap {
  param(
    [string]$Path
  )

  $map = @{}
  if (-not $Path -or -not (Test-Path -LiteralPath $Path)) {
    return $map
  }

  $lines = Get-Content -LiteralPath $Path
  foreach ($lineRaw in $lines) {
    $line = [string]$lineRaw
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) {
      continue
    }
    $parts = $trimmed -split '=', 2
    if ($parts.Count -ne 2) {
      continue
    }
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    if ($key.Length -gt 0) {
      $map[$key] = $value
    }
  }

  return $map
}

function Get-ModSourcePaths {
  param(
    [string]$ModsRootPath
  )

  if (-not (Test-Path -LiteralPath $ModsRootPath)) {
    throw "Mods root not found: $ModsRootPath"
  }

  $paths = @()
  $rootModInfo = Join-Path $ModsRootPath 'modinfo.json'
  if (Test-Path -LiteralPath $rootModInfo) {
    $paths += $ModsRootPath
  }

  $paths += Get-ChildItem -LiteralPath $ModsRootPath -Directory -Recurse |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'modinfo.json') } |
    Select-Object -ExpandProperty FullName

  $uniquePaths = $paths | Select-Object -Unique
  if (-not $uniquePaths -or $uniquePaths.Count -eq 0) {
    throw "No deployable mod folders found under: $ModsRootPath"
  }

  return $uniquePaths
}

function Deploy-Mod {
  param(
    [string]$ResolvedSource,
    [string]$Context,
    [string]$IdentifierOverride,
    [string]$ClientRoot,
    [string]$ServerRoot
  )

  $modInfoPath = Join-Path $ResolvedSource 'modinfo.json'
  if (-not (Test-Path -LiteralPath $modInfoPath)) {
    throw "modinfo.json not found in source path: $ResolvedSource"
  }

  $modInfoRaw = Get-Content -LiteralPath $modInfoPath -Raw -Encoding UTF8
  try {
    $modInfo = $modInfoRaw | ConvertFrom-Json
  }
  catch {
    $modInfoRaw = Get-Content -LiteralPath $modInfoPath -Raw
    $modInfo = $modInfoRaw | ConvertFrom-Json
  }

  $resolvedIdentifier = $IdentifierOverride
  if (-not $resolvedIdentifier -or $resolvedIdentifier.Trim().Length -eq 0) {
    $resolvedIdentifier = [string]$modInfo.identifier
  }

  if (-not $resolvedIdentifier -or $resolvedIdentifier.Trim().Length -eq 0) {
    throw "Identifier is empty for mod: $ResolvedSource. Provide -Identifier or set modinfo.json.identifier."
  }

  $targetRoot = if ($Context -eq 'client') { $ClientRoot } else { $ServerRoot }
  if (-not (Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
  }

  $targetPath = Join-Path $targetRoot $resolvedIdentifier
  if (Test-Path -LiteralPath $targetPath) {
    Remove-Item -LiteralPath $targetPath -Recurse -Force
  }

  New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
  Copy-Item -Path (Join-Path $ResolvedSource '*') -Destination $targetPath -Recurse -Force

  return [PSCustomObject]@{
    Source     = $ResolvedSource
    Target     = $targetPath
    Context    = $Context
    Identifier = $resolvedIdentifier
  }
}

$envMap = Get-DotEnvMap -Path $EnvFilePath

$defaultDataRoot = Join-Path $env:LOCALAPPDATA 'Uber Entertainment\Planetary Annihilation'
$dataRoot = if ($envMap.ContainsKey('PA_DATA_DIR') -and $envMap['PA_DATA_DIR']) { $envMap['PA_DATA_DIR'] } elseif ($env:PA_DATA_DIR) { $env:PA_DATA_DIR } else { $defaultDataRoot }
$clientRoot = if ($envMap.ContainsKey('PA_CLIENT_MODS_DIR') -and $envMap['PA_CLIENT_MODS_DIR']) { $envMap['PA_CLIENT_MODS_DIR'] } elseif ($env:PA_CLIENT_MODS_DIR) { $env:PA_CLIENT_MODS_DIR } else { Join-Path $dataRoot 'client_mods' }
$serverRoot = if ($envMap.ContainsKey('PA_SERVER_MODS_DIR') -and $envMap['PA_SERVER_MODS_DIR']) { $envMap['PA_SERVER_MODS_DIR'] } elseif ($env:PA_SERVER_MODS_DIR) { $env:PA_SERVER_MODS_DIR } else { Join-Path $dataRoot 'server_mods' }

$workspaceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..\..')).Path
$candidateModsRoot = if ([System.IO.Path]::IsPathRooted($SourceModsRoot)) { $SourceModsRoot } else { Join-Path $workspaceRoot $SourceModsRoot }

$resolvedSource = Resolve-InputPath -Path $SourceModPath -ArgumentName 'SourceModPath'
$resolvedModsRoot = Resolve-InputPath -Path $candidateModsRoot -ArgumentName 'SourceModsRoot'

if ($Identifier -and (-not $resolvedSource)) {
  throw "-Identifier can only be used with -SourceModPath. Auto-discovery deploys each mod using its own modinfo.json.identifier."
}

$sourcePaths = if ($resolvedSource) { @($resolvedSource) } else { Get-ModSourcePaths -ModsRootPath $resolvedModsRoot }

if (-not $resolvedSource) {
  Write-Output "Discovered $($sourcePaths.Count) mod(s) under: $resolvedModsRoot"
}

$results = @()
foreach ($sourcePath in $sourcePaths) {
  $results += Deploy-Mod -ResolvedSource $sourcePath -Context $Context -IdentifierOverride $Identifier -ClientRoot $clientRoot -ServerRoot $serverRoot
}

foreach ($result in $results) {
  Write-Output "Deployed: $($result.Source)"
  Write-Output "Target:   $($result.Target)"
  Write-Output "Context:  $($result.Context)"
  Write-Output "Id:       $($result.Identifier)"
}

Write-Output "EnvFile:  $EnvFilePath"
Write-Output "Total:    $($results.Count)"
