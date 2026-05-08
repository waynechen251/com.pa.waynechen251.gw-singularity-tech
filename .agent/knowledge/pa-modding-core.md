# PA Modding 核心規範（Agent 版）

## 1) Mod 類型快速判斷

- `client mod`：只影響本機玩家體驗（UI、效果、建造輔助、地圖包）。
- `server mod`：可改單位名單/單位規格，會影響房內所有玩家。
- `companion client mod`：由 server mod 指定，玩家連線時強制掛載。

決策原則：

- 需求涉及 `unit specs` 或多人同步規則 → 優先 `server mod`。
- 需求只改介面、音效、可視化 → 優先 `client mod`。
- server mod 體積過大且含大量 client 資源 → 拆 companion。

## 2) Identifier 命名規範

- 必須唯一，格式為反向網域全小寫：`com.example.mod-name`
- 若沒有網域可用：`com.pa.<handle>.<mod-name>`
- 建議用 `-`，避免 `_`。

## 3) 基本資料夾結構

本地開發安裝路徑（PA Data Directory）：

- `client_mods/<identifier>/...`
- `server_mods/<identifier>/...`

每個 mod 根目錄都必須有 `modinfo.json`。

## 4) modinfo.json 必填欄位

- `author` (string)
- `build` (string)
- `category` (string[])
- `context` (`client` or `server`)
- `date` (`YYYY-MM-DD`, UTC)
- `description` (string)
- `display_name` (string)
- `forum` (string URL)
- `identifier` (string)
- `signature` (non-empty string)
- `version` (`major.minor.revision` 可帶 suffix)

常用選填欄位：

- `dependencies`、`companions`、`framework`
- `github`、`icon`、`priority`
- `scenes`（client UI 注入）
- `titansOnly`、`classicOnly`

## 5) category 建議

常用：`classic`, `titans`, `ui`, `lobby`, `gameplay`, `units`, `maps`, `effects`, `settings`。

避免使用：`mod`, `client`, `server`, `map`, `planets`, `systems` 等泛詞。

## 6) 打包與檔案慣例

- ZIP 根層必須直接包含 `modinfo.json`。
- UI mod 檔案慣例：`ui/mods/<identifier>/<scene>.js`
- 只打包 mod 必要檔案；排除 `src`、設計素材與中間檔。

## 7) 風險與治理

- 不可安裝到遊戲目錄外。
- 不可未經允許變更使用者資料或阻止離場。
- 不可遠端追蹤個資；若要收集資料，僅存最小必要資訊。
- `DisplayName` 可變，不可作唯一識別；識別用 `uberId`。
