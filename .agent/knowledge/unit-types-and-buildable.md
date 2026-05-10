# Unit Types 標籤系統與 Buildable Types 運算式

> 資料源:Palobby Wiki 封存(archived 2021-09-05)+ 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:PA 仍有更新版本,實際以本機 `media/pa/units/...` 為準。

## 目的

PA 的單位「能不能被某工廠生產」、「在 build bar 哪個分頁顯示」、「電腦 AI 會不會選用」**全靠標籤系統**。新單位若沒掛對標籤,就算 JSON 完美也不會出現在遊戲裡。

## 1) UNITTYPES_* 常用標籤值

下表為從本機 `media/pa/units/` 抽樣彙整的常見標籤,並非完整清單。

### 1.1 領域 (Domain)

| 標籤 | 意義 |
| --- | --- |
| `UNITTYPES_Mobile` | 可移動 |
| `UNITTYPES_Structure` | 靜態建築 |
| `UNITTYPES_Land` | 地面 |
| `UNITTYPES_Air` | 空中 |
| `UNITTYPES_Naval` | 海上 |
| `UNITTYPES_Orbital` | 軌道 |
| `UNITTYPES_Amphibious` | 兩棲 |

### 1.2 類型 (Type)

| 標籤 | 意義 |
| --- | --- |
| `UNITTYPES_Tank` | 坦克 |
| `UNITTYPES_Bot` | 機器人 |
| `UNITTYPES_Fighter` | 戰鬥機 |
| `UNITTYPES_Bomber` | 轟炸機 |
| `UNITTYPES_Gunship` | 砲艇 |
| `UNITTYPES_Frigate` | 巡防艦 |
| `UNITTYPES_Destroyer` | 驅逐艦 |
| `UNITTYPES_Submarine` | 潛艇 |
| `UNITTYPES_Commander` | 指揮官 |
| `UNITTYPES_SupportCommander` | 副指揮官 |
| `UNITTYPES_Fabber` | 建造機 |
| `UNITTYPES_Factory` | 工廠 |

### 1.3 科技層級 (Tech Tier)

| 標籤 | 意義 |
| --- | --- |
| `UNITTYPES_Basic` | T1 / 基礎 |
| `UNITTYPES_Advanced` | T2 / 進階 |

### 1.4 角色 (Role)

| 標籤 | 意義 |
| --- | --- |
| `UNITTYPES_AntiAir` | 防空 |
| `UNITTYPES_AntiSurface` | 對地 |
| `UNITTYPES_AntiNaval` | 對艦 |
| `UNITTYPES_AntiBot` | 反步兵 |
| `UNITTYPES_Defense` | 防禦塔 |
| `UNITTYPES_Recon` | 偵察 |
| `UNITTYPES_Artillery` | 火砲 |
| `UNITTYPES_Energy` | 能源產生 |
| `UNITTYPES_Metal` | 金屬產生 |
| `UNITTYPES_Storage` | 儲存設施 |
| `UNITTYPES_Wall` | 圍牆 |

### 1.5 自訂擴展 (Modding)

| 標籤 | 意義 |
| --- | --- |
| `UNITTYPES_Custom1` ~ `UNITTYPES_Custom4` | 給 modder 用的擴展 tag |

> 完整可用標籤需以本機 `media/pa/units/unit_types/*.json` 為準 — 不同 PA 版本與 DLC 會新增。

[CONFIDENCE: WIKI]

## 2) Buildable Types 布林運算式

工廠的 `buildable_types` 不是字串陣列,而是**布林運算式字串**:

| 運算子 | 意義 | 範例 |
| --- | --- | --- |
| `&` | 且 (AND) | `UNITTYPES_Bot & UNITTYPES_Basic` |
| `|` | 或 (OR) | `UNITTYPES_Tank | UNITTYPES_Bot` |
| `!` | 非 (NOT) | `!UNITTYPES_Commander` |
| `*` | 全部 | `*` |
| 括號 | 分組 | `(A | B) & !C` |

### 範例

從本機抽樣的工廠 `buildable_types` (示意,實際以本機為準):

