# Papa 工具鏈速查 (papatran / Blender-PAPA-IO / PTexEdit)

> 資料源:Blender-PAPA-IO README + 社群論壇實踐 + papatran.exe --help 抽樣
> 抽樣日期:2026-05-09
> 注意:本檔大量依賴**社群工具**,並非 PA 官方文件。工具版本變動會讓部分指令失效,使用前以工具當前 README 為準。

## ⚠ 整體可信度警示

PA 官方對 3D 工具鏈幾乎無文件。本檔內容主要從:
- Blender-PAPA-IO 與 PTexEdit GitHub README
- 社群論壇貼文
- 本機 `papatran.exe --help` 輸出 (需自行驗證版本)

[CONFIDENCE: COMMUNITY-TOOL]

---

## 1) papatran.exe CLI

PA 客戶端內建工具,通常位於:

```
<Steam>\steamapps\common\Planetary Annihilation Titans\bin_x64\papatran.exe
```

### 1.1 模型轉換 (FBX → papa)

```powershell
$papatran = "$env:PA_INSTALL\bin_x64\papatran.exe"

# 基本轉換
& $papatran --input "model.fbx" --output "model.papa"

# 單一材質模式 (避免拆 mesh)
& $papatran --input "model.fbx" --output "model.papa" --single-material
```

### 1.2 紋理轉換 (PNG → papa)

```powershell
# 基本紋理 (papatran 會自動選 DXT 壓縮)
& $papatran --input "diffuse.png" --output "diffuse.papa"

# 強制不壓縮 (除錯用)
& $papatran --input "diffuse.png" --output "diffuse.papa" --no-compress
```

### 1.3 取得當前可用選項

```powershell
& $papatran --help
```

CLI 旗標會隨 PA 版本變動,以本機輸出為準。

[CONFIDENCE: NEEDS-LOCAL-SAMPLING]

---

## 2) Blender-PAPA-IO 匯出設定

- Repo: https://github.com/Luther-1/Blender-PAPA-IO
- Blender 版本:依 README (通常 2.9x ~ 3.x)

### 2.1 安裝

1. Blender → Edit → Preferences → Add-ons → Install...
2. 選擇下載的 Blender-PAPA-IO ZIP
3. 啟用 "Import-Export: Papa I/O"

### 2.2 匯入既有 papa

`File → Import → Papa (.papa)`,選 PA 內建單位 papa,在 Blender 內檢查骨架命名與網格結構。常見用途:
- 對照本檔規範驗證骨骼命名
- 把模型作為新單位的參考底模

### 2.3 匯出新模型

工作流:

1. **建模**:在 Blender 建立 mesh
2. **骨架**:Add → Armature,骨骼用 `bone_*` / `muzzle_*` 命名
3. **綁骨**:選 mesh → Object Parent → Armature Deform With Automatic Weights
4. **檢查 32 骨上限**:每個 mesh 最多 32 加權骨,超過要拆
5. **匯出**:`File → Export → Papa (.papa)`
6. **檢查 console**:有無「Too many bones」「Missing armature」等警告

### 2.4 匯出設定要點

| 選項 | 建議值 | 說明 |
| --- | --- | --- |
| Apply Modifiers | ☑ | 匯出前應用 modifier |
| Selected Only | ☐ / ☑ | 視場景而定 |
| Export Animation | ☐ (匯模型時) | 動畫另開檔匯出 |

### 2.5 匯出動畫

1. 確認 Action 已選 (Animation Editor)
2. `File → Export → Papa Animation`
3. 動畫 papa 不含網格,只含骨架 keyframes

[CONFIDENCE: COMMUNITY-TOOL]

---

## 3) PTexEdit 通道打包

- Repo: https://github.com/Luther-1/PTexEdit
- 替代:https://github.com/DeathByDenim/papatextureeditor

### 用途

PA 紋理常需要「多通道合併」(例如 mask 的 R/G/B 三通道分別代表三種遮罩)。PTexEdit 把多張 PNG 合併到一個 papa。

