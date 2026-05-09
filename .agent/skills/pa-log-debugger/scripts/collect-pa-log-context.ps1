param(
  [string]$EnvFilePath = '.agent/env/pa-local.env',
  [string]$Identifier
)

$ErrorActionPreference = 'Stop'

function Get-DotEnvMap {
  param([string]$Path)
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

function Resolve-PathFromMap {
  param(
    [hashtable]$EnvMap,
    [string]$Key,
    [string]$EnvKey,
    [string]$Fallback
  )
  if ($EnvMap.ContainsKey($Key) -and $EnvMap[$Key]) {
    return $EnvMap[$Key]
  }
  if (Get-Item "Env:$EnvKey" -ErrorAction SilentlyContinue) {
    $value = (Get-Item "Env:$EnvKey").Value
    if ($value) {
      return $value
    }
  }
  return $Fallback
}

function List-DirectoriesSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    return [string[]]@()
  }
  return [string[]](Get-ChildItem -LiteralPath $Path -Directory | Select-Object -ExpandProperty Name)
}

$envMap = Get-DotEnvMap -Path $EnvFilePath

$defaultDataRoot = Join-Path $env:LOCALAPPDATA 'Uber Entertainment\Planetary Annihilation'
$dataRoot = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_DATA_DIR' -EnvKey 'PA_DATA_DIR' -Fallback $defaultDataRoot
$clientModsDir = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_CLIENT_MODS_DIR' -EnvKey 'PA_CLIENT_MODS_DIR' -Fallback (Join-Path $dataRoot 'client_mods')
$serverModsDir = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_SERVER_MODS_DIR' -EnvKey 'PA_SERVER_MODS_DIR' -Fallback (Join-Path $dataRoot 'server_mods')
$gameDir = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_GAME_DIR' -EnvKey 'PA_GAME_DIR' -Fallback ''
$mediaDir = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_MEDIA_DIR' -EnvKey 'PA_MEDIA_DIR' -Fallback ($(if ($gameDir) { Join-Path $gameDir 'media' } else { '' }))
$logDir = Resolve-PathFromMap -EnvMap $envMap -Key 'PA_LOG_DIR' -EnvKey 'PA_LOG_DIR' -Fallback (Join-Path $dataRoot 'log')

$latestLog = $null
if (Test-Path -LiteralPath $logDir) {
  $latestLog = Get-ChildItem -LiteralPath $logDir -File -Filter 'PA-*.txt' |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName
}

$clientMods = @(List-DirectoriesSafe -Path $clientModsDir)
$serverMods = @(List-DirectoriesSafe -Path $serverModsDir)

$identifierCheck = $null
if ($Identifier) {
  $clientTarget = Join-Path $clientModsDir $Identifier
  $serverTarget = Join-Path $serverModsDir $Identifier
  $identifierCheck = [PSCustomObject]@{
    identifier = $Identifier
    client_mod_exists = Test-Path -LiteralPath $clientTarget
    server_mod_exists = Test-Path -LiteralPath $serverTarget
    client_modinfo_exists = Test-Path -LiteralPath (Join-Path $clientTarget 'modinfo.json')
    server_modinfo_exists = Test-Path -LiteralPath (Join-Path $serverTarget 'modinfo.json')
  }
}

$context = [PSCustomObject]@{
  env_file_path = $EnvFilePath
  paths = [PSCustomObject]@{
    pa_data_dir = $dataRoot
    pa_client_mods_dir = $clientModsDir
    pa_server_mods_dir = $serverModsDir
    pa_game_dir = $gameDir
    pa_media_dir = $mediaDir
    pa_log_dir = $logDir
  }
  exists = [PSCustomObject]@{
    pa_data_dir = Test-Path -LiteralPath $dataRoot
    pa_client_mods_dir = Test-Path -LiteralPath $clientModsDir
    pa_server_mods_dir = Test-Path -LiteralPath $serverModsDir
    pa_game_dir = $(if ($gameDir) { Test-Path -LiteralPath $gameDir } else { $false })
    pa_media_dir = $(if ($mediaDir) { Test-Path -LiteralPath $mediaDir } else { $false })
    pa_log_dir = Test-Path -LiteralPath $logDir
  }
  installed_mods = [PSCustomObject]@{
    client_count = $clientMods.Count
    client_items = $clientMods
    server_count = $serverMods.Count
    server_items = $serverMods
  }
  latest_log = $latestLog
  identifier_check = $identifierCheck
}

$context | ConvertTo-Json -Depth 8
