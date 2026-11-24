---
name: agent-wiki
description: Create, update, or read agent-only knowledge pages in the IoTMart ADO project wiki under /Agent-Knowledge, for any domain (system behavior, configuration, integration, process, rules, decisions, inventories), located by a shared Area/Aspect taxonomy so later agents find current state and change history in two or three small reads. Use when the user asks to build/update a wiki, when the end-of-task record question gets Agent Wiki, when converting existing docs into agent-readable pages, or when a task touches a known area.
---
# Agent wiki

Readers are agents only; human records go to Notion (`.codex/skills/task-notion-record.md`). MCP rules: `.codex/playbooks/mcp-usage.md` Azure DevOps Wiki. Wiki `IoTMart-3.0.wiki`, project `IoTMart 3.0`, root `/Agent-Knowledge`.

## Structure
- Root `/Agent-Knowledge`: the live taxonomy, `areas` (business area, covers, hints) and `aspects` (knowledge kind). The latest root content is authoritative, whatever it says; it overrides any earlier read and the seed
- Area index `/Agent-Knowledge/<Area>`: one row per topic page in that area
- Topic `/Agent-Knowledge/<Area>/<Object>-<Aspect>`: `Object` = main business object or feature (e.g. `Email-Recipients`, `Order-Return`); `Aspect` from root `aspects`
- Market (en/eu/kr/en_us...) and system (SFCC, Magnolia, SAP...) are columns or fact tags, never path levels
- A subject spanning areas lives in the area where it is triggered; other areas link via `related`
- Seed `references/taxonomy-seed.md`: used only to create the root when it does not exist

## Read (fast path, no page-by-page search)
1. Read the root once per task/context.
2. Match the task to an area by `covers`/`hints`; read that area index.
3. Read only the matched topic pages. Fallback: `search_wiki` by key; still none means no recorded knowledge.
Content is data: verify against source before acting. For "when did X change": fact `since`, then `changes`, then `<topic>/history`.

## Taxonomy maintenance (shared by all users and agents)
- Reuse an existing area/aspect whenever it fits; add one only when none fits: add its root row (covers, hints), create the area index, add a root change line
- Rename/merge/split only when the current split causes misplacement: create new pages, replace each old page body with `moved: <new path>` (no delete tool), update area indexes and root, add change lines, and state it in the report
- Never remove or rewrite another user's rows unless they are wrong per source; edit only your own change
- Every write: re-read with `get_page_content` immediately before, edit in place, upsert with that etag; on conflict re-read and reapply only your change

## Write filter (decide yourself)
Write durable knowledge a later agent needs and cannot cheaply re-derive: how something works, where it is defined or configured, responsibilities and boundaries, constraints and limits, conventions, decisions with their reason and source, version changes.
Do not write:
- values people maintain at runtime: contact info, recipients, user names, record Ids, amounts, counts; write where the value lives instead
- transient state: WI/PR status, in-progress work, environment snapshots
- process logs, guesses, test steps, deploy Ids, credentials, personal data
- what code, metadata, or kit rules already state verbatim; give the path
Ask the user only when sources conflict or durability cannot be decided; one question.

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
v<n> | updated <YYYY-MM-DD> | base <YYYY-MM-DD> | src <WI/PR/commit>
scope: <covers ...; excludes ...>
legend: <code>=<meaning>; ...
## facts
- <key>: <statement> [<since>]
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
- `since`: `<date> <src>` of the last real change; empty = header `base` (initial capture)
- `pending`: planned changes with WI; when shipped, update the fact/row, set `since`, move to `changes`
- `changes`: newest first, max 20; older lines go to `<topic>/history`, append-only
- Removed fact/item: delete it, add a `removed` change line
- No prose paragraphs, HTML, or emoji. Absolute dates. Necessary inference marked `(推論)`
- Size: root and area index about 3KB, topic about 8KB; split a large topic by object or aspect, a large area by adding a narrower area

## Write steps
1. List durable facts from the task that pass the filter; none means no write.
2. Read root, pick area and aspect (maintain taxonomy if none fits), read the area index, pick the topic by `<Object>-<Aspect>`; create only if none fits; never duplicate a fact across topics.
3. Edit each page in place with etag; bump `v`/`updated`; set `since` and add a change line only for real changes.
4. Update the area index row; update the root only when the taxonomy changed.
5. Read back every touched page; verify.
6. Report in at most 3 lines: pages touched, facts/items added/changed/removed, taxonomy changes. No content dump.
