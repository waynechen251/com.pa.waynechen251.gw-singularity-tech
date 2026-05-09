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
  $evidence = "L$lineNo: $line"

  if ($line -match 'Script error for:\s*pages\/gw_start\/gw_dealer') {
    $findings.Add((New-Finding -Severity 'high' -Category 'module_require_failure' -Evidence $evidence -Hypothesis 'Galactic War 的 require module 名稱或載入時機不正確，導致腳本已注入但核心模組未成功解析。' -Fix '優先改用 requireGW 載入 pages/gw_start/gw_dealer，並保留 fallback require。確認錯誤場景（gw_start/gw_play）均能解析該模組。'))
    continue
  }

  if ($line -match 'Failed loading .* with 404') {
    $findings.Add((New-Finding -Severity 'high' -Category 'resource_404' -Evidence $evidence -Hypothesis '注入路徑、檔名或場景映射錯誤，導致 COUI 資源不存在。' -Fix '比對 modinfo.json 的 scenes 與實際 ui/mods/<identifier>/ 路徑；確認大小寫與 identifier 完全一致。'))
    continue
  }

  if ($line -match 'ERROR Error reading .*: 3' -or $line -match 'Access to the path .* is denied' -or $line -match 'Unable to find path:') {
    $findings.Add((New-Finding -Severity 'high' -Category 'path_or_permission' -Evidence $evidence -Hypothesis 'PA 目錄路徑不存在或權限不足，造成 mod 或資源讀取失敗。' -Fix '檢查 PA_DATA_DIR / PA_CLIENT_MODS_DIR / PA_GAME_DIR 是否正確，必要時提權部署並確認目標資料夾存在。'))
    continue
  }

  if ($line -match 'client_mods\\com\.pa\.wayne(\.|chen251\.)gw-bot-overclock-tech') {
    $findings.Add((New-Finding -Severity 'medium' -Category 'legacy_mod_residue' -Evidence $evidence -Hypothesis '舊版模組殘留可能與新版 identifier 或卡片邏輯衝突。' -Fix '刪除舊版 mod 目錄，只保留目標 identifier 的單一版本，重啟遊戲再驗證。'))
    continue
  }

  if ($line -match 'Uncaught (TypeError|ReferenceError)' -or $line -match 'ERROR .*Uncaught') {
    $findings.Add((New-Finding -Severity 'medium' -Category 'javascript_runtime_error' -Evidence $evidence -Hypothesis 'UI 腳本在執行時呼叫未定義函式或資料結構不符合預期。' -Fix '針對出錯腳本加 defensive check（型別/存在性判斷），再用同場景重跑並確認錯誤消失。'))
    continue
  }

  if ($line -match 'gw_force_first_pick\.js loaded') {
    $findings.Add((New-Finding -Severity 'info' -Category 'scene_injection_confirmed' -Evidence $evidence -Hypothesis '目標腳本已被場景成功注入，問題較可能在執行邏輯或後續 require。' -Fix '優先檢查該腳本內 require/module 名稱、hook 時機與回傳資料格式（卡片字串 vs 物件）。'))
    continue
  }
}

$highCount = @($findings | Where-Object { $_.severity -eq 'high' }).Count
$mediumCount = @($findings | Where-Object { $_.severity -eq 'medium' }).Count
$infoCount = @($findings | Where-Object { $_.severity -eq 'info' }).Count

$recommendations = @(
  '先處理 high severity：module require 失敗、404、路徑/權限問題。',
  '清理舊版模組殘留並重啟 PA TITANS，再進行回歸測試。',
  '修正後重跑本腳本，確認同類錯誤訊號不再出現。'
)

$verificationSteps = @(
  '完整重啟 PA TITANS，避免舊場景快取。',
  '進入 Community Mods 確認僅啟用目標 identifier。',
  '開新 Galactic War，檢查目標卡片行為與描述是否正確。',
  '再次掃描最新 PA-*.txt，確認無新增 high severity finding。'
)

$result = [PSCustomObject]@{
  summary = [PSCustomObject]@{
    log_path = $resolvedLogPath
    findings_total = $findings.Count
    high = $highCount
    medium = $mediumCount
    info = $infoCount
  }
  findings = @($findings)
  recommendations = $recommendations
  verification_steps = $verificationSteps
}

if ($OutputFormat -eq 'json') {
  $result | ConvertTo-Json -Depth 8
  exit 0
}

Write-Output "PA Log Diagnostic"
Write-Output "Log: $resolvedLogPath"
Write-Output ("Findings: total={0}, high={1}, medium={2}, info={3}" -f $result.summary.findings_total, $result.summary.high, $result.summary.medium, $result.summary.info)
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
