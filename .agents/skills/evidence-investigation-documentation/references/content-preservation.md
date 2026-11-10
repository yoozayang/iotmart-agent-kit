# Preserve document content

Read before writing Notion or editing another existing document, including requirements and SDD. Reading alone does not require this reference.

- Write only within the user's authorized scope. Keep repository/environment/deployment authorization boundaries.
- Fetch the current target immediately before editing; retain affected content as the Before record.
- Preserve existing sections, sentences, child-page URLs, and order. Make targeted insertions or replacements; leave unrelated content untouched.
- Correct, combine, simplify, or retire wording by retaining the original with strikethrough and adding its replacement immediately after it. This applies to user- and agent-authored text, including old questions and assumptions.
- Use native Notion strikethrough (`~~original~~` in supported Markdown). Do not physically delete text or blocks without explicit permanent-deletion authorization. If preservation cannot be achieved, stop and propose a safe replacement plan.
- Ask before changing user-authored text; move user-authored content or existing child pages only with explicit authorization. Never edit, delete, or reorder a protected `我的記錄區`, even when empty.
- Add evidence and date/source for material changes. Report edited sections as added or revised.
- Re-fetch each edited page: verify every affected original is unchanged or retained with strikethrough, replacements are present, and unrelated text/URLs remain.
- If concurrent changes or unexplained post-write differences appear, stop; do not restore or overwrite without user direction. Report failed checks and do not advance a documentation baseline.
