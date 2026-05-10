# 新單位 Recipes (可貼上的片段)

> 資料源:Palobby Wiki + 本機 PA 抽樣 + 社群 mod 範例
> 抽樣日期:2026-05-09
> 適用對象:已決定要做新單位、想直接套模板者。

每個 recipe 給「適用情境 → 檔案 → 片段 → 注意事項」四段。檔案路徑都是 mod 內相對路徑。

---

## R1. 克隆既有單位 (策略 A:純複製)

### 適用情境

想做某既有單位的「精英版 / 快速版 / 變體」,完全復用模型與動畫,只改 ID 與少量數值。

[CONFIDENCE: WIKI]

### 檔案

```
server_mods/com.example.heavy-bot-mk2/
├── modinfo.json
└── pa/units/land/heavy_bot_mk2/
    └── heavy_bot_mk2.json
```

### 片段

`modinfo.json`:

```json
{
  "context": "server",
  "identifier": "com.example.heavy-bot-mk2",
  "display_name": "Heavy Bot Mk2",
  "description": "Heavy Bot 的進化版,HP 與射程強化。",
  "author": "<your handle>",
  "version": "0.1.0",
  "build": "<本機 PA build,例 122530>",
  "date": "2026-05-09",
  "signature": "heavybotmk2-init",
  "category": ["units", "classic"],
  "forum": "<URL>"
}
```

`pa/units/land/heavy_bot_mk2/heavy_bot_mk2.json`:

```json
{
  "base_spec": "/pa/units/land/bot_heavy/bot_heavy.json",
  "display_name": "Heavy Bot Mk2",
  "description": "強化版 Heavy Bot。",
  "max_health": 1600,
  "build_metal_cost": 1200,
  "unit_types": [
    "UNITTYPES_Mobile",
    "UNITTYPES_Land",
    "UNITTYPES_Bot",
    "UNITTYPES_Advanced"
  ],
  "tools": [
    {
      "record_index": 0,
      "weapon": {
        "max_range": 130,
        "rate_of_fire": 1.5
      }
    }
  ]
}
```

### 注意事項

- `base_spec` 直接指向**既有單位 JSON**(不是 unit_types/*),自動繼承模型、動畫、tools 結構等
- `tools[]` 用 `record_index` 對齊既有槽位,只覆寫要改的欄位
- `unit_types[]` **要完整重列**(不繼承合併),否則工廠看不到
- `display_name` 不可與既有單位完全相同,否則 build bar 會混淆

---

## R2. 把新單位掛入既有工廠

### 適用情境

新單位的 `unit_types[]` 已含工廠 `buildable_types` 運算式所需的標籤,但工廠運算式沒有匹配條件 (例如新增了自訂 tag `UNITTYPES_Custom1`)。

[CONFIDENCE: WIKI]

### 檔案

兩種做法擇一:

**方式 A (推薦)**:不動工廠,新單位自己選擇匹配既有 tag。

`pa/units/land/heavy_bot_mk2/heavy_bot_mk2.json` 的 `unit_types[]`:

```json
{
  "unit_types": [
    "UNITTYPES_Mobile",
    "UNITTYPES_Land",
    "UNITTYPES_Bot",
    "UNITTYPES_Advanced"
  ]
}
```

只要進階機器人工廠的 `buildable_types` 包含 `UNITTYPES_Bot & UNITTYPES_Advanced`,新單位自動出現在 build bar。

**方式 B**:override 工廠,加新自訂 tag 入運算式。

`pa/units/land/factory_bot_advanced/factory_bot_advanced.json`:

```json
{
  "buildable_types": "UNITTYPES_Mobile & UNITTYPES_Land & UNITTYPES_Bot & UNITTYPES_Advanced | UNITTYPES_Custom1"
}
```

> ⚠ 方式 B 會與其他改同工廠的 mod 衝突。**先確認本機原始運算式內容**(從 `media/pa/units/land/factory_bot_advanced/factory_bot_advanced.json` 抓),再加上你的條件,不要憑空亂寫。

### 注意事項

- buildable_types 是**字串運算式**,不是字串陣列
- 改了工廠運算式記得在 mod 的 `category` 加 `"units"`
- AI 是否會選用新單位另外取決於 AI build templates,本 recipe 不涵蓋

---

## R3. 圖示與在地化掛點

### 適用情境

新單位需要自訂 strategic icon、build icon、或多語顯示名稱。

[CONFIDENCE: COMMUNITY-TOOL]

### 檔案結構

通常需要 server mod + companion client mod:

```
server_mods/com.example.heavy-bot-mk2/
└── (上述 R1 / R2)

client_mods/com.example.heavy-bot-mk2-client/
├── modinfo.json
└── pa/effects/specs/strategic_icons/
    └── heavy_bot_mk2.png       # 戰略視圖 icon
```

### 片段

server mod 的 `modinfo.json` 加 `companions[]`:

```json
{
  "companions": ["com.example.heavy-bot-mk2-client"]
}
```

client mod 的 `modinfo.json`:

```json
{
  "context": "client",
  "identifier": "com.example.heavy-bot-mk2-client",
  "display_name": "Heavy Bot Mk2 (Client)",
  "category": ["units"],
  "...": "..."
}
```

server unit JSON 內的 icon 引用 (示意,實際路徑需以本機驗):

```json
{
  "selection_icon": {
    "size": 30,
    "filename": "/pa/effects/specs/strategic_icons/heavy_bot_mk2.png"
  }
}
```

### 在地化字串

PA 的 client UI 會把 unit JSON 的 `display_name` / `description` 直接顯示。多語化做法:

- 在 client mod 內 override `ui/main/main/strings/<lang>.json` 把 unit display_name 替換成翻譯字串
- 或在 unit JSON 直接寫 i18n key (例 `!LOC:heavy_bot_mk2_name`),client strings 表對應 key 提供翻譯

> ⚠ i18n key 機制 Wiki 未明確記載,需以本機現有多語 mod 範例驗證。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

### 注意事項

- companion client mod 的 identifier 必須**對應**到 server modinfo 的 `companions[]`
- strategic_icon 通常是 PNG,與單位 papa 不同 (icon 是 client 資源)
- icon 路徑大小寫敏感

---

## 相關文件

- 完整流程:[workflows/create-new-unit-mod.md](../workflows/create-new-unit-mod.md)
- 標籤系統詳解:[knowledge/unit-types-and-buildable.md](../knowledge/unit-types-and-buildable.md)
- JSON 骨架:[samples/units/_new-unit-skeleton.md](../samples/units/_new-unit-skeleton.md)
- 數值調整片段:[cookbook/unit-balance-tweaks.md](./unit-balance-tweaks.md)
