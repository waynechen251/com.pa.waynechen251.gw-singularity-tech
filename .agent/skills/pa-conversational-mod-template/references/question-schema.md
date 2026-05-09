# Required Question Schema

## 必填欄位

- `mod_context`: `client` | `server` | `companion-client`
- `mod_goal_type`: `ui-enhancement` | `unit-balance` | `galactic-war-card` | `map-or-system` | `other-pa`
- `identifier`: 反向網域格式（例：`com.pa.you.mod-name`）
- `display_name`
- `description`
- `author`
- `target_build`
- `version`: `x.y.z`（可加 suffix）
- `category`: 字串陣列，至少 1 個
- `forum_url`: 完整 URL
- `feature_scope`: 字串或字串陣列（場景/單位/卡片範圍）
- `deploy_context`: `client` | `server`

## 選填欄位

- `optional_companion_identifier`（server mod 可用）
- `user_language`（例：`zh-TW`, `en-US`）
- `signature`（預設單一空白）

## 條件性追問（依 mod_goal_type 觸發）

- 當 `mod_goal_type = unit-balance`：追問
  - `target_unit_term`：玩家想改的單位（中文俗稱亦可，如「砲塔」「轟炸機」）
    - 由 [glossary/zh-unit-terms.md](../../../glossary/zh-unit-terms.md) 翻譯為 identifier 與檔案路徑
  - `target_attribute`：想改的屬性（例「射程 +50%」「HP ×2」「移速 ×1.5」）
    - 由 [knowledge/unit-spec-fields.md](../../../knowledge/unit-spec-fields.md) 對應到 JSON 路徑
    - 由 [cookbook/unit-balance-tweaks.md](../../../cookbook/unit-balance-tweaks.md) 套用 patch 模板

- 當 `mod_goal_type = ui-enhancement`：追問
  - `target_scene`：要改哪個 scene（大廳 / 戰場 / 設定...）
    - 由 [glossary/zh-ui-terms.md](../../../glossary/zh-ui-terms.md) 對應 scene 名與 model
  - `trigger_event`：什麼事件觸發 mod 行為（玩家加入、聊天、警告...）
    - 由 [knowledge/scene-models.md](../../../knowledge/scene-models.md) 對應 observable
    - 由 [cookbook/ui-hook-recipes.md](../../../cookbook/ui-hook-recipes.md) 或 [cookbook/chat-alert.md](../../../cookbook/chat-alert.md) 套用模板

- 當 `mod_goal_type = galactic-war-card`：追問
  - `card_effect_type`：卡片類型（單位 buff / 解鎖 / 全局 buff）
    - 由 [knowledge/galactic-war-cards.md](../../../knowledge/galactic-war-cards.md) 與 [samples/gw-cards/_skeleton.md](../../../samples/gw-cards/_skeleton.md) 對應結構

- 當 `mod_goal_type = map-or-system`：追問
  - `map_kind`：地圖類型（單一行星 / 系統 / 戰役地圖）
  - 註：本輪知識庫尚未涵蓋 map/system modding 細節，AI 應提示玩家此分支為 follow-up scope

## 驗證規則

- 缺任一必填：回傳 `missing_required_fields`，並停止產出。
- `identifier` 僅允許小寫字母、數字、點號、連字號，且需至少兩段。
- `deploy_context` / `mod_context` 一致性：
  - `client` / `companion-client` 只能是 `client`
  - `server` 只能是 `server`
- `category` 必須是非空陣列。
- `mod_goal_type = map-or-system` 時必須提示「該分支知識尚未完整，產出可能需要人工補充」。
