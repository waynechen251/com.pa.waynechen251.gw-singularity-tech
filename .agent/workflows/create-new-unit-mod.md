# Workflow: 建立全新單位 MOD (含 3D 建模與動畫)

> 資料源:Palobby Wiki 封存(archived 2021-09-05)+ planetaryannihilation.wiki.gg + 社群工具 (Blender-PAPA-IO / PTexEdit / papatran)
> 抽樣日期:2026-05-09
> 注意:PA 仍有更新版本,實際以本機 `media/...` 為準。

## 目標

建立**全新單位** (新 identifier、新模型、可選新動畫),並讓玩家能在遊戲內透過工廠生產出來。涵蓋規劃 → 建模 → 紋理 → 動畫 → JSON → 工廠掛載 → 本機驗證 → 打包的完整端到端流程。

## 適用範圍

| 情境 | 走哪個 workflow |
| --- | --- |
| 改既有單位數值 (HP / 射程 / 速度等) | [create-server-unit-mod.md](./create-server-unit-mod.md) (shadow override) |
| 既有單位的小幅外觀調整 (僅 JSON 改 model.filename) | [create-server-unit-mod.md](./create-server-unit-mod.md) |
| **建立全新 identifier 的單位** | **本檔** |
| 全新單位但完全復用既有模型/動畫 | 本檔 (跳過 §3-§5) |
| 既有單位克隆變體 (新 ID 但同模型) | 本檔的「策略 A:純複製」 |

## 前置條件

1. 已讀過 [knowledge/pa-modding-core.md](../knowledge/pa-modding-core.md) (mod 通則、identifier 規範)
2. 已設好 `.agent/env/pa-local.env` 並能透過 [skills/pa-local-steam-paths/SKILL.md](../skills/pa-local-steam-paths/SKILL.md) 取本機 PA 路徑
3. 若要新建模型/動畫:已安裝 Blender + Blender-PAPA-IO 外掛 (見 [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md))

## 步驟

### 1. 策劃 (Planning)

- 決定新單位的 **base_spec** 基底 (見 [samples/units/_skeleton.md](../samples/units/_skeleton.md) 的 A-F 類型骨架)
  - 地面移動 → `/pa/units/unit_types/mobile_unit.json`
  - 飛行 → `/pa/units/unit_types/air_unit.json`
  - 靜態建築/塔 → `/pa/units/unit_types/structure.json`
  - 指揮官 → `/pa/units/unit_types/commander.json`
- 決定新單位的 **unit_types 標籤組合** (決定哪些工廠能造它,見 [knowledge/unit-types-and-buildable.md](../knowledge/unit-types-and-buildable.md))
- 決定新單位的 identifier 與內部 unit_name (反向網域全小寫,例 `com.example.heavy-bot`)
- 決定四種 from-scratch 策略中哪一種 (見 [knowledge/new-unit-creation.md](../knowledge/new-unit-creation.md) §3):
  - **A. 純複製**:克隆既有單位,只改 ID 與 display_name (最快,1-2 小時)
  - **B. 復用模型新數值**:同模型新 JSON (例如做「重型版」,3-4 小時)
  - **C. 新模型復用動畫**:換皮但動畫狀態機相同 (1-2 天)
  - **D. 全新**:全新模型與動畫 (數天到數週)

### 2. 建立 mod 骨架

複製 [templates/server-unit](../templates/server-unit) 為起始點:

```
server_mods/<identifier>/
├── modinfo.json                  ← 必填,context: "server"
└── pa/units/<class>/<unit_id>/
    └── <unit_id>.json            ← 主規格檔
```

更新 `modinfo.json`:
- `identifier`、`display_name`、`description`、`author`、`version`、`build`、`date`、`signature`
- `category` 至少含 `["units"]`,可加 `["classic"]` 或 `["titans"]`
- 若有 client-side 資源 (icon、UI),建立 companion client mod 並在 `companions[]` 列出

