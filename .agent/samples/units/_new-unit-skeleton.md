# 全新單位 Root JSON 骨架 (From-Scratch)

> 資料源:Palobby Wiki + planetaryannihilation.wiki.gg + 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:本檔不複製商業遊戲原始檔內容,僅描述根 JSON 的完整結構,玩家本機可直接從 `media/pa/units/...` 取實際工作副本。

## 與 [_skeleton.md](./_skeleton.md) 的差異

| 檔案 | 視角 | 何時用 |
| --- | --- | --- |
| `_skeleton.md` | 各類單位 (坦克 / 機器人 / 飛機 / 工廠 / 塔台) 的 **section 樹**,以「override 既有單位」視角列欄位 | 想改某既有單位的某 section 時 |
| **`_new-unit-skeleton.md`** | from-scratch 建立**全新單位**的**完整 root JSON**,列出新單位該有哪些欄位才能運作 | 從 0 建單位時 |

兩者欄位重疊但用途不同:override 寫最小 diff,新單位要寫足夠讓 PA 能載入。

---

## 完整 Root JSON 骨架 (含註解的虛擬範例)

```jsonc
{
  // ── 繼承 ─────────────────────────────────────────────
  "base_spec": "/pa/units/unit_types/mobile_unit.json",  // ★ 必填
                                                          // 選擇:mobile_unit / air_unit / structure / commander / turret

  // ── 基本資訊 ─────────────────────────────────────────
  "display_name": "Heavy Bot",                            // ★ 必填
  "description": "高 HP、慢速的進階機器人。",            // ★ 必填
  "unit_name": "Heavy Bot",                               // 內部名稱

  // ── 經濟 ─────────────────────────────────────────────
  "max_health": 800,                                      // ★ 必填
  "build_metal_cost": 600,                                // ★ 必填
  // build_time 通常由 cost / 建造臂功率推導,不需直接寫

  // ── 標籤 (決定可建造性) ─────────────────────────────
  "unit_types": [                                         // ★ 必填,見 unit-types-and-buildable.md
    "UNITTYPES_Mobile",
    "UNITTYPES_Land",
    "UNITTYPES_Bot",
    "UNITTYPES_Advanced"
  ],

  // ── 模型 ─────────────────────────────────────────────
  "model": {                                              // ★ 必填
    "filename": "/pa/units/land/heavy_bot/heavy_bot.papa",  // 主模型 papa
    "animations": {                                       // 進階:列出動畫資源
      "idle": "/pa/units/land/heavy_bot/anim/heavy_bot_idle.papa",
      "walk": "/pa/units/land/heavy_bot/anim/heavy_bot_walk.papa",
      "fire": "/pa/units/land/heavy_bot/anim/heavy_bot_fire.papa",
      "die":  "/pa/units/land/heavy_bot/anim/heavy_bot_die.papa"
    },
    "animtree": "/pa/units/land/heavy_bot/heavy_bot_anim.json"  // 進階:狀態機 JSON
  },

  // ── 物理 ─────────────────────────────────────────────
  "physics": {                                            // ★ mobile 必填
    "mass": 50,
    "gravity_scale": 1,                                   // ⚠ 飛行單位必須為 0
    "push_class": 4
  },

  // ── 導航 ─────────────────────────────────────────────
  "navigation": {                                         // ★ mobile 必填,structure 不需要
    "type": "land",                                       // land / air / water / amphibious
    "move_speed": 8,
    "acceleration": 30,
    "brake": 30,
    "turn_speed": 90,
    "turn_radius": 0
  },

  // ── 武器 / 工具 (陣列) ──────────────────────────────
  "tools": [                                              // ★ 至少一個
    {
      "record_index": 0,                                  // ⚠ 槽位編號,從 0 起遞增
      "aim_bone": "bone_turret",                          // 對應 papa 內骨骼名
      "aim_bone_root": "bone_turret",
      "muzzle_bones": ["muzzle_0"],
      "yaw_speed": 90,
      "pitch_speed": 45,
      "weapon": {
        "ammo_id": "/pa/ammo/heavy_bot_shell/heavy_bot_shell.json",
        "rate_of_fire": 1.0,
        "max_range": 100,
        "min_range": 0,
        "muzzle_velocity": 200,
        "firing_arc_yaw": 360,
        "firing_arc_pitch": 30
      }
    }
  ],

  // ── 偵測 / 視野 ─────────────────────────────────────
  "recon": {
    "observer": {
      "items": [
        { "channel": "sight", "shape": "capsule", "radius": 100, "layer": "surface_and_air" }
      ]
    },
    "observable": {
      "items": [
        { "channel": "sight", "shape": "sphere", "layer": "surface_and_air" },
        { "channel": "radar", "shape": "sphere", "layer": "surface" }
      ]
    }
  },

  // ── 事件 (音效 / 特效) ─────────────────────────────
  "events": {
    "fired": {
      "effect_spec": "/pa/effects/specs/muzzle_flash_basic.json",
      "offset": "muzzle_0"
    },
    "died": {
      "effect_spec": "/pa/effects/specs/explosion_basic.json"
    }
  },

  // ── 視覺特效掛點 ────────────────────────────────────
  "fx_offsets": [
    { "type": "damage_smoke", "bone": "bone_chassis", "offset": [0, 1, 0] }
  ],

  // ── 可下達指令 ──────────────────────────────────────
  "command_caps": [
    "ORDER_Move",
    "ORDER_Attack",
    "ORDER_Patrol",
    "ORDER_Stop"
  ],

  // ── 選取 icon ───────────────────────────────────────
  "selection_icon": {
    "size": 30
  }
}
```

