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

## 8) Unit Override 路徑慣例（Shadow 機制）

Server mod 改單位數值時，在 mod 內建立**與原檔相同的相對路徑**並覆寫該 JSON：

```
server_mods/<identifier>/
└── pa/units/<class>/<unit_id>/<unit_id>.json    # 與原 media/pa/... 同路徑
```

PA 載入順序：mod 路徑優先於原檔。等於對該 unit JSON 做 shadow override。

**最小 diff 原則**：

- **只寫要改的欄位**，不要整檔複製（原檔變動時不會被洗掉）。
- 對 `tools[]` 之類陣列欄位，需保留 `record_index` 對齊原始槽位。
- 詳細欄位字典見 [unit-spec-fields.md](./unit-spec-fields.md)。

## 9) 衍生知識文件的標頭格式

`.agent/knowledge/`、`.agent/samples/` 內的所有衍生文件，**檔頭必須註明資料源與時間戳**，方便日後判斷是否過時：

```markdown
> 資料源：Palobby Wiki 封存（archived 2021-09-05）+ 本機 PA 抽樣
> 抽樣日期：YYYY-MM-DD
> 注意：PA 仍有更新版本，實際以本機 `media/...` 為準
```

不要把過時的數值當權威，**標時間戳 + 提醒以本機原檔為準** 是底線。

## 10) 結構摘要 vs 完整檔的版權邊界

`.agent/samples/` 目錄存放「結構骨架」（schema outline），**不複製商業遊戲原始 JSON 全文**：

- ✅ 可以列出 unit JSON 的 section 樹、欄位名、合理範圍
- ✅ 可以給「最小 diff patch」範例
- ❌ 不可以整檔複製原始 unit / ammo / GW card JSON 內容
- ❌ 不可以把 PA 內建素材（音訊、貼圖、模型）打包進 repo

工作副本由玩家本機 PA 安裝目錄取得。本 repo 是「導航圖」與「規則手冊」，不是遊戲資產備份。
