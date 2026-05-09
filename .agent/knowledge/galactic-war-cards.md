# Galactic War（GW）卡片 / 內容 Modding

> 資料源：Palobby Wiki + 本機 PA `media/pa/galactic_war/...` 抽樣。
> 用途：玩家想做 GW 卡片、敵人 AI、星系劇情等 GW 內容時的入口知識。
> 抽樣日期：2026-05-09。
> 注意：GW 是單機戰役模式，相關 mod 屬 **client mod**（不影響多人對戰）。

## 1) 什麼是 GW Modding

Galactic War 是 PA 的單機 roguelike 戰役：玩家在星圖上推進、戰鬥取得「卡片」強化指揮官 / 軍隊，遇到 boss 戰役。

可改的內容：

- **卡片（cards）**：給予 buff / 解鎖單位 / 加被動效果。
- **遭遇（encounters）**：星圖上的事件（戰鬥、商人、boss）。
- **劇情 / 文本（inventory texts）**：卡片描述、對話。
- **AI 配方（loadouts）**：敵人指揮官開局單位組。

GW 是 client-only 內容，所以 GW mod 一律 `context: "client"`。

## 2) 主要目錄結構

```
pa/galactic_war/
├── cards/
│   ├── <category>/                    # land / air / sea / orbital / commander / experimental ...
│   │   └── <card_id>.json             # 單張卡片定義
│   └── card_categories.json           # 類別定義
├── ai/
│   └── loadouts/                      # AI 開局配方
├── star_system_descs/                 # 星系敘述
├── encounters/                        # 遭遇定義
└── inventory/
    └── inventory_texts/               # 卡片描述本（i18n）
```

## 3) 卡片 JSON 結構（典型欄位）

```
{
  "id": "card_<unique_id>",
  "name": "卡片顯示名（i18n key 或字串）",
  "description": "卡片描述",
  "category": "<card_category>",       # 對應 card_categories.json
  "tier": 1-3,                          # 階級（影響掉落率與強度）
  "tags": ["land", "tank", ...],
  "icon": "coui://ui/main/galactic_war/img/cards/<icon>.png",

  "effects": [                         # 卡片帶來的修改
    {
      "spec_id": "/pa/units/land/tank_light/tank_light.json",
      "modify": [
        { "op": "mul", "path": "max_health", "value": 1.5 },
        { "op": "add", "path": "navigation.move_speed", "value": 2 }
      ]
    },
    {
      "spec_id": "/pa/units/commanders/imperial_alpha/imperial_alpha.json",
      "modify": [
        { "op": "set", "path": "tools[0].weapon.max_range", "value": 200 }
      ]
    }
  ],

  "unlocks": [                         # 解鎖建造
    "/pa/units/land/tank_heavy/tank_heavy.json"
  ]
}
```

> `op` 常見：`mul`（乘）、`add`（加）、`set`（直接設）、`replace`（替換物件）。實際 op 集合以本機原檔為準。

## 4) 注入方式（mod 內 GW 內容）

GW mod 在 client mod 內，於 `pa/galactic_war/` 路徑覆寫或新增檔案。新增卡片需：

1. 建立 `pa/galactic_war/cards/<category>/<my_card>.json`
2. 在 `card_categories.json` 註冊（若需要新類別）
3. 在 `inventory_texts/<lang>.json` 加描述文本
4. 確保 `unit_types` 與 `tags` 對應現有規則

## 5) 注意事項

- **GW 是單機**：mod 不影響多人對戰，但會被同帳號 GW 存檔影響（mod 改動可能讓既有存檔崩潰）。
- **存檔相容性**：刪除既有卡片可能讓玩家舊存檔遺失資料。新增卡片相對安全。
- **卡片強度平衡**：`tier` 影響掉率，太強的 tier 1 卡片會破壞遊戲節奏。
- **i18n key**：`name` / `description` 可用 `!LOC()` 字串格式對接 `inventory_texts/`。

## 6) 與其他知識的銜接

- 卡片 effect 會引用 unit spec 路徑與欄位 → 查 [unit-spec-fields.md](./unit-spec-fields.md)
- 想做「指揮官 buff 卡」之類的需求 → 配 [zh-unit-terms.md](../glossary/zh-unit-terms.md) 找 commander identifier
- 結構骨架 → [samples/gw-cards/_skeleton.md](../samples/gw-cards/_skeleton.md)

## 7) 常見地雷

- **路徑大小寫**：所有 `spec_id` 必須小寫且存在於遊戲檔內。
- **op 不存在**：用了原版不支援的 `op` 會直接被忽略（不報錯），表現為「卡片沒效果」。
- **circular tags**：在 unit_types 中加循環標籤可能讓 buildable_types 運算式錯亂。
- **語系覆蓋**：用 `inventory_texts/zh.json` 覆寫某 key，但 key 在 `en.json` 不存在 → fallback 失效。
