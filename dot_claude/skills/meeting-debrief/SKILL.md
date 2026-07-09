---
name: meeting-debrief
description: Turn a recent Fathom meeting recap into a QA-newcomer-friendly brief plus a two-track next-steps roadmap, corroborated read-only against ClickUp. Use when Charlie asks to debrief a meeting, catch up on what a standup/call means for him, or turn a Fathom report into tasks and learning.
user-invocable: true
---

# /meeting-debrief — Fathom meeting → brief + roadmap

Arguments passed: `$ARGUMENTS` (optional meeting hint — a date, a title, or
"latest". Empty means the most recent Fathom meeting.)

Turn a Fathom meeting into: a plain-language summary, explanations of the
confusing bits, a task list corroborated against ClickUp, and a two-track
roadmap (what to do next + what to learn next). Read-only against ClickUp —
this skill never creates or edits tasks.

## Stage 1 — Find the report (Gmail)

Search Charlie's mail for the Fathom recap, newest first. Try, in order:

- `from:fathom.video newer_than:30d`
- `subject:(recap OR "meeting" OR "action items") from:fathom newer_than:30d`
- broaden to `fathom newer_than:90d` if nothing lands.

If `$ARGUMENTS` names a date/title, filter to that. Pick the matching thread
and read the full message body — **do not assume a format**, Fathom's recap
layout may differ from what you expect. Note what the email actually contains:
summary? action items? a `fathom.video` link to the full report?

**If the email is only a summary + a `fathom.video` link**, try to fetch the
linked page for the full transcript using an existing logged-in browser
session (browser MCP). This link usually needs auth — if it will not load,
**say so plainly and continue from the email summary**. Never invent
transcript content you could not read.

If no Fathom recap email exists at all, stop and tell Charlie — offer to work
from a pasted summary instead. (Fathom does not always auto-email full
recaps; the report may only live in the app.)

## Stage 2 — Summarize

Plain-language recap: what the meeting was about, who cared about what, what
was decided. Apply the `explain-for-newcomer` style — big-picture first, no
QA-textbook voice, human prose.

## Stage 3 — Explain the confusing bits

Scan for QA/tech terms, tools, and jargon a newcomer would trip on. For each,
give a short big-picture-first explanation (what it is → where it fits → why
it came up here). Keep the list of terms — Stage 6 turns them into vault notes.

## Stage 4 — Extract tasks from the transcript

Pull action items: explicit ("Charlie, can you test X?") and implied ("we
should probably check whether…"). For each, capture who owns it, what it is,
and any deadline mentioned. Do not corroborate yet — just extract.

## Stage 5 — Corroborate against ClickUp (read-only)

**Connection guard first.** The ClickUp tools are named
`mcp__clickup__clickup_*` (e.g. `mcp__clickup__clickup_search`,
`mcp__clickup__clickup_get_task`). If none are available this session, do NOT
silently skip — write the tasks with a `⏳ pending ClickUp check` marker and
tell Charlie plainly: the ClickUp MCP isn't connected, it's configured
globally in `~/.claude.json`, and it loads on session start — so restarting
the session and re-running the skill will light it up. Then continue to
Stage 6 with the un-corroborated task list.

When the tools ARE available, first **filter tasks by Charlie as assignee**
(`clickup_resolve_assignees` on "me" → `clickup_filter_tasks` with that id and
`include_closed: true`) rather than dumping whole lists — a bare list dump hits
the 100-task page cap and silently misses recently-assigned tasks. Keyword
`clickup_search` also misses freshly-created tasks, so treat a zero-result
search as "not found yet," not "confirmed gap." Then for each extracted task:

- **Match** — if a task exists, report its status, assignee, and link. Pull the
  task description with `clickup_get_task` (`include: ["description"]`) — it
  often holds the concrete first step the meeting glossed over.
- **Flag gaps** — mark meeting tasks with no ClickUp task as `⚠ not tracked`,
  so nothing slips.
- **Pull context** — for matches, surface the ClickUp description/comments
  that fill in details the meeting glossed over.

Do not create, edit, or comment on ClickUp tasks. If a match is ambiguous,
say so rather than guessing.

## Stage 6 — Two-track roadmap + output

Build two ordered lists:

- **Task track** — immediate next steps for the actual work, ordered by what
  to do first. Each item: the action, the ClickUp link (or `⚠ not tracked`),
  and the one-line "why it matters" from Stage 5.
- **Learning track** — QA/tech concepts to shore up given what came up,
  ordered by what Charlie will hit soonest.

Then write the output:

1. **Meeting brief** — one dated markdown file at
   `~/knowledge/meetings/YYYY-MM-DD-<slug>.md` with four sections: Summary,
   Concepts explained, Tasks (with ClickUp corroboration), Roadmap (both
   tracks). Create the `meetings/` folder if it does not exist.
2. **Concept notes** — in the brief, always list the concepts worth keeping
   as `[[wikilink]]` stubs (Stage 3). Do NOT auto-generate a note per concept
   by default — 5–8 meetings' worth of auto-notes would bury the vault. After
   writing the brief, offer to generate the notes and let Charlie pick which
   ones; generate the chosen ones by delegating to the `/recap` skill. A
   `[[wikilink]]` with no note yet is fine — it just marks one worth writing.
3. **In chat** — echo the summary highlights and the full roadmap so Charlie
   can act without opening the file.

## Stage 7 — Granular task playbooks (the mentorship layer)

The roadmap says *what* to do. A playbook says *how to actually do the job* —
this is where the skill earns its keep for a QA newcomer. For each **tracked,
substantial task** (skip trivial admin like "upgrade a subscription"), write a
separate playbook file at
`~/knowledge/meetings/YYYY-MM-DD-<task-slug>-playbook.md` and link it from the
roadmap.

To build one, **go get the real material** — don't write generic advice:

- Read the ClickUp task and everything it points to. A "verify a release" task
  links to the release; pull the **actual changes in that release**
  (`clickup_search` the release name, or filter the release's list) and read
  **each change's description**, especially any "Release Notes" / "Testing
  Considerations" the dev wrote. Those are your test steps.
- For a "start learning X" task, read the onboarding doc / repo file it names.

Then write the playbook granular enough to act on cold:

- **What this task means** — one paragraph, big-picture-first, newcomer framing
  ([[what-is-qa]] style), with the relevant concept `[[wikilinks]]`.
- **Before you start — confirm with <person>** — list the things you genuinely
  **cannot** determine from the data (environment URLs, test accounts/logins,
  test-mode credentials, whether to update which ticket). Never invent these;
  park them as crisp questions. Note environment gotchas (e.g. ticket "source"
  URLs usually point at prod, not the env being verified; reported device /
  viewport may matter).
- **Per change/sub-item** — what changed and why, the click-by-click steps to
  reproduce and verify, edge cases the dev flagged, and what evidence to record.
- **Closing out** — how to record results, file any failures (`bug-report`
  skill / [[writing-bug-reports]]), which ticket/status to update, and how to
  report back.
- **Open questions parked** — the unknowns collected up top, in one list.

Keep the voice human and specific to *this* release/task — a playbook that
could apply to any release isn't granular enough.

## Notes

- One meeting per run. If several recaps match, ask which.
- Best-effort transcript fetch — degrade gracefully to the email summary.
- Keep prose human and calibrated to a sharp newcomer; no filler, no
  template voice (Charlie will call it out).
