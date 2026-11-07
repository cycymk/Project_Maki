# Project Maki 規劃

## 目標

用 GitHub 當唯一的版本來源，讓你在多台電腦上接續同一個專案；Codex 與 Gemini 各自在獨立的分支和資料夾裡工作，互相審查；你在手機上試玩最新版，遇到問題直接在遊戲裡按「回報」開 Issue，Issue 再變成下一輪 agent 的任務。

```
你在手機上試玩 ──按「回報」──▶ GitHub Issue ──貼標籤 agent:codex / agent:gemini──▶
   ▲                                                                            │
   │                                                                  new-task.ps1 開 worktree
   │                                                                            ▼
 自動部署 ◀── 合併 main ◀── 另一個 agent 審查 ◀── CI（build + 測試）◀── agent 開 PR
```

## 架構決定

| 項目 | 選擇 | 原因 |
|---|---|---|
| 版控 | GitHub 公開 repo `cycymk/Project_Maki` | 多台電腦同步、Issue/PR/Actions 都在同一處；公開才能免費用 GitHub Pages |
| 規則檔 | 一份 `AGENTS.md`，其他工具指向它 | Codex、Gemini、Claude 讀到同一套規則，不會漂移 |
| 隔離 | 每個任務一個 git worktree + 分支 | 多個 agent 同時改也不會踩到彼此的檔案 |
| 多 agent 監看 | Windows Terminal 分頁起步；之後用 Herdr | 見下方「Herdr」 |
| 建置 | Vite | 有 dev server 可給手機連；之後拆模組方便 |
| 測試 | Playwright 冒煙測試 + GitHub Actions | agent 改壞時 PR 直接變紅 |
| 手機測試網址 | Cloudflare Pages（推薦）或 GitHub Pages | 見下方「手機測試」 |
| 行尾 | `.gitattributes` 統一 LF | Windows 與 WSL/Mac 混用時避免整檔 diff |

## Herdr

Herdr 是開源的「agent 多工器」：在終端機裡同時開好幾個 AI agent，側邊欄會顯示每一個是在工作、卡住、完成還是閒置。它支援 Codex、Gemini CLI 和 Claude Code，session 斷線後可以重新接上，也能透過 SSH 從遠端連進去。

要注意的是：**Herdr 在 Linux 和 macOS 是正式支援，Windows 還是 beta。**建議的用法：

1. **第一階段**：先不用 Herdr。Windows Terminal 開兩個分頁，一個跑 Codex、一個跑 Gemini，各自在自己的 worktree 裡。先把流程跑順。
2. **第二階段**：同時跑三個以上的 agent、開始常常忘記哪個在等你回覆時，再導入 Herdr。安裝 WSL2（Ubuntu），在 WSL 裡裝 Herdr，用 `herdr integration install codex` / `gemini` 開啟狀態回報。WSL 是 Linux 環境，可以避開 Windows 版 beta 的問題；可以直接開 `/mnt/d/AI_Project/Project_Maki`，但檔案多了以後會比放在 WSL 自己的家目錄慢。
3. **想用手機看 agent 進度**：Herdr 可以透過 SSH 遠端連入，iOS 上的 Moshi 終端機 App 有直接支援 Herdr。這需要你家電腦開 SSH，並且從外面連得到（例如用 Tailscale），屬於進階選項。

## 手機測試

三種方式，由快到完整：

1. **同一個 Wi-Fi，看本機最新改動**：電腦執行 `npm run dev:lan`，終端機會印出 `http://192.168.x.x:5173`，手機打開這個網址。
2. **看已合併的正式版**：每次合併到 `main` 自動部署。
   - **GitHub Pages**：設定最簡單，但**免費帳號的私人 repo 不能用 Pages**，要嘛 repo 公開，要嘛升級付費方案。workflow 已放在 `.github/workflows/deploy-pages.yml`。
   - **Cloudflare Pages（推薦）**：免費、私人 repo 也能用，而且**每個 PR 都會有自己的預覽網址**，可以在合併前就用手機試 agent 的成果。在 Cloudflare 後台連結 GitHub repo，建置指令 `npm run build`，輸出資料夾 `dist`。
3. **回報問題**：遊戲右上角最上面的「回報」按鈕會開啟 GitHub 新 Issue，自動帶入裝置型號、螢幕大小、柴柴所在位置、時間與天氣設定。你只要補上「發生什麼事」和截圖。手機上建議裝 GitHub App 並先登入。

## 多台電腦

- 每台電腦第一次：裝好 Git、Node.js、GitHub CLI 後，執行 `scripts/setup-windows.ps1 -Clone`。
- 換電腦前：把手上的分支 push 上去（`git push`）。worktree 只存在本機，換電腦後用 `new-task.ps1` 重新開同一個 Issue 號碼，它會接上遠端已存在的分支。
- agent 的登入狀態（Codex、Gemini）每台電腦各自登入一次。

## 路線圖

**第 0 階段：建立環境（今天）**
- 在 D 槽建立專案、推上 GitHub、裝好 Codex 與 Gemini CLI
- 設定 Cloudflare Pages 或 GitHub Pages，確認手機能打開

**第 1 階段：拆模組（讓 agent 好協作）**
目前整個遊戲在一個 900 多行的 `index.html`，兩個 agent 同時改一定會衝突。先拆開：
- `src/world/`（地形、道路、河、建築、公園設施）
- `src/env/`（時間、太陽、季節、天氣、風）
- `src/player/`（柴柴模型、移動、碰撞）
- `src/camera.js`、`src/ui/`、`src/shaders/`（草、水）
- Three.js 改用 npm 安裝的版本並固定版本號

**第 2 階段：玩法**
- 走進店裡的室內場景；在老街買阿給、魚丸湯
- 小鎮居民與其他動物（貓、鴿子）
- 收集要素：散落在小鎮的骨頭、明信片
- 存檔（瀏覽器 localStorage）

**第 3 階段：自動化加深（選用）**
- 在 GitHub Actions 加上 AI 自動審查 PR、自動分類新 Issue（Codex 與 Gemini 都有官方的 GitHub Action，需要各自的 API key 放進 repo secrets）
- Herdr 一次跑多個 agent

## 已決定

- repo 公開，手機測試用 GitHub Pages：`https://cycymk.github.io/Project_Maki/`
- 公開 repo 的防護：只有貢獻者能開 Issue/PR（安裝腳本會設定）、agent 只處理你貼過標籤的 Issue、金鑰永遠不進 repo

## 待你決定

- 是否也要讓 Claude Code 參與實作？規則檔已經相容，加進來不用改設定。
