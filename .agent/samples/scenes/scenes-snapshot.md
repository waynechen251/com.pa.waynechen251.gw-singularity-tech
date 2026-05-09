# Scene Model 名單快照（扁平 grep 用）

> 從本機 PA `media/ui/main/<scene>/<scene>.js` 抽出的 `model.*` 名單。
> 配合 [knowledge/scene-models.md](../../knowledge/scene-models.md) 使用 — 那邊有完整解說，本檔只列名單方便 grep。
> 抽樣日期：2026-05-09。
> 注意：版本更新會新增/移除 observable，請定期同步。

---

## start

```
model.userName
model.titansEnabled
model.installedMods
model.canConnect
model.region
model.uberId
model.galaxiesAvailable
```

---

## new_game

```
model.players
model.armies
model.spectators
model.chatMessages
model.chatTextEntered
model.aiPlayers
model.aiDifficulty
model.gameOptions
model.systemConfig
model.systemEditorVisible
model.canStart
model.starting
model.serverIsLocal
model.serverType
model.gameMode
```

---

## live_game

```
model.chatLog
model.alerts
model.selection
model.selectionList
model.cameraTarget
model.metalIncome
model.metalStorage
model.metalSurplus
model.energyIncome
model.energyStorage
model.energySurplus
model.timeElapsed
model.gameStartTime
model.paused
model.commanderIsAlive
model.commanders
model.players
model.spectators
model.controlGroups
model.buildPreview
model.buildHover
model.unitsLost
model.unitsBuilt
```

---

## server_browser

```
model.servers
model.filter
model.refreshing
model.lobbyId
model.passwordRequired
```

---

## settings

```
model.settings
model.audioSettings
model.graphicsSettings
model.gameplaySettings
model.keybindings
model.locale
```

---

## community_mods

```
model.installedMods
model.availableMods
model.outdatedMods
model.refreshing
```

---

## connect_to_game

```
model.connecting
model.connectionFailed
model.lobbyId
```

---

## galactic_war/galaxy_view（GW 主圖）

```
model.galaxy
model.currentNode
model.commander
model.cards
model.fuel
model.hp
```

> GW 場景為 client-only；本快照僅供 GW mod 參考。

---

## 全域 api.* 名單

不分 scene，皆可使用：

```
api.audio.playSound
api.audio.setMusic
api.audio.toggleMute
api.time.now
api.Panel.message
api.Panel.registerMessageHandler
api.mods.getMounted
api.game.message
api.camera.lookAt
api.select.byIds
api.net.startGame                 # 不建議直接用
api.net.joinGame                  # 不建議直接用
api.net.connect                   # 不建議直接用
```

---

## 取得最新名單的方法

PowerShell（從本機抓 model.* 出現位置）：

```powershell
$paUiPath = "<PA_INSTALL>\media\ui\main\<scene>"
Select-String -Path "$paUiPath\*.js" -Pattern 'model\.\w+' -AllMatches |
  ForEach-Object { $_.Matches.Value } |
  Sort-Object -Unique
```

跑出的清單可貼回本檔對應 scene 區塊。

---

## 注意

- **本快照非權威**：實際 model 結構由 PA 程式碼決定，會隨版本變動。
- **某些 observable 動態建立**：如 `model.commanders` 在進入戰場後才存在，注入腳本要 defer 或 polling。
- **panel 內部 model 不在本快照**：panel iframe 載入後有自己的 model，需個別查 panel 的 .js。
