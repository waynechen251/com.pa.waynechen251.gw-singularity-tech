# Agent 調用手冊（執行入口）

## 任務路由

### 建立 / 規劃 mod
- 要建立新 mod：先讀 `.agent/knowledge/pa-modding-core.md`
- 要做 UI/場景 hook：再讀 `.agent/knowledge/ui-and-api.md`
- 要做 client UI mod：執行 `.agent/workflows/create-client-ui-mod.md`
- 要做 server 單位平衡：執行 `.agent/workflows/create-server-unit-mod.md`
- 要做 Galactic War 卡片 / 戰役內容：讀 `.agent/knowledge/galactic-war-cards.md`
- 要發佈：執行 `.agent/workflows/test-package-release.md`

### 玩家用自然語言提需求（vibe coding 路由）
- **玩家用中文俗稱講單位**（例「砲塔」「轟炸機」「建造機」）：先查 `.agent/glossary/zh-unit-terms.md` 取得 identifier 與檔案路徑
- **玩家用中文 UI 術語**（例「大廳」「戰場警告」「設定頁」）：先查 `.agent/glossary/zh-ui-terms.md` 對應 scene 與 model
- **想改某單位的某屬性**（例「射程 +50%」「HP ×2」）：依序使用
  1. `.agent/glossary/zh-unit-terms.md`（拿 identifier）
  2. `.agent/knowledge/unit-spec-fields.md`（拿 JSON 路徑）
  3. `.agent/cookbook/unit-balance-tweaks.md`（套用對應 patch 模板）
- **想做某 UI 行為**（例「玩家加入響鈴」「警告播音」）：依序使用
  1. `.agent/knowledge/scene-models.md`（拿可 hook 的 observable）
  2. `.agent/cookbook/chat-alert.md` 或 `.agent/cookbook/ui-hook-recipes.md`（套用對應 .js 模板）
- **找原始 unit JSON 結構**：`.agent/samples/units/_skeleton.md`（骨架）+ `.agent/samples/units/_index.md`（目錄索引）
- **找原始 GW 卡結構**：`.agent/samples/gw-cards/_skeleton.md`
- **找 model.* 名單供 grep**：`.agent/samples/scenes/scenes-snapshot.md`

### 除錯
- **要查 log / 診斷執行錯誤**：**必須**執行 `.agent/skills/pa-log-debugger/SKILL.md`

> **強制規則**：使用者說「查 log」、「看 log」、「debug」、或提及任何 PA 執行錯誤（`Uncaught`、`Failed loading`、`Script error`、mod 載入失敗）時，**一律先調用 `pa-log-debugger`**，不得跳過直接推測原因。

## 標準輸出（建議）

agent 在產出新 mod 時，至少要同時生成：

1. `<mod_root>/modinfo.json`
2. 對應場景或單位覆寫檔案
3. `release_notes.md`（準備論壇/社群發文）

## 快速檢查清單

- identifier 是否唯一、全小寫反向網域。
- `context` 是否與目標一致（client/server）。
- `scenes` 路徑是否與檔案一致。
- `date/version/build` 是否已更新。
- 是否只打包必要檔案。
