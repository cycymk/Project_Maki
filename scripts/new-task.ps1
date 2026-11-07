<#
  為一張 Issue 建立獨立的分支與 worktree，讓 agent 在裡面工作。
  用法：.\scripts\new-task.ps1 -Agent codex -Issue 12 -Slug grass-lod
#>
param(
  [Parameter(Mandatory)][ValidateSet('codex','gemini','claude','human')][string]$Agent,
  [Parameter(Mandatory)][int]$Issue,
  [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Slug
)
$ErrorActionPreference = 'Stop'
$Project = Split-Path -Parent $PSScriptRoot
$Branch  = "agent/$Agent/$Issue-$Slug"
$WtRoot  = Join-Path (Split-Path -Parent $Project) ((Split-Path -Leaf $Project) + '.worktrees')
$Path    = Join-Path $WtRoot "$Agent-$Issue-$Slug"

if (Test-Path $Path) { Write-Host "已存在：$Path" -ForegroundColor Yellow; Set-Location $Path; return }
New-Item -ItemType Directory -Force $WtRoot | Out-Null

git -C $Project fetch origin --prune
$remote = git -C $Project ls-remote --heads origin $Branch
$local  = git -C $Project branch --list $Branch
if ($local)      { git -C $Project worktree add $Path $Branch }
elseif ($remote) { git -C $Project worktree add --track -b $Branch $Path "origin/$Branch" }   # 另一台電腦開過的任務
else             { git -C $Project worktree add -b $Branch $Path origin/main }

Push-Location $Path
npm install --no-audit --no-fund
Pop-Location

$ErrorActionPreference = 'Continue'; gh issue edit $Issue --add-label "agent:$Agent" *> $null

Write-Host ''
Write-Host "分支：$Branch" -ForegroundColor Green
Write-Host "資料夾：$Path" -ForegroundColor Green
Write-Host ''
Write-Host '啟動 agent：' -ForegroundColor Cyan
Write-Host "  cd `"$Path`""
Write-Host "  $Agent"
Write-Host "然後貼上 docs/WORKFLOW.md 最後那段開場白，把 #$Issue 填進去。"
