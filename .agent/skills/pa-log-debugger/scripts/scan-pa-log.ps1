param(
  [string]$LogPath,
  [string]$EnvFilePath = '.agent/env/pa-local.env',
  [ValidateSet('text', 'json')]
  [string]$OutputFormat = 'text',
  [int]$MaxFindings = 20
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

function Resolve-LogRoot {
  param([hashtable]$EnvMap)

  if ($EnvMap.ContainsKey('PA_LOG_DIR') -and $EnvMap['PA_LOG_DIR']) {
    return $EnvMap['PA_LOG_DIR']
  }
  if ($env:PA_LOG_DIR) {
    return $env:PA_LOG_DIR
  }

  $defaultDataRoot = Join-Path $env:LOCALAPPDATA 'Uber Entertainment\Planetary Annihilation'
  $dataRoot = if ($EnvMap.ContainsKey('PA_DATA_DIR') -and $EnvMap['PA_DATA_DIR']) {
    $EnvMap['PA_DATA_DIR']
  } elseif ($env:PA_DATA_DIR) {
    $env:PA_DATA_DIR
  } else {
    $defaultDataRoot
  }

  return (Join-Path $dataRoot 'log')
}

function Resolve-LogFile {
  param(
    [string]$InputPath,
    [string]$LogRoot
  )

  if ($InputPath) {
    $resolved = Resolve-Path -LiteralPath $InputPath -ErrorAction Stop
    return $resolved.Path
  }

  if (-not (Test-Path -LiteralPath $LogRoot)) {
    throw "Log directory does not exist: $LogRoot"
  }

  $latest = Get-ChildItem -LiteralPath $LogRoot -File -Filter 'PA-*.txt' |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $latest) {
    throw "No PA-*.txt log file found under: $LogRoot"
  }

  return $latest.FullName
}

function New-Finding {
  param(
    [string]$Severity,
    [string]$Category,
    [string]$Evidence,
    [string]$Hypothesis,
    [string]$Fix
  )
  return [PSCustomObject]@{
    severity = $Severity
    category = $Category
    evidence = $Evidence
    hypothesis = $Hypothesis
    fix = $Fix
  }
}

$envMap = Get-DotEnvMap -Path $EnvFilePath
$logRoot = Resolve-LogRoot -EnvMap $envMap
$resolvedLogPath = Resolve-LogFile -InputPath $LogPath -LogRoot $logRoot
$lines = Get-Content -LiteralPath $resolvedLogPath

$findings = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($findings.Count -ge $MaxFindings) {
    break
  }

  $line = [string]$lines[$i]
  $lineNo = $i + 1
  $evidence = "L${lineNo}: $line"

  if ($line -match 'Script error for:\s*pages\/gw_start\/gw_dealer') {
    $findings.Add((New-Finding -Severity 'high' -Category 'module_require_failure' -Evidence $evidence -Hypothesis 'The Galactic War module name or loader timing is wrong. The script was injected but the core module failed to resolve.' -Fix 'Use requireGW for pages/gw_start/gw_dealer and keep a fallback require only when needed. Verify both gw_start and gw_play can resolve the module.'))
    continue
  }

  if ($line -match 'Failed loading .* with 404') {
    $findings.Add((New-Finding -Severity 'high' -Category 'resource_404' -Evidence $evidence -Hypothesis 'Scene mapping, file name, or injection path is incorrect, so the COUI asset was not found.' -Fix 'Check modinfo.json scenes against the real ui/mods/<identifier>/ path and confirm exact casing and identifier match.'))
    continue
  }

  if ($line -match 'client_mods\\com\.pa\.wayne(\.|chen251\.)gw-bot-overclock-tech') {
    $findings.Add((New-Finding -Severity 'medium' -Category 'legacy_mod_residue' -Evidence $evidence -Hypothesis 'Legacy mod folders may conflict with the current identifier or card logic.' -Fix 'Remove old mod folders, keep only the target identifier, then restart the game and re-test.'))
    continue
  }

  if ($line -match 'ERROR Error reading .*: 3' -or $line -match 'Access to the path .* is denied' -or $line -match 'Unable to find path:') {
    $findings.Add((New-Finding -Severity 'high' -Category 'path_or_permission' -Evidence $evidence -Hypothesis 'PA paths are missing or access permissions are insufficient, causing mod/resource read failures.' -Fix 'Verify PA_DATA_DIR / PA_CLIENT_MODS_DIR / PA_GAME_DIR and deploy with elevation if required. Confirm target directories exist.'))
    continue
  }

  if ($line -match 'Uncaught (TypeError|ReferenceError)' -or $line -match 'ERROR .*Uncaught') {
    $findings.Add((New-Finding -Severity 'medium' -Category 'javascript_runtime_error' -Evidence $evidence -Hypothesis 'A UI script called an undefined function or assumed an unexpected data shape.' -Fix 'Add defensive checks for existence and type, then replay the same scene and confirm the error is gone.'))
    continue
  }

  if ($line -match 'gw_force_first_pick\.js loaded') {
    $findings.Add((New-Finding -Severity 'info' -Category 'scene_injection_confirmed' -Evidence $evidence -Hypothesis 'The target script was injected successfully. The failure is likely in runtime logic or follow-up module loading.' -Fix 'Check module names, hook timing, and card list entry shape handling (string vs object).'))
    continue
  }
}

