# Error Taxonomy (PA Log Debugger)

## Priority

1. `high`: 會阻斷模組載入、腳本執行或關鍵資源讀取。
2. `medium`: 不一定阻斷，但高度可能造成功能失效。
3. `info`: 狀態證據，用於判定問題落點。

## Categories

### `module_require_failure` (`high`)

- Typical evidence:
  - `Uncaught Error: Script error for: pages/gw_start/gw_dealer`
- Hypothesis:
  - module 名稱、載入器（`require` vs `requireGW`）或載入時機不正確。
- Fix:
  - 在 GW 場景優先用 `requireGW`，並確認場景注入與 module 路徑一致。

### `resource_404` (`high`)

- Typical evidence:
  - `Failed loading coui://... with 404`
- Hypothesis:
  - `modinfo.json` scenes 與實際檔案路徑不一致，或 identifier/大小寫錯誤。
- Fix:
  - 比對 `ui/mods/<identifier>/...`、`scenes`、檔名大小寫。

### `path_or_permission` (`high`)

- Typical evidence:
  - `ERROR Error reading ... : 3`
  - `Access to the path ... is denied`
  - `Unable to find path: ...`
- Hypothesis:
  - 路徑不存在、設定錯誤或寫入權限不足。
- Fix:
  - 驗證 `PA_DATA_DIR` / `PA_CLIENT_MODS_DIR` / `PA_GAME_DIR`；必要時提權部署。

### `legacy_mod_residue` (`medium`)

- Typical evidence:
  - 舊 identifier 仍在 `client_mods` 下被掃描到。
- Hypothesis:
  - 舊版模組與新版同時存在，造成行為混淆或干擾。
- Fix:
  - 刪除舊版模組目錄，僅保留目標 identifier。

### `javascript_runtime_error` (`medium`)

- Typical evidence:
  - `Uncaught TypeError`
  - `Uncaught ReferenceError`
- Hypothesis:
  - 腳本假設資料結構或 API 一定存在，但實際不成立。
- Fix:
  - 加入 defensive check，確認型別/存在性，再重跑驗證。

### `scene_injection_confirmed` (`info`)

- Typical evidence:
  - `coui://ui/mods/<identifier>/... loaded`
- Hypothesis:
  - 腳本已載入，問題多半在腳本內邏輯或後續 module require。
- Fix:
  - 針對該檔案追查 hook 時機、module 名稱與輸入資料格式。