### 流程

1. Blender 烘焙 (bake) 出獨立 PNG (例如 ao.png、metallic.png、emissive.png)
2. PTexEdit 開啟 → New → 設定通道對應:
   - R 通道 ← ao.png (灰階)
   - G 通道 ← metallic.png
   - B 通道 ← emissive.png
3. 設定壓縮 (DXT5 通常是預設)
4. Export → `<unit_id>_material.papa`

[CONFIDENCE: COMMUNITY-TOOL]

---

## 4) 常見錯誤對應表

| 錯誤訊息 / 症狀 | 原因 | 解法 |
| --- | --- | --- |
| Blender 匯出時「Too many bones in mesh」 | 單 mesh 超過 32 加權骨 | 拆 mesh 或簡化骨架 |
| 遊戲內模型不顯示 | `model.filename` 路徑錯 / 大小寫不符 | PA 全小寫,檢查 JSON 路徑 |
| 武器子彈從錯位置射出 | `tools[].aim_bone` 對應的骨在 papa 不存在 | 用 Blender 開 papa 看實際骨骼名 |
| 紋理變紫色 / 缺失 | `_diffuse` / `_mask` / `_material` 命名錯 | 後綴必須完全符合 |
| 遊戲載入時 crash | papa 編譯失敗或版本不符 | 用 papatran 重新編譯 |
| 動畫不播放 | `model.animations` 路徑錯或 animtree 漏寫 | 對照本機既有單位 JSON 結構 |
| 動畫骨骼錯位 | 動畫 papa 與模型 papa 骨架不一致 | 用同一份 Armature,別重綁 |

---

## 5) 完整工作流範例 (從 Blender 到 mod)

```powershell
# 1. Blender 內匯出
#    File → Export → Papa
#    Output: D:\work\heavy_bot.papa

# 2. 烘焙紋理 (Blender Bake)
#    Output: D:\work\heavy_bot_diffuse.png
#            D:\work\heavy_bot_mask.png
#            D:\work\heavy_bot_material.png

# 3. PNG → papa (papatran 直接轉,無多通道合併情境)
$papatran = "$env:PA_INSTALL\bin_x64\papatran.exe"
& $papatran --input "D:\work\heavy_bot_diffuse.png" --output "D:\work\heavy_bot_diffuse.papa"
& $papatran --input "D:\work\heavy_bot_mask.png"    --output "D:\work\heavy_bot_mask.papa"
& $papatran --input "D:\work\heavy_bot_material.png" --output "D:\work\heavy_bot_material.papa"

# 4. 複製到 mod
$modRoot = "D:\mods\com.example.heavy-bot\pa\units\land\heavy_bot"
New-Item -ItemType Directory -Path $modRoot -Force | Out-Null
Copy-Item "D:\work\heavy_bot*.papa" $modRoot

# 5. 部署到本機 PA (依 .agent/skills/pa-local-steam-paths/SKILL.md)
& "$PWD\.agent\skills\pa-local-steam-paths\scripts\deploy-mod.ps1" -ModPath "D:\mods\com.example.heavy-bot"
```

## 待驗清單 (NEEDS-LOCAL-SAMPLING)

- §1.1 完整 papatran CLI 旗標列表 — 跑本機 `papatran.exe --help` 確認
- §1.2 紋理壓縮格式選項 — papatran 是否能指定 DXT1 / DXT3 / DXT5 / 不壓縮
- §2.5 動畫匯出時是否要 / 不要勾「Apply Transform」等選項 — 需從 Blender-PAPA-IO 當前版本 README 確認
- §3 PTexEdit 與 papatextureeditor 的功能差異 — 兩者是否能互相替代

## 參考來源

- https://github.com/Luther-1/Blender-PAPA-IO
- https://github.com/Luther-1/PTexEdit
- https://github.com/DeathByDenim/papatextureeditor
- https://wiki.palobby.com/wiki/Planetary_Annihilation_Papa_Spec
