# Cookbook：Chat Alert / 提示音 mod

> 給「想在某事件發生時播音 / 跳通知」的玩家直接複製。
> 三種變體 → 大廳玩家加入、戰場聊天、戰場警告。
> 配套：[knowledge/scene-models.md](../knowledge/scene-models.md) 拿 model.* 路徑。
> 套用方式：建 client mod，把對應 .js 放到 `ui/mods/<identifier>/<scene>.js`，然後在 `modinfo.json#scenes` 註冊。

---

## A) 玩家加入大廳響鈴（new_game scene）

**檔案**：`ui/mods/<identifier>/new_game.js`

```js
(function () {
  if (!model || !model.players || !model.players.subscribe) {
    return;
  }

  var lastCount = (model.players() || []).length;

  model.players.subscribe(function (newPlayers) {
    var count = (newPlayers || []).length;
    if (count > lastCount) {
      api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
    }
    lastCount = count;
  });
})();
```

**modinfo.json scenes 註冊**：
```json
{
  "scenes": {
    "new_game": ["coui://ui/mods/<identifier>/new_game.js"]
  }
}
```

**注意**：
- 用 `lastCount` 比較才能區分「加入」與「離開」。否則玩家離開也會響。
- IIFE 包住避免污染全域。
- 第一次載入時 `lastCount` 已是當前人數，不會誤觸發。

---

## B) 戰場聊天訊息響鈴（live_game scene）

**檔案**：`ui/mods/<identifier>/live_game.js`

```js
(function () {
  if (!model || !model.chatLog || !model.chatLog.subscribe) {
    return;
  }

  model.chatLog.subscribe(function () {
    api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
  });
})();
```

**注意**：
- 戰場 `chatLog` 也包括玩家自己發的訊息 → 會自響。要避免可比對最後一筆 `senderId` 與本機玩家。
- 過於頻繁的訊息會洗音效，建議加節流（debounce）。

---

## C) 戰場警告觸發音效（受擊 / 單位陣亡）

**檔案**：`ui/mods/<identifier>/live_game.js`

```js
(function () {
  if (!model || !model.alerts || !model.alerts.subscribe) {
    return;
  }

  model.alerts.subscribe(function (newAlerts) {
    if (!newAlerts || newAlerts.length === 0) {
      return;
    }

    var latest = newAlerts[newAlerts.length - 1];
    // latest 通常含 type, location, time 等欄位
    if (latest && latest.type === 'unit_lost') {
      api.audio.playSound('/SE/UI/UI_camera_anchor_saved');
    } else {
      api.audio.playSound('/SE/UI/UI_camera_anchor_set');
    }
  });
})();
```

**注意**：
- `alerts` 物件結構依本機版本而定，先在瀏覽器 DevTools console 印 `model.alerts()` 確認欄位。
- 「指揮官受擊」可監看 `model.commanderIsAlive` 由 true 變 false 的 transition。

---

## D) 開戰倒數結束播音（live_game scene）

**檔案**：`ui/mods/<identifier>/live_game.js`

```js
(function () {
  if (!model || !model.timeElapsed) {
    return;
  }

  var fired = false;
  model.timeElapsed.subscribe(function (t) {
    if (!fired && t >= 1) {
      api.audio.playSound('/SE/UI/UI_count_down_5');
      fired = true;
    }
  });
})();
```

**注意**：
- 開戰前 `timeElapsed` 為 0 / 負數，正式開戰後變正。
- 用 `fired` flag 避免重複觸發。

---

## 可用 PA 內建音效路徑（節錄）

| 音效路徑 | 描述 |
| --- | --- |
| `/SE/UI/UI_camera_anchor_saved` | 相機錨點儲存音（清脆叮） |
| `/SE/UI/UI_camera_anchor_set` | 相機設置音 |
| `/SE/UI/UI_count_down_5` | 倒數 5 秒音 |
| `/SE/UI/UI_count_down_3` | 倒數 3 秒音 |
| `/SE/UI/UI_count_down_1` | 倒數 1 秒音 |
| `/SE/UI/UI_button_click` | 按鈕點擊 |
| `/SE/UI/UI_alert_under_attack` | 受擊警告 |
| `/SE/UI/UI_alert_player_lost` | 玩家陣亡 |

> 完整音效清單在本機 `media/audio/` 下，但路徑使用 `/SE/UI/<name>` 不含副檔名。

---

## 通用注意

- **scene 注入錯誤**：把 `new_game.js` 寫的 `model.players` 拿到 `live_game` scene 跑會永遠不觸發（live_game 沒有 players observable）。先確認 scene。
- **訂閱重複**：mod 重新載入會堆積 subscribe，IIFE 一次性執行可避開。
- **音量過大**：用 `api.audio.playSound` 直接播是固定音量。要調可以包 wrapper 控制冷卻 + 音量比例。
- **靜音狀態**：使用者把音效關掉時 `playSound` 不會出聲，這是正常的，不需特別處理。

## 與其他知識銜接

- 找其他可 hook 的 model.* → [scene-models.md](../knowledge/scene-models.md)
- 想做更通用的 UI hook 模式 → [ui-hook-recipes.md](./ui-hook-recipes.md)
- UI 中文術語對應 → [glossary/zh-ui-terms.md](../glossary/zh-ui-terms.md)
