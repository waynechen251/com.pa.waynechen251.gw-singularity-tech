# 中文俗稱 ↔ PA Unit 對照表

> 給華語玩家做 vibe coding 用。
> 玩家說「我想改砲塔」，AI 必須能找到實際 identifier 與檔案路徑。
> 三欄式：**中文俗稱** / **identifier 範例** / **檔案路徑模式 + 同義英文**。
> 來源：Palobby Wiki + 本機 PA `media/pa/units/` 抽樣（建議 AI 套用前比對本機原檔確認）。

---

## 1) 指揮官（Commanders）

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 指揮官（通稱） | `commander` | `pa/units/commanders/<id>/...` — Commander |
| 標準指揮官 | `imperial_alpha` | Imperial Alpha |
| Delta 指揮官 | `imperial_delta` | Imperial Delta |
| Omega 指揮官 | `imperial_omega` | Imperial Omega |
| Titans DLC 指揮官 | `progenitor_*` 等 | Progenitor / Centurion 等 |

> 找完整列表：本機 `media/pa/units/commanders/` 目錄下的子資料夾。

---

## 2) 陸戰單位（Land）

### 2.1 步兵 / 機器人

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 機器人（通稱） | `bot_*` | `pa/units/land/bot_*` — Bot |
| 偵察車 / 偵察機器人 | `bot_scout` | Scout Bot |
| 自爆機器人 | `bot_bomb` | Bomb Bot |
| 突擊機甲 | `bot_assault` | Assault Bot |
| 重型機器人 / Slammer | `bot_heavy` | Slammer |

### 2.2 坦克 / 車輛

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 輕型坦克 | `tank_light` | Light Tank / Ant |
| 中型坦克 | `tank_medium` | Medium Tank |
| 重型坦克 | `tank_heavy` | Heavy Tank / Leveler |
| 飛彈車 | `tank_missile` | Missile Tank |
| 火砲 / 自走砲 | `tank_artillery` | Artillery |

### 2.3 工程 / 建造

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 建造機器人（一般） | `engineer_bot_basic` | Combat Fabrication Bot / Fabber Bot |
| 建造車（一般） | `engineer_land_basic` | Fabber Vehicle / Fabber Tank |
| 高級建造機 | `engineer_*_advanced` | Advanced Fabber |

### 2.4 防禦 / 塔台

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 基礎砲塔 | `base_turret_basic_l1` | Single Laser Defense / Pelter |
| 防空砲台 | `aa_turret_*` | Anti-Air Turret / Spinner |
| 飛彈塔 | `missile_defense_*` | Missile Defense |
| 重砲台 / 大砲塔 | `base_turret_advanced_l2` | Advanced Turret / Holkins |
| 雷達塔 | `recon_*` | Radar |
| 圍牆 | `wall_*` | Wall |

---

## 3) 空中單位（Air）

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 戰鬥機 | `fighter` | `pa/units/air/fighter/...` — Fighter |
| 轟炸機 | `bomber` | Bomber |
| 砲艇 / Gunship | `gunship` | Gunship |
| 運輸機 | `air_transport` | Air Transport |
| 偵察機 | `air_scout` | Air Scout |
| 飛行建造機 | `engineer_air_basic` | Air Fabber |

---

## 4) 海軍單位（Naval）

| 中文俗稱 | identifier 範例 | 路徑 / 英文 |
| --- | --- | --- |
| 巡防艦 | `frigate` | `pa/units/sea/frigate/...` — Frigate |
| 驅逐艦 / 戰艦 | `destroyer` / `battleship` | Destroyer / Battleship |
| 潛艇 | `submarine` | Submarine |
| 海軍工程艇 | `engineer_sea_basic` | Naval Fabber |

---

## 5) 工廠（Factory）

| 中文俗稱 | identifier 範例 | 路徑 |
| --- | --- | --- |
| 機器人工廠 | `factory_bot_basic` | `pa/units/land/factory_bot_basic/...` |
| 載具工廠 | `factory_land_basic` | `pa/units/land/factory_land_basic/...` |
| 飛機工廠 | `factory_air_basic` | `pa/units/air/factory_air_basic/...` |
| 海軍船塢 | `factory_sea_basic` | `pa/units/sea/factory_sea_basic/...` |
| 高級工廠 | `factory_*_advanced` | 同上 advanced |

---

## 6) 經濟（Economy）

| 中文俗稱 | identifier 範例 | 路徑 |
| --- | --- | --- |
| 金屬礦機 / 礦場 | `metal_extractor` | `pa/units/land/metal_extractor/...` |
| 太陽能板 | `energy_plant` | Energy Plant |
| 風力發電機 | `energy_wind` | Wind Turbine |
| 礦倉 | `metal_storage` | Metal Storage |
| 能源倉 | `energy_storage` | Energy Storage |

---

## 7) 戰略 / 大殺器

| 中文俗稱 | identifier 範例 | 路徑 |
| --- | --- | --- |
| 核彈發射器 | `nuke_launcher` | Nuke Launcher |
| 反核 | `anti_nuke` | Anti-Nuke |
| 軌道砲 | `orbital_lance` | Orbital Lance |
| 大殺器（俗稱）| 各家 super weapon | 不固定 |

---

## 8) 軌道 / 太空（Orbital）

| 中文俗稱 | identifier 範例 | 路徑 |
| --- | --- | --- |
| 衛星 | `orbital_*` | `pa/units/orbital/...` |
| 軌道工程 | `engineer_orbital_basic` | Orbital Fabber |
| 太空船 / 行星砲 | `orbital_lance` | Annihilaser / Halley |

---

## 9) 家族詞（Pattern Search）

當玩家用模糊詞時，可用下列前綴 grep 本機 `pa/units/`：

| 中文 | grep 前綴 |
| --- | --- |
| 機器人系列 | `bot_*` |
| 坦克系列 | `tank_*` |
| 飛機系列 | `air_*`、`fighter`、`bomber`、`gunship` |
| 工程 / 建造 | `engineer_*`、`fab*` |
| 防禦塔 | `*_turret_*`、`base_*` |
| 工廠 | `factory_*` |
| 雷達 / 偵測 | `recon_*` |
| 軌道 | `orbital_*` |

---

## 10) 找不到時的 fallback

1. 在本機 `media/pa/units/` 用 grep 搜 `display_name` 中的英文關鍵字（玩家可能說「Slammer」「Levellor」）。
2. 開遊戲內建造列表，用滑鼠 hover 看 tooltip 拿英文名，再回查 identifier。
3. PA Stats 之類社群工具網站可看單位列表（最新 build 較準）。
4. 本機 `media/pa/units/unit_list.json` 是所有可建造 unit 的 master list（各陣營分檔）。

---

## 維護注意

- **這份是抽樣，不是完整名單**。Vanilla PA 約有 100+ 個 unit identifier，本檔只列高頻 30-50 條。
- 玩家如有罕見單位需求，AI 應先建議用 fallback 方法查 identifier，再回填到本表。
- Titans DLC 與 PA Inc. 後續更新可能新增單位，請註明本機 build 號。
