# Unit Spec 欄位字典（Agent 版）

> 資料源：Palobby Wiki 封存（archived 2021-09-05）+ 本機 PA 安裝目錄抽樣。
> 適用對象：玩家用自然語言提需求（「想改某單位的 X」），AI 需要把需求翻譯成具體 JSON 路徑與修改值。
> 注意：PA 仍有更新版，實際數值請以玩家本機 `media/pa/units/...` 原檔為準。本檔只列 modding 常用欄位。

> **視角註記**：本檔以「override 既有單位的數值」為主視角，聚焦於玩家最常改的欄位。若要從零建立**全新單位**，涉及的 `unit_types[]` / `buildable_types` / `model.filename` / `model.animations` / `model.animtree` 等「from-scratch 才會碰」的欄位，改在 [`unit-types-and-buildable.md`](./unit-types-and-buildable.md)、[`unit-model-papa.md`](./unit-model-papa.md)、[`unit-animation.md`](./unit-animation.md)；完整 root 骨架見 [`../samples/units/_new-unit-skeleton.md`](../samples/units/_new-unit-skeleton.md)。

## 1) Unit JSON 結構總覽

一個典型 unit spec 的頂層 section（並非全部 unit 都有所有 section）：

```
{
  "base_spec": "/pa/units/unit_types/<role>.json",   # 繼承基底
  "display_name": "Light Tank",
  "description": "...",
  "max_health": <數值>,
  "build_metal_cost": <數值>,
  "build_time": <數值>,
  "physics": { ... },           # 物理 / 移動
  "navigation": { ... },        # 導航 / 速度
  "tools": [ ... ],             # 武器、建造臂、塔台等
  "events": { ... },            # 事件音效 / 特效
  "fx_offsets": [ ... ],        # 視覺特效掛點
  "recon": { ... },             # 偵測 / 視野
  "command_caps": [ ... ],      # 可下達指令
  "selection_icon": { ... },
  "audio": { ... },
  "lamps": [ ... ],             # 燈號 / 視覺
  "model": { "filename": "..." }
}
```

> Modding 一般原則：**只覆寫要改的欄位**，PA 的 `base_spec` 會繼承未列欄位。整檔複製反而會把日後遊戲更新洗掉。

## 2) 欄位字典（modding 高頻）

### 2.1 基本

| JSON 路徑 | 型別 | 中文意義 | 常見範圍 | 改後影響 |
| --- | --- | --- | --- | --- |
| `display_name` | string | 顯示名（玩家看到的） | — | 不影響識別，UI 顯示用 |
| `description` | string | tooltip 文字 | — | 純 UI |
| `max_health` | number | 最大 HP | 步兵 100-300、塔台 1000-4000、指揮官 12000+ | 直接決定生存力 |
| `build_metal_cost` | number | 建造金屬成本 | 60-50000+ | 影響 build_time（與建造臂功率聯動） |
| `build_time`（部分繼承） | number | 建造耗時 | — | 多由 cost 與建造臂自動推導；通常不需直接改 |

### 2.2 物理與導航

| JSON 路徑 | 型別 | 中文意義 | 常見範圍 | 改後影響 |
| --- | --- | --- | --- | --- |
| `physics.mass` | number | 質量 | — | 影響碰撞、推進反作用 |
| `physics.gravity_scale` | number | 重力倍率 | 0-1 | 飛行單位常設 0；改大會讓飛機掉下來 |
| `physics.push_class` | int | 推擠分類 | — | 同類互推、跨類阻擋；亂改會讓單位卡住 |
| `navigation.move_speed` | number | 地面/海面移動速度 | 步兵 8-12、坦克 6-10、艦艇 9-13 | 玩家最常想改的欄位之一 |
| `navigation.acceleration` | number | 加速度 | — | 改太低會讓單位「開不出去」 |
| `navigation.brake` | number | 煞車 | — | 影響停止精準度 |
| `navigation.turn_speed` | number | 轉向速度（度/秒） | — | 影響戰鬥靈敏度 |
| `navigation.type` | string | 導航類型（land / air / water / amphibious） | — | 改了會讓單位走不該走的地形 |

### 2.3 武器（`tools[].weapon`）

`tools` 是陣列，每個 tool 可能是武器、建造臂、雷達或工具。武器位於某個 `tool.weapon` 子物件。

