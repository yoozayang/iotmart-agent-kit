# IoTMart Agent Kit installer (Windows PowerShell 5.1+ / PowerShell 7).
# Copies the kit into a project and/or the user profile. No git, admin rights or symlinks needed.
# Started by install-windows.cmd; safe to run again to update (changed files are backed up first).
#
#   -ProjectPath <dir>  install rules + skills into this project (skips the project menu)
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

# --- Windows path checks -----------------------------------------------------
# Windows PowerShell 5.1 (.NET Framework) cannot open paths of 260+ characters; PowerShell 7 can.
$MaxPath = if ($PSVersionTable.PSEdition -eq 'Desktop') { 259 } else { 32000 }

# Longest file path inside the kit, relative to the kit root (".git" excluded). Skills keep the
# same relative path when copied (.agents/skills -> .claude/skills has the same length).
function Get-KitMaxRelativeLength {
  $max = 0
  Get-ChildItem -LiteralPath $Kit -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
    ForEach-Object { $len = $_.FullName.Length - $Kit.Length; if ($len -gt $max) { $max = $len } }
  return $max
}

# Stop before copying anything when the files would not fit under the path limit.
function Assert-PathFits([string]$root, [string]$what) {
  $need = $root.TrimEnd('\', '/').Length + $KitMaxRel
  $backupNeed = $Backup.Length + 21 + $KitMaxRel   # "\home\.claude\skills" prefix in the backup
  if ($need -le $MaxPath -and $backupNeed -le $MaxPath) { return }
  Say "$what 的路徑太長:$root" 'Red'
  Say "  最長的檔案路徑會有 $([Math]::Max($need, $backupNeed)) 個字元,Windows PowerShell 最多只能處理 $MaxPath 個字元" 'Red'
  Say "  請把資料夾移到較短的位置(例如 $(Join-Path $UserHome 'Development'))後再執行" 'Yellow'
  Finish 1
}

# A git clone on Windows without core.longpaths leaves long-path files unchecked-out, with only a
# warning. Installing from such a kit would silently copy an incomplete set of skills.
function Assert-KitComplete {
  if (-not (Test-Path -LiteralPath (Join-Path $Kit '.git'))) { return }
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return }
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { $missing = @(& git -C $Kit diff --name-only --diff-filter=D HEAD 2>$null) } finally { $ErrorActionPreference = $prev }
  if ($missing.Count -eq 0) { return }
  Say "kit 不完整:有 $($missing.Count) 個檔案沒有被 git 取出(通常是 Windows 路徑長度限制造成)" 'Red'
  Say "請在 kit 資料夾($Kit)開命令列執行下面兩行,再重新執行安裝:" 'Yellow'
  Say '  git config core.longpaths true'
  Say '  git restore --source=HEAD --staged --worktree :/'
  Finish 1
}

# --- Project folder lookup ---------------------------------------------------
# An IoTMart project is a folder whose sfdx-project.json mentions IoTMart ("name": "Adv--IoTMartDev").
function Test-IoTMartProject([string]$dir) {
  $f = Join-Path $dir 'sfdx-project.json'
  if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { return $false }
  try { return [bool]((Get-Content -LiteralPath $f -Raw) -match 'IoTMart') } catch { return $false }
}

# Folders holding sfdx-project.json at most $depth levels below $dir.
function Find-SfdxFolders([string]$dir, [int]$depth) {
  if (-not (Test-Path -LiteralPath $dir -PathType Container)) { return @() }
  return @(Get-ChildItem -LiteralPath $dir -Filter 'sfdx-project.json' -File -Recurse -Depth $depth -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|\.sf|\.sfdx|\.iotmart-agent-kit-backup)\\' -and $_.DirectoryName -ne $Kit } |
    ForEach-Object { $_.DirectoryName })
}

