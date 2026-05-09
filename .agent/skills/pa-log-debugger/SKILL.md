---
name: pa-log-debugger
description: 專門用於 Planetary Annihilation/TITANS 執行錯誤 log 除錯與 MOD 問題診斷。當需要檢查 PA-*.txt、分析 JS 錯誤（Uncaught/Script error）、Failed loading/404、mod 載入失敗、Galactic War 卡片或場景注入失效、require/load 失敗、舊版模組殘留衝突時使用。
---

# PA Log Debugger

## 執行目標

將 PA 執行 log 轉成可執行的修正建議，輸出固定包含：

- 證據行（log 內容與行號）
- 根因假設
- 修正建議
- 驗證步驟

## 操作流程

1. 先收集環境脈絡（mod 目錄、identifier、log 路徑）。
2. 掃描單一 log 或最新 `PA-*.txt`。
3. 擷取關鍵訊號：`ERROR`、`Uncaught`、`Failed loading`、`Script error`。
4. 依分類規則輸出診斷（見 `references/error-taxonomy.md`）。
5. 若問題在 Galactic War，套用 `references/patterns-pa-gw.md` 補齊修正與回歸驗證。

## 指令

先收集上下文：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-log-debugger/scripts/collect-pa-log-context.ps1 -EnvFilePath ".agent/env/pa-local.env" -Identifier "com.pa.waynechen251.gw-singularity-tech"
```

掃描最新 log（文字報告）：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-log-debugger/scripts/scan-pa-log.ps1 -EnvFilePath ".agent/env/pa-local.env" -OutputFormat text -MaxFindings 20
```

掃描指定 log（JSON 報告）：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/pa-log-debugger/scripts/scan-pa-log.ps1 -LogPath "<path-to-log>" -EnvFilePath ".agent/env/pa-local.env" -OutputFormat json -MaxFindings 20
```

## 輸出規範

- 標準格式與欄位請依 `references/output-template.md`。
- 不做自動修復，不直接改檔；先提供可審核的修正方案。
- 若同時存在多種錯誤，優先處理會阻斷模組載入/執行的錯誤。
