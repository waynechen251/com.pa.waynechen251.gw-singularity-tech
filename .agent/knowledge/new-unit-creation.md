# 全新單位建立 (From-Scratch) 通則

> 資料源:Palobby Wiki 封存(archived 2021-09-05)+ planetaryannihilation.wiki.gg + 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:PA 仍有更新版本,實際以本機 `media/pa/units/...` 為準。

## 1) 何時走全新單位 vs override

| 需求 | 走法 |
| --- | --- |
| 改既有單位的 HP / 射程 / 速度 / 傷害 | **shadow override** ([create-server-unit-mod.md](../workflows/create-server-unit-mod.md)) |
| 既有單位換貼圖但同模型 | shadow override (改 `model.filename` 指到 mod 內 papa) |
| 給既有單位加新武器槽 | shadow override (`tools[]` 加新項目,小心 `record_index`) |
| **建立新 identifier 的單位** | **本檔流程** |
| 既有單位的「精英版」(新 ID 但同模型) | 本檔流程 (策略 A:純複製) |
| 全新概念單位 (新模型新動畫) | 本檔流程 (策略 D) |

決策原則:**有沒有要新增 unit_id 是分水嶺**。新增 unit_id 就是「新單位」,進入本檔流程;只調既有 unit_id 的數值就走 override。

[CONFIDENCE: WIKI]

## 2) 完整資產清單 (新單位最大集合)

```
server_mods/<identifier>/
├── modinfo.json                                        ★ 必填
└── pa/
    ├── units/<class>/<unit_id>/
    │   ├── <unit_id>.json                             ★ 主規格 JSON (必填)
    │   ├── <unit_id>.papa                             ◐ 模型 (策略 C/D 必填)
    │   ├── <unit_id>_diffuse.papa                     ◐ 基底顏色貼圖
    │   ├── <unit_id>_mask.papa                        ◐ 隊伍色遮罩
    │   ├── <unit_id>_material.papa                    ◐ 材質通道
    │   ├── <unit_id>_anim.json                        ○ animation tree (策略 D)
    │   └── anim/                                      ○ 動畫 papa 檔
    │       ├── <unit_id>_idle.papa
    │       ├── <unit_id>_walk.papa
    │       ├── <unit_id>_fire.papa
    │       └── <unit_id>_die.papa
    └── ammo/<ammo_id>/
        └── <ammo_id>.json                             ◐ 彈藥 JSON (有武器才需要)
```

★ 一定要、◐ 視策略而定、○ 進階選用

**Wiki 未明確列完整清單**,本表整合自 Palobby Mod_Structure 頁面、wiki.gg `Unit_Properties` 與本機 `media/pa/units/<某單位>/` 抽樣比對。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 3) From-Scratch 的 4 種策略

| 策略 | 工作量 | 關鍵步驟 | 適合 |
| --- | --- | --- | --- |
| **A. 純複製** | 1-2 小時 | 改 identifier、display_name、unit_types,模型動畫全用既有 | 製作變體 (例「幽靈版」「精英版」) |
| **B. 復用模型新數值** | 3-4 小時 | 同 A + 大幅調整數值、武器、tools 結構 | 「重型版」「快速版」等強化版本 |
| **C. 新模型復用動畫** | 1-2 天 | 新建 papa 模型 + 復用既有 animtree | 換皮但不改行為的全新單位 |
| **D. 全新建模與動畫** | 數天到數週 | 從 0 建模 + 自訂骨架 + 新 animtree | 全新概念單位 (例「會跳的機器人」) |

決策建議:能用策略 A 解的就不要走 D。先用策略 A 出原型驗證玩法,確定有市場再升級到 C 或 D。

## 4) 依賴鏈與最小可運作單位

最小可在遊戲內生產出來的新單位需要:

