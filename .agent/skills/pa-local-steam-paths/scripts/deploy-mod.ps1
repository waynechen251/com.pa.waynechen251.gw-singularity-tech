param(
  [Parameter(Mandatory = $true)]
  [string]$SourceModPath,

  [Parameter(Mandatory = $true)]
  [ValidateSet('client', 'server')]
  [string]$Context,

  [string]$Identifier,

  [string]$EnvFilePath = '.agent/env/pa-local.env'
)

$ErrorActionPreference = 'Stop'

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

$envMap = Get-DotEnvMap -Path $EnvFilePath

$defaultDataRoot = Join-Path $env:LOCALAPPDATA 'Uber Entertainment\Planetary Annihilation'
$dataRoot = if ($envMap.ContainsKey('PA_DATA_DIR') -and $envMap['PA_DATA_DIR']) { $envMap['PA_DATA_DIR'] } elseif ($env:PA_DATA_DIR) { $env:PA_DATA_DIR } else { $defaultDataRoot }
$clientRoot = if ($envMap.ContainsKey('PA_CLIENT_MODS_DIR') -and $envMap['PA_CLIENT_MODS_DIR']) { $envMap['PA_CLIENT_MODS_DIR'] } elseif ($env:PA_CLIENT_MODS_DIR) { $env:PA_CLIENT_MODS_DIR } else { Join-Path $dataRoot 'client_mods' }
$serverRoot = if ($envMap.ContainsKey('PA_SERVER_MODS_DIR') -and $envMap['PA_SERVER_MODS_DIR']) { $envMap['PA_SERVER_MODS_DIR'] } elseif ($env:PA_SERVER_MODS_DIR) { $env:PA_SERVER_MODS_DIR } else { Join-Path $dataRoot 'server_mods' }

$resolvedSource = (Resolve-Path -LiteralPath $SourceModPath).Path
$modInfoPath = Join-Path $resolvedSource 'modinfo.json'

if (-not (Test-Path -LiteralPath $modInfoPath)) {
  throw "modinfo.json not found in source path: $resolvedSource"
}

$modInfoRaw = Get-Content -LiteralPath $modInfoPath -Raw -Encoding UTF8
try {
  $modInfo = $modInfoRaw | ConvertFrom-Json
}
catch {
  $modInfoRaw = Get-Content -LiteralPath $modInfoPath -Raw
  $modInfo = $modInfoRaw | ConvertFrom-Json
}

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
Write-Output "EnvFile:  $EnvFilePath"