# Look for IoTMart projects in the usual places: folders in the user profile (Documents, Development,
# source\repos, OneDrive, ...) and the top of every local drive. Skips AppData and system folders.
function Find-IoTMartProjects {
  $found = New-Object System.Collections.Generic.List[string]
  $roots = New-Object System.Collections.Generic.List[object]
  Get-ChildItem -LiteralPath $UserHome -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '^(AppData|\..*)$' -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
    ForEach-Object { $roots.Add(@($_.FullName, 3)) }
  if ($OnWindows -and -not $env:IOTMART_KIT_HOME) {
    $skip = '^(Windows|Users|ProgramData|Program Files.*|\$.*|System Volume Information|Recovery|PerfLogs)$'
    foreach ($drive in [IO.DriveInfo]::GetDrives()) {
      if ($drive.DriveType -ne 'Fixed' -or -not $drive.IsReady) { continue }
      Get-ChildItem -LiteralPath $drive.RootDirectory.FullName -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch $skip -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
        ForEach-Object { $roots.Add(@($_.FullName, 2)) }
    }
  }
  foreach ($r in $roots) {
    foreach ($dir in (Find-SfdxFolders $r[0] $r[1])) {
      if ((Test-IoTMartProject $dir) -and -not $found.Contains($dir)) { $found.Add($dir) }
    }
  }
  return ,$found.ToArray()
}

function Show-FolderPicker {
  if ($OnWindows) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = '選擇 IoTMart 專案資料夾(裡面有 sfdx-project.json 的那一層)'
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.SelectedPath }
    return ''
  }
  return (Read-Host '輸入專案資料夾路徑(直接 Enter = 回到選單)').Trim().Trim('"').Trim("'")
}

# Exactly one project found: use it without asking. Several: pick a number. None (or another
# location): paste the path, Enter opens the folder dialog, S = skills only (returns '').
function Select-ProjectFolder {
  Say '正在尋找電腦裡的 IoTMart 專案資料夾...'
  $found = Find-IoTMartProjects
  if ($found.Count -eq 1) {
    Say "找到專案資料夾:$($found[0])" 'Cyan'
    return $found[0]
  }
  Say ''
  if ($found.Count -gt 1) {
    Say '找到多個 IoTMart 專案資料夾,請輸入要安裝的編號:' 'Cyan'
    for ($i = 0; $i -lt $found.Count; $i++) { Say "  [$($i + 1)] $($found[$i])" }
    Say '  (專案在其他位置時,直接貼上資料夾路徑)'
  } else {
    Say '沒有自動找到 IoTMart 專案資料夾(專案可能放在其他位置)' 'Yellow'
    Say '請貼上專案資料夾路徑(裡面有 sfdx-project.json 的那一層)'
  }
  Say '  直接按 Enter = 跳出選擇資料夾視窗;輸入 S = 只安裝 skill 到使用者資料夾'
  while ($true) {
    $ans = "$(Read-Host '請輸入')".Trim().Trim('"').Trim("'")
    if ($ans -match '^\d+$' -and [int]$ans -ge 1 -and [int]$ans -le $found.Count) { return $found[[int]$ans - 1] }
    if ($ans -match '^[Ss]$') { return '' }
    if ($ans -eq '') {
      $picked = Show-FolderPicker
      if ($picked) { return $picked }
      Say '沒有選資料夾,請重新輸入' 'Yellow'
      continue
    }
    if (Test-Path -LiteralPath $ans -PathType Container) { return $ans }
    Say "找不到這個資料夾:$ans,請重新輸入" 'Yellow'
  }
}

