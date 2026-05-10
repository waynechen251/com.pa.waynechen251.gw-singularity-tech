# Papa 資產目錄佈局

> 資料源:Palobby Wiki `Mod_Structure` + 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:本檔僅列路徑模式,**不打包二進位資產**(版權邊界,見 `pa-modding-core.md` § 10)。

## 目的

PA 引擎透過 unit JSON 的 `model.filename` 欄位找模型,但實際的 papa 檔、紋理檔、動畫檔擺放位置有命名與路徑慣例。新單位 mod 內的資產樹要對齊這些慣例,引擎才會自動找到對應通道。

## 完整單位資產樹

```
server_mods/<identifier>/
└── pa/units/<class>/<unit_id>/
    │
    ├── <unit_id>.json                             # 主規格 JSON
    │
    ├── <unit_id>.papa                             # ★ 主模型 (網格 + 骨架)
    │
    ├── <unit_id>_diffuse.papa                     # 基底顏色貼圖
    ├── <unit_id>_mask.papa                        # 隊伍色遮罩
    ├── <unit_id>_material.papa                    # 材質通道
    │
    ├── <unit_id>_anim.json                        # animation tree (狀態機)
    │
    └── anim/                                      # 動畫資源 (慣例放子資料夾)
        ├── <unit_id>_idle.papa
        ├── <unit_id>_walk.papa
        ├── <unit_id>_fire.papa
        ├── <unit_id>_die.papa
        ├── <unit_id>_build.papa                   # being_built 動畫
        └── <unit_id>_recoil.papa                  # 武器後座力 (進階)
```

### `<class>` 取值

| class | 對應領域 |
| --- | --- |
| `land` | 地面單位 (坦克、機器人、塔台、礦機) |
| `air` | 飛行單位 |
| `sea` | 水面 / 水下單位 |
| `orbital` | 軌道單位 |
| `commanders` | 指揮官 |

## 命名慣例規則

1. **全小寫**:資料夾與檔名全小寫,只用 `a-z 0-9 _`
2. **底線分隔**:多字單位用 `_` 分隔 (例 `heavy_bot`、`tank_artillery`)
3. **副檔名小寫**:`.papa`、`.json`
4. **紋理後綴標準化**:`_diffuse` / `_mask` / `_material`,引擎自動找這三個後綴
5. **動畫慣例放 `anim/`**:不強制,但本機原檔大多如此

## 取本機原始路徑的腳本片段

要對照本機某類型單位實際資料夾結構:

```powershell
# 取 PA Data 路徑 (依 .agent/skills/pa-local-steam-paths/SKILL.md 流程)
$paDataPath = ((Get-Content "$PWD\.agent\env\pa-local.env" -ErrorAction Stop) -match "^PA_DATA=") -replace "^PA_DATA=", ""

# 列出本機某類型單位的完整資產樹
Get-ChildItem -Recurse "$paDataPath\media\pa\units\land\bot_heavy" |
  Select-Object Name, Length, FullName |
  Format-Table -AutoSize

# 列出所有有完整三紋理通道的單位
Get-ChildItem -Recurse -Filter "*_diffuse.papa" "$paDataPath\media\pa\units" |
  Select-Object DirectoryName -Unique
```

## 引擎查找順序

PA 載入單位資產時:

1. **JSON 內顯式路徑優先**:`model.filename` 寫什麼用什麼
2. **同資料夾自動匹配**:若 JSON 沒列 `_mask.papa` 等,引擎在主 papa 同資料夾找對應後綴
3. **mod 路徑優先於原檔**:server_mods 內若有同路徑 papa,覆蓋原檔
4. **預設 fallback**:同資料夾沒紋理時,用 `model_diffuse.papa` 等預設名

[CONFIDENCE: COMMUNITY-TOOL]

## 體積優化建議

- 紋理用 DXT5 壓縮 (papatran 預設),可省 75% 體積
- 不需要動畫的單位省略 `anim/` 資料夾
- 共用模型的多個變體 (策略 A) 共用同一份 papa,各 unit_id 的 JSON 都指向同一檔案
- 不要把 PSD / FBX 原始檔放進 mod,只放編譯後的 papa

## 與其他資產的關聯

| 主題 | 不在本資料夾,但相關 |
| --- | --- |
| ammo JSON | `pa/ammo/<ammo_id>/<ammo_id>.json` (與單位平行) |
| ammo 模型 (子彈、飛彈) | `pa/ammo/<ammo_id>/<ammo_id>.papa` |
| 特效 spec | `pa/effects/specs/...` |
| 戰略 icon | `pa/effects/specs/strategic_icons/...` (通常 client 端) |
| build icon (UI) | `ui/main/game/icons/build_bar/...` (client mod 內) |
| 字串表 (i18n) | `ui/main/main/strings/...` (client mod 內) |

## 待驗清單 (NEEDS-LOCAL-SAMPLING)

- 引擎查找順序 (§「引擎查找順序」第 2、4 點) 為從社群實踐推斷,需從 PA log debugger 抓「找不到資產」的 fallback 訊息驗證
- `anim/` 子資料夾是否強制 — 部分老單位資產直接放在主資料夾根層,動畫 papa 與主 papa 同層