$highCount = @($findings | Where-Object { $_.severity -eq 'high' }).Count
$mediumCount = @($findings | Where-Object { $_.severity -eq 'medium' }).Count
$infoCount = @($findings | Where-Object { $_.severity -eq 'info' }).Count

$recommendations = @(
  'Handle high-severity findings first: module require failures, 404 errors, and path/permission issues.',
  'Remove legacy mod residues and fully restart PA TITANS before regression tests.',
  'Re-run this scanner after fixes to confirm the same signals are gone.'
)

$verificationSteps = @(
  'Fully restart PA TITANS to avoid stale scene cache.',
  'In Community Mods, verify only the target identifier is enabled.',
  'Start a new Galactic War and validate card behavior/description.',
  'Scan the latest PA-*.txt again and ensure no new high-severity findings remain.'
)

$scanFindings = @()
foreach ($findingItem in $findings) {
  $scanFindings += $findingItem
}

$scanResult = @{
  'summary' = @{
    'log_path' = $resolvedLogPath
    'findings_total' = $findings.Count
    'high' = $highCount
    'medium' = $mediumCount
    'info' = $infoCount
  }
  'findings' = $scanFindings
  'recommendations' = $recommendations
  'verification_steps' = $verificationSteps
}

if ($OutputFormat -eq 'json') {
  $scanResult | ConvertTo-Json -Depth 8
  exit 0
}

Write-Output "PA Log Diagnostic"
Write-Output "Log: $resolvedLogPath"
Write-Output ("Findings: total={0}, high={1}, medium={2}, info={3}" -f $scanResult.summary.findings_total, $scanResult.summary.high, $scanResult.summary.medium, $scanResult.summary.info)
Write-Output ""

if ($findings.Count -eq 0) {
  Write-Output "No targeted findings matched the current rule set."
} else {
  $index = 1
  foreach ($finding in $findings) {
    Write-Output ("[{0}] {1} / {2}" -f $index, $finding.severity.ToUpperInvariant(), $finding.category)
    Write-Output ("  Evidence:   {0}" -f $finding.evidence)
    Write-Output ("  Hypothesis: {0}" -f $finding.hypothesis)
    Write-Output ("  Fix:        {0}" -f $finding.fix)
    Write-Output ""
    $index++
  }
}

Write-Output "Recommendations:"
foreach ($item in $recommendations) {
  Write-Output ("- {0}" -f $item)
}
Write-Output ""
Write-Output "Verification Steps:"
foreach ($step in $verificationSteps) {
  Write-Output ("- {0}" -f $step)
}
