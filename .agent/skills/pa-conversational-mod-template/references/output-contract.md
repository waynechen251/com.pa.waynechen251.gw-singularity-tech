# Output Contract

## 1) 固定產出檔案

在 `<output_root>/<identifier>/` 生成：

- `modinfo.json`
- `README.md`
- `release_notes.md`
- `validation-checklist.md`

## 2) Context 專屬骨架

- `mod_context=client`：套用 `.agent/templates/client-ui`
- `mod_context=server`：套用 `.agent/templates/server-unit`
- `mod_context=companion-client`：套用 `.agent/templates/companion-client`

## 3) 語言策略

- 文件語言預設使用 `user_language`。
- 未提供 `user_language` 時，以 `display_name` 與 `description` 推定語言（含 CJK 字元視為中文，否則英文）。
- 技術鍵值維持英文（例如 `identifier`, `context`, `category`, `version`）。

## 4) 部署輸出

固定提供（僅文字，不執行）：

- client:
  - `powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<generated_mod_path>" -Context client -EnvFilePath ".agent/env/pa-local.env"`
- server:
  - `powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<generated_mod_path>" -Context server -EnvFilePath ".agent/env/pa-local.env"`
