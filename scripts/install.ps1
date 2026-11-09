# IoTMart Agent Kit installer (Windows PowerShell 5.1+ / PowerShell 7).
# Copies the kit into a project and/or the user profile. No git, admin rights or symlinks needed.
# Started by install-windows.cmd; safe to run again to update (changed files are backed up first).
#
#   -ProjectPath <dir>  install rules + skills into this project (skips the folder dialog)
#   -SkillsOnly         install skills to the user profile only
#   -Yes                no questions, no pause (for testing)
param(
  [string]$ProjectPath,
  [switch]$SkillsOnly,
  [switch]$Yes
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$Kit = Split-Path -Parent $PSScriptRoot
$UserHome = if ($env:IOTMART_KIT_HOME) { $env:IOTMART_KIT_HOME } else { [Environment]::GetFolderPath('UserProfile') }
$OnWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = [IO.Path]::Combine($UserHome, '.iotmart-agent-kit-backup', $Stamp)

$Installed = New-Object System.Collections.Generic.List[string]
$Kept = New-Object System.Collections.Generic.List[string]
$BackedUp = New-Object System.Collections.Generic.List[string]
$Notes = New-Object System.Collections.Generic.List[string]

function Say([string]$msg, [string]$color = 'Gray') { Write-Host $msg -ForegroundColor $color }

function Finish([int]$code) {
  if (-not $Yes) { [void](Read-Host '按 Enter 關閉視窗') }
  exit $code
}

function Get-TreeHash([string]$path) {
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
  }
  $base = (Resolve-Path -LiteralPath $path).Path
  $lines = Get-ChildItem -LiteralPath $path -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($base.Length).Replace('\', '/')
    "$rel $((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)"
  } | Sort-Object
  $sha = [Security.Cryptography.SHA256]::Create()
  return [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(($lines -join "`n"))))
}

function Get-BackupPath([string]$label) {
  if ($label.StartsWith('~/')) { return Join-Path $Backup ('home/' + $label.Substring(2)) }
  return Join-Path $Backup ('project/' + $label)
}

function Test-IsLink([string]$path) {
  $item = Get-Item -LiteralPath $path -Force
  return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

# Copy src to dst. Existing content is moved to the backup first; identical content is left alone.
function Install-Copy([string]$src, [string]$dst, [string]$label) {
  if (-not (Test-Path -LiteralPath $src)) { return }
  if (Test-Path -LiteralPath $dst) {
    if (Test-IsLink $dst) { $Kept.Add("$label (是連結,維持原樣)"); return }
    if ((Get-TreeHash $src) -eq (Get-TreeHash $dst)) { $Kept.Add("$label (已是最新)"); return }
    $bk = Get-BackupPath $label
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bk) | Out-Null
    try {
      Move-Item -LiteralPath $dst -Destination $bk -Force
    } catch {
      # Windows PowerShell cannot move a folder across drives (e.g. project on D:, backup on C:).
      Copy-Item -LiteralPath $dst -Destination $bk -Recurse -Force
      Remove-Item -LiteralPath $dst -Recurse -Force
    }
    $BackedUp.Add($label)
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
  $Installed.Add($label)
}

# Copy only when the destination does not exist yet (personal settings stay untouched).
function Install-IfMissing([string]$src, [string]$dst, [string]$label) {
  if (-not (Test-Path -LiteralPath $src)) { return }
  if (Test-Path -LiteralPath $dst) { $Kept.Add("$label (已存在,保留你的設定)"); return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item -LiteralPath $src -Destination $dst -Force
  $Installed.Add($label)
}

function Add-GitExclude([string]$project, [string[]]$entries) {
  $gitDir = Join-Path $project '.git'
  if (-not (Test-Path -LiteralPath $gitDir -PathType Container)) { return }
  $exclude = [IO.Path]::Combine($gitDir, 'info', 'exclude')
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $exclude) | Out-Null
  $existing = @()
  if (Test-Path -LiteralPath $exclude) { $existing = @(Get-Content -LiteralPath $exclude) }
  $add = @($entries | Where-Object { $existing -notcontains $_ })
  if ($add.Count -eq 0) { return }
  $text = "`n# iotmart-agent-kit`n" + ($add -join "`n") + "`n"
  [IO.File]::AppendAllText($exclude, $text, (New-Object Text.UTF8Encoding($false)))
  $Installed.Add('.git/info/exclude (避免把agent檔案commit進公司repo)')
}

# ---------------------------------------------------------------------------

if ($OnWindows) {
  # Files from a downloaded zip are marked as "from the internet"; clear that so they run normally.
  try { Get-ChildItem -LiteralPath $Kit -Recurse -File | Unblock-File } catch {}
}

if (-not (Test-Path -LiteralPath (Join-Path $Kit 'AGENTS.md'))) {
  Say '找不到 AGENTS.md:請先把整個 zip 解壓縮,再執行資料夾裡的安裝檔' 'Red'
  Finish 1
}

Say ''
Say '=== IoTMart Agent Kit 安裝 ===' 'Cyan'
Say "來源:$Kit"
Say ''

if (-not $ProjectPath -and -not $SkillsOnly) {
  Say '接下來會跳出「選擇資料夾」視窗:'
  Say '  - 請選你的 IoTMart 專案資料夾(裡面有 sfdx-project.json 的那一層)'
  Say '  - 按「取消」= 只安裝 skill,不放專案規則'
  Say ''
  if ($OnWindows) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = '選擇 IoTMart 專案資料夾(取消 = 只安裝 skill)'
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $ProjectPath = $dialog.SelectedPath }
  } else {
    $ProjectPath = (Read-Host '輸入專案資料夾路徑(直接 Enter = 只安裝 skill)').Trim().Trim('"').Trim("'")
  }
}

