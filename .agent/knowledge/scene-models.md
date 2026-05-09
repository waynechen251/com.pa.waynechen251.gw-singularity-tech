# Scene Model 速查（Agent 版）

> 資料源：Palobby Wiki + 本機 PA `ui/main/<scene>/` 抽樣。
> 用途：玩家想做某個 UI 行為時，AI 需要知道「在哪個 scene 注入腳本」與「該 scene 暴露了哪些 `model.*` observable 可 hook」。
> 注意：PA UI 為 Knockout JS 驅動，`model` 為當前 scene 全域變數，scenes 之間 model 結構不共享。

## 1) Scene 全景

```
main/                  # 根 scene（uberbar、頂層 layer）
├── start/             # 主選單（單機/連線入口）
├── new_game/          # 大廳（lobby、玩家加入前/開戰前）
├── live_game/         # 遊戲中（戰場 HUD）
├── server_browser/    # 房間瀏覽器
├── settings/          # 設定頁
├── connect_to_game/   # 連線中（過場）
├── community_mods/    # mod 管理
└── (其他特殊 scene：replay_browser、galactic_war/* 等)
```

注入點：`modinfo.json#scenes`（路徑用 `coui://ui/mods/<identifier>/<file>.js`）。

## 2) 各 scene 主要 model.* 對照

### 2.1 `new_game`（大廳 / 開戰前）

| 路徑 | 型別 | 用途 | 可 subscribe |
| --- | --- | --- | --- |
| `model.chatMessages` | observableArray | 大廳聊天訊息 | ✅ |
| `model.players` | observableArray | 房內玩家清單 | ✅（玩家加入/離開） |
| `model.armies` | observableArray | 軍隊配置 | ✅ |
| `model.aiDifficulty` | observable | AI 難度 | ✅ |
| `model.gameOptions` | observable | 遊戲設定 | ✅ |
| `model.systemEditorVisible` | observable | 系統編輯器顯示 | ✅ |
| `model.canStart` | computed | 是否可開戰 | ✅ |

**最小 hook 範例**：見 [cookbook/chat-alert.md §A](../cookbook/chat-alert.md)（玩家加入大廳響鈴）。

### 2.2 `live_game`（遊戲中 HUD）

| 路徑 | 型別 | 用途 | 可 subscribe |
| --- | --- | --- | --- |
| `model.chatLog` | observableArray | 戰場聊天 | ✅ |
| `model.alerts` | observableArray | 警告（受擊、單位陣亡等） | ✅ |
| `model.selection` | observable | 當前選取單位 | ✅ |
| `model.metalIncome` / `model.energyIncome` | observable | 經濟流 | ✅ |
| `model.metalStorage` / `model.energyStorage` | observable | 倉儲量 | ✅ |
| `model.timeElapsed` | observable | 開戰時長（秒） | ✅ |
| `model.paused` | observable | 是否暫停 | ✅ |
| `model.commanderIsAlive` | observable | 指揮官存活 | ✅ |
| `model.cameraTarget` | observable | 相機目標 | ✅ |

**最小 hook 範例**：
```js
model.alerts.subscribe(function (newAlerts) {
  if (newAlerts.length > 0) {
    api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
  }
});
```

### 2.3 `start`（主選單）

| 路徑 | 型別 | 用途 |
| --- | --- | --- |
| `model.userName` | observable | 登入用戶 |
| `model.titansEnabled` | observable | 是否啟用 Titans |
| `model.installedMods` | observableArray | 已安裝 mod 列表 |

start scene 適合做：版本資訊覆蓋、自訂主選單按鈕。

### 2.4 `server_browser`（房間瀏覽）

| 路徑 | 型別 | 用途 |
| --- | --- | --- |
| `model.servers` | observableArray | 可加入的房間 |
| `model.filter` | observable | 篩選條件 |
| `model.refreshing` | observable | 是否刷新中 |

適合做：自動篩選、自動加入熱門房等。

### 2.5 `settings`（設定）

| 路徑 | 型別 | 用途 |
| --- | --- | --- |
| `model.settings` | observable | 設定樹 |
| `model.audioSettings` | observable | 音量設定 |

加自訂設定頁籤的常用 hook 點。

### 2.6 `community_mods`（mod 管理頁）

| 路徑 | 型別 | 用途 |
| --- | --- | --- |
| `model.installedMods` | observableArray | 已安裝 |
| `model.availableMods` | observableArray | 可安裝 |

## 3) 可用 `api.*` 速查（與 scene 無關，全域）

| API | 用途 |
| --- | --- |
| `api.audio.playSound(path)` | 播音效（`/SE/UI/...`） |
| `api.audio.setMusic(path)` | 改 BGM |
| `api.time.now()` | 取當前遊戲時間（秒） |
| `api.Panel.message(target, msg, payload)` | scene 間訊息 |
| `api.Panel.registerMessageHandler(name, fn)` | 接收 panel 訊息 |
| `api.mods.getMounted(context, raw)` | 查掛載的 mods（Promise） |
| `api.game.message(name, payload)` | 戰場端事件廣播（live_game） |
| `api.camera.lookAt(target)` | 相機聚焦 |
| `api.select.byIds(ids)` | 程式化選取單位 |

> `api.net.*` 不建議直接使用，見 [ui-and-api.md §5](./ui-and-api.md)。

## 4) Scene 之間的訊息傳遞

不同 scene（含 panel）的 `model` 與 session storage 不共享。要跨 scene 傳資料，用：

```js
// scene A
api.Panel.message('panel_b', 'my_event', { foo: 1 });

// scene B
handlers['my_event'] = function (payload) { /* ... */ };
```

`handlers` 必須宣告在 panel 全域並由 PA 框架自動掛接。

## 5) 找原始 model 結構的方法

PA 安裝目錄下：
```
media/ui/main/<scene>/<scene>.js     # scene 控制器
media/ui/main/<scene>/<scene>.html   # KO binding 模板
```

直接讀原始 .js 是最權威的 model 定義來源（封存 wiki 略過時更新時更須以原始檔為準）。

## 6) 常見地雷

- **錯 scene 注入**：在 `start` 注入 `model.chatMessages` 不存在 → 永遠不觸發。
- **觀測時機**：scene 載入時 `model` 可能還沒初始化，subscribe 前判 `if (!model || !model.X)`。
- **subscribe 累積**：同一 scene 反覆載入同 mod 會疊加 subscribe，可在 IIFE 用 flag 防重複。
- **panel session storage 隔離**：別假設 scene A 寫的 sessionStorage scene B 讀得到。
