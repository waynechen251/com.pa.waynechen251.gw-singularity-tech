# Workflow: 建立 Client UI MOD

## 目標

建立只影響本機體驗的 UI MOD，例：大廳/遊戲聊天提示、面板增強、設定頁擴展。

## 步驟

1. 定義 identifier（例：`com.pa.<handle>.<mod-name>`）。
2. 複製模板：`.agent/templates/client-ui`。
3. 將模板中的 `__MOD_IDENTIFIER__` 換成真實 identifier。
4. 在 `modinfo.json` 更新 `build`、`date`、`version`、`forum`。
5. 依需求編寫 `new_game.js` / `live_game.js` / `settings.js`。
6. 使用場景注入 `scenes` 綁定腳本路徑。
7. 本地安裝至 `client_mods/<identifier>` 測試。

## 實作檢查點

- `modinfo.json` 是合法 JSON。
- `context` 必須是 `client`。
- `category` 包含 `ui`，依遊戲版本加 `titans`/`classic`。
- `scenes` 中 `coui://` 路徑與檔案實際位置一致。

## 常見失敗

- 檔案路徑大小寫不一致造成場景不載入。
- 在錯誤場景注入導致 `model` 結構不存在。
- JSON 有尾逗號或格式錯誤導致無法辨識為 mod。
