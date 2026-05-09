# Cookbook：UI Hook 通用模式

> 給「想做 UI 改造但不知從哪下手」的玩家用。
> 三種主流模式 → subscribe observable、注入按鈕、panel 訊息傳遞。
> 配套：[knowledge/scene-models.md](../knowledge/scene-models.md) 拿 model.* 路徑、[knowledge/ui-and-api.md](../knowledge/ui-and-api.md) 拿 API 速查。

---

## A) Subscribe Observable（最通用模式）

任何 KO observable 都可 subscribe，當值變動時觸發 callback。

**範本**：
```js
(function () {
  if (!model || !model.<observable_name> || !model.<observable_name>.subscribe) {
    return;
  }

  // 可選：保留前一個值做比對
  var previous = model.<observable_name>();

  model.<observable_name>.subscribe(function (newValue) {
    // 對 observableArray，newValue 是整個陣列
    // 對單值 observable，newValue 是新值
    console.log('<observable_name> changed:', newValue);

    previous = newValue;
  });
})();
```

**選擇 observable 的判斷**：

| 想做的事 | scene | 監看 |
| --- | --- | --- |
| 玩家加入 / 離開大廳 | new_game | `model.players` |
| 開戰前準備就緒 | new_game | `model.canStart` |
| 戰場警告 | live_game | `model.alerts` |
| 經濟流變動 | live_game | `model.metalIncome`, `model.energyIncome` |
| 選取單位變動 | live_game | `model.selection` |
| 暫停 / 恢復 | live_game | `model.paused` |

完整列表：[scene-models.md](../knowledge/scene-models.md)

---

## B) 注入新按鈕（DOM + KO binding）

PA UI 使用 KO binding 渲染。注入按鈕兩種做法：

### B1) 純 DOM 插入（簡單）

```js
(function () {
  $(document).ready(function () {
    var btn = $('<button class="btn">My Button</button>');
    btn.on('click', function () {
      api.audio.playSound('/SE/UI/UI_button_click');
      console.log('Clicked!');
    });
    $('.some-existing-container').append(btn);
  });
})();
```

**注意**：
- `.some-existing-container` 必須是該 scene 已存在的 DOM 選擇器。先在 DevTools 找到對應 class。
- 純 DOM 不會被 KO 的雙向綁定影響，沒有資料聯動。

### B2) KO binding 加按鈕（與 model 聯動）

```js
(function () {
  // 擴充 model
  model.myToggle = ko.observable(false);

  // 用 ko 模板注入
  var html = '<button data-bind="click: function () { model.myToggle(!model.myToggle()); }, css: { active: model.myToggle }">Toggle</button>';
  var $btn = $(html);
  $('.some-container').append($btn);

  // 重要：手動套用 KO binding
  ko.applyBindings(model, $btn[0]);

  model.myToggle.subscribe(function (val) {
    console.log('Toggle:', val);
  });
})();
```

**注意**：
- 對動態 DOM 必須手動 `ko.applyBindings`，否則 binding 不生效。
- 不要對整個 document 重複 applyBindings，會錯誤。

---

## C) Panel / Scene 間訊息

PA 不同 scene（含 panel iframe）的 model 與 sessionStorage 不共享，跨 scene 傳資料用 `api.Panel.message`。

**發送方**（scene A）：
```js
api.Panel.message('panel_b', 'my_event', { foo: 1, bar: 'hello' });
```

**接收方**（panel B）：
```js
// PA 框架自動掛接 handlers
handlers['my_event'] = function (payload) {
  console.log('received:', payload.foo, payload.bar);
};
```

**注意**：
- `target` 是 panel 名稱字串，不是 scene 名。
- payload 必須是可 JSON 序列化的物件。
- 接收方必須在 panel 載入後就掛上 handler，不然 message 會丟失。

---

## D) 加快捷鍵綁定

```js
(function () {
  $(document).on('keydown', function (e) {
    // 例：Ctrl+M = 切換靜音
    if (e.ctrlKey && e.key === 'm') {
      api.audio.toggleMute();
      e.preventDefault();
    }
  });
})();
```

**注意**：
- 別綁 PA 內建快捷鍵（會搶輸入），先在遊戲內看 keybinding 設定。
- 注入到 `live_game` 才能在戰場觸發；在 `new_game` 注入只能在大廳生效。

---

## E) 自訂 Panel 載入

擴充 panel 可在 modinfo.json 指定，但更常見是用「附掛在現有 panel 上的 div + iframe」：

```js
(function () {
  var $iframe = $('<iframe src="coui://ui/mods/<identifier>/my_panel.html" style="width:300px;height:200px;"></iframe>');
  $('.some-container').append($iframe);
})();
```

**注意**：
- `coui://` 是 Coherent UI 內部協議，本地 mod 路徑都用此前綴。
- iframe panel 與父 scene 不共享 sessionStorage。

---

## 通用最佳實踐

1. **永遠先檢查 model 與 observable 存在**：`if (!model || !model.X) return;`
2. **用 IIFE 包住**：避免變數污染全域 / 避免重複載入累積 subscribe。
3. **先在 DevTools 探索**：F12 開 console（PA 啟動加 `--debug` 或環境變數），印 `model` 看真實結構。
4. **不要假設 model 永久存在**：scene 切換時 model 會被銷毀。subscribe 不需要顯式 dispose（scene 銷毀會 GC），但別在 callback 裡引用已銷毀的 DOM。
5. **避免遠端載入資源**：PA 不允許從外網載入 JS / CSS（CSP 限制 + Wiki 明確不建議）。

## 與其他知識銜接

- 想做的是音效提示 → [chat-alert.md](./chat-alert.md)
- 想找 model 路徑 → [scene-models.md](../knowledge/scene-models.md)
- 想找 UI 中文術語 → [glossary/zh-ui-terms.md](../glossary/zh-ui-terms.md)
- 想知道 PA UI 技術棧 → [ui-and-api.md](../knowledge/ui-and-api.md)
