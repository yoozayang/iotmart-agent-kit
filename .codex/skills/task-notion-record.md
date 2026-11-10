# Notion task record

Use only for authorized Notion task-record creation/updates, not for reading a WI or code review.

1. Before writing, read `.agents/skills/evidence-investigation-documentation/references/content-preservation.md`. For ADO source use `.codex/playbooks/ado-work-item.md`; identity is WI ID + `System.Title`.
2. Unless the user already requested the write, show a concise summary and ask `要建立Notion任務頁嗎？`. Do not create/update/move before authorization.
3. Use the supplied destination or `.notion-links.json` `task_record_parent`. Fetch the parent and search descendants by exact WI ID; reuse an existing record. Missing/ambiguous/inaccessible parent: ask, do not create a private root page.
4. Use the format below. Record confirmed requirement/acceptance criteria/scope/priority/linked WIs. Generate SDD from confirmed requirements and revise after design decisions; separate pending choices.
5. Discussion updates contain dated decisions/scope changes + source, not process logs or intermediate guesses. Technical notes distinguish facts from necessary labelled inferences, with paths/links.
6. Update only `需求`,`SDD`,`討論更新項`,`技術點記錄`. Material changes carry WI URL and discussion date. The current requirement/SDD is confirmed non-struck-through text; resolved pending items are retained under the shared preservation rule and no longer count as unresolved.
7. Re-fetch and verify parent/path/title/headings plus shared preservation checks. Never claim success without read-back evidence.

## Page format (H2 headings)
Title: `<編號>_<標題>`

- `我的記錄區`: create an empty callout, without labels or placeholder text; user-maintained, never edit/delete/reorder
- `需求`: Azure Board URL, summary, acceptance criteria, confirmed scope, pending decisions
- `SDD`: first version from current confirmed requirements; revise after development decisions
- `討論更新項`: `<日期>｜<來源>:<已確認決定或範圍變更>`
- `技術點記錄`: `事實：<已驗證內容與來源>` / `推論：<必要且明確標示的推論>`

WI branch/PR handoff is independent of Notion; use `.codex/playbooks/wi-development-handoff.md` only when that update is requested/authorized.
