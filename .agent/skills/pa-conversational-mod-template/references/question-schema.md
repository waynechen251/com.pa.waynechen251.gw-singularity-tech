# Required Question Schema

## 必填欄位

- `mod_context`: `client` | `server` | `companion-client`
- `mod_goal_type`: `ui-enhancement` | `unit-balance` | `galactic-war-card` | `other-pa`
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

## 驗證規則

- 缺任一必填：回傳 `missing_required_fields`，並停止產出。
- `identifier` 僅允許小寫字母、數字、點號、連字號，且需至少兩段。
- `deploy_context` / `mod_context` 一致性：
  - `client` / `companion-client` 只能是 `client`
  - `server` 只能是 `server`
- `category` 必須是非空陣列。
