# Agent 調用手冊（執行入口）

## 任務路由

- 要建立新 mod：先讀 `.agent/knowledge/pa-modding-core.md`
- 要做 UI/場景 hook：再讀 `.agent/knowledge/ui-and-api.md`
- 要做 client UI mod：執行 `.agent/workflows/create-client-ui-mod.md`
- 要做 server 單位平衡：執行 `.agent/workflows/create-server-unit-mod.md`
- 要發佈：執行 `.agent/workflows/test-package-release.md`
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
