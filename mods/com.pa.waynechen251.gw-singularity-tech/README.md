# 銀河戰爭：奇點工程科技

Identifier: `com.pa.waynechen251.gw-singularity-tech`

此 MOD 會新增一張銀河戰爭科技卡 `gwc_singularity_tech`（奇點工程科技）：

- 所有完整建造科技（空/機器人/車輛/海軍/軌道 + 砲兵/防禦/超級武器/泰坦）
- 所有建築效率科技（指揮官建造臂 + 工廠/工兵建造臂）
- 所有成本減免科技（air/bot/vehicle/sea/orbital/economy/defense/intel/artillery/superweapons/titans）
- 所有基礎建造者（機器人/車輛/空軍/海軍/軌道）可直接建造該類型高階建築與工廠
- 所有基礎工廠（機器人/車輛/空軍/海軍/軌道發射）可生產該類型所有可建造單位
- 軌道建設衛星可建造所有建築類別
- 指揮官可直接建造高階建築與工廠
- 首次探索抽卡保底此卡（若你尚未持有此卡）

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
4. 首次探索時，科技卡第一張應為「奇點工程科技」。

## 路徑規範

- 本文件不包含任何機器專屬絕對路徑。
- 本機路徑僅能透過 `.agent/env/pa-local.env` 注入。
