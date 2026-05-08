# Workflow: 測試、打包與發佈

## 1) 本地驗證

- 確認 mod 出現在 Community Mods 的 Installed 分頁。
- 檢查 client/server log 無持續錯誤。
- 驗證 `date` 與 `version` 已更新。
- 無法排查時可用 `--nomods` 排除干擾。

## 2) 打包

- 產生 ZIP，根層包含 `modinfo.json` 與 mod 檔案。
- 僅打包必要檔（可用 `.gitattributes export-ignore` 排除）。
- 不可把下載頁連結當安裝 URL，需 direct zip URL。

## 3) 發佈

- 建立論壇貼文，並把論壇 URL 寫入 `modinfo.json#forum`。
- 建議使用 GitHub release/static URL 供自動更新。
- 提交到社群審核流程（Discord #mod-submissions）。

## 4) 更新策略

- 不改 `identifier` 與 ZIP URL，可讓既有安裝自動更新。
- 每次更新同步調整 `date`、`version`。
- 釋出說明貼在論壇與討論串，便於追蹤差異。
