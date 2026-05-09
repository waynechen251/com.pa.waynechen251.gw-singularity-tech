param(
  [Parameter(Mandatory = $true)]
  [string]$InputFile,

  [string]$OutputRoot = 'mods',

  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function ConvertFrom-JsonSafe {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  try {
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
  }
  catch {
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
  }
}

function Test-HasValue {
  param([object]$Value)
  if ($null -eq $Value) { return $false }
  if ($Value -is [string]) { return $Value.Trim().Length -gt 0 }
  if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
    return @($Value).Count -gt 0
  }
  return $true
}

function Replace-PlaceholdersInFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][hashtable]$Map
  )

  $content = Get-Content -LiteralPath $Path -Raw
  foreach ($key in $Map.Keys) {
    $content = $content.Replace($key, [string]$Map[$key])
  }
  Set-Content -LiteralPath $Path -Value $content -Encoding UTF8
}

function Rename-PlaceholderPaths {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][hashtable]$Map
  )

  $items = Get-ChildItem -LiteralPath $Root -Recurse -Force | Sort-Object { $_.FullName.Length } -Descending
  foreach ($item in $items) {
    $newName = $item.Name
    foreach ($key in $Map.Keys) {
      if ($newName.Contains($key)) {
        $newName = $newName.Replace($key, [string]$Map[$key])
      }
    }
    if ($newName -ne $item.Name) {
      Rename-Item -LiteralPath $item.FullName -NewName $newName
    }
  }
}

function Get-UiLanguage {
  param(
    [object]$Spec
  )

  if (Test-HasValue $Spec.user_language) {
    return [string]$Spec.user_language
  }

  $probe = ([string]$Spec.display_name) + ' ' + ([string]$Spec.description)
  if ($probe -match '[\u4e00-\u9fff]') {
    return 'zh-TW'
  }
  return 'en-US'
}

function New-DocText {
  param(
    [Parameter(Mandatory = $true)][string]$Language,
    [Parameter(Mandatory = $true)][pscustomobject]$Spec,
    [Parameter(Mandatory = $true)][string]$DeployContext
  )

  $contextLabel = if ($Spec.mod_context -eq 'companion-client') { 'companion-client' } else { [string]$Spec.mod_context }
  $feature = if ($Spec.feature_scope -is [System.Collections.IEnumerable] -and -not ($Spec.feature_scope -is [string])) {
    (@($Spec.feature_scope) -join ', ')
  } else {
    [string]$Spec.feature_scope
  }

  $deployCmd = "powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath `"$($Spec.generated_path)`" -Context $DeployContext -EnvFilePath `".agent/env/pa-local.env`""

  if ($Language -like 'zh*') {
    $readme = @(
      "# $($Spec.display_name)",
      "",
      "$($Spec.description)",
      "",
      "## 基本資訊",
      "",
      "- Context: $contextLabel",
      "- Goal Type: $($Spec.mod_goal_type)",
      "- Build: $($Spec.target_build)",
      "- Version: $($Spec.version)",
      "- Category: $((@($Spec.category) -join ', '))",
      "- Feature Scope: $feature",
      "",
      "## 部署（手動執行）",
      "",
      "$deployCmd",
      "",
      "## 測試建議",
      "",
      "1. 啟用 MOD 後建立新對局或新銀河戰爭存檔。",
      "2. 驗證 modinfo.json 與對應場景/覆寫檔是否生效。",
      "3. 若異常，先用 --nomods 排除其他模組干擾。"
    ) -join "`n"

    $release = @(
      "# 釋出說明 - $($Spec.display_name)",
      "",
      "## 變更重點",
      "",
      "- 建立初始 MOD 草稿",
      "- 完成標準化 modinfo.json",
      "- 生成 context 專屬骨架",
      "",
      "## 相容資訊",
      "",
      "- Build: $($Spec.target_build)",
      "- Context: $contextLabel"
    ) -join "`n"

    $changelog = @(
      "# Changelog",
      "",
      "## [$($Spec.version)] - $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd'))",
      "",
      "- 初始化專案模板",
      "- 新增核心輸出文件"
    ) -join "`n"

    $checklist = @(
      "# Validation Checklist",
      "",
      "- [ ] 必填欄位完整（identifier/context/version/build/category/forum）",
      "- [ ] modinfo.json 可解析且欄位正確",
      "- [ ] 場景注入或單位覆寫路徑存在",
      "- [ ] 版本與日期已更新",
      "- [ ] 部署命令可在本機 env 下執行"
    ) -join "`n"

    return @{
      Readme = $readme
      Release = $release
      Changelog = $changelog
      Checklist = $checklist
    }
  }

  $readme = @(
    "# $($Spec.display_name)",
    "",
    "$($Spec.description)",
    "",
    "## Overview",
    "",
    "- Context: $contextLabel",
    "- Goal Type: $($Spec.mod_goal_type)",
    "- Build: $($Spec.target_build)",
    "- Version: $($Spec.version)",
    "- Category: $((@($Spec.category) -join ', '))",
    "- Feature Scope: $feature",
    "",
    "## Deployment (manual)",
    "",
    "$deployCmd",
    "",
    "## Suggested validation",
    "",
    "1. Enable the mod and start a new game or a new Galactic War save.",
    "2. Verify modinfo.json and scene/override files are active.",
    "3. Use --nomods to isolate issues if needed."
  ) -join "`n"

  $release = @(
    "# Release Notes - $($Spec.display_name)",
    "",
    "## Highlights",
    "",
    "- Initial MOD draft scaffold",
    "- Standardized modinfo.json",
    "- Context-specific skeleton generated",
    "",
    "## Compatibility",
    "",
    "- Build: $($Spec.target_build)",
    "- Context: $contextLabel"
  ) -join "`n"

  $changelog = @(
    "# Changelog",
    "",
    "## [$($Spec.version)] - $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd'))",
    "",
    "- Initialize template scaffold",
    "- Add baseline output documents"
  ) -join "`n"

  $checklist = @(
    "# Validation Checklist",
    "",
    "- [ ] Required fields are complete (identifier/context/version/build/category/forum)",
    "- [ ] modinfo.json is valid and fields are correct",
    "- [ ] Scene hooks or unit override paths exist",
    "- [ ] Version and date are updated",
    "- [ ] Deployment command works with local env file"
  ) -join "`n"

  return @{
    Readme = $readme
    Release = $release
    Changelog = $changelog
    Checklist = $checklist
  }
}

