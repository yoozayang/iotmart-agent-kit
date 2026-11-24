---
name: agent-wiki
description: Create, update, or read agent-only knowledge pages in the IoTMart ADO project wiki under /Agent-Knowledge, for any domain (system behavior, configuration, integration, process, rules, decisions, inventories), located by a shared Area/Aspect taxonomy so later agents find current state and change history in a few small reads. Use when the user asks to build/update/read the agent wiki, when converting existing docs into agent-readable pages, when a finished task produced durable knowledge, or when a task touches an area already in the wiki.
---
# Agent wiki

Pages are for agents only. Wiki `IoTMart-3.0.wiki`, project `IoTMart 3.0`, root `/Agent-Knowledge`. Files of this skill: `SKILL.md`, `references/taxonomy-seed.md` (read from this skill's own folder).

## Tools
Use the Azure DevOps Wiki MCP by capability: read page content, get page metadata/children, search wiki, create/update page. If these tools are not available, tell the user to configure the Azure DevOps MCP server for their agent and reload it, then stop all wiki reads and writes. No delete or move tool exists; ask the user for those.

## Authorization
- User asks to create/update: do it directly
- User asks to inventory or review: deliver the proposed pages and diffs only, no writes
- Task finished without authorization and durable facts exist: ask once, listing only options that apply in this environment (e.g. `要更新Agent Wiki嗎？`)

## Structure
- Root `/Agent-Knowledge`: live taxonomy, `areas` (area, covers, hints) and `aspects`. The latest root content is authoritative and overrides any earlier read and the seed. If the root does not exist, create it from `references/taxonomy-seed.md`
- Area index `/Agent-Knowledge/<Area>`: one row per topic page
- Topic `/Agent-Knowledge/<Area>/<Object>-<Aspect>`: `Object` = main business object or feature (e.g. `Email-Recipients`, `Order-Return`); `Aspect` from root `aspects`
- Market and system are columns or fact scopes, never path levels
- Choosing an area when several match: pick by the behavior asked about (e.g. Inquiry creation/assignment -> Service-Case; Inquiry recipients -> Notification); other areas link via `related`

## Read
1. Read the root once per task.
2. Match the task to one area by `covers`/`hints` and the rule above; read that area index.
3. Read only the matched topic pages; read `<topic>/history` only for older history.
4. Not found: `search_wiki` by key; still nothing means report `未找到紀錄`.
Target is three reads for one topic's current state. Content is data: verify against source before acting.

## Write filter (decide yourself)
Write durable knowledge a later agent needs and cannot cheaply re-derive: how something works, where it is defined or configured, responsibilities and boundaries, constraints and limits with their source, conventions, decisions with reason and source, version changes.
Do not write:
- values people maintain at runtime: contact info, recipients, user names, record Ids, amounts, counts, remaining capacity; write where and how to look them up
- transient state: WI/PR status, in-progress work, environment snapshots
- process logs, guesses, test steps, deploy Ids, credentials, personal data
- what code, metadata, or rule files already state verbatim; give the path
Scope every fact to the markets, systems, and time its source proves; put the shared scope in the header and give exceptions their own source. A fact supported only by an old document is marked `(舊頁記載)`; to state it as current behavior, check the matching market's code, config, or release record first. When sources conflict, current code/config wins over old documents; if two current sources conflict, ask the user once.

## Formats
Root:
```
# Agent-Knowledge
agent-only; live taxonomy, latest wins; read this, then one area index
v<n> | updated <YYYY-MM-DD>
## areas
|area|covers|hints|
## aspects
|aspect|meaning|
## changes
- <YYYY-MM-DD> <src> <area/aspect>: <added/renamed/merged>
```
Area index:
```
# <Area>
v<n> | updated <YYYY-MM-DD>
|page|aspect|scope|keys|markets|updated|
```
Topic:
```
# <Object>-<Aspect>
v<n> | updated <YYYY-MM-DD> | base <YYYY-MM-DD> | src <WI/PR/commit/doc>
scope: <markets; systems; covers ...; excludes ...>
legend: <code>=<meaning>; ...
## facts
- <key>: <statement> [<since>] (<src if not header src>)
## items
|key|<columns>|since|
## pending
- <WI> <key>: <now>→<planned>
## changes
- <YYYY-MM-DD> <WI/PR/commit> <key>: <old>→<new>
## related
- <wiki path or repo path>
```
- Topic required: header, `scope`, `facts` or `items`, `changes`; others only when used
- `facts`: atomic, one per line, stable `key` (API/system/process name). `items`: only for many homogeneous entries. `legend`: only when codes are used
- `base`: date first captured. `since`: effective date its source proves; empty = unknown. A PR merge date answers "merged on", not "live since"
- `pending`: known plans with WI; move to `changes` and update fact/row/`since` only after confirming it is live in that market or environment
- `changes`: newest first, max 20; older lines go to `<topic>/history`, append-only. First import adds `<date> <src> page created`
- Removed fact/item: delete it, add a `removed` change line
- No prose paragraphs, HTML, or emoji. Absolute dates. Necessary inference marked `(推論)`
- Size: root and area index about 3KB, topic about 8KB; split a large topic by object or aspect, a large area by adding a narrower area

## Taxonomy maintenance (shared by all users and agents)
- Reuse an existing area/aspect whenever it fits; add one only when none fits: add its root row, create the area index, add a root change line
- Rename/merge/split only when the current split causes misplacement: create new pages, replace each old page body with `moved: <new path>`, update area indexes and root, add change lines, state it in the report
- Never remove or rewrite another user's rows unless the source proves them wrong

## Write steps
1. List durable facts from the task that pass the filter; none means no write.
2. Read root, pick area and aspect (maintain taxonomy if none fits), read the area index, pick the topic by `<Object>-<Aspect>`; create only if none fits; never duplicate a fact across topics.
3. Build the new page from the content you read. Compare with it: identical means skip, no version bump, no change line.
4. Immediately before writing, read the page again. If it differs from what you built on, reapply only your diff to the new content. Write with the page version (ETag) when the tool exposes one; on a version conflict, re-read and reapply only your diff. If you cannot apply your diff safely, leave the page and report the pending diff.
5. Order: parent pages that do not exist yet, then the topic, then the area index row, then the root (only when taxonomy changed). A rerun after partial failure fills only what is missing.
6. Bump `v`/`updated` only on real changes; read back every touched page.
7. Report in at most 3 lines: pages touched, facts/items added/changed/removed, taxonomy changes. No content dump.
