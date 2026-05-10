# Unit 3D 模型 (.papa 格式) 與建模管線

> 資料源:Palobby Wiki `Planetary_Annihilation_Papa_Spec`(archived 2021-09-05)+ Blender-PAPA-IO (Luther-1) GitHub README + 本機 PA 抽樣
> 抽樣日期:2026-05-09
> 注意:PA 仍有更新版本,papa 格式版本可能變動,實際以本機 papa 為準。

## ⚠ 整體可信度警示

PA 官方 Wiki 對 3D 建模管線的覆蓋**極為稀薄**。本檔大量依賴:
- Palobby Wiki 的 `Papa_Spec` 頁面 (二進位格式片段)
- 社群工具 Blender-PAPA-IO 與 PTexEdit 的 source code 與 README
- 論壇貼文與本機 papa 反編譯觀察

**任何標 `[CONFIDENCE: COMMUNITY-TOOL]` 或 `[CONFIDENCE: NEEDS-LOCAL-SAMPLING]` 的段落都不可作為權威來源**,使用前請以本機 PA 實測為準。

## 1) .papa 二進位格式概觀

papa 是 PA 自有的二進位資產格式,同副檔名同時用於:
- 模型 (含網格、骨架、材質參考)
- 紋理 (壓縮 / 未壓縮位元圖)
- 動畫 (骨架關鍵幀)

**檔頭結構** (摘自 Palobby Papa Spec):

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `magic` | `char[4]` | `"Papa"` |
| `version` | `uint16` | 通常為 3 |
| `string_table_offset` | `uint64` | 字串表偏移 |
| `texture_table_offset` | `uint64` | 紋理表偏移 |
| `vbuffer_table_offset` | `uint64` | 頂點緩衝偏移 |
| `ibuffer_table_offset` | `uint64` | 索引緩衝偏移 |
| `material_table_offset` | `uint64` | 材質表偏移 |
| `mesh_table_offset` | `uint64` | 網格表偏移 |
| `skeleton_table_offset` | `uint64` | 骨架表偏移 |
| `model_table_offset` | `uint64` | 模型表偏移 |
| `animation_table_offset` | `uint64` | 動畫表偏移 |

頂點格式支援:位置 / 法線 / 切線 / 雙切線 / 4 條骨權重 / 多組 UV。
紋理壓縮支援:DXT1 / DXT3 / DXT5 / 浮點 / 深度。

[CONFIDENCE: WIKI]

## 2) 骨骼命名規範

骨骼名稱**直接影響武器發射、特效掛點、瞄準混合**。錯了會讓子彈從錯位置飛出來。

### 2.1 必備骨

| 骨骼名 | 用途 | 在 unit JSON 哪裡引用 |
| --- | --- | --- |
| `bone_root` | 骨架根節點 | 預設 |
| `bone_turret` | 砲塔旋轉骨 | `tools[].aim_bone`、`tools[].aim_bone_root` |
| `bone_recoil` | 後座力動畫骨 | animation tree 內的 `recoil` type 動畫 |
| `muzzle_<n>` | 砲口位置 | `tools[].muzzle_bones[]` |

### 2.2 慣例命名

| 慣例 | 說明 |
| --- | --- |
| `bone_*` 前綴 | 所有可動骨 |
| `muzzle_*` | 砲口、噴射點 |
| `fx_*` | 視覺特效掛點 (但通常用 `fx_offsets[]` 在 JSON 寫絕對位置而非綁骨) |

### 2.3 範例:坦克骨架命名

```
Armature
├── bone_root
│   ├── bone_chassis
│   │   └── bone_turret
│   │       ├── bone_recoil
│   │       │   ├── muzzle_0
│   │       │   └── muzzle_1
│   │       └── (其他細節骨)
│   └── (履帶等)
```

[CONFIDENCE: COMMUNITY-TOOL]

## 3) 單網格 32 加權骨上限

**PA 引擎限制單個 mesh 最多 32 個有效加權骨**。超過會載入失敗或骨骼變形錯誤。

### 規避方式

- Blender-PAPA-IO 匯出時**自動偵測超限並拆分網格**
- 手動拆分:把模型按部位分成多個 mesh,各自綁少於 32 骨
- 簡化骨架:合併不必要的中間骨

範例:複雜的指揮官常拆成「軀幹網格」+「左臂網格」+「右臂網格」+「頭部網格」+「武器網格」,每個 mesh 只受相關骨影響。

[CONFIDENCE: COMMUNITY-TOOL]

## 4) 紋理三通道

PA 單位紋理用三個 papa 檔組成完整外觀:

| 通道 | 檔名慣例 | 內容 |
| --- | --- | --- |
| **Diffuse** | `<unit_id>_diffuse.papa` | 基底顏色 (RGB) |
| **Mask** | `<unit_id>_mask.papa` | 隊伍色遮罩 (R / G / B 通道對應不同遮罩用途) |
| **Material** | `<unit_id>_material.papa` | 材質參數 (光澤 / 金屬度 / 發光等) — 藍色通道 (B) 為 CSG 自發光遮罩 |

