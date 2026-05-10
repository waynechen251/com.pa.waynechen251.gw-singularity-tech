# Unit 動畫系統 (model.animations / model.animtree)

> 資料源:planetaryannihilation.wiki.gg `Unit_Animation` + Palobby Wiki `Papa_Spec` + 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:PA 仍有更新版本,實際以本機 `media/pa/units/<某動的單位>/` 為準。

## ⚠ 整體可信度警示

PA 動畫系統的官方文件非常稀薄。本檔大量片段為從 wiki.gg 條目與本機 unit JSON 推斷,使用前必須對照本機真實單位 (例如 `bot_heavy`、`commander_*`) 的 `model.animations` 與 `model.animtree` 區塊驗證。

## 1) model.animations vs model.animtree

unit JSON 內的動畫由兩個欄位協作:

### `model.animations`

列出**動畫資源**,把動畫名稱對應到 papa 檔路徑:

```json
{
  "model": {
    "filename": "/pa/units/land/bot_heavy/bot_heavy.papa",
    "animations": {
      "idle": "/pa/units/land/bot_heavy/anim/bot_heavy_idle.papa",
      "walk": "/pa/units/land/bot_heavy/anim/bot_heavy_walk.papa",
      "fire": "/pa/units/land/bot_heavy/anim/bot_heavy_fire.papa",
      "die": "/pa/units/land/bot_heavy/anim/bot_heavy_die.papa"
    }
  }
}
```

### `model.animtree`

指向 **animation tree JSON**,定義狀態機:

```json
{
  "model": {
    "animtree": "/pa/units/land/bot_heavy/bot_heavy_anim.json"
  }
}
```

animation tree JSON 描述:狀態之間如何轉換、blend 方式、什麼條件觸發什麼動畫。根節點通常是 `"blend_root"`。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 2) 四大 unit_state

PA 動畫系統的最頂層分四個狀態:

| 狀態 | 觸發 | 說明 |
| --- | --- | --- |
| `being_built` | 工廠正在建造 | 通常是浮現 / 組裝動畫 |
| `living` | 建造完成正常運作 | 進入子狀態機 (idle / walk / fire 等) |
| `dead` | HP ≤ 0 | 倒下、爆炸動畫 |
| `ghost` | 預覽建造大綱 | wiki.gg 標 broken |

`living` 狀態下還有更細的子狀態,由 animation tree 內的 transitions 控制。

[CONFIDENCE: WIKI]

## 3) Blend Transitions

animation tree JSON 用 `transitions` 欄位定義狀態間如何切換,條件以函數式描述:

| 條件函數 | 意義 |
| --- | --- |
| `anim_complete` | 當前動畫播完 |
| `has_build_target` | 建造機正在建造目標 |
| `has_energy` | 能量充足 (用於消耗能量的動畫) |
| `is_moving` | 單位正在移動 |
| `is_firing` | 武器正在發射 |

範例 (示意,實際以本機為準):

```json
{
  "blend_root": {
    "type": "switch",
    "default": "idle",
    "transitions": [
      { "to": "walk", "condition": "is_moving" },
      { "to": "fire", "condition": "is_firing" },
      { "to": "die", "condition": "is_dead", "priority": 100 }
    ]
  }
}
```

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 4) aim_blend 與 procedural_aim

砲塔瞄準是**程序動畫**而非預錄動畫 — 用骨骼即時旋轉而不是 keyframe。

| 機制 | 用法 |
| --- | --- |
| `aim_blend` | animation tree 內的 type,把瞄準方向混合進當前動畫 |
| `procedural_aim` | 直接旋轉骨骼 (例如 `bone_turret`) 到目標方向 |

unit JSON 內相關欄位:

```json
{
  "tools": [
    {
      "aim_bone_root": "bone_turret",         // 瞄準混合的根骨
      "aim_bone": "bone_turret",              // 實際旋轉骨
      "rotation_bone": "bone_turret",         // 程序旋轉的骨
      "yaw_speed": 90,                        // 水平旋轉速度 (度/秒)
      "pitch_speed": 45                       // 垂直旋轉速度
    }
  ]
}
```

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 5) Recoil 是 animation type 不是 event

武器後座力與 muzzle flash 的觸發方式不同:

- **Recoil** (後座力):由 animation tree 的 `recoil` type 動畫觸發,武器發射時 PA 自動播 `bone_recoil` 的位移動畫
- **Muzzle flash** (砲口閃光):由 unit JSON 的 `events.fired` 或 ammo JSON 的 fx 觸發,綁定 `muzzle_*` 骨

兩者獨立,可單獨啟用或共用。

```json
{
  "events": {
    "fired": {
      "effect_spec": "/pa/effects/specs/muzzle_flash_basic.json",
      "offset": "muzzle_0"
    }
  }
}
```

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 6) Muzzle Flash 與動畫關係

muzzle flash 不算動畫,而是**特效**(particle / fx)。它與動畫的關聯:

- 透過 `muzzle_bones[]` 把特效錨點綁到骨架
- 動畫中骨架移動 (例如後座力位移) 會帶動特效跟隨
- 若 muzzle_bone 不存在或命名錯,fx 出現位置會錯亂 (常見坐落於模型原點)

[CONFIDENCE: COMMUNITY-TOOL]

## 7) 動畫到 fx_offsets 的對齊

unit JSON 的 `fx_offsets[]` 可定義特效掛點 (損傷煙、引擎噴射等):

```json
{
  "fx_offsets": [
    { "type": "damage_smoke", "bone": "bone_chassis", "offset": [0, 1, 0] },
    { "type": "engine_glow", "bone": "muzzle_engine", "offset": [0, 0, 0] }
  ]
}
```

`bone` 欄位必須對應 papa 模型內存在的骨。動畫播放時特效會跟著骨移動。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 8) 待驗清單 (NEEDS-LOCAL-SAMPLING)

下列項目以推測或片段資訊為主,使用前請以本機 PA 抽樣:

- §1 `model.animtree` 確切路徑慣例 (是否一定是 `<unit_id>_anim.json`)
- §3 完整 `transitions` 條件函數列表 — 需從本機原檔 grep `"condition":` 收集
- §4 `aim_blend` vs `procedural_aim` 的優先權 (兩者並存時誰生效)
- §5 動畫 papa 是否與模型 papa 共用同一骨架 (應該是,但需驗證)
- §6 muzzle 特效綁骨後是否承接動畫變換 (推斷是,但實測確認)

驗證方式:

```powershell
# 找 PA 內所有用 model.animtree 的單位
$paDataPath = ((Get-Content .agent\env\pa-local.env) -match "^PA_DATA=").Replace("PA_DATA=", "")
Get-ChildItem -Recurse -Filter "*.json" "$paDataPath\media\pa\units" |
  Select-String -Pattern "animtree" |
  Select-Object Path, LineNumber, Line
```

抽出結果後,讀其中一個 animtree JSON 對照本檔 §1-§3 內容。

## 參考來源

- https://planetaryannihilation.wiki.gg/wiki/Unit_Animation
- https://wiki.palobby.com/wiki/Planetary_Annihilation_Papa_Spec
- https://github.com/Luther-1/Blender-PAPA-IO
