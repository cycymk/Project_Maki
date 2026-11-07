# Project Maki · 淡水柴柴小鎮

操控柴犬 Maki，從家裡出發走進以新北市淡水為原型的小鎮。日夜、四季、天氣跟著真實時間變化。

## 第一次在這台電腦上設定

**第一台電腦**（建立 GitHub repo）：

1. 把整個資料夾放在 `D:\AI_Project\Project_Maki`
2. 在資料夾裡開 PowerShell：
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -Public
   ```
   手機測試網址：https://cycymk.github.io/Project_Maki/

**其他電腦**：

```powershell
winget install GitHub.cli
gh auth login
gh repo clone cycymk/Project_Maki D:\AI_Project\Project_Maki
cd D:\AI_Project\Project_Maki
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

## 常用

| 要做什麼 | 指令 |
|---|---|
| 本機開發 | `npm run dev` |
| 手機在同一個 Wi-Fi 測試 | `npm run dev:lan` |
| 跑測試 | `npm test` |
| 開新任務給 agent | `.\scripts\new-task.ps1 -Agent codex -Issue 12 -Slug grass-lod` |
| 清掉已合併的任務 | `.\scripts\cleanup-worktrees.ps1` |

規劃看 [docs/PLAN.md](docs/PLAN.md)，日常操作看 [docs/WORKFLOW.md](docs/WORKFLOW.md)，AI agent 的規則在 [AGENTS.md](AGENTS.md)。

## 操作

WASD 移動 · Shift 跑 · 空白鍵跳 · E 汪 · 右鍵拖曳轉鏡頭 · 滾輪縮放 · R 重設鏡頭 · H 隱藏介面
手機：左下搖桿、右下跳與汪、兩指拖曳轉鏡頭、兩指捏合縮放。遊戲右上角的蟲子圖示可以直接回報問題。
