# 建模 / 動畫術語中英對照

> 資料源:Blender 與一般 3D 圖學術語對照 + PA 特有命名
> 抽樣日期:2026-05-09
> 用途:玩家用中文俗稱描述建模 / 動畫需求時,agent 把它對應到正確的英文 identifier 或 PA 引擎欄位。

## 1) 通用 3D 術語

| 中文 | 英文 | 在 PA 對應 |
| --- | --- | --- |
| 模型 / 網格 | model / mesh | `model.filename` 內的 papa |
| 頂點 | vertex | papa 內 vbuffer |
| 三角面 / 多邊形 | triangle / polygon | papa 內 ibuffer |
| 法線 | normal | papa vertex 屬性 |
| 切線 | tangent | papa vertex 屬性 |
| UV 座標 / UV 展開 | UV / UV unwrap | papa vertex 屬性 |
| 紋理 / 貼圖 | texture | `_diffuse.papa` 等 |
| 材質 | material | papa 內 material table |
| 著色器 | shader | PA 內建固定 shader |
| 法線貼圖 | normal map | 通常烘焙進 material 通道 |
| 鏡面貼圖 / 高光 | specular map | material 通道 |
| 環境光遮蔽 | ambient occlusion (AO) | mask 或 material 通道 |
| 烘焙 (貼圖) | bake | Blender bake 功能 |

## 2) 骨架 / 動畫術語

| 中文 | 英文 | 在 PA 對應 |
| --- | --- | --- |
| 骨架 | armature / skeleton | papa 內 skeleton table |
| 骨骼 | bone | `bone_*` 命名 |
| 根骨 | root bone | `bone_root` |
| 加權 / 蒙皮 | weighting / skinning | Blender Vertex Groups |
| 關鍵幀 | keyframe | papa 動畫 frames |
| 動畫狀態 | animation state | `unit_state` (being_built / living / dead) |
| 狀態機 | state machine | `model.animtree` JSON |
| 過渡 / 混合 | transition / blend | animtree 的 `transitions` |
| 程序動畫 | procedural animation | `procedural_aim` |
| 瞄準混合 | aim blend | animtree 的 `aim_blend` type |
| 後座力 | recoil | animation type (非 event) |
| 砲口 | muzzle | `muzzle_*` 骨 |
| 砲口閃光 | muzzle flash | 特效 (event 觸發) |
| 待機動畫 | idle animation | animtree `idle` 狀態 |
| 行走動畫 | walk animation | animtree `walk` 狀態 |
| 攻擊動畫 | fire / attack animation | animtree `fire` 狀態 |
| 死亡動畫 | death animation | unit_state `dead` |
| 建造動畫 | being_built animation | unit_state `being_built` |
| 布娃娃物理 | ragdoll | PA 未明確支援 |

## 3) PA 特有術語

| 中文 | 英文 / 識別子 | 說明 |
| --- | --- | --- |
| 隊伍色 | team color | 透過 mask 通道控制 |
| 遮罩通道 | mask channel | `_mask.papa`,RGB 對應不同遮罩 |
| 材質通道 | material channel | `_material.papa`,B 通道為自發光 |
| 戰略 icon | strategic icon | 戰略視圖縮放後的 PNG icon |
| 建造 icon | build icon | build bar 縮圖 |
| 選取圈 | selection icon | unit 被選時的圈圈 |
| 標籤 | unit_types tag | `UNITTYPES_*` |
| 可建造列表 | buildable types | 工廠的 `buildable_types` 運算式 |
| 基底規格 | base spec | `base_spec` (繼承來源) |
| 工具槽 | tool / tool slot | `tools[]` 陣列項 |
| 武器槽 | weapon slot | `tools[]` 內的 weapon 子物件 |
| 建造臂 | build arm | `tools[].build_arm` |
| 視野 | sight / observer | `recon.observer` |
| 雷達 | radar | `recon.observer` 的 channel: radar |

## 4) 工具鏈專有名詞

| 中文 | 英文 | 工具 |
| --- | --- | --- |
| Blender 外掛 | Blender add-on | Blender-PAPA-IO |
| 紋理編輯器 | texture editor | PTexEdit / papatextureeditor |
| 紋理通道打包 | channel packing | PTexEdit 功能 |
| 模型編譯器 | model compiler | papatran.exe |
| 壓縮 | compression | DXT1 / DXT3 / DXT5 |
| 多細節層次 | LOD (Level of Detail) | PA 支援度低 (見 [unit-model-papa.md](../knowledge/unit-model-papa.md) §8) |

## 5) 從中文需求路由到文件的速查

| 玩家說 | agent 應該查 |
| --- | --- |
| 「想做新坦克 / 新機器人」 | [workflows/create-new-unit-mod.md](../workflows/create-new-unit-mod.md) |
| 「想建模匯出到 PA」 | [knowledge/unit-model-papa.md](../knowledge/unit-model-papa.md) + [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md) |
| 「動畫怎麼接」 | [knowledge/unit-animation.md](../knowledge/unit-animation.md) |
| 「骨骼名稱要什麼」 | [knowledge/unit-model-papa.md](../knowledge/unit-model-papa.md) §2 |
| 「貼圖通道」/「mask」/「material」 | [knowledge/unit-model-papa.md](../knowledge/unit-model-papa.md) §4 |
| 「Blender 外掛」 | [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md) §2 |
| 「papatran 是什麼」 | [cookbook/papa-toolchain-cheatsheet.md](../cookbook/papa-toolchain-cheatsheet.md) §1 |
| 「為什麼工廠看不到我的新單位」 | [knowledge/unit-types-and-buildable.md](../knowledge/unit-types-and-buildable.md) §5 |