1. `modinfo.json` (context: server, identifier 唯一)
2. `pa/units/<class>/<unit_id>/<unit_id>.json` 含至少:
   - `base_spec` (繼承基底)
   - `display_name`
   - `max_health`
   - `build_metal_cost`
   - `unit_types[]` (至少要有能被某工廠 buildable_types 匹配的標籤)
   - `model.filename` (指向 papa,可指向既有單位的 papa)
   - `tools[]` (至少一個 — 即使是空的建造臂)
   - `navigation` (mobile 必填) 或省略 (structure 不需要)
3. 若引用既有單位的 ammo,`tools[].weapon.ammo_id` 直接指原檔路徑即可 (不需要在 mod 內複製)

從 `base_spec` 繼承的欄位**不需重複寫**。最小 diff 原則同樣適用於新單位 — 別整檔複製基底 JSON。

[CONFIDENCE: WIKI]

## 5) 中文化與圖示掛點

### 5.1 字串

- `display_name` / `description` 直接寫在 unit JSON
- 多語化做法:由 client 端 strings table 替換 (Wiki 未明確記載 server unit JSON 是否支援 i18n key,需本機驗證)
- 實務:多語版 mod 通常做 server + companion client,client mod 內覆寫 strings JSON

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

### 5.2 圖示

- `selection_icon`:選取圈 icon (server unit JSON 內定義路徑)
- `strategic_icon`:戰略視圖 icon — 通常是 client 端資源,放 companion client mod 的 `pa/effects/specs/strategic_icons/...`
- `build_icon`:建造列表縮圖 — 同樣 client 端

[CONFIDENCE: COMMUNITY-TOOL]

## 6) 常見地雷

| 地雷 | 後果 | 解法 |
| --- | --- | --- |
| identifier 撞 mod | 載入失敗或互相覆蓋 | 用反向網域全小寫,加上獨特字串 |
| `unit_types[]` 沒任何工廠匹配的標籤 | build bar 看不到新單位 | 至少加一個既有工廠 buildable_types 包含的 UNITTYPES_* |
| `model.filename` 路徑大小寫錯 | 模型不顯示 / 遊戲崩潰 | PA 全小寫,確認路徑與檔名一致 |
| 引用 ammo 寫絕對路徑但 ammo 不存在 | 武器不發射或崩潰 | 用本機驗過的既有 ammo 路徑,或自己建 ammo JSON |
| 飛行單位 `physics.gravity_scale != 0` | 飛機掉下來 | air_unit 必設 0 |
| 整檔複製 base_spec | 遊戲更新被洗掉 / 與基底偏離 | 只寫差異欄位,讓 base_spec 繼承 |
| `tools[]` 沒寫 `record_index` | 槽位錯亂,武器當建造臂 | 從 0 起逐項加 record_index |
| companion client mod 的 identifier 與 server 不對應 | client 資源沒掛載 | server modinfo 的 `companions[]` 必須列出 client identifier |
| 沒做多人測試就上架 | 玩家加入 desync / 房卡死 | server mod 必做 ≥2 人多機驗證 |

[CONFIDENCE: WIKI]

## 7) 待驗清單 (NEEDS-LOCAL-SAMPLING)

下列項目本檔以推測或社群片段為主,使用前請以本機 `media/pa/units/...` 抽樣驗證:

- 完整資產清單表 §2 的 `_anim.json` 檔名是否就是 `<unit_id>_anim.json` (有些單位實際是寫在主 JSON 的 `model.animtree` 路徑)
- §5.1 server unit JSON 是否支援 i18n key (例如 `!LOC:...`) 還是只能硬寫字串
- §5.2 `strategic_icon` 是否可放 server mod 內,還是必須 companion client
- 動畫檔在 mod 內的最佳組織方式 (`anim/` 子資料夾 vs 平鋪)

驗證方法:用 [skills/pa-local-steam-paths/SKILL.md](../skills/pa-local-steam-paths/SKILL.md) 取本機 PA 路徑後,grep 對應欄位:

```powershell
# 例:找一個動畫多的單位看 model.animations 與 model.animtree 怎麼寫
Select-String -Path "$paDataPath\media\pa\units\land\bot_heavy\bot_heavy.json" -Pattern "anim"
```