$inputPath = (Resolve-Path -LiteralPath $InputFile).Path
$spec = ConvertFrom-JsonSafe -Path $inputPath

$requiredFields = @(
  'mod_context',
  'mod_goal_type',
  'identifier',
  'display_name',
  'description',
  'author',
  'target_build',
  'version',
  'category',
  'forum_url',
  'feature_scope',
  'deploy_context'
)

$missing = @()
foreach ($field in $requiredFields) {
  if (-not (Test-HasValue $spec.$field)) {
    $missing += $field
  }
}

if ($missing.Count -gt 0) {
  $joined = $missing -join ', '
  throw "missing_required_fields: $joined"
}

$allowedContexts = @('client', 'server', 'companion-client')
if ($allowedContexts -notcontains [string]$spec.mod_context) {
  throw "Invalid mod_context: $($spec.mod_context)"
}

$allowedGoalTypes = @('ui-enhancement', 'unit-balance', 'galactic-war-card', 'other-pa')
if ($allowedGoalTypes -notcontains [string]$spec.mod_goal_type) {
  throw "Invalid mod_goal_type: $($spec.mod_goal_type)"
}

$allowedDeployContexts = @('client', 'server')
if ($allowedDeployContexts -notcontains [string]$spec.deploy_context) {
  throw "Invalid deploy_context: $($spec.deploy_context)"
}

$modContext = [string]$spec.mod_context
$deployContext = [string]$spec.deploy_context
if (($modContext -eq 'client' -or $modContext -eq 'companion-client') -and $deployContext -ne 'client') {
  throw "deploy_context must be client when mod_context is $modContext"
}
if ($modContext -eq 'server' -and $deployContext -ne 'server') {
  throw "deploy_context must be server when mod_context is server"
}

$identifier = [string]$spec.identifier
if ($identifier -notmatch '^[a-z0-9]+(\.[a-z0-9-]+)+$') {
  throw "Invalid identifier format: $identifier"
}

$version = [string]$spec.version
if ($version -notmatch '^\d+\.\d+\.\d+([-.][A-Za-z0-9]+)?$') {
  throw "Invalid version format: $version"
}

