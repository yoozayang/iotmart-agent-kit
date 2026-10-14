---
name: evidence-investigation-documentation
description: Investigate repositories, systems, configurations, environments, incidents, or completed tasks from direct evidence, then prepare or safely update maintainable documentation. Use when asked to investigate, survey, understand, map, create an operations manual, document findings, or turn a completed task into documentation, including Magnolia, IoTMart, Notion, runtime, JCR, UI, log, and configuration work. Triggers include「調查某件事」、「盤點Repository」、「建立維運手冊」and「把Task處理完化成文件」.
---

# Evidence Investigation Documentation

Use one evidence-led workflow for investigation and documentation. Do not assume a platform structure, system owner, runtime behavior, or implementation from names alone.

## 1. Establish scope and authority

- Identify the target, question, intended audience, in-scope sources, and required output.
- State whether the request authorizes investigation only, documentation planning, or documentation editing.
- Treat investigation as read-only unless the user explicitly authorizes a change.
- Apply the target repository's instructions, routing, and safety rules before this skill.

## 2. Investigate from primary evidence

- Start from the actual repository, configuration, runtime state, logs, API responses, JCR, or UI named by the request.
- Read representative content before assigning purpose to a file, directory, module, service, or setting.
- Let the discovered structure determine categories. Do not force a standard Magnolia or project layout.
- Record concrete evidence for important conclusions: path, identifier, source URL, command result, or observable UI/runtime state.
- Distinguish confirmed facts, clearly labelled inferences, and unknowns.

## 3. Build the maintenance map

For each finding with maintenance value, capture:

| Responsibility or behavior | Actual location | Confirmed purpose | Maintenance impact | Evidence |
| --- | --- | --- | --- | --- |

Classify findings only when supported by evidence:

- Architecture overview
- Configuration or resource map
- Independently actionable How-to candidate
- System behavior or mechanism
- Development or deployment flow
- Maintenance convention, risk, or known pitfall
- Runtime, environment, JCR, API, or UI verification required

Treat something as a How-to only when a maintainer can identify the goal, location, change, and verification. Do not create a How-to merely because a directory or file exists.

## 4. Report investigation results

Return these sections unless the request narrows the output:

1. **Repository or System Map** — only structures that help understanding or maintenance
2. **Maintenance Map** — responsibility, location, confirmed use, maintenance context, and evidence
3. **How-to Candidates** — mark each as ready for a first version, needs more investigation, or needs runtime/environment verification
4. **Manual Coverage** — what the evidence supports documenting now
5. **Unknowns** — what the available evidence cannot prove

Keep unknowns explicit. Do not present probable behavior as confirmed behavior.

## 5. Convert findings into documentation

Edit Notion or another documentation target only after explicit user authorization to document or update it.

### Choose the document location

- Reuse an existing How-to child page when it already covers the same maintenance goal.
- Create a new How-to child page when a confirmed maintenance scenario has a distinct goal, location, change, and verification method.
- Keep the parent manual page as an overview and How-to index. Add only a concise link or summary there after the child page exists.
- Do not put a full independent procedure in the parent manual page when it belongs in a How-to child page.
- Do not create a duplicate child page for a scenario already covered by an existing How-to.
- If the target page has no clear How-to section or the correct parent is ambiguous, present the proposed location and wait for direction before creating a page.

### Place architecture and customization documentation

- Create a child page beneath an existing architecture or customization section when evidence confirms a distinct, stable maintenance responsibility.
- Keep the parent architecture or customization page as a concise responsibility map and child-page index.
- Group child pages by confirmed responsibility, behavior, or maintenance boundary, not by one-to-one directory or file names.
- Keep architecture and customization pages focused on scope, ownership, locations, dependencies, and evidence.
- Keep goal-oriented steps, validation, and operational decisions in How-to child pages. Cross-link to the relevant architecture or customization page instead of duplicating the explanation.
- Leave low-value, unclear, legacy, or purely supporting directories in the parent map or Unknowns until evidence shows they need an independent page.

