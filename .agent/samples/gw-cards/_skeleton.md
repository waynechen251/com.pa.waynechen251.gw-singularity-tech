# GW Card JSON 結構骨架

> **本檔不複製原始 GW 卡片內容**，僅以縮排 outline 描述典型結構。
> 玩家本機可直接從 `media/pa/galactic_war/cards/...` 取實際工作副本。
> 來源：Palobby Wiki + 本機抽樣。
> 抽樣日期：2026-05-09。

## 1) 通用卡片骨架

```
{
  id: "card_<unique>"
  name: "..." 或 "!LOC(card_name_key)"
  description: "..." 或 "!LOC(card_desc_key)"
  category: "<category_id>"             # 來自 card_categories.json
  tier: 1 | 2 | 3
  tags: ["land", "tank", "buff", ...]
  icon: "coui://ui/main/galactic_war/img/cards/<icon>.png"

  effects: [
    {
      spec_id: "/pa/units/<class>/<id>/<id>.json"
      modify: [
        { op: "mul", path: "max_health", value: 1.5 }
        { op: "add", path: "navigation.move_speed", value: 2 }
        { op: "set", path: "tools[0].weapon.max_range", value: 200 }
      ]
    }
  ]

  unlocks: [                            # 可選 — 解鎖建造
    "/pa/units/land/tank_heavy/tank_heavy.json"
  ]

  buffs: [                              # 可選 — 玩家層被動
    { stat: "metal_income_multiplier", value: 1.2 }
  ]
}
```

## 2) 三類典型卡片

### A) 單位 buff 卡（最常見）

```
{
  id: "card_tank_armor_boost"
  category: "land"
  tier: 1
  tags: ["land", "tank", "defense"]
  effects: [
    {
      spec_id: "/pa/units/land/tank_light/tank_light.json"
      modify: [
        { op: "mul", path: "max_health", value: 1.3 }
      ]
    },
    {
      spec_id: "/pa/units/land/tank_medium/tank_medium.json"
      modify: [
        { op: "mul", path: "max_health", value: 1.3 }
      ]
    }
  ]
}
```

### B) 解鎖卡（解鎖更高級單位）

```
{
  id: "card_unlock_advanced_air"
  category: "air"
  tier: 2
  tags: ["air", "unlock"]
  unlocks: [
    "/pa/units/air/factory_air_advanced/factory_air_advanced.json",
    "/pa/units/air/bomber_advanced/bomber_advanced.json"
  ]
}
```

### C) 全局 buff 卡（玩家層被動）

```
{
  id: "card_economy_boost"
  category: "economy"
  tier: 1
  tags: ["economy", "buff"]
  buffs: [
    { stat: "metal_income_multiplier", value: 1.15 }
    { stat: "energy_income_multiplier", value: 1.15 }
  ]
}
```

## 3) Card Categories 骨架（card_categories.json）

```
{
  categories: [
    { id: "land", display_name: "Land", color: "..." }
    { id: "air", display_name: "Air", color: "..." }
    { id: "sea", display_name: "Sea", color: "..." }
    { id: "orbital", display_name: "Orbital", color: "..." }
    { id: "commander", display_name: "Commander", color: "..." }
    { id: "experimental", display_name: "Experimental", color: "..." }
    { id: "economy", display_name: "Economy", color: "..." }
  ]
}
```

## 4) i18n（inventory_texts/<lang>.json）骨架

```
{
  card_<unique>_name: "卡片中文名"
  card_<unique>_desc: "卡片中文描述"
  card_<unique>_flavor: "風味文字"
}
```

## 5) 改 GW 內容的最小變更建議

新增「指揮官 HP +50%」卡片：

1. 建 client mod，identifier 例 `com.pa.you.gw-buff-pack`
2. 路徑 `pa/galactic_war/cards/commander/card_cmdr_hp_boost.json`
3. 內容（依本骨架）
4. 在 `pa/galactic_war/inventory/inventory_texts/zh-tw.json`（或其他語系）加 i18n key
5. mod scenes 不需要注入 .js（純資料覆寫）
6. 部署到 `client_mods/<identifier>/`，啟動 GW 應出現新卡

## 6) 注意事項

- **存檔影響**：增加新卡通常安全，**刪除既有卡** 可能讓舊存檔讀取錯誤。
- **op 行為**：`mul` 用乘法、`add` 用加法、`set` 直接設定。`set` 可能會覆蓋繼承欄位，慎用。
- **路徑大小寫**：所有 `spec_id` 必須與本機原檔大小寫一致。
- **平衡考量**：tier 1 卡片掉率高，太強的 effect 會破壞 GW 節奏。

## 7) 與其他知識銜接

- GW 卡片完整規範 → [knowledge/galactic-war-cards.md](../../knowledge/galactic-war-cards.md)
- 卡片 effect 引用的 unit 欄位 → [knowledge/unit-spec-fields.md](../../knowledge/unit-spec-fields.md)
- 找 commander identifier → [glossary/zh-unit-terms.md](../../glossary/zh-unit-terms.md)