### 3. 3D 建模 (策略 C/D 才需要)

詳見 [knowledge/unit-model-papa.md](../knowledge/unit-model-papa.md) 與 [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md)。

關鍵點:
- Blender 中建立網格 + 骨架 (Armature)
- 骨骼命名遵守規範:`bone_root`、`bone_turret`、`muzzle_*`、`bone_recoil` 等
- **單網格 32 加權骨上限** (Blender-PAPA-IO 限制,超過要拆網格)
- 用 Blender-PAPA-IO 匯出 `.papa`,放到 `pa/units/<class>/<unit_id>/<unit_id>.papa`

### 4. 紋理 (策略 C/D 才需要)

PA 用三通道紋理:
- `<unit_id>_diffuse.papa` — 基底顏色
- `<unit_id>_mask.papa` — 隊伍色遮罩 (RGB 對應不同遮罩用途)
- `<unit_id>_material.papa` — material 通道 (含發光等)

PNG → papa 用 `papatran.exe` 編譯 (PA 客戶端內建工具),或用 PTexEdit 通道打包後再轉。詳見 [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md)。

### 5. 動畫 (策略 D 才需要)

詳見 [knowledge/unit-animation.md](../knowledge/unit-animation.md)。

關鍵概念:
- `model.animations` 列出動畫檔
- `model.animtree` 指向 animation tree JSON,定義狀態機
- 四大 unit_state:`being_built` / `living` / `dead` / `ghost`
- 武器後座力 (recoil) 是 animation type,不是 event
- 動畫檔本身也是 `.papa` 格式 (但只含骨架關鍵幀,不含網格)

### 6. 撰寫 unit JSON

依 [samples/units/_new-unit-skeleton.md](../samples/units/_new-unit-skeleton.md) 寫 from-scratch 的完整根 JSON。

最小可運作必填:
```json
{
  "base_spec": "/pa/units/unit_types/mobile_unit.json",
  "display_name": "Heavy Bot",
  "description": "...",
  "max_health": 800,
  "build_metal_cost": 600,
  "unit_types": ["UNITTYPES_Mobile", "UNITTYPES_Land", "UNITTYPES_Bot", "UNITTYPES_Advanced"],
  "model": { "filename": "/pa/units/land/<unit_id>/<unit_id>.papa" },
  "tools": [
    {
      "record_index": 0,
      "aim_bone": "bone_turret",
      "weapon": {
        "ammo_id": "/pa/ammo/<id>/<id>.json",
        "rate_of_fire": 1.0,
        "max_range": 100
      }
    }
  ],
  "navigation": {
    "type": "land",
    "move_speed": 8,
    "acceleration": 30,
    "brake": 30,
    "turn_speed": 90
  }
}
```

詳細欄位字典見 [knowledge/unit-spec-fields.md](../knowledge/unit-spec-fields.md)。

### 7. 工廠掛載 (Buildable Types)

新單位若要被既有工廠生產,有兩種做法 (詳見 [knowledge/unit-types-and-buildable.md](../knowledge/unit-types-and-buildable.md)):

- **方式 A**:在新單位的 `unit_types[]` 加既有工廠已篩選的標籤 (例如 `UNITTYPES_BasicBot`),自動被機器人工廠包含
- **方式 B**:override 工廠的 `buildable_types` 運算式,加上自定 tag

範例片段見 [cookbook/new-unit-recipes.md](../cookbook/new-unit-recipes.md) R2。

### 8. 圖示與在地化

- `selection_icon`:選取圈 icon (可選,無則用預設)
- `strategic_icon`:戰略視圖 icon (位於 client 端資源,通常透過 companion client mod)
- `build_icon`:建造列表縮圖
- `display_name` / `description` 直接在 unit JSON 寫字串;多語化需 companion client mod 提供字串表

詳見 [cookbook/new-unit-recipes.md](../cookbook/new-unit-recipes.md) R3。

### 9. 本機驗證

