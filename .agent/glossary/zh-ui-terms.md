# UI 中文術語 ↔ PA Scene / Model 對照表

> 玩家用 UI 中文術語提需求，AI 必須能定位到對應的 scene 與 model.* observable。
> 三欄式：**中文術語** / **scene 名** / **主要 model.* 與英文**。
> 配套：[scene-models.md](../knowledge/scene-models.md) 看完整 model 表。

---

## 1) 主介面 / 流程 scene

| 中文術語 | scene | 主要 model / 英文 |
| --- | --- | --- |
| 主選單 / 開始畫面 | `start` | `model.userName`, `model.installedMods` — Main Menu |
| 大廳 / 房間 / 開戰前 | `new_game` | `model.players`, `model.chatMessages`, `model.armies` — Lobby |
| 戰場 / 遊戲中 | `live_game` | `model.alerts`, `model.selection`, `model.timeElapsed` — In-Game |
| 房間瀏覽 / 找房 | `server_browser` | `model.servers`, `model.filter` — Server Browser |
| 設定 / 偏好 | `settings` | `model.settings`, `model.audioSettings` — Settings |
| 連線中 / 過場 | `connect_to_game` | — — Connecting |
| 模組管理 | `community_mods` | `model.installedMods`, `model.availableMods` — Community Mods |

---

## 2) 戰場 HUD 元素

| 中文術語 | 對應 model / DOM |
| --- | --- |
| 聊天 / 戰場聊天 | `model.chatLog` |
| 警告 / 警告列 | `model.alerts` |
| 倒數 / 開戰時間 | `model.timeElapsed`, `model.gameStartTime` |
| 暫停 | `model.paused` |
| 經濟列 / 金屬流 | `model.metalIncome`, `model.metalStorage` |
| 經濟列 / 能源流 | `model.energyIncome`, `model.energyStorage` |
| 選取資訊 / 選中單位 | `model.selection` |
| 建造列表 / 建造選單 | DOM: `.build_bar`, `.unit_carousel` |
| 小地圖 | DOM: `.minimap`, `model.cameraTarget` |
| 指揮官狀態 | `model.commanderIsAlive`, `model.commanders` |

---

## 3) 大廳元素

| 中文術語 | 對應 model |
| --- | --- |
| 玩家列 / 軍隊列 | `model.players`, `model.armies` |
| 大廳聊天 | `model.chatMessages` |
| AI 設定 | `model.aiDifficulty`, `model.aiPlayers` |
| 系統 / 星系編輯 | `model.systemEditorVisible`, `model.systemConfig` |
| 開戰按鈕 | `model.canStart`（computed） |
| 遊戲設定 / 規則 | `model.gameOptions` |
| 觀戰 | `model.spectators` |

---

## 4) 設定頁

| 中文術語 | 對應 model |
| --- | --- |
| 圖形設定 | `model.graphicsSettings` |
| 音量 / 音效 | `model.audioSettings` |
| 鍵盤 / 快捷鍵 | `model.keybindings` |
| 介面語言 | `model.locale` |

---

## 5) GW（Galactic War）相關

| 中文術語 | scene / 路徑 |
| --- | --- |
| 戰役 / Galactic War | scene `galactic_war/*` |
| 卡片 / 卡牌 | `pa/galactic_war/cards/...`（資料）|
| 星圖 | scene `galactic_war/galaxy_view` |
| 倉庫 / 卡庫 | scene `galactic_war/inventory` |

---

## 6) 中文同義詞補充

不同人對同一 UI 元素有多種講法，列舉常見：

| 中文 | 等同術語 | 對應 |
| --- | --- | --- |
| 大廳 | 房間、開戰前 | `new_game` scene |
| 戰場 | 遊戲中、開戰中、對戰中 | `live_game` scene |
| 警告 | 警報、提示、通知 | `model.alerts` |
| 建造列表 | 建造列、單位列、生產列 | `.build_bar` DOM |
| 礦機 / 礦場 | 採礦點、提取機 | `metal_extractor` unit |
| 工廠 | 生產設施 | `factory_*` unit |
| 指揮官 | 機甲、Commander、CC | `commander` unit |

---

## 7) 找對應 model 的 fallback 流程

當玩家提到的元素不在本表時：

1. 開遊戲，按 F12（或啟動加 `--debug`）開啟 DevTools。
2. 在對應 scene 的 console 印 `Object.keys(model)` 列出所有 observable。
3. 用滑鼠 inspect 想 hook 的 DOM 元素，看 `data-bind` 拿 KO binding 的 model 路徑。
4. 用 `ko.dataFor(element)` 拿任意 DOM 對應的 model context。

---

## 8) 與其他知識銜接

- 完整 model 表 → [knowledge/scene-models.md](../knowledge/scene-models.md)
- 想做某 UI 行為的範例 → [cookbook/ui-hook-recipes.md](../cookbook/ui-hook-recipes.md)
- 想做提示音 → [cookbook/chat-alert.md](../cookbook/chat-alert.md)
- 想找單位中文俗稱 → [glossary/zh-unit-terms.md](./zh-unit-terms.md)
