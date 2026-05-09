---
name: pa-local-steam-paths
description: 以本機 env 設定檔管理 Planetary Annihilation (Steam) 的安裝路徑與 MOD 部署路徑，並提供固定部署流程。當需要把 MOD 複製到本機遊戲資料夾、讀取遊戲原始檔（例如 media/pa 單位與 UI 檔）或在不同開發者電腦上快速套用相同流程時使用。
---

# PA Local Steam Paths

## 使用 env 管理本機路徑

1. 複製 `.agent/env/pa-local.env.example` 為 `.agent/env/pa-local.env`。
2. 在 `.agent/env/pa-local.env` 填入本機路徑（此檔已在 `.gitignore` 內，不會進版控）。
3. 讓部署與參考流程統一讀該 env。

建議最少填入：

- `PA_DATA_DIR`（或 `PA_CLIENT_MODS_DIR` / `PA_SERVER_MODS_DIR`）
- `PA_GAME_DIR`

## 執行固定部署

1. 準備來源資料夾，確保其根層包含 `modinfo.json`。
2. 執行 `scripts/deploy-mod.ps1`，指定來源路徑與目標 context。
3. 由 `modinfo.json.identifier` 或手動指定 identifier 建立目的資料夾。
4. 清空舊目標後覆蓋複製，保持部署結果一致。

## 指令

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<mod-folder>" -Context client -EnvFilePath ".agent/env/pa-local.env"
```

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<mod-folder>" -Context server -EnvFilePath ".agent/env/pa-local.env"
```

## 讀取遊戲原始檔參考

- UI 檔案：從 `PA_MEDIA_DIR\ui\main\game\...` 讀取。
- 單位檔案：從 `PA_MEDIA_DIR\pa\units\...` 讀取。
- 貼圖/地形：從 `PA_MEDIA_DIR\pa\terrain\...` 讀取。
