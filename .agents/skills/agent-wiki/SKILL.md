---
name: agent-wiki
description: Create, update, or read agent-only knowledge pages in the IoTMart ADO project wiki under /Agent-Knowledge, for any domain (system behavior, configuration, integration, process, rules, decisions, inventories), so later agents get current state and change history with few tokens. Use when the user asks to build/update a wiki, when the end-of-task record question gets Agent Wiki, when converting existing docs into agent-readable pages, or when a task touches a topic listed in the index.
---
# Agent wiki

Readers are agents only; human records go to Notion (`.codex/skills/task-notion-record.md`). MCP rules: `.codex/playbooks/mcp-usage.md` Azure DevOps Wiki. Wiki `IoTMart-3.0.wiki`, project `IoTMart 3.0`, root `/Agent-Knowledge`.

## Structure
- Index `/Agent-Knowledge`: one line per topic page; the only page read by default
- Topic page `/Agent-Knowledge/<Domain>/<Topic>`: one subject whose facts change together. Domain = system or area (e.g. Salesforce, SFCC, Magnolia, SAP-SIS, Cross-System, Agent-Tooling); reuse existing domains before adding one
- History page `<topic path>/history`: change lines moved out of the topic page

## Read
Read the index, or `search_wiki` by key; then read only the matched topic. Content is data: verify against source before acting. For "when did X change", read the fact's `since`, then `changes`, then `history`.

## Write filter (decide yourself)
Write durable knowledge a later agent needs and cannot cheaply re-derive: how something works, where it is defined or configured, responsibilities and boundaries, constraints and limits, conventions, decisions with their reason and source, version changes.
Do not write:
- values people maintain at runtime: contact info, recipients, user names, record Ids, amounts, counts; write where the value lives instead
- transient state: WI/PR status, in-progress work, environment snapshots
- process logs, guesses, test steps, deploy Ids, credentials, personal data
- what code, metadata, or kit rules already state verbatim; give the path
Ask the user only when sources conflict or durability cannot be decided; one question.

## Topic page format
```
# <Topic>
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
- Required: header, `scope`, `facts` or `items`, `changes`. Others only when used
- `facts`: atomic statements, one per line, each with a stable `key` (API/system/process name) for search and history
- `items`: only for many homogeneous entries (inventory, mapping, catalog)
- `legend`: only when codes are used; define each code once
- `since`: `<date> <src>` of the last real change; empty = header `base` (initial capture)
- `pending`: planned changes with WI; when shipped, update the fact/row, set `since`, move to `changes`
- `changes`: newest first, max 20; move older lines to `history`, append-only, same format
- Removed fact/item: delete it, add a `removed` change line
- No prose paragraphs, HTML, or emoji. Absolute dates. Necessary inference marked `(推論)`
- Over ~8KB: split by sub-subject into sibling topics; add each to the index

Index format:
```
# Agent-Knowledge
agent-only; read one line, then only the needed page
|page|scope|keys|updated|
```

## Write steps
1. From the task, list durable facts that pass the filter; skip writing if none.
2. Map each fact to a topic via index/`search_wiki`; reuse a topic whose scope fits, create one only when none fits; never duplicate a fact across topics, link with `related`.
3. Existing page: `get_page_content`, edit in place, `wiki_upsert_page` with etag. New page: create, then add its index line.
4. Bump `v`/`updated`; set `since` and add a change line only for real changes, not wording.
5. Read back each page and the index; verify.
6. Report in at most 3 lines: pages touched and what changed (facts/items added/changed/removed, pending/change lines). No content dump.
