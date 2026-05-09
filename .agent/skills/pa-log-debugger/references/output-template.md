# Output Template (Diagnosis + Fix Recommendations)

## Summary

- `log_path`:
- `findings_total`:
- `high`:
- `medium`:
- `info`:

## Findings

對每一筆 finding 輸出：

- `severity`: `high|medium|info`
- `category`:
- `evidence`: 建議含行號（`L123: ...`）
- `hypothesis`: 根因假設
- `fix`: 可執行修正步驟

## Recommendations

- 先修 high severity（會阻斷載入/執行）。
- 再處理 medium（功能錯誤或相容性）。
- info 僅作為定位輔助。

## Verification Steps

1. 完整重啟 PA TITANS。
2. 確認 Community Mods 只啟用目標 identifier。
3. 重現問題場景（例如 GW 新局）。
4. 再掃最新 log，確認 high finding 消失。
