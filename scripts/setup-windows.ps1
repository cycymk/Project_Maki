<#
  Project Maki 環境安裝（Windows）
  用法：在專案資料夾裡開 PowerShell，執行
    powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
  第一台電腦：會建立 GitHub repo 並推上去。
  其他電腦：先 gh repo clone cycymk/Project_Maki D:\AI_Project\Project_Maki，再執行這支，它只會裝工具。
#>
param(
  [string]$Owner = 'cycymk',
  [string]$RepoName = 'Project_Maki',
  [switch]$Public
)
$ErrorActionPreference = 'Stop'
$Project = Split-Path -Parent $PSScriptRoot
Set-Location $Project
Write-Host "專案資料夾：$Project" -ForegroundColor Cyan

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}
function Need($cmd) { -not (Get-Command $cmd -ErrorAction SilentlyContinue) }

# 1. 基本工具
$missing = @()
if (Need git)  { $missing += @{ id='Git.Git';            name='Git' } }
if (Need node) { $missing += @{ id='OpenJS.NodeJS.LTS';  name='Node.js LTS' } }
if (Need gh)   { $missing += @{ id='GitHub.cli';         name='GitHub CLI' } }
if ($missing.Count -gt 0) {
  Write-Host ("缺少：" + (($missing | ForEach-Object { $_.name }) -join '、')) -ForegroundColor Yellow
  if (Need winget) { throw '找不到 winget，請先從 Microsoft Store 安裝「應用程式安裝程式」，或手動安裝上面這些工具。' }
  $ok = Read-Host '要用 winget 安裝嗎？(Y/N)'
  if ($ok -notmatch '^[Yy]') { throw '已取消。請手動安裝後再執行。' }
  foreach ($m in $missing) { winget install --id $m.id -e --source winget --accept-package-agreements --accept-source-agreements }
  Refresh-Path
}

# 2. AI agent CLI
Write-Host '安裝 / 更新 Codex CLI 與 Gemini CLI…' -ForegroundColor Cyan
npm install -g @openai/codex @google/gemini-cli

# 3. GitHub 登入
$ErrorActionPreference = 'Continue'; gh auth status *> $null; $authed = ($LASTEXITCODE -eq 0); $ErrorActionPreference = 'Stop'
if (-not $authed) { gh auth login --web --git-protocol https }

# 4. Git repo
git config --global core.autocrlf false   # 行尾交給 .gitattributes 處理
if (-not (Test-Path (Join-Path $Project '.git'))) {
  git init -b main
  git add -A
  git commit -m "chore: initial Project Maki scaffold" -m "Agent: claude"
  $vis = if ($Public) { '--public' } else { '--private' }
  gh repo create "$Owner/$RepoName" $vis --source . --remote origin --push
  foreach ($l in @(
      @{ n='agent:codex';  c='10a37f'; d='交給 Codex' },
      @{ n='agent:gemini'; c='4285f4'; d='交給 Gemini' },
      @{ n='from-phone';   c='ff9b54'; d='從手機上的回報按鈕開的' })) {
    gh label create $l.n --color $l.c --description $l.d --force | Out-Null
  }
  if ($Public) {
    # 開啟 GitHub Pages（由 Actions 部署），並限制只有曾經貢獻過的人能開 Issue/PR，擋掉陌生人的垃圾留言
    $ErrorActionPreference = 'Continue'
    gh api -X POST "repos/$Owner/$RepoName/pages" -f build_type=workflow *> $null
    gh api -X PUT "repos/$Owner/$RepoName/interaction-limits" -f limit=contributors_only -f expiry=six_months *> $null
    $ErrorActionPreference = 'Stop'
    Write-Host "手機測試網址（第一次部署約 1–2 分鐘）：https://$($Owner.ToLower()).github.io/$RepoName/" -ForegroundColor Green
  }
  Write-Host "已建立 https://github.com/$Owner/$RepoName" -ForegroundColor Green
} else {
  Write-Host '已經是 git repo，略過建立。' -ForegroundColor DarkGray
  git pull --ff-only
}

# 5. 專案相依套件
npm install
npx playwright install chromium

Write-Host ''
Write-Host '完成。接下來：' -ForegroundColor Green
Write-Host '  1. 執行 codex 和 gemini 各一次，照畫面登入'
Write-Host '  2. npm run dev:lan，用同一個 Wi-Fi 的手機打開印出來的網址'
Write-Host '  3. 開第一個任務：.\scripts\new-task.ps1 -Agent codex -Issue 1 -Slug split-modules'
