# PA MOD Agent 知識庫

本目錄把 `Planetary Annihilation` 的 Modding Wiki（Palobby 存檔）整理成可被 agent 快速調用的工程化知識庫。

## 目標

- 讓 agent 能快速判斷「該做 client mod 還是 server mod」。
- 提供可直接複製的 `modinfo.json` 與資料夾模板。
- 提供從開發、測試到發佈的標準流程，降低反覆踩坑。

## 使用方式（給 agent）

1. 先讀 `catalog.json`，依任務標籤選文件。
2. 讀 `knowledge/*.md` 決策技術路徑與約束。
3. 依需求套用 `templates/*` 作為起始骨架。
4. 按 `workflows/*` 執行實作、驗證、打包與提交。

## 本機路徑（敏感資訊抽換）

- 專案只保存範本：`.agent/env/pa-local.env.example`
- 本機自用檔案：`.agent/env/pa-local.env`（已列入 `.gitignore`）
- 請把 Steam/PA 路徑寫在 `.agent/env/pa-local.env`，再執行部署腳本

## 內容結構

- `catalog.json`：可程式化檢索索引（意圖、關鍵字、路徑）。
- `knowledge/`：核心規範、API 與架構知識。
- `workflows/`：任務導向操作手冊（client UI、server unit、release）。
- `skills/`：可直接調用的專用技能（例如本機固定路徑與部署）。
- `templates/`：可直接複製調整的 MOD 骨架。
- `sources.md`：來源頁面與可追溯連結。

## 注意事項

- 來源 Wiki 為封存內容（頁面顯示 archived date: `2021-09-05`）。
- 新版本遊戲若有變更，請先驗證 `build` 與 API 行為，再發佈。