# A common mistake is picking the parent folder (e.g. IoTMart3.0 instead of IoTMart3.0\IoTMart 3.0).
# When the chosen folder has no sfdx-project.json but projects sit up to two levels below: use the
# only one, or ask which one when there are several.
function Resolve-ProjectFolder([string]$path) {
  if (Test-Path -LiteralPath (Join-Path $path 'sfdx-project.json')) { return $path }
  $inner = @(Find-SfdxFolders $path 1)
  if ($inner.Count -eq 0) { return $path }
  if ($inner.Count -eq 1) {
    Say "這個資料夾裡沒有 sfdx-project.json,改用裡面的專案資料夾:$($inner[0])" 'Yellow'
    return $inner[0]
  }
  if ($Yes) { return $path }
  Say '這個資料夾裡沒有 sfdx-project.json,但裡面有多個專案資料夾,請輸入要安裝的編號:' 'Yellow'
  for ($i = 0; $i -lt $inner.Count; $i++) { Say "  [$($i + 1)] $($inner[$i])" }
  while ($true) {
    $ans = "$(Read-Host '請輸入')".Trim()
    if ($ans -match '^\d+$' -and [int]$ans -ge 1 -and [int]$ans -le $inner.Count) { return $inner[[int]$ans - 1] }
    Say '看不懂這個選項,請重新輸入' 'Yellow'
  }
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

Assert-KitComplete
$KitMaxRel = Get-KitMaxRelativeLength
Assert-PathFits $Kit 'kit 資料夾'

if (-not $ProjectPath -and -not $SkillsOnly) {
  $ProjectPath = Select-ProjectFolder
  Say ''
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
  $ProjectPath = Resolve-ProjectFolder $ProjectPath
  Assert-PathFits $ProjectPath '專案資料夾'
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
  foreach ($d in 'routing.md', 'knowledge', 'playbooks', 'skills') {
    Install-Copy ([IO.Path]::Combine($Kit, '.codex', $d)) ([IO.Path]::Combine($ProjectPath, '.codex', $d)) ".codex/$d"
  }
  Install-IfMissing ([IO.Path]::Combine($Kit, '.codex', 'config.toml')) ([IO.Path]::Combine($ProjectPath, '.codex', 'config.toml')) '.codex/config.toml'
  Install-Copy ([IO.Path]::Combine($Kit, '.gemini', 'styleguide.md')) ([IO.Path]::Combine($ProjectPath, '.gemini', 'styleguide.md')) '.gemini/styleguide.md'
  Install-IfMissing ([IO.Path]::Combine($Kit, '.gemini', 'settings.json')) ([IO.Path]::Combine($ProjectPath, '.gemini', 'settings.json')) '.gemini/settings.json'
  foreach ($s in $SkillDirs) {
    Install-Copy $s.FullName ([IO.Path]::Combine($ProjectPath, '.agents', 'skills', $s.Name)) ".agents/skills/$($s.Name)"
    Install-Copy $s.FullName ([IO.Path]::Combine($ProjectPath, '.claude', 'skills', $s.Name)) ".claude/skills/$($s.Name)"
  }
  # Claude Code prefers a personal skill over a project skill of the same name, so copies left by an
  # earlier "skills only" install would hide the new project version: update the ones that exist.
  Assert-PathFits $UserHome '使用者資料夾'
  foreach ($s in $SkillDirs) {
    foreach ($tool in '.agents', '.claude') {
      $dst = [IO.Path]::Combine($UserHome, $tool, 'skills', $s.Name)
      if (Test-Path -LiteralPath $dst) { Install-Copy $s.FullName $dst "~/$tool/skills/$($s.Name)" }
    }
  }
  Add-GitExclude $ProjectPath @('/AGENTS.md', '/CLAUDE.md', '/GEMINI.md', '/GIT_GUIDE.md', '/skills-lock.json',
    '/salesforce-mcp-config.json', '/.codex', '/.agents', '/.gemini', '/.claude/skills', '/.claude/settings.json')
} else {
  Assert-PathFits $UserHome '使用者資料夾'
  Say '只安裝 skill 到使用者資料夾(所有專案都能用)' 'Cyan'
  foreach ($s in $SkillDirs) {
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.agents', 'skills', $s.Name)) "~/.agents/skills/$($s.Name)"
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.claude', 'skills', $s.Name)) "~/.claude/skills/$($s.Name)"
  }
  $Notes.Add('只裝了 skill:專案規則(AGENTS.md 等)與 sf-skills-overlay.md 沒有安裝;要完整功能請重新執行並選專案資料夾')
}

# Legacy SF Guard cleanup (the guard was removed). Only files carrying the kit's signature are touched.
$legacyRule = [IO.Path]::Combine($UserHome, '.codex', 'rules', 'iotmart-sf-guard.rules')
if (Test-Path -LiteralPath $legacyRule) {
  if ((Get-Content -LiteralPath $legacyRule -Raw) -match 'IoTMart Salesforce guard rules') { Remove-Item -LiteralPath $legacyRule -Force }
}
if ($ProjectPath) {
  $projectRule = [IO.Path]::Combine($ProjectPath, '.codex', 'rules', 'sf-guard.rules')
  if ((Test-Path -LiteralPath $projectRule) -and -not (Test-IsLink ([IO.Path]::Combine($ProjectPath, '.codex'))) -and
      ((Get-Content -LiteralPath $projectRule -Raw) -match 'IoTMart Salesforce guard rules')) {
    $bk = Get-BackupPath '.codex/rules/sf-guard.rules'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bk) | Out-Null
    Move-Item -LiteralPath $projectRule -Destination $bk -Force
    $BackedUp.Add('.codex/rules/sf-guard.rules')
    $rulesDir = Split-Path -Parent $projectRule
    if (-not (Get-ChildItem -LiteralPath $rulesDir -Force)) { Remove-Item -LiteralPath $rulesDir -Force }
  }
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