| JSON 路徑 | 型別 | 中文意義 | 常見範圍 | 改後影響 |
| --- | --- | --- | --- | --- |
| `tools[].aim_bone` | string | 開火骨架 | — | 改錯會發射位置錯誤 |
| `tools[].record_index` | int | 武器槽編號 | — | 用於對應 ammo |
| `tools[].weapon.ammo_id` | string | ammo 檔路徑 | — | 改換 ammo 等於換武器類型 |
| `tools[].weapon.muzzle_velocity` | number | 砲口初速 | — | 影響彈道與命中率 |
| `tools[].weapon.rate_of_fire` | number | 每秒發射數 | 0.5-5 | 玩家最常改 |
| `tools[].weapon.max_range` | number | 最大射程 | 步兵 80、坦克 90-110、塔台 130-220 | 玩家最常改 |
| `tools[].weapon.min_range` | number | 最小射程 | — | 改 0 可讓近戰不卡 |
| `tools[].weapon.firing_arc_yaw` | number | 水平射界（度） | — | 砲塔轉動範圍 |
| `tools[].weapon.firing_arc_pitch` | number | 垂直射界 | — | 對空 / 對地 |

> **ammo JSON 另外存在**：`pa/ammo/<id>/<id>.json`，含 `damage`、`splash_radius`、`splash_damage`、`lifetime` 等。改傷害要改 ammo 不是 weapon。

### 2.4 偵測（`recon`）

| JSON 路徑 | 型別 | 中文意義 | 常見範圍 | 改後影響 |
| --- | --- | --- | --- | --- |
| `recon.observer.items[].channel` | string | 偵測通道（`sight` / `radar` / `sonar` / `omni`） | — | 跨類別亂混會破壞遊戲平衡 |
| `recon.observer.items[].shape` | string | 視野形狀（`capsule` / `sphere`） | — | — |
| `recon.observer.items[].radius` | number | 視野/雷達半徑 | 步兵 80、雷達塔 250+ | 玩家最常改 |
| `recon.observer.items[].layer` | string | 偵測平面（`surface_and_air` 等） | — | 影響能否偵測空中目標 |

### 2.5 建造（建造臂 tool）

| JSON 路徑 | 型別 | 中文意義 |
| --- | --- | --- |
| `tools[].build_arm` | object | 建造臂；含 `repair_speed`、`reclaim_speed` 等 |
| `tools[].construction_demand.metal` | number | 每秒消耗金屬（即建造功率） |
| `tools[].construction_demand.energy` | number | 每秒消耗能源 |
| `buildable_types` | string | 可建造列表（CSV 或標籤式） |

> 「建造機速度 ×2」→ 改 `tools[].construction_demand.metal` 與 `energy`，**同時等比放大**才不會供需失衡。

### 2.6 經濟（資源類單位）

| JSON 路徑 | 型別 | 中文意義 |
| --- | --- | --- |
| `production.metal` | number | 每秒產金屬 |
| `production.energy` | number | 每秒產能源 |
| `storage.metal` | number | 金屬儲量 |
| `storage.energy` | number | 能源儲量 |

### 2.7 飛行單位特有

| JSON 路徑 | 型別 | 中文意義 |
| --- | --- | --- |
| `air.fuel_capacity` | number | 燃料總量（部分版本有） |
| `air.flight_height` | number | 飛行高度 |
| `air.cruise_altitude` | number | 巡航高度 |
| `physics.gravity_scale` | number | 應為 0 |

## 3) 典型 patch 範例（最小 diff）

### 3.1 砲塔射程 +50%

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

> 套用檔：`pa/units/land/base_turret_basic_l1/base_turret_basic_l1.json`
> 注意：`tools` 必須以陣列出現，且至少帶 `record_index` 對齊原始槽位。

### 3.2 HP ×2

```json
{
  "max_health": 200
}
```

### 3.3 建造機速度 ×2（同時放大金屬與能源消耗）

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

> **務必兩個都改**，只改其一會被另一資源卡瓶頸。

### 3.4 視野 ×1.5

```json
{
  "recon": {
    "observer": {
      "items": [
        { "channel": "sight", "radius": 120 }
      ]
    }
  }
}
```

## 4) 改 unit 前的查表流程（建議）

1. 玩家用中文俗稱描述 → 查 [glossary/zh-unit-terms.md](../glossary/zh-unit-terms.md) 拿 identifier 與檔案路徑
2. 想改的屬性 → 查本檔（unit-spec-fields）拿 JSON 路徑
3. 想要套用模板 → 查 [cookbook/unit-balance-tweaks.md](../cookbook/unit-balance-tweaks.md)
4. 對照本機 `pa/units/<class>/<id>/<id>.json` 確認原始欄位確實存在再寫 patch

## 5) 常見地雷

- **改 ammo 而非 weapon**：傷害（damage / splash_damage）在 ammo 檔，不在 weapon 子物件。改 weapon.damage 通常無效。
- **`tools[]` 用 record_index 對齊**：直接寫 `[ {...} ]` 沒帶 record_index，可能蓋掉錯誤的槽位。
- **物理參數連動**：改 mass、acceleration、brake 必須同步調整，否則單位會「滑」或「卡」。
- **air 單位改 gravity_scale**：必須維持 0；改非 0 會讓飛機墜落。
- **base_spec 繼承被覆寫**：若改 `base_spec` 路徑，會把所有繼承欄位換成新基底，影響非常大。