try {
  $forumUri = [System.Uri]([string]$spec.forum_url)
  if (-not $forumUri.IsAbsoluteUri) {
    throw "forum_url must be absolute"
  }
}
catch {
  throw "Invalid forum_url: $($spec.forum_url)"
}

$categories = @($spec.category)
if ($categories.Count -eq 0) {
  throw "category must contain at least one item"
}

$templateRoot = switch ($modContext) {
  'client' { '.agent/templates/client-ui' }
  'server' { '.agent/templates/server-unit' }
  'companion-client' { '.agent/templates/companion-client' }
}

$templatePath = (Resolve-Path -LiteralPath $templateRoot).Path
$outputRootResolved = (Resolve-Path -LiteralPath '.').Path
$targetRoot = Join-Path $outputRootResolved $OutputRoot
if (-not (Test-Path -LiteralPath $targetRoot)) {
  New-Item -ItemType Directory -Path $targetRoot | Out-Null
}

$targetPath = Join-Path $targetRoot $identifier
if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
  throw "Target already exists: $targetPath. Use -Force to overwrite."
}
if (Test-Path -LiteralPath $targetPath) {
  Remove-Item -LiteralPath $targetPath -Recurse -Force
}

New-Item -ItemType Directory -Path $targetPath | Out-Null
Copy-Item -Path (Join-Path $templatePath '*') -Destination $targetPath -Recurse -Force

$dateUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
$optionalCompanion = if (Test-HasValue $spec.optional_companion_identifier) { [string]$spec.optional_companion_identifier } else { '' }
$placeholderMap = @{
  '__MOD_IDENTIFIER__' = $identifier
  '__DISPLAY_NAME__' = [string]$spec.display_name
  '__DESCRIPTION__' = [string]$spec.description
  '__AUTHOR__' = [string]$spec.author
  '__PA_BUILD__' = [string]$spec.target_build
  '__UTC_YYYY_MM_DD__' = $dateUtc
  '__FORUM_URL__' = [string]$spec.forum_url
  '__OPTIONAL_COMPANION_IDENTIFIER__' = $optionalCompanion
}

Rename-PlaceholderPaths -Root $targetPath -Map $placeholderMap

$textFiles = Get-ChildItem -LiteralPath $targetPath -Recurse -File | Where-Object {
  $_.Extension -in @('.json', '.md', '.js', '.txt')
}
foreach ($file in $textFiles) {
  Replace-PlaceholdersInFile -Path $file.FullName -Map $placeholderMap
}

$modInfoPath = Join-Path $targetPath 'modinfo.json'
$modInfo = ConvertFrom-JsonSafe -Path $modInfoPath
$modInfo.identifier = $identifier
$modInfo.display_name = [string]$spec.display_name
$modInfo.description = [string]$spec.description
$modInfo.author = [string]$spec.author
$modInfo.version = [string]$spec.version
$modInfo.build = [string]$spec.target_build
$modInfo.date = $dateUtc
$modInfo.forum = [string]$spec.forum_url
$modInfo.category = $categories
if (Test-HasValue $spec.signature) {
  $modInfo.signature = [string]$spec.signature
}

if ($modContext -eq 'server') {
  if (Test-HasValue $optionalCompanion) {
    $modInfo.companions = @($optionalCompanion)
  } else {
    $modInfo.companions = @()
  }
}

$modInfo | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $modInfoPath -Encoding UTF8

$spec | Add-Member -MemberType NoteProperty -Name generated_path -Value $targetPath -Force
$language = Get-UiLanguage -Spec $spec
$docs = New-DocText -Language $language -Spec $spec -DeployContext $deployContext

Set-Content -LiteralPath (Join-Path $targetPath 'README.md') -Value $docs.Readme -Encoding UTF8
Set-Content -LiteralPath (Join-Path $targetPath 'release_notes.md') -Value $docs.Release -Encoding UTF8
Set-Content -LiteralPath (Join-Path $targetPath 'validation-checklist.md') -Value $docs.Checklist -Encoding UTF8

$result = [pscustomobject]@{
  status = 'ok'
  language = $language
  mod_context = $modContext
  deploy_context = $deployContext
  identifier = $identifier
  output_path = $targetPath
}
$result | ConvertTo-Json -Depth 8
