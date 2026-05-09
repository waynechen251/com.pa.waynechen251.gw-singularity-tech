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

### api.audio

- `api.audio.playSound(path)`：播音效（`/SE/UI/<name>`，不含副檔名）。
- `api.audio.setMusic(path)`：切換 BGM。
- `api.audio.toggleMute()`：切換靜音。

完整音效路徑與事件對應範例見 [cookbook/chat-alert.md](../cookbook/chat-alert.md)。

### api.Panel（scene/panel 訊息傳遞）

- `api.Panel.message(target, name, payload)`：跨 scene/panel 廣播事件。
- `api.Panel.registerMessageHandler(name, fn)`：註冊接收。
- 不同 panel 之間 **session storage 不共享**：要傳資料必須用 `api.Panel.message`，不能依賴 sessionStorage 跨 panel 讀寫。
- payload 必須可 JSON 序列化。

### api.time

- `api.time.now()`：取當前時間（戰場為遊戲時間秒數）。

### api.game / api.camera / api.select

- `api.game.message(name, payload)`：戰場端事件廣播（live_game scene）。
- `api.camera.lookAt(target)`：相機聚焦座標。
- `api.select.byIds(ids)`：程式化選取單位。

### api.net（高風險，避免直接調）

Wiki 明確建議：不要直接用 `api.net.*`，優先透過 `connect to game scene` 流程。

- `api.net.startGame(region, mode)`
- `api.net.joinGame({ lobbyId })`
- `api.net.connect(params)`

已知注意點（Wiki 記載）：

- `joinGame` 對無效 `lobbyId` 可能不回傳。
- `connection_failed` handler 記載為可能不觸發。

## 6) 常見 UI Mod 模式速查

具體實作 snippet 已抽到 cookbook，本節只列模式索引：

- 「事件到音效 / 提示」類型 → [cookbook/chat-alert.md](../cookbook/chat-alert.md)（玩家加入大廳、戰場聊天、警告）
- 「subscribe model observable」「注入按鈕」「panel 訊息」三種通用模式 → [cookbook/ui-hook-recipes.md](../cookbook/ui-hook-recipes.md)
- 各 scene 暴露的 `model.*` 完整對照 → [scene-models.md](./scene-models.md)
- UI 中文術語 → scene/model 對照 → [glossary/zh-ui-terms.md](../glossary/zh-ui-terms.md)
