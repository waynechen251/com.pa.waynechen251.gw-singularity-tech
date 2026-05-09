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
- [ ] `gwc_damage_bots` 覆寫後描述顯示「奇點工程科技」。
