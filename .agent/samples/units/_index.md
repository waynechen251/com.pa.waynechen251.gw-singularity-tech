# PA Unit 目錄索引

> 從本機 PA 安裝目錄 `media/pa/units/` 抽出的目錄樹。
> **僅列路徑，不複製檔案內容**。
> 用途：玩家用中文俗稱說想改某類單位時，AI 知道對應資料夾在哪。
> 抽樣日期：2026-05-09（請依本機 build 標註）。
> 注意：DLC（Titans）、社群 mod、版本更新會變更目錄結構，請以本機為準。

```
pa/units/
├── commanders/
│   ├── imperial_alpha/
│   ├── imperial_delta/
│   ├── imperial_omega/
│   └── ...（更多依本機版本）
│
├── land/
│   ├── tank_light/                    # 輕型坦克
│   ├── tank_medium/
│   ├── tank_heavy/
│   ├── tank_missile/                  # 飛彈車
│   ├── tank_artillery/                # 自走砲
│   │
│   ├── bot_scout/                     # 偵察機器人
│   ├── bot_bomb/                      # 自爆機器人
│   ├── bot_assault/                   # 突擊機甲
│   ├── bot_heavy/                     # 重型機器人 (Slammer)
│   │
│   ├── engineer_bot_basic/            # 建造機器人
│   ├── engineer_bot_advanced/
│   ├── engineer_land_basic/           # 建造車
│   ├── engineer_land_advanced/
│   │
│   ├── factory_bot_basic/             # 機器人工廠
│   ├── factory_bot_advanced/
│   ├── factory_land_basic/            # 載具工廠
│   ├── factory_land_advanced/
│   │
│   ├── base_turret_basic_l1/          # 基礎砲塔
│   ├── base_turret_advanced_l2/       # 大砲台
│   ├── aa_turret_basic/               # 防空砲台
│   ├── aa_turret_advanced/
│   ├── missile_defense_basic/         # 飛彈塔
│   ├── recon_basic/                   # 雷達
│   ├── recon_advanced/
│   │
│   ├── wall_basic/                    # 圍牆
│   ├── metal_extractor/               # 礦機
│   ├── energy_plant/                  # 太陽能
│   ├── energy_wind/                   # 風力
│   ├── metal_storage/
│   ├── energy_storage/
│   │
│   ├── nuke_launcher/                 # 核彈發射器
│   ├── anti_nuke/                     # 反核
│   └── ...
│
├── air/
│   ├── fighter/                       # 戰鬥機
│   ├── bomber/                        # 轟炸機
│   ├── gunship/                       # 砲艇
│   ├── air_transport/                 # 運輸機
│   ├── air_scout/                     # 偵察機
│   ├── engineer_air_basic/            # 飛行建造機
│   ├── factory_air_basic/             # 飛機工廠
│   ├── factory_air_advanced/
│   └── ...
│
├── sea/
│   ├── frigate/                       # 巡防艦
│   ├── destroyer/                     # 驅逐艦
│   ├── battleship/                    # 戰艦
│   ├── submarine/                     # 潛艇
│   ├── engineer_sea_basic/
│   ├── factory_sea_basic/
│   └── ...
│
├── orbital/
│   ├── orbital_lance/                 # 軌道砲（Annihilaser）
│   ├── orbital_radar/
│   ├── orbital_fighter/
│   ├── engineer_orbital_basic/
│   ├── factory_orbital/
│   └── ...
│
├── ammo/                              # 彈藥（與 units 同級存在於 pa/）
│   └── （見 pa/ammo/）
│
└── unit_types/                        # 基底 base_spec 定義
    ├── mobile_unit.json
    ├── structure.json
    ├── commander.json
    └── ...
```

## 注意事項

- **大寫慣例**：所有資料夾與檔案均小寫，identifier 反向網域中可用小寫字母、數字、`-`。
- **base_spec 鏈**：每個 unit 多繼承 `unit_types/<role>.json`，再層層繼承到 `unit_types/base.json`。Modding 一般不要改 base，只改具體 unit。
- **Ammo 路徑**：unit 的 `tools[].weapon.ammo_id` 指向 `pa/ammo/<id>/<id>.json`，傷害數值改在那邊。
- **DLC 與社群 mod**：Titans 與其他 DLC 會在原路徑中加入新單位；社群 mod（Legion / Nova / Statera）有自己的 unit set，識別前綴各異。

## 全新單位資料夾佈局

若要**建立全新 identifier 的單位**(而非 override 既有單位),mod 內單位資料夾佈局見:

- 完整資產樹 (papa / 紋理 / 動畫):[`_papa-asset-layout.md`](./_papa-asset-layout.md)
- from-scratch 的根 JSON 骨架:[`_new-unit-skeleton.md`](./_new-unit-skeleton.md)
- 完整流程:[`../../workflows/create-new-unit-mod.md`](../../workflows/create-new-unit-mod.md)

## 取得最新目錄樹

PowerShell（建議用 [pa-local-steam-paths skill](../../skills/pa-local-steam-paths/SKILL.md) 解 PA Data 路徑）：

```powershell
Get-ChildItem -Recurse -Directory "$paDataPath\media\pa\units" |
  Select-Object -ExpandProperty FullName
```

把結果回填到本檔即可保持最新。
