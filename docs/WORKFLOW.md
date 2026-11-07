# 日常操作手冊

## 開一個新任務

1. 在 GitHub 開 Issue（或用手機上的「回報」按鈕產生的 Issue），貼上標籤 `agent:codex` 或 `agent:gemini`。
2. 在專案資料夾開 PowerShell：

   ```powershell
   .\scripts\new-task.ps1 -Agent codex -Issue 12 -Slug grass-lod
   ```

   這會建立分支 `agent/codex/12-grass-lod` 和資料夾 `D:\AI_Project\Project_Maki.worktrees\codex-12-grass-lod`。

3. 進到那個資料夾啟動 agent，並把 Issue 交給它：

   ```powershell
   cd ..\Project_Maki.worktrees\codex-12-grass-lod
   codex "讀 GitHub Issue #12（gh issue view 12），照 AGENTS.md 的流程完成並開 PR"
   ```

   Gemini 一樣：`gemini` 啟動後輸入同樣的指示。

## 審查 PR

讓另一個 agent 審：

```powershell
gemini "用 gh pr view 15 和 gh pr diff 15 審查這個 PR。檢查是否符合 AGENTS.md、手機操作有沒有壞、效能有沒有退步。用 gh pr review 留下意見。"
```

CI（GitHub Actions）會自動跑 build 和 Playwright 測試，紅燈就退回給原本的 agent 修。

## 合併之後

- 用手機打開部署網址試玩
- 有問題按遊戲右上角的「回報」
- 清掉已合併的 worktree：`.\scripts\cleanup-worktrees.ps1`

## 同時跑兩個 agent

Windows Terminal 開兩個分頁，各自 `cd` 到自己的 worktree。兩個 agent 不會改到同一份檔案，除非兩張 Issue 本身就在改同一個地方。指派前先看一下兩張 Issue 會不會撞到同一個檔案；會的話，排先後順序。

## 給 agent 的固定開場白（可以直接複製）

> 你在 Project Maki 的一個 worktree 裡。先讀 AGENTS.md。任務是 GitHub Issue #__（用 `gh issue view __` 讀）。完成後執行 `npm run build` 和 `npm test`，都通過才 commit、push，並用 `gh pr create` 開 PR，描述照範本填並寫 `Closes #__`。有需要人決定的事就在 Issue 留言問我，不要自己猜。