$SkillDirs = @(Get-ChildItem -LiteralPath ([IO.Path]::Combine($Kit, '.agents', 'skills')) -Directory)

if ($ProjectPath) {
  if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    Say "資料夾不存在:$ProjectPath" 'Red'
    Finish 1
  }
  $ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
  if ($ProjectPath -eq $Kit) {
    Say '選到的是 kit 本身,請改選你的專案資料夾' 'Red'
    Finish 1
  }
  if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath 'sfdx-project.json'))) {
    Say "這個資料夾裡沒有 sfdx-project.json,看起來不是 IoTMart 專案:$ProjectPath" 'Yellow'
    if (-not $Yes) {
      $ans = Read-Host '仍要安裝到這裡嗎?輸入 Y 繼續,其他鍵取消'
      if ($ans -notmatch '^[Yy]') { Say '已取消'; Finish 1 }
    }
  }
  Say "安裝到專案:$ProjectPath" 'Cyan'

  foreach ($f in 'AGENTS.md', 'CLAUDE.md', 'GEMINI.md', 'GIT_GUIDE.md', 'skills-lock.json', 'salesforce-mcp-config.json') {
    Install-Copy (Join-Path $Kit $f) (Join-Path $ProjectPath $f) $f
  }
  foreach ($d in 'routing.md', 'knowledge', 'playbooks', 'skills', 'rules') {
    Install-Copy ([IO.Path]::Combine($Kit, '.codex', $d)) ([IO.Path]::Combine($ProjectPath, '.codex', $d)) ".codex/$d"
  }
  Install-IfMissing ([IO.Path]::Combine($Kit, '.codex', 'config.toml')) ([IO.Path]::Combine($ProjectPath, '.codex', 'config.toml')) '.codex/config.toml'
  Install-Copy ([IO.Path]::Combine($Kit, '.gemini', 'styleguide.md')) ([IO.Path]::Combine($ProjectPath, '.gemini', 'styleguide.md')) '.gemini/styleguide.md'
  Install-IfMissing ([IO.Path]::Combine($Kit, '.gemini', 'settings.json')) ([IO.Path]::Combine($ProjectPath, '.gemini', 'settings.json')) '.gemini/settings.json'
  foreach ($s in $SkillDirs) {
    Install-Copy $s.FullName ([IO.Path]::Combine($ProjectPath, '.agents', 'skills', $s.Name)) ".agents/skills/$($s.Name)"
    Install-Copy $s.FullName ([IO.Path]::Combine($ProjectPath, '.claude', 'skills', $s.Name)) ".claude/skills/$($s.Name)"
  }
  Add-GitExclude $ProjectPath @('/AGENTS.md', '/CLAUDE.md', '/GEMINI.md', '/GIT_GUIDE.md', '/skills-lock.json',
    '/salesforce-mcp-config.json', '/.codex', '/.agents', '/.gemini', '/.claude/skills', '/.claude/settings.json')
} else {
  Say '只安裝 skill 到使用者資料夾(所有專案都能用)' 'Cyan'
  foreach ($s in $SkillDirs) {
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.agents', 'skills', $s.Name)) "~/.agents/skills/$($s.Name)"
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.claude', 'skills', $s.Name)) "~/.claude/skills/$($s.Name)"
  }
  $Notes.Add('只裝了 skill:專案規則(AGENTS.md 等)與 sf-skills-overlay.md 沒有安裝;要完整功能請重新執行並選專案資料夾')
}

# Remove legacy kit-installed Codex SF Guard rule if it matches the kit signature.
$legacyRule = [IO.Path]::Combine($UserHome, '.codex', 'rules', 'iotmart-sf-guard.rules')
if (Test-Path $legacyRule) {
  if ((Get-Content $legacyRule -Raw) -match 'IoTMart Salesforce guard rules') { Remove-Item $legacyRule -Force }
}

Say ''
Say '=== 安裝完成 ===' 'Green'
if ($Installed.Count) { Say "已安裝或更新($($Installed.Count)):" 'Green'; $Installed | ForEach-Object { Say "  + $_" } }
if ($Kept.Count) { Say "未變動($($Kept.Count)):"; $Kept | ForEach-Object { Say "  = $_" 'DarkGray' } }
if ($BackedUp.Count) { Say "舊檔已備份到:$Backup" 'Yellow' }
if ($Notes.Count) { Say '注意:' 'Yellow'; $Notes | ForEach-Object { Say "  ! $_" 'Yellow' } }
Say ''
Say '請重新開啟 Codex / Claude Code / Gemini 讓設定生效' 'Cyan'
Finish 0