---

## 各情境的「最小可運作」子集

### 情境 A:最簡單可載入單位 (僅占位)

```jsonc
{
  "base_spec": "/pa/units/unit_types/mobile_unit.json",
  "display_name": "Test Unit",
  "max_health": 100,
  "build_metal_cost": 60,
  "unit_types": ["UNITTYPES_Mobile", "UNITTYPES_Land", "UNITTYPES_Bot", "UNITTYPES_Basic"],
  "model": { "filename": "/pa/units/land/bot_assault/bot_assault.papa" },  // ← 借用既有模型
  "tools": [],
  "navigation": { "type": "land", "move_speed": 8, "acceleration": 30, "brake": 30, "turn_speed": 90 },
  "physics": { "gravity_scale": 1 }
}
```

### 情境 B:有武器的可戰鬥單位

加上 §「武器 / 工具」section,並引用既有 ammo 路徑或自建 ammo JSON。

### 情境 C:全新模型+動畫

加上 `model.animations` 與 `model.animtree`,並且自己的 papa 與 animtree JSON 都存在。

---

## 必填 vs 選填速查

| 欄位 | 必填情況 |
| --- | --- |
| `base_spec` | 永遠必填 |
| `display_name` | 永遠必填 |
| `max_health` | 永遠必填 |
| `build_metal_cost` | 永遠必填 |
| `unit_types[]` | 永遠必填 (沒它工廠看不到) |
| `model.filename` | 永遠必填 (可指既有 papa) |
| `tools[]` | 永遠必填 (可為空陣列,但欄位必須有) |
| `navigation` | mobile 必填,structure 不需要 |
| `physics` | mobile 必填,飛行需 `gravity_scale: 0` |
| `recon` | 強烈建議 (沒它沒視野) |
| `command_caps[]` | 繼承自 base_spec,可省略 |
| `events`, `audio`, `fx_offsets` | 選填 |
| `model.animations`, `model.animtree` | 進階,新動畫才需要 |
| `selection_icon` | 選填 |

[CONFIDENCE: WIKI + NEEDS-LOCAL-SAMPLING]

## 使用建議

1. 從本機抓一個結構接近的既有單位 JSON 對照欄位
2. 以本檔作為**完整性檢查清單**,逐項確認
3. 細欄位字典查 [knowledge/unit-spec-fields.md](../../knowledge/unit-spec-fields.md)
4. 標籤系統查 [knowledge/unit-types-and-buildable.md](../../knowledge/unit-types-and-buildable.md)
5. 最小 diff 原則仍然適用 — 能繼承自 base_spec 的別重複寫