- Fetch and read the current target before editing.
- Preserve every existing section and sentence. Never silently delete, overwrite, merge away, or reorder existing content.
- When correcting, replacing, combining, or retiring existing wording, retain the original wording with strikethrough, then add the replacement immediately after it.
- Add new content without altering unrelated content.
- Cite the evidence source in every material new or replacement claim.
- Report each edited section and whether it was added or revised.

Use Notion's strikethrough syntax for retained original wording:

```markdown
~~Original wording retained for history~~

Replacement wording with evidence: `actual/path` or source link
```

If a requested edit would require deleting existing content, stop and ask for a preservation-safe replacement plan.

## 6. Handover

- State the completed scope, edited targets, and evidence boundaries.
- List follow-up validation separately from confirmed findings.
- Keep any environment, deployment, credential, or production action subject to the target repository's stricter rules.

## 7. Incremental documentation

Use incremental documentation only when the user asks to sync or update an already-documented scope and a trustworthy baseline is available.

- Do not create a YAML, state file, baseline file, or new repository convention by default.
- Use an existing, user-supplied baseline such as a commit, PR, completed task, release, or clearly recorded previous documentation scope.
- If no trustworthy baseline exists, say so. Re-establish a baseline through a scoped investigation, or investigate only the change range the user names.
- When the baseline is a commit, confirm it exists and is a valid comparison point before relying on a diff. If history has diverged or been rewritten, do not infer a safe incremental range.
- Review only the in-scope changes and their related source files. A refactor, typo, formatting-only change, or implementation change with no maintenance impact does not require a documentation update.
- Reuse and update the page that already covers an affected maintenance responsibility or scenario. Create a child page only for a newly confirmed independent responsibility or How-to.
- Update any documented baseline only after the documentation write and all post-write checks succeed.

## 8. Classification and Notion structure guardrails

Classify before creating, moving, or duplicating documentation:

- Put platform-native mechanisms in the platform or original-product architecture area.
- Put project, site, locale, environment, and implementation-specific configuration in the project customization area.
- Split a finding that crosses those boundaries. Cross-link the pages instead of repeating the complete explanation in both places.
- Put goal, change location, and verification steps in a How-to child page.
- Keep unverified runtime behavior in Unknowns or a clearly labelled pending-verification area.

For Notion child pages:

- A page mention is a link, not a child-page placement. Verify that a real child-page block is directly beneath the intended parent section.
- Fetch the parent after creating or moving a child page. Do not report completion when Notion has appended the page under the wrong section or at the document end.
- Move user-authored content or existing child pages only with explicit authorization. Preserve every moved page URL and each original text block under the retention rules.

## 9. Documentation integrity checks

Treat a documentation update as incomplete until it passes these checks:

- Fetch every target page immediately before writing and retain the affected content as the Before record.
- Make the smallest targeted edit possible. Do not use a broad replacement when an insertion or exact replacement is sufficient.
- Re-fetch every edited page after writing. For every affected existing substantive block, verify that it is unchanged or retained as strikethrough immediately beside its replacement or move notice.
- Verify that unrelated text, existing child-page URLs, and required parent-child placement remain present.
- If the page changes between inspection and write, or the post-write result contains an unaccounted change, stop. Do not restore, overwrite, or claim success without user direction.
- If any retention or placement check fails, report the failure and do not advance a documentation baseline.

## 10. Configuration documentation minimum content

For every document or child page that explains configuration items, include at least:

| Setting item | Actual location | What to change | Corresponding behavior or maintenance purpose | Evidence |
| --- | --- | --- | --- | --- |

- Name the actual setting key, property, or resource. Do not describe a configuration item only by its directory or filename.
- Give the exact path, page, UI location, or environment boundary where the setting is maintained.
- State what value, option, or relationship the maintainer changes and what that change corresponds to in the system, site, locale, component, or workflow.
- Use one row per meaningful setting or a clearly labelled grouped row when several settings always change together.
- Separate site, locale, environment, or other variant values. Do not imply that one observed value applies everywhere.
- Mark any unverified mapping or runtime effect as pending verification instead of presenting it as confirmed behavior.