依 [skills/pa-local-steam-paths/SKILL.md](../skills/pa-local-steam-paths/SKILL.md) 部署到 `server_mods/<identifier>/`,然後:

1. 啟動 PA,進入 mod 管理確認 mod 載入無錯
2. 開單機沙盒場景,選擇對應工廠,確認 build bar 出現新單位
3. 建造一個出來,確認:
   - 模型正確顯示
   - 移動正常
   - 武器發射有命中、有特效、有音效
   - 受傷與死亡動畫正常
4. 若有問題,執行 [skills/pa-log-debugger/SKILL.md](../skills/pa-log-debugger/SKILL.md)

### 10. 打包與發佈

依 [workflows/test-package-release.md](./test-package-release.md) ZIP 打包,依 [workflows/publish-to-community-mods.md](./publish-to-community-mods.md) 提交社群。

## 實作檢查點

- [ ] `modinfo.json` `context` 為 `server`
- [ ] identifier 唯一且全小寫反向網域
- [ ] unit JSON 的 `base_spec` 路徑存在於本機 PA `media/pa/units/unit_types/`
- [ ] `unit_types[]` 至少有一個會被某工廠的 `buildable_types` 比對到
- [ ] `model.filename` 路徑與實際 papa 檔位置一致
- [ ] `tools[].record_index` 正確標記 (0 通常是建造臂 / 主武器)
- [ ] 飛行單位 `physics.gravity_scale` 必須為 0
- [ ] ammo JSON 與 unit JSON 同 mod 內提供 (或引用既有 ammo 路徑)
- [ ] 多人遊戲驗過 (server mod 影響所有玩家)

## 進階建議

- **拆 server / companion**:大型 mod 把 server-only 的 unit JSON 與 client-only 的 icon/strategic_icon 分開,companion mod 玩家加入時自動掛載
- **AI 建造**:讓電腦 AI 會建造新單位,需要在 AI build templates 加掛 (Wiki 未覆蓋,需從本機 `pa/ai/...` 抽樣)
- **科技樹分層**:用 `UNITTYPES_Basic` / `UNITTYPES_Advanced` 控制 tier
- **單位變體**:用同 base_spec 加少量欄位 override 做變體 (例如 `bot_heavy_anti_air` 是 `bot_heavy` 加防空 tools)

## 風險提示

- 全新單位是 server mod,**會影響所有玩家**,發佈前務必多人驗證
- 模型骨骼命名錯會讓武器發射位置錯亂
- `unit_types[]` 標籤錯會讓單位無法被任何工廠生產 (build bar 看不到)
- papa 編譯失敗時 PA 會直接 crash,務必先在本機跑過完整建造週期
- 不可上傳遊戲原始素材 (見 [knowledge/pa-modding-core.md](../knowledge/pa-modding-core.md) §10)

## 交叉連結速查

| 主題 | 文件 |
| --- | --- |
| 通則決策 | [knowledge/new-unit-creation.md](../knowledge/new-unit-creation.md) |
| 標籤系統 | [knowledge/unit-types-and-buildable.md](../knowledge/unit-types-and-buildable.md) |
| 3D 模型 | [knowledge/unit-model-papa.md](../knowledge/unit-model-papa.md) |
| 動畫 | [knowledge/unit-animation.md](../knowledge/unit-animation.md) |
| 欄位字典 | [knowledge/unit-spec-fields.md](../knowledge/unit-spec-fields.md) |
| 完整 JSON 骨架 | [samples/units/_new-unit-skeleton.md](../samples/units/_new-unit-skeleton.md) |
| 資產目錄佈局 | [samples/units/_papa-asset-layout.md](../samples/units/_papa-asset-layout.md) |
| 克隆/掛載片段 | [cookbook/new-unit-recipes.md](../cookbook/new-unit-recipes.md) |
| 工具鏈速查 | [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md) |
| 中文術語 | [glossary/zh-modeling-terms.md](../glossary/zh-modeling-terms.md) |
