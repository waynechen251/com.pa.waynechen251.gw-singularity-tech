# Unit JSON 結構骨架（Schema Outline）

> **本檔不複製原始檔內容**，僅以縮排 outline 描述各類單位的典型欄位結構，避開商業遊戲資產版權邊界。
> 玩家本機可直接從 `media/pa/units/...` 取實際工作副本。
> 來源：Palobby Wiki + 抽樣比對。
> 抽樣日期：2026-05-09（請依本機 build 標註自己版本）。

## 通用根欄位（所有 unit 大致都有）

```
{
  base_spec               # 繼承基底 unit_types JSON
  display_name            # 顯示名
  description             # tooltip
  max_health              # HP
  build_metal_cost        # 金屬成本
  unit_types              # 標籤陣列（影響 buildable_types 運算）
  unit_name               # 內部名稱
  model                   # { filename, animations, ... }
  fx_offsets              # 視覺特效掛點陣列
  events                  # 事件音效 / 特效
  audio                   # 環境音
  selection_icon          # 選取圈 icon
  recon                   # 偵測 / 視野（observer + observable）
  tools                   # 武器、建造臂、雷達等陣列
}
```

---

## A) 坦克（land/tank_*）骨架

```
{
  base_spec: "/pa/units/unit_types/mobile_unit.json"
  display_name, description, max_health
  build_metal_cost: 60-2000
  unit_types: ["UNITTYPES_Mobile", "UNITTYPES_Land", "UNITTYPES_Tank", ...]

  physics: {
    mass
    gravity_scale: 1
    push_class
  }

  navigation: {
    type: "land"
    move_speed: 6-13
    acceleration, brake, turn_speed
    turn_radius
  }

  tools: [
    {
      record_index: 0
      aim_bone: "bone_turret"
      muzzle_bones: [...]
      weapon: {
        ammo_id: "/pa/ammo/<id>/<id>.json"
        rate_of_fire
        max_range, min_range
        muzzle_velocity
        firing_arc_yaw, firing_arc_pitch
      }
    }
  ]

  recon: {
    observer: { items: [{ channel: "sight", radius, layer: "surface_and_air" }] }
    observable: { items: [...] }
  }

  command_caps: ["ORDER_Move", "ORDER_Attack", "ORDER_Patrol", ...]
}
```

---

## B) 機器人（land/bot_*）骨架

主要差異：通常更輕、更快、走 `bot` push_class。

```
{
  ...（同坦克通用欄位）
  navigation: { type: "land", move_speed: 8-12 }
  physics: { mass: 較小, push_class: bot }

  # bot 可能有近戰武器
  tools: [
    {
      weapon: {
        ammo_id: "/pa/ammo/<melee_or_short_range>/...",
        max_range: 較短
      }
    }
  ]
}
```

---

## C) 戰鬥機（air/fighter）骨架

關鍵差異：`physics.gravity_scale = 0`、`navigation.type = "air"`、有 `air` 子物件。

```
{
  base_spec: "/pa/units/unit_types/air_unit.json"
  unit_types: ["UNITTYPES_Mobile", "UNITTYPES_Air", "UNITTYPES_Fighter", ...]

  physics: {
    gravity_scale: 0       # 必須！
    mass
  }

  navigation: {
    type: "air"
    move_speed: 高（30+）
    acceleration, brake, turn_speed
  }

  air: {
    cruise_altitude
    flight_envelope: { ... }
    landing_pad: false
  }

  tools: [{
    weapon: {
      firing_arc_pitch: 較大（對地需要）
      ...
    }
  }]
}
```

---

## D) 指揮官（commanders/<id>）骨架

關鍵差異：多 tool（建造臂 + 主砲 + 副武器）、超高 HP、可建造大量類型。

```
{
  base_spec: "/pa/units/unit_types/commander.json"
  display_name: "...Commander"
  max_health: 12000+
  unit_types: ["UNITTYPES_Mobile", "UNITTYPES_Commander", "UNITTYPES_Land", ...]

  physics, navigation                   # 同坦克
  air: { ... }                          # 部分指揮官會飛

  tools: [
    {
      record_index: 0                   # 通常是建造臂
      aim_bone: "bone_root"
      construction_demand: { metal, energy }
      build_arm: {
        repair_speed, reclaim_speed, capture_speed
      }
    },
    {
      record_index: 1                   # 主砲
      weapon: { ammo_id, max_range, rate_of_fire, ... }
    },
    {
      record_index: 2                   # 副武器（防空 / 近戰）
      weapon: { ... }
    }
  ]

  buildable_types: "UBERTYPE_FactoryUnits & ..."   # 可建造類型運算式

  death_weapon: {                       # 死亡爆炸（毀星彈）
    ammo_id
    initial_velocity
  }
}
```

---

## E) 工廠（factory_*）骨架

關鍵差異：`navigation` 通常為靜態（或無）、有 `buildable_types` 與 `factory.production` 子物件。

```
{
  base_spec: "/pa/units/unit_types/structure.json"
  unit_types: ["UNITTYPES_Structure", "UNITTYPES_Factory", ...]
  navigation: { type: "land" }   # 靜態建築通常無 navigation 或極簡

  buildable_types: "UNITTYPES_Bot & UNITTYPES_BasicBot"
  factory: {
    production: { metal_rate, energy_rate }   # 視版本而定
  }

  tools: [
    {
      record_index: 0
      construction_demand: { metal, energy }
    }
  ]
}
```

---

## F) 防禦塔台（base_turret_*）骨架

關鍵差異：靜態、`tools` 通常只有一個武器、有 `firing_arc_yaw` 360。

```
{
  base_spec: "/pa/units/unit_types/turret.json"
  unit_types: ["UNITTYPES_Structure", "UNITTYPES_Defense", ...]

  tools: [{
    weapon: {
      max_range, min_range
      rate_of_fire
      firing_arc_yaw: 180   # 半弧 / 全弧
      firing_arc_pitch: 較大（對空 / 對地）
    }
  }]
}
```

---

## 使用建議

1. AI 看到玩家提需求，先用本檔判斷「對應哪類骨架」。
2. 從骨架知道有哪些 section 可改。
3. 細欄位查 [unit-spec-fields.md](../../knowledge/unit-spec-fields.md)。
4. 真的要寫 patch 時，**用 [pa-local-steam-paths skill](../../skills/pa-local-steam-paths/SKILL.md) 從本機抓原檔，** 對照確認原始欄位 key 與值，再做最小 diff 覆寫。
5. 不要用本骨架直接當原檔貼上 — 它是「導航圖」，不是工作副本。