未自定義紋理時 PA 會找預設名稱:
- `model_diffuse.papa`
- `model_mask.papa`
- `model_material.papa`

**注意**:選擇主模型 papa 時避免命名為 `*_blend.papa` / `*_diffuse.papa` 等後綴,引擎會誤判為紋理檔。

[CONFIDENCE: COMMUNITY-TOOL]

## 5) papatran.exe 流程

PA 客戶端內建 `papatran.exe`,負責:
- FBX → papa 模型轉換
- PNG → papa 紋理編譯

### 典型 CLI

```powershell
# 模型 (FBX → papa)
& "$paInstall\bin_x64\papatran.exe" --input model.fbx --output model.papa

# 紋理 (PNG → papa,含 DXT 壓縮)
& "$paInstall\bin_x64\papatran.exe" --input texture.png --output texture.papa

# 單材質模式
& "$paInstall\bin_x64\papatran.exe" --input model.fbx --output model.papa --single-material
```

詳細選項見 [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md)。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 6) Blender-PAPA-IO 安裝與匯出設定

社群維護的 Blender 外掛 (Luther-1 fork 自 Raevn 原作),是目前最完整的 papa 工作流入口。

- Repo: https://github.com/Luther-1/Blender-PAPA-IO
- 支援:模型 import / export、紋理 import / export、動畫 export
- Blender 版本:依 README 指定 (通常 2.9x ~ 3.x)

### 安裝

1. 從 GitHub 下載 ZIP
2. Blender → Edit → Preferences → Add-ons → Install
3. 啟用 "Import-Export: Papa I/O"

### 匯出模型流程

1. 確保物件原點對齊 (origin to world center)
2. Armature 父於網格,網格用 Vertex Groups 綁骨
3. 骨骼名稱遵守 §2 規範
4. File → Export → Papa (.papa)
5. 檢查 console 有無「超過 32 骨」警告,若有則確認自動拆分結果

[CONFIDENCE: COMMUNITY-TOOL]

## 7) PTexEdit 通道打包

PTexEdit (Java) 用於把多通道 PNG 合併到單一 papa 紋理 (例如 mask 的 RGB 三通道分別編碼不同遮罩)。

- Repo: https://github.com/Luther-1/PTexEdit
- 替代品:DeathByDenim 的 https://github.com/DeathByDenim/papatextureeditor

實務工作流:
1. Blender 烘焙 (bake) 出三個 PNG (diffuse / mask / material)
2. PTexEdit 開 PNG → 設定壓縮格式 (通常 DXT5) → 匯出 papa
3. 放到 mod 內 `pa/units/<class>/<unit_id>/<unit_id>_<channel>.papa`

[CONFIDENCE: COMMUNITY-TOOL]

## 8) LOD 與碰撞

**Wiki 未明確記載**:
- papa spec 有 `num_meshes` 欄位,理論上單 papa 可含多個 LOD 網格
- 但 LOD 切換距離、碰撞網格定義方式都缺官方文件
- 社群實務:目前看到的單位 papa 多為單網格,無明確 LOD 機制
- 碰撞通常依靠引擎自動產生的 bounding box,而非自訂碰撞網格

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

## 9) 待驗清單 (NEEDS-LOCAL-SAMPLING)

下列項目本檔以推測或社群片段為主,使用前請以本機 PA 實測:

- §1 papa 格式版本是否在新版 PA 改動 (用 hex viewer 檢查本機 papa 檔頭 version 欄位)
- §2 完整骨骼命名清單 — 抽樣不同類型單位 (坦克 / 機器人 / 飛機 / 指揮官) 的 papa,看實際骨骼名
- §4 mask 與 material 通道的 RGB 分配規則 — 反編譯本機 papa 紋理確認
- §5 papatran.exe 完整 CLI 選項 — 跑 `papatran.exe --help` 取輸出
- §8 LOD 與碰撞機制 — 需在 PA bug 修報或社群 Discord 詢問

驗證腳本片段:

```powershell
# 從本機抓一個有複雜骨架的單位 papa,用 Blender-PAPA-IO 匯入後檢查骨架命名
$paDataPath = (Get-Content .agent\env\pa-local.env | Where-Object { $_ -match "PA_DATA" }) -replace "PA_DATA=", ""
Copy-Item "$paDataPath\media\pa\units\land\bot_heavy\bot_heavy.papa" .\sample.papa
# 在 Blender 內 File → Import → Papa,檢查 Armature
```

## 參考來源

- https://wiki.palobby.com/wiki/Planetary_Annihilation_Papa_Spec
- https://github.com/Luther-1/Blender-PAPA-IO
- https://github.com/Luther-1/PTexEdit
- https://github.com/DeathByDenim/papatextureeditor
