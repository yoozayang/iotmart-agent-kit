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
  if (-not $Yes -and -not $env:IOTMART_AGENT_KIT_LAUNCHER) { [void](Read-Host 'Press Enter to close') }
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
    if (Test-IsLink $dst) { $Kept.Add("$label (symbolic link; left unchanged)"); return }
    if ((Get-TreeHash $src) -eq (Get-TreeHash $dst)) { $Kept.Add("$label (already up to date)"); return }
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
  if (Test-Path -LiteralPath $dst) { $Kept.Add("$label (already exists; kept)"); return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item -LiteralPath $src -Destination $dst -Force
  $Installed.Add($label)
}

# Merge Claude permissions: keep everything already there, add the kit's ask/deny rules.
function Merge-ClaudeSettings([string]$src, [string]$dst, [string]$label) {
  if (-not (Test-Path -LiteralPath $dst)) { Install-IfMissing $src $dst $label; return }
  if (Test-IsLink $dst) { $Kept.Add("$label (symbolic link; left unchanged)"); return }
  try {
    $cur = Get-Content -LiteralPath $dst -Raw -Encoding UTF8 | ConvertFrom-Json
  } catch {
    $alt = Join-Path (Split-Path -Parent $dst) 'settings.iotmart.json'
    Copy-Item -LiteralPath $src -Destination $alt -Force
    $Notes.Add("$label could not be parsed, so permissions were not merged. Kit permissions were saved as settings.iotmart.json for manual review.")
    return
  }
  $kit = Get-Content -LiteralPath $src -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $cur.PSObject.Properties['permissions']) {
    $cur | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{})
  }
  $changed = $false
  foreach ($key in 'ask', 'deny') {
    $have = @()
    if ($cur.permissions.PSObject.Properties[$key]) { $have = @($cur.permissions.$key) }
    $merged = @($have + @($kit.permissions.$key) | Where-Object { $_ } | Select-Object -Unique)
    if ($merged.Count -ne $have.Count) { $changed = $true }
    if ($cur.permissions.PSObject.Properties[$key]) { $cur.permissions.$key = $merged }
    else { $cur.permissions | Add-Member -NotePropertyName $key -NotePropertyValue $merged }
  }
  if (-not $changed) { $Kept.Add("$label (kit permissions already present)"); return }
  $bk = Get-BackupPath $label
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bk) | Out-Null
  Copy-Item -LiteralPath $dst -Destination $bk -Force
  $BackedUp.Add($label)
  $json = $cur | ConvertTo-Json -Depth 20
  [IO.File]::WriteAllText($dst, $json, (New-Object Text.UTF8Encoding($false)))
  $Installed.Add("$label (kit permissions merged)")
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
  $Installed.Add('.git/info/exclude (keeps agent files out of company repository changes)')
}

# ---------------------------------------------------------------------------

if ($OnWindows) {
  # Files from a downloaded zip are marked as "from the internet"; clear that so they run normally.
  try { Get-ChildItem -LiteralPath $Kit -Recurse -File | Unblock-File } catch {}
}

if (-not (Test-Path -LiteralPath (Join-Path $Kit 'AGENTS.md'))) {
  Say 'AGENTS.md was not found. Extract the entire ZIP archive, then run the installer from the extracted folder.' 'Red'
  Finish 1
}

Say ''
Say '=== IoTMart Agent Kit Installer ===' 'Cyan'
Say "Source: $Kit"
Say ''

if (-not $ProjectPath -and -not $SkillsOnly) {
  Say 'Choose your IoTMart project root in the folder picker.'
  Say '  - Select the folder that contains sfdx-project.json.'
  Say '  - Cancel to install skills in your user profile only.'
  Say ''
  if ($OnWindows) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Select your IoTMart project root (the folder containing sfdx-project.json). Cancel installs user-level skills only.'
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $ProjectPath = $dialog.SelectedPath }
  } else {
    $ProjectPath = (Read-Host 'Enter your IoTMart project root path (press Enter to install user-level skills only)').Trim().Trim('"').Trim("'")
  }
}

$SkillDirs = @(Get-ChildItem -LiteralPath ([IO.Path]::Combine($Kit, '.agents', 'skills')) -Directory)

if ($ProjectPath) {
  if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    Say "Folder not found: $ProjectPath" 'Red'
    Finish 1
  }
  $ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
  if ($ProjectPath -eq $Kit) {
    Say 'You selected the kit folder. Select your IoTMart project folder instead.' 'Red'
    Finish 1
  }
  if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath 'sfdx-project.json'))) {
    Say "No sfdx-project.json was found in this folder. It may not be an IoTMart project: $ProjectPath" 'Yellow'
    if (-not $Yes) {
      $ans = Read-Host 'Install here anyway? Enter Y to continue; any other key cancels'
      if ($ans -notmatch '^[Yy]') { Say 'Installation cancelled.'; Finish 1 }
    }
  }
  Say "Installing to project: $ProjectPath" 'Cyan'

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
  Merge-ClaudeSettings ([IO.Path]::Combine($Kit, '.claude', 'settings.json')) ([IO.Path]::Combine($ProjectPath, '.claude', 'settings.json')) '.claude/settings.json'
  Add-GitExclude $ProjectPath @('/AGENTS.md', '/CLAUDE.md', '/GEMINI.md', '/GIT_GUIDE.md', '/skills-lock.json',
    '/salesforce-mcp-config.json', '/.codex', '/.agents', '/.gemini', '/.claude/skills', '/.claude/settings.json')
} else {
  Say 'Installing skills to your user profile (available to all projects).' 'Cyan'
  foreach ($s in $SkillDirs) {
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.agents', 'skills', $s.Name)) "~/.agents/skills/$($s.Name)"
    Install-Copy $s.FullName ([IO.Path]::Combine($UserHome, '.claude', 'skills', $s.Name)) "~/.claude/skills/$($s.Name)"
  }
  $Notes.Add('Only skills were installed. Project rules (including AGENTS.md) and sf-skills-overlay.md were not installed. Run the installer again and select your project folder for the complete setup.')
}

# Codex execution rules apply to every project, so they go to the user profile in both modes.
Install-Copy ([IO.Path]::Combine($Kit, '.codex', 'rules', 'sf-guard.rules')) ([IO.Path]::Combine($UserHome, '.codex', 'rules', 'iotmart-sf-guard.rules')) '~/.codex/rules/iotmart-sf-guard.rules'

if ($OnWindows) {
  $Notes.Add('The sf command guard is not available on Windows (bin/sf supports macOS/Linux only). Codex rules and Claude permissions require confirmation for commands that write to an org.')
}

Say ''
Say '=== Installation complete ===' 'Green'
if ($Installed.Count) { Say "Installed or updated ($($Installed.Count)) items:" 'Green'; $Installed | ForEach-Object { Say "  + $_" } }
if ($Kept.Count) { Say "Unchanged ($($Kept.Count)) items:"; $Kept | ForEach-Object { Say "  = $_" 'DarkGray' } }
if ($BackedUp.Count) { Say "Previous files backed up to: $Backup" 'Yellow' }
if ($Notes.Count) { Say 'Notes:' 'Yellow'; $Notes | ForEach-Object { Say "  ! $_" 'Yellow' } }
Say ''
Say 'Restart Codex / Claude Code / Gemini to apply the changes.' 'Cyan'
Finish 0
