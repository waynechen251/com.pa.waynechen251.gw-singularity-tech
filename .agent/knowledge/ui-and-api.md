# UI 與 API 速查（Agent 版）

## 1) UI 技術棧

- JavaScript（大量使用 KnockoutJS）
- HTML5
- Coherent UI 2.x（內嵌瀏覽器）
- Chromium 子集

## 2) UI 場景概念

- 根層是 `main`，常見子場景有 `game`、`uberbar`。
- `game` 內會切換 `start`、`new_game`、`live_game`、`server_browser`、`settings` 等場景。
- 場景可再載入 panel（類似 iframe，但 session storage 不共享）。

## 3) scenes 注入規則

`modinfo.json` 可用 `scenes` 指定注入：

```json
{
  "scenes": {
    "new_game": [
      "coui://ui/mods/com.pa.you.some-mod/new_game.js"
    ],
    "live_game": [
      "coui://ui/mods/com.pa.you.some-mod/live_game_chat.js"
    ]
  }
}
```

## 4) UI Mod 開發慣例

- 先在原生 UI 檔案定位資料流，再決定 hook 點。
- 針對 Knockout observable / observableArray 用 `subscribe`。
- 盡量局部注入，不要全域載入不必要腳本。
- 避免遠端載入資源（Wiki 指南明確不建議）。

## 5) API 速查

### api.mods

- `api.mods.getMounted(context, raw)`：查目前掛載 mods（Promise）。
- `api.mods.getMountedMods(...)`：已標示 deprecated。

### api.net（高風險，避免直接調）

Wiki 明確建議：不要直接用 `api.net.*`，優先透過 `connect to game scene` 流程。

- `api.net.startGame(region, mode)`
- `api.net.joinGame({ lobbyId })`
- `api.net.connect(params)`

已知注意點（Wiki 記載）：

- `joinGame` 對無效 `lobbyId` 可能不回傳。
- `connection_failed` handler 記載為可能不觸發。

## 6) Chat Alert 類型範例提煉

- 大廳：監看 `model.chatMessages.subscribe(...)`
- 遊戲中：監看 `model.chatLog.subscribe(...)`
- 音效可用：`api.audio.playSound('/SE/UI/UI_camera_anchor_saved')`

這個模式可泛化為「事件到音效/提示」類型 UI MOD。
