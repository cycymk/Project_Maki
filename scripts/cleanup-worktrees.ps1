<#
  清掉已經合併的任務 worktree 與本機分支。每一個都會先問你。
  用法：.\scripts\cleanup-worktrees.ps1
#>
$ErrorActionPreference = 'Continue'
$Project = Split-Path -Parent $PSScriptRoot
git -C $Project fetch origin --prune
$lines = git -C $Project worktree list --porcelain
$items = @(); $cur = @{}
foreach ($l in $lines) {
  if ($l -like 'worktree *') { $cur = @{ path = $l.Substring(9) } }
  elseif ($l -like 'branch *') { $cur.branch = $l.Substring(7) -replace '^refs/heads/',''; $items += $cur }
}
$found = $false
foreach ($w in $items) {
  if ($w.branch -notlike 'agent/*') { continue }
  $merged = gh pr list --head $w.branch --state merged --json number --jq 'length' 2>$null
  if ($merged -ne '0' -and $merged) {
    $found = $true
    $ans = Read-Host "已合併：$($w.branch)`n  $($w.path)`n刪除這個資料夾和本機分支？(Y/N)"
    if ($ans -match '^[Yy]') {
      git -C $Project worktree remove $w.path
      git -C $Project branch -D $w.branch
      Write-Host '  已清除' -ForegroundColor Green
    }
  }
}
if (-not $found) { Write-Host '沒有已合併、可以清除的 worktree。' }
git -C $Project worktree prune
