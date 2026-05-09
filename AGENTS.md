# AGENTS.md

> 根層 agent 入口。本檔只做導航,詳細內容請依連結進入 [.agent/](.agent/)。

## 專案定位

本 repo 是 **Planetary Annihilation(PA)Modding 的工程化知識庫**,將 Palobby 封存 Wiki 整理成可被 AI Agent 與人類開發者快速調用的決策樹、技能、模板與工作流。

## Agent 啟動順序(必讀)

1. [.agent/catalog.json](.agent/catalog.json) — 機械可讀索引(9 個 entrypoint + 3 個 template,含 intents 與 tags)
2. [.agent/agent-playbook.md](.agent/agent-playbook.md) — 任務路由、標準輸出、快速檢查清單
3. 依任務類型進入對應 [workflow](.agent/workflows/)

## 目錄速查

- [.agent/knowledge/](.agent/knowledge/) — 核心規則(modinfo、UI 技術棧、API 速查)
- [.agent/workflows/](.agent/workflows/) — 標準操作流程(client UI / server unit / release)
- [.agent/skills/](.agent/skills/) — 可調用技能(本機部署、對話式 MOD 模板)
- [.agent/templates/](.agent/templates/) — 可複製的 MOD 骨架(client-ui / server-unit / companion-client)
- [.agent/env/](.agent/env/) — 本機路徑範本(敏感資訊,不進版控)

## 任務路由速覽

- 想建立新 MOD → [.agent/agent-playbook.md](.agent/agent-playbook.md)
- 想理解 PA modding 規則 → [.agent/knowledge/pa-modding-core.md](.agent/knowledge/pa-modding-core.md)
- 想做 UI / 場景 hook → [.agent/knowledge/ui-and-api.md](.agent/knowledge/ui-and-api.md)
- 想對話式產出 MOD 草稿 → [.agent/skills/pa-conversational-mod-template/SKILL.md](.agent/skills/pa-conversational-mod-template/SKILL.md)
- 想本機部署測試 → [.agent/skills/pa-local-steam-paths/SKILL.md](.agent/skills/pa-local-steam-paths/SKILL.md)

## 本機環境設置(每台電腦做一次)

1. 複製 [.agent/env/pa-local.env.example](.agent/env/pa-local.env.example) 為 `.agent/env/pa-local.env`
2. 填入個人 Steam / PA 安裝與資料路徑
3. 此檔已被 [.gitignore](.gitignore) 排除,不會進版控

### Agent 行為規則 — env 缺失偵測

任何涉及部署、本機測試、檔案複製到 PA 安裝目錄的任務,執行前 agent **必須**先檢查 `.agent/env/pa-local.env` 是否存在:

- **若不存在**:停下來,主動詢問使用者「是否依 `pa-local.env.example` 自動生成 `pa-local.env`?」並請使用者確認 / 補上各路徑值,**取得回應後再繼續**部署流程。
- **若已存在**:讀取後即可進入後續流程,不需再詢問。

不可在缺 env 的情況下硬跑 [.agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1](.agent/skills/pa-local-steam-paths/scripts/deploy-mod.ps1) 或任何依賴本機路徑的步驟。

## 標準輸出契約

agent 產出新 MOD 時最少需含:

1. `<mod_root>/modinfo.json`
2. 對應場景或單位覆寫檔
3. `CHANGELOG.md`(version / date / build 變更)
4. `release_notes.md`(社群發文素材)

完整契約見 [.agent/skills/pa-conversational-mod-template/references/output-contract.md](.agent/skills/pa-conversational-mod-template/references/output-contract.md)。

## 來源

封存自 Palobby Wiki(`archived: 2021-09-05`),完整連結見 [.agent/sources.md](.agent/sources.md)。新版本遊戲若有變更,請先驗證 `build` 與 API 行為再發佈。
