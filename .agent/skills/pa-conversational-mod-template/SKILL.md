---
name: pa-conversational-mod-template
description: 以對話方式引導使用者建立 Planetary Annihilation MOD 模板。使用必填問題收斂需求，只有在必填欄位完整且格式合法時才產出草稿。輸出包含可直接開工的 mod 目錄、modinfo、README、release_notes、validation-checklist，且語言跟隨使用者當前語言。
---

# PA Conversational Mod Template

## 執行目標

以問答收集必要資訊，生成標準化 MOD 草稿，不自動部署。

## 對話流程

1. 識別或設定使用者語言（預設跟隨使用者當前語言）。
2. 依序詢問必填欄位（見 `references/question-schema.md`）。
3. 驗證格式與一致性；若有缺失，列出缺失並追問，不得產出草稿。
4. 必填完成後，呼叫 `scripts/render-mod-draft.ps1` 生成草稿。
5. 回覆輸出位置、部署指令與檢查清單。

## 強制規則

- 任一必填未完成：不得生成模板。
- `deploy_context` 必須與 `mod_context` 一致：
  - `client` / `companion-client` -> `client`
  - `server` -> `server`
- 不可自動部署，只提供命令。
- 本機路徑只可由 `.agent/env/pa-local.env` 取得，不可硬編碼。

## 產出指令

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-conversational-mod-template/scripts/render-mod-draft.ps1 -InputFile "<answers.json>" -OutputRoot "mods"
```

## 產出內容

依 `references/output-contract.md` 產出：

- `modinfo.json`
- `README.md`
- `CHANGELOG.md`
- `release_notes.md`
- `validation-checklist.md`
- context 專屬骨架（client/server/companion-client）
