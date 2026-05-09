# Release Notes

## 銀河戰爭：奇點工程科技

### 本次更新重點

- 統一模組識別為 `com.pa.waynechen251.gw-singularity-tech`。
- 改為新增獨立科技卡 `gwc_singularity_tech`，不再覆蓋 `gwc_damage_bots`。
- 首抽保底邏輯新增 GWAIO 相容處理，降低與大型 GW 模組衝突機率。
- 新增 `Land Anywhere` 效果：持有 `gwc_singularity_tech` 進入對戰時自動啟用。
- README 改為 env-only 流程，不再包含任何本機絕對路徑。
- 新增標準驗證文件，方便後續發佈前檢查。

### 相容性

- 保留原版 `gwc_damage_bots`。
- 新增卡片效果為整合型爽局科技（建造解鎖/效率/成本減免）。