```json
// 基礎機器人工廠 — 只造 T1 機器人
{ "buildable_types": "UNITTYPES_Mobile & UNITTYPES_Land & UNITTYPES_Bot & UNITTYPES_Basic" }

// 進階載具工廠 — 造 T2 坦克類
{ "buildable_types": "UNITTYPES_Mobile & UNITTYPES_Land & UNITTYPES_Tank & UNITTYPES_Advanced" }

// 工程建造機 (Fabber) — 能造絕大部分建築,排除某些特殊類
{ "buildable_types": "UNITTYPES_Structure & !UNITTYPES_Commander & !UNITTYPES_Factory" }
```

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 3) 把新單位掛入既有工廠的兩種方式

### 方式 A:在新單位的 unit_types[] 加既有工廠匹配的標籤

**最常用、不破壞既有平衡**。新單位自己宣告適合的 tag,既有工廠的 buildable_types 自動匹配。

```json
// 新「重型機器人」要被進階機器人工廠生產
{
  "unit_types": [
    "UNITTYPES_Mobile",
    "UNITTYPES_Land",
    "UNITTYPES_Bot",
    "UNITTYPES_Advanced"   // ← 這個讓進階機器人工廠看見它
  ]
}
```

優點:
- 不需 override 任何既有檔
- 與其他 mod 衝突風險低
- 新單位自動納入 AI build templates (若 AI 用同樣標籤搜尋)

### 方式 B:Override 工廠的 buildable_types

當新單位的「分類」沒有對應既有 tag 時,得改工廠 buildable_types。例如做一個全新類型「跳躍機器人」(`UNITTYPES_JumpBot`),需要在工廠端把該 tag 加入運算式。

```json
// override pa/units/land/factory_bot_advanced/factory_bot_advanced.json
{
  "buildable_types": "UNITTYPES_Mobile & UNITTYPES_Land & UNITTYPES_Bot & UNITTYPES_Advanced | UNITTYPES_JumpBot"
}
```

風險:
- 與其他改同工廠的 mod 衝突
- 必須完整重寫整個運算式 (不能只 patch 局部)
- 維護成本高 (PA 更新工廠時要重新比對)

**建議**:能用方式 A 解的就不要走 B。

[CONFIDENCE: WIKI]

## 4) 與 base_spec 繼承的交互

`unit_types[]` **不會自動繼承**:子 unit JSON 寫了就用子的,沒寫才用 base_spec 的。

但 `unit_types[]` 在 mod override 時是**整段替換**而非合併:

```json
// 假設原 bot_assault.json 有 unit_types: ["UNITTYPES_Mobile", "UNITTYPES_Bot", "UNITTYPES_Basic"]
// mod 寫:
{ "unit_types": ["UNITTYPES_Mobile"] }
// 結果:覆寫成只有 ["UNITTYPES_Mobile"],其他標籤都丟了 → 工廠看不到、AI 不選用
```

**新單位的 `unit_types[]` 必須完整列出所有需要的 tag**,不能只列差異。

[CONFIDENCE: WIKI]

## 5) 過濾器除錯

新單位掛標籤後 build bar 看不到怎麼辦:

1. 確認本機原始工廠 JSON 的 `buildable_types` 運算式 — `Select-String -Path "$paDataPath\media\pa\units\land\factory_bot_advanced\factory_bot_advanced.json" -Pattern "buildable_types"`
2. 把運算式逐項拆開,確認新單位的 `unit_types[]` 至少滿足所有 `&` 條件、不踩任何 `!` 條件
3. 確認 `UNITTYPES_*` 拼字 (大小寫敏感,有些 PA 版本是 `UnitTypes_*`)
4. 確認沒有寫成 string array 而是 string (tag 是字串陣列,但 buildable_types 是運算式字串)

工具:[skills/pa-log-debugger/SKILL.md](../skills/pa-log-debugger/SKILL.md) 的 scan 腳本能抓 buildable_types 解析失敗時的 log。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 6) 待驗清單 (NEEDS-LOCAL-SAMPLING)

- §1 完整 UNITTYPES_* 列表需與本機 `media/pa/units/unit_types/*.json` 比對更新
- §2 `*` 萬用字元行為 (是否真的匹配所有,或排除某些隱藏類型) 需本機驗證
- §2 括號分組行為 — Wiki 未明示優先權順序,可能要看 PA parser 行為
- §4 `unit_types[]` 是否真的整段替換 — 從幾個 mod 範例觀察推斷,需用本機 PA 實測 mod 效果確認
