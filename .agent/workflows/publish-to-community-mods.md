# Workflow: 上架到 In-game Community Mods 與自動化邊界

> 對象：第一次要把 PA 模組推到「遊戲內 Community Mods 頁面」的開發者。
> 目的：把流程拆成可執行的步驟，並明確指出哪些段落能自動化、哪些是人工瓶頸。

## 1) In-game Community Mods 機制

- 遊戲內 Community Mods 頁面顯示的是**社群維護的策展清單**，不是任何人上傳就會出現。
- 清單條目指向每個 mod 的 `modinfo.json` 與下載 ZIP URL。
- 玩家點安裝 → 抓 ZIP → 解壓到 `client_mods/<identifier>/` 或 `server_mods/<identifier>/`。
- **自動更新**依賴：`identifier` 與 ZIP URL 不變、`date`/`version` 變動即觸發。
- 詳細的 modinfo 欄位規範見 [pa-modding-core.md](../knowledge/pa-modding-core.md)。

## 2) 首次上架完整流程

| # | 步驟 | 動作 | 可否自動化 |
| --- | --- | --- | --- |
| ① | 準備 `modinfo.json` | 必填欄位齊全（`identifier`、`signature`、`version`、`date`、`forum` 等） | ✅ 模板生成（見 [pa-conversational-mod-template](../skills/pa-conversational-mod-template/SKILL.md)） |
| ② | 打包 ZIP | 根層含 `modinfo.json`，排除 `src` 與設計檔（`.gitattributes export-ignore`） | ✅ CI 腳本 |
| ③ | 取得穩定 ZIP URL | **推薦 GitHub Release，固定 asset 檔名** | ✅ CI 腳本 |
| ④ | 建立論壇貼文 | 貼到 PA 官方論壇，URL 寫回 `modinfo.json#forum` 後重打 ZIP | ⚠️ 半自動（首次人工） |
| ⑤ | 提交 Discord `#mod-submissions` | 附 modinfo 與 ZIP URL，等社群審核 | ❌ 人工 |
| ⑥ | 社群維護者把條目加到 mod list | 由策展團隊操作 | ❌ 人工 |
| ⑦ | 出現在 in-game Community Mods | 玩家可在 Available 分頁安裝 | — |

提交前的本地驗證流程（含 `--nomods` 排除干擾）見 [test-package-release.md](./test-package-release.md)。

## 3) 後續更新流程（高度可自動化）

**關鍵洞見：identifier + ZIP URL 不變的前提下，後續更新可 100% 自動化。**

- 只需：bump `date`、`version` → 重打 ZIP → 上傳到「同一 release asset URL」。
- 既有安裝在玩家下次啟動遊戲時自動更新。
- 不需重新提交 Discord、不需改 community list。

## 4) 自動化邊界一頁速查

```
首次上架     ── 人工瓶頸：Discord 審核 + 加進策展清單
後續每次更新 ── 全自動：CI 重打 ZIP + 覆蓋同一 release asset URL
本機開發測試 ── 已有 deploy-mod.ps1（見 pa-local-steam-paths skill）
```

## 5) 給新手的務實建議

- **第一次上架先別投資 CI**。先把人工流程跑過一遍（特別是論壇貼文與 Discord 提交），理解卡點與審核風格。
- **stable ZIP URL 直接用 GitHub Release**。避免之後換 URL 導致既有安裝斷更新。
- **首次提交前**用 [pa-local-steam-paths](../skills/pa-local-steam-paths/SKILL.md) 的 `deploy-mod.ps1` 在本機驗證；遊戲端用 `--nomods` 排查干擾。
- **上架成功後**才投資 CI 自動化「打包 + 發 release」這段，ROI 最高。
- 不要把下載頁連結當安裝 URL，社群清單需要 **direct ZIP URL**。

## 6) 後續可選自動化（範圍指引）

當你決定要做 CI 時，最值得自動化的範圍依序：

1. 從 git tag 推導 `version`，產生 ZIP，附帶根層 `modinfo.json`。
2. 把產出的 ZIP 上傳到 GitHub Release 的固定 asset 名稱（覆蓋上次 asset）。
3. 同步把 `modinfo.json#date` 設為 release 當天 UTC。
4. （選用）跑 lint：檢查 `identifier` 命名、必填欄位齊全、ZIP 根層結構。

這些都不在本工作流的範疇內，留給實際投入時再規劃。

## 參考來源

- Palobby Wiki 封存頁面（見 [sources.md](../sources.md)）
- 既有打包與發佈工作流：[test-package-release.md](./test-package-release.md)
- modinfo 欄位規範：[pa-modding-core.md](../knowledge/pa-modding-core.md)
