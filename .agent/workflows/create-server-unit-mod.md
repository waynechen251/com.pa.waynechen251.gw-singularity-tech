# Workflow: 建立 Server Unit MOD（Override 既有單位）

## 適用範圍

本檔聚焦在**修改既有單位**(shadow override)的流程:HP / 射程 / 速度 / 武器數值等調整。

| 需求 | 走哪個 workflow |
| --- | --- |
| **改既有單位數值** | **本檔** |
| 改既有單位的 model.filename(換貼圖) | 本檔 |
| 建立**全新 identifier 的單位**(新模型 / 新動畫 / 變體) | [create-new-unit-mod.md](./create-new-unit-mod.md) |

## 目標

建立會影響多人遊戲規則的 server mod（改單位數值、單位名單、平衡調整）。

## 步驟

1. 定義 server mod identifier。
2. 複製模板：`.agent/templates/server-unit`。
3. 更新 `modinfo.json` 必填欄位與 `category`（通常含 `units`）。
4. 找到目標單位原始檔（例：`pa/units/land/bot_bomb/*`）。
5. 在 mod 內建立相同路徑並覆寫（shadow）所需 JSON。
6. 本地安裝至 `server_mods/<identifier>` 測試。
7. 若需要，建立 companion client mod 承載 client-only 資源。

## 實作檢查點

- `context` 必須是 `server`。
- 只覆寫必要檔案，避免整包複製造成維護負擔。
- 若使用 `companions`，identifier 必須與 companion mod 對應。

## 進階建議

- 大型 server mod 拆分：
  - 主 server mod：僅保留 server 必要檔。
  - companion client mod：玩家加入/觀戰必需 client 資源。
  - optional UI mod：非必要 UI/品牌化內容。

## 風險提示

- server mod 會影響所有參與者，發佈前必做多人驗證。
- 壞行為 mod 會被社群服務拒絕或移除（依 Wiki 指南）。
