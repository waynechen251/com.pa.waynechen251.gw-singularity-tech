# Patterns: PA Galactic War Debug

## 1) Scene 已注入但功能沒生效

- Evidence:
  - log 顯示 `gw_force_first_pick.js loaded`。
  - 同時出現 `Script error for: pages/gw_start/gw_dealer`。
- Interpretation:
  - 注入成功，錯在注入後執行（常見為 require 方式/時機）。
- Fix direction:
  - 優先 `requireGW(['pages/gw_start/gw_dealer'], ...)`。
  - 在非 GW loader 環境才 fallback 到 `require(...)`。

## 2) 卡片覆寫檔存在，但抽卡結果不對

- Checkpoints:
  - 覆寫檔位於 `ui/main/game/galactic_war/cards/<card-id>.js`。
  - `card-id` 與目標原卡一致（例如 `gwc_damage_bots`）。
  - 抽卡列表元素型態可能是字串或物件，需同時處理。
- Fix direction:
  - 對 `list[i]` 取 id 時支援兩種格式。
  - 強制插入卡片時維持原結構（字串或 `{id: ...}`）。

## 3) MOD 已啟用但讀不到檔案

- Evidence:
  - `Error reading ... client_mods ... : 3`
  - `Unable to find path ...`
- Interpretation:
  - 部署到錯誤目錄、identifier 不一致、或資料夾不存在。
- Fix direction:
  - 用 env 檔統一路徑，部署後核對目標資料夾與 `modinfo.identifier`。

## 4) 多個舊版 MOD 殘留

- Evidence:
  - `client_mods` 下同時存在多個舊 identifier。
- Interpretation:
  - 可能載入到非預期版本或造成行為衝突。
- Fix direction:
  - 清掉舊版，只保留一個目標 identifier，完整重啟遊戲。
