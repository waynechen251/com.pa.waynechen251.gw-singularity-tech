---
name: pa-local-steam-paths
description: 記錄此電腦的 Planetary Annihilation (Steam) 實際安裝路徑與本機 MOD 部署路徑，並提供固定部署流程。當需要把 MOD 複製到本機遊戲資料夾、讀取遊戲原始檔（例如 media/pa 單位與 UI 檔）或快速引用固定路徑時使用。
---

# PA Local Steam Paths

## 使用本機固定路徑

- Steam Library Root: `F:\SteamLibrary`
- PA Titans Install Dir: `F:\SteamLibrary\steamapps\common\Planetary Annihilation Titans`
- PA Media Dir: `F:\SteamLibrary\steamapps\common\Planetary Annihilation Titans\media`
- PA Bin x64 Dir: `F:\SteamLibrary\steamapps\common\Planetary Annihilation Titans\bin_x64`
- PA Data Dir: `C:\Users\WaynePC\AppData\Local\Uber Entertainment\Planetary Annihilation`
- Client Mods Dir: `C:\Users\WaynePC\AppData\Local\Uber Entertainment\Planetary Annihilation\client_mods`
- Server Mods Dir: `C:\Users\WaynePC\AppData\Local\Uber Entertainment\Planetary Annihilation\server_mods`

## 執行固定部署

1. 準備來源資料夾，確保其根層包含 `modinfo.json`。
2. 執行 `scripts/deploy-mod.ps1`，指定來源路徑與目標 context。
3. 由 `modinfo.json.identifier` 或手動指定 identifier 建立目的資料夾。
4. 清空舊目標後覆蓋複製，保持部署結果一致。

## 指令

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<mod-folder>" -Context client
```

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<mod-folder>" -Context server
```

## 讀取遊戲原始檔參考

- UI 檔案：從 `PA Media Dir\ui\main\game\...` 讀取。
- 單位檔案：從 `PA Media Dir\pa\units\...` 讀取。
- 貼圖/地形：從 `PA Media Dir\pa\terrain\...` 讀取。
