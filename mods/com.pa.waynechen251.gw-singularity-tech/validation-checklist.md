# Validation Checklist

- [ ] `modinfo.json` 為合法 JSON，`context` 為 `client`。
- [ ] `identifier` 為 `com.pa.waynechen251.gw-singularity-tech` 且全小寫。
- [ ] 模組根目錄名稱等於 identifier。
- [ ] `ui/mods/<identifier>/gw_force_first_pick.js` 路徑存在。
- [ ] `modinfo.json.scenes` 中 `coui://ui/mods/<identifier>/gw_force_first_pick.js` 與實際檔案一致。
- [ ] README 不包含本機絕對路徑（Windows 磁碟代號前綴或使用者家目錄絕對路徑）。
- [ ] README 部署命令包含 `-EnvFilePath ".agent/env/pa-local.env"`。
- [ ] README 部署命令的 `-SourceModPath` 使用 placeholder（`"<generated_mod_path>"`）。
- [ ] 啟用 MOD 後，GW 開局可正確套用 `gw_force_first_pick.js`。
- [ ] 首次探索抽卡第一張為 `gwc_singularity_tech`（未持有時）。
- [ ] 原版 `gwc_damage_bots` 仍保持原本功能（未被此 MOD 覆寫）。
- [ ] 取得 `gwc_singularity_tech` 後，基礎工廠可生產該類型全單位。
- [ ] 取得 `gwc_singularity_tech` 後，軌道建設衛星可建造所有建築類別。
- [ ] 取得 `gwc_singularity_tech` 後，基礎建造者可建造進階建築。
