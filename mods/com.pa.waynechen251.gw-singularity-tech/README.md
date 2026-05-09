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
- 指揮官建造臂提升為進階工兵等級（`construction_demand.metal = 80`）
- 基礎採礦場收入調整為 `production.metal = 5`
- 戰鬥啟動時若持有此卡，自動啟用 `Land Anywhere`
- 首次探索抽卡保底此卡（若你尚未持有此卡）

## 效果說明（生效時機）

- 以上效果都綁定在 `gwc_singularity_tech`，必須先拿到卡片才會生效。
- `Land Anywhere` 在進入戰鬥前寫入 GW 對戰設定（`config.land_anywhere = true`）。
- 指揮官建造速度與採礦場收入屬於該局 GW 的單位規格覆寫，不會改動原版檔案。

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
5. 拿到卡片後進戰鬥，確認可在星球任意地點空降（Land Anywhere）。
6. 進入對戰後確認：
   - 指揮官建造效率明顯高於原版（對應 `metal 80` 建造臂）
   - 基礎採礦場顯示收入為 `10`

## 路徑規範

- 本文件不包含任何機器專屬絕對路徑。
- 本機路徑僅能透過 `.agent/env/pa-local.env` 注入。
