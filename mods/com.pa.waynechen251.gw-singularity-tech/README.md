# 銀河戰爭：奇點工程科技

Identifier: `com.pa.waynechen251.gw-singularity-tech`

此 MOD 會覆寫銀河戰爭內建卡片 `gwc_damage_bots`，改為一張整合型科技卡：

- 所有完整建造科技（空/機器人/車輛/海軍/軌道 + 砲兵/防禦/超級武器/泰坦）
- 所有建築效率科技（指揮官建造臂 + 工廠/工兵建造臂）
- 所有成本減免科技（air/bot/vehicle/sea/orbital/economy/defense/intel/artillery/superweapons/titans）
- 首次抽卡必中此卡（若你尚未持有此卡）

## 安裝（env-only 流程）

1. 複製 `.agent/env/pa-local.env.example` 為 `.agent/env/pa-local.env`。
2. 在 `.agent/env/pa-local.env` 填入本機 `PA_DATA_DIR`（或 `PA_CLIENT_MODS_DIR`）與 `PA_GAME_DIR`。
3. 使用部署腳本安裝到 `client_mods/<identifier>`（由 env 決定實際位置）。

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1 -SourceModPath "<generated_mod_path>" -Context client -EnvFilePath ".agent/env/pa-local.env"
```

## 測試

1. 啟動 PA TITANS。
2. Community Mods -> Installed 啟用 `GW Singularity Tech`。
3. 開新銀河戰爭。
4. 拿到原本 `gwc_damage_bots` 位置的卡時，描述應顯示「奇點工程科技」。

## 路徑規範

- 本文件不包含任何機器專屬絕對路徑。
- 本機路徑僅能透過 `.agent/env/pa-local.env` 注入。
