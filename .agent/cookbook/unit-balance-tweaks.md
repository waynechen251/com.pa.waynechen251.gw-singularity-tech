# Cookbook：單位平衡 Tweaks

> 給「想對某單位做小改動」的玩家直接複製。
> 每例三段：**目標檔** / **patch（最小 diff）** / **注意事項**。
> 配套：先讀 [unit-spec-fields.md](../knowledge/unit-spec-fields.md) 了解欄位、[zh-unit-terms.md](../glossary/zh-unit-terms.md) 翻譯中文俗稱。
> 套用方式：在 server mod 內以原檔相同路徑 shadow 該 JSON。

---

## 1) 砲塔射程 +50%（基礎 L1 砲塔）

**目標檔**：`pa/units/land/base_turret_basic_l1/base_turret_basic_l1.json`

**patch**：
```json
{
  "tools": [
    {
      "record_index": 0,
      "weapon": {
        "max_range": 270
      }
    }
  ]
}
```

**注意**：
- 原始 `max_range` 約 180，270 = 1.5×。實際以本機原檔為準。
- 必須保留 `record_index` 對齊原 tool 槽位。
- 別忘了 `min_range` 通常不需要動。

---

## 2) HP ×2

**目標檔**：對應單位的 `<id>.json`（任意單位皆可）

**patch**：
```json
{
  "max_health": 200
}
```

**注意**：直接寫絕對值，不是倍率。AI 套用時要先讀原始值再 ×2。

---

## 3) 建造機速度 ×2

**目標檔**：例 `pa/units/land/engineer_land_basic/engineer_land_basic.json`

**patch**：
```json
{
  "tools": [
    {
      "record_index": 0,
      "construction_demand": {
        "metal": 20,
        "energy": 1000
      }
    }
  ]
}
```

**注意**：
- **金屬與能源必須等比放大**，否則被另一資源卡住。
- 建造速度是「每秒消耗 metal × 工廠數 ÷ 目標 cost」推導，純改 demand 是最直接的「加快」方式。
- 此修改會增加經濟壓力，不平衡時可同步降 `build_metal_cost`。

---

## 4) 移動速度 ×1.5

**目標檔**：例 `pa/units/land/tank_light/tank_light.json`

**patch**：
```json
{
  "navigation": {
    "move_speed": 13.5,
    "acceleration": 30,
    "brake": 30
  }
}
```

**注意**：
- 純改 `move_speed` 而不放大 `acceleration`/`brake`，單位會「滑」而且急停慢。
- 建議三個欄位等比放大。

---

## 5) 視野 ×2（偵測雷達塔）

**目標檔**：例 `pa/units/land/recon_advanced/recon_advanced.json`

**patch**：
```json
{
  "recon": {
    "observer": {
      "items": [
        { "channel": "sight", "shape": "capsule", "radius": 320, "layer": "surface_and_air" }
      ]
    }
  }
}
```

**注意**：
- `items` 整個替換才生效（非合併陣列），所以 `channel` / `layer` 也要保留。
- `surface_and_air` 才能同時看地面與空中，別省略。

---

## 6) 武器射速 ×2（連發）

**目標檔**：對應單位的 `<id>.json`

**patch**：
```json
{
  "tools": [
    {
      "record_index": 0,
      "weapon": {
        "rate_of_fire": 4
      }
    }
  ]
}
```

**注意**：
- 原 `rate_of_fire` 例如 2，乘 2 = 4（單位：發/秒）。
- 不會自動等比下調傷害，整體 DPS 直接 ×2，慎用。

---

## 7) 改傷害（要改 ammo，不是 weapon）

**目標檔**：`pa/ammo/<ammo_id>/<ammo_id>.json`（從 unit 的 `tools[].weapon.ammo_id` 取得 ammo 路徑）

**patch**：
```json
{
  "damage": 200,
  "splash_damage": 100,
  "splash_radius": 6
}
```

**注意**：
- **這是新手最常踩的坑**：把 `damage` 寫到 unit JSON 裡無效，必須改 ammo。
- 改 splash_radius 過大會誤傷友軍。

---

## 8) 移除某單位（讓建造列表少一個）

**目標檔**：建造該單位的工廠 `<factory>.json`（例 `pa/units/land/factory_land_advanced/factory_land_advanced.json`）

**patch**：
```json
{
  "buildable_types": "* & !UNITTYPES_<TargetType>"
}
```

**注意**：
- PA 的 `buildable_types` 是標籤運算式（`* & !X` 表示「所有類型扣除 X」）。
- 不可直接刪除原列表內容，必須用運算式語法。
- 完整語法以本機 PA 工廠原檔為準。

---

## 9) 指揮官 build power ×2（量身改善開局）

**目標檔**：`pa/units/commanders/<commander_id>/<commander_id>.json`

**patch**：
```json
{
  "tools": [
    {
      "record_index": 0,
      "construction_demand": { "metal": 16, "energy": 1600 }
    }
  ]
}
```

**注意**：
- 指揮官有多個 tool（建造臂 + 主砲），改錯 `record_index` 會把武器當建造臂。
- 必須先看原檔確認哪個 record_index 是建造臂。

---

## 10) 飛行單位巡航高度提升

**目標檔**：例 `pa/units/air/fighter/fighter.json`

**patch**：
```json
{
  "air": {
    "cruise_altitude": 240
  }
}
```

**注意**：
- 過高會超出某些武器的對空射界，導致防空塔打不到。
- 對玩家可能是 buff，對單位實戰平衡影響大。

---

## 製作流程速覽

1. 玩家用中文俗稱講需求（「砲塔射程加 50%」）
2. 查 [zh-unit-terms.md](../glossary/zh-unit-terms.md) → 拿 identifier 與檔案路徑
3. 查 [unit-spec-fields.md](../knowledge/unit-spec-fields.md) → 拿要改的 JSON 路徑
4. 用本檔對應的 patch 模板 → 填入新值
5. 在 server mod 內建立同路徑 JSON 並貼上 patch
6. 用 [pa-local-steam-paths skill](../skills/pa-local-steam-paths/SKILL.md) deploy 到本機 server_mods 測試
7. 對局確認效果，看 log 確認無 schema 錯誤

## 通用地雷清單

- **絕對值不是倍率**：所有 JSON 欄位都吃絕對值。AI 必須先讀原檔再算新值。
- **陣列覆寫**：PA 的 JSON 覆寫機制對陣列欄位（如 `tools`、`recon.observer.items`）通常是**整段替換**，不要假設會合併。
- **改 ammo 不是 weapon**：傷害、爆風永遠在 ammo 檔。
- **檔名大小寫**：路徑大小寫一律小寫，跨平台慣例。
- **JSON 必須合法**：不能有尾逗號、單引號、註解（除非是文件骨架）。
