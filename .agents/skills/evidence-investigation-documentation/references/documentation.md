# Write investigation documentation

Read [content-preservation.md](content-preservation.md) before writing.

## Location and structure
- Reuse the page covering the same maintenance responsibility or How-to. Create a child only for a distinct, confirmed responsibility or independently actionable scenario; do not duplicate pages for individual directories/files.
- A How-to needs a goal, exact change location, change, and verification. Keep full procedures in How-to children; keep the parent as an overview/index with concise links.
- Put platform-native mechanisms in platform architecture; put project/site/locale/environment-specific configuration in customization. Split findings crossing those boundaries and cross-link rather than duplicating explanations.
- Architecture/customization pages contain scope, ownership, locations, dependencies, and evidence. Cross-link to goal-oriented How-tos. Leave unclear, legacy, or supporting material in the parent map or Unknowns until its independent maintenance value is verified.
- If the requested parent/section is ambiguous, show the proposed location and wait for direction. Follow a named destination and existing placement convention.
- For Notion children, a mention is only a link: verify a real child-page block under the intended parent section. Fetch the parent after creating/moving the child; wrong section or end-of-page placement is not success. Preserve moved URLs and original text under the retention rules.

## Incremental updates
- Use only when requested and a trustworthy user-supplied baseline exists: commit, PR, completed task, release, or recorded documentation scope.
- Do not create state/YAML/baseline files or new repository conventions by default.
- Validate commit baselines before using a diff. Diverged/rewritten history is not a safe incremental range. Without a baseline, report the gap and investigate the named change range or re-establish scope from evidence.
- Inspect in-scope changes and related source. Formatting, typos, refactors, or implementation changes with no maintenance impact need no documentation update.
- Update existing responsibilities; add a child only for a newly confirmed independent responsibility/How-to. Advance the documented baseline only after successful writes and all preservation/placement checks.

## Configuration documentation
Include one row per meaningful setting, or a labelled group always changed together:

| Setting key/property/resource | Exact path/UI/environment | Value/option/relationship to change | Behavior/maintenance purpose | Evidence |
| --- | --- | --- | --- | --- |

- A filename/directory alone is insufficient: identify the actual setting and its effect.
- Separate site/locale/environment variants. Mark unverified mappings or runtime effects as pending verification.
- Handover: scope, page links, sections added/revised, evidence limits, completed checks, and remaining verification.
