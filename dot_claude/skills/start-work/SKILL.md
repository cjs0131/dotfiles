---
name: start-work
description: Charlie's morning kickoff — pull his open ClickUp tasks and recent playbooks/briefs, present a clean rundown, and suggest an ordered outline for the day that always opens with a short learning block. Use when he sits down ready to work and wants to pick up where things stand.
user-invocable: true
---
# /start-work — morning rundown + suggested outline

Charlie just sat down ready to work. Give him a clean read on where things
stand and a suggested shape for the day. Companion to `/meeting-debrief`: that
skill turns a meeting into tasks + playbooks; this is what he runs the next
morning to pick those threads back up.

**Read-only against ClickUp — never create, edit, or comment on tasks.** The one
thing this skill *does* write is Charlie's local daily worklog (Stage 0 and
Stage 6) — that's the running memory of what's actually been done, so nothing
gets re-suggested or lost between sessions.

## Stage 0 — Read the recent worklog (before anything else)

Worklogs live at `~/knowledge/worklog/YYYY-MM-DD.md`, one file per working day.
Before pulling tasks, read the **last few** (most recent 3–5 by date, and always
today's if it already exists). This is your memory of what's already been done.

Use it to avoid the cardinal sin: **don't suggest or re-open work the log shows
is already finished.** If a task looks open in ClickUp but the log says it was
completed, trust the log and flag the mismatch ("log says D1 verified Tue, but
its ClickUp task is still open — worth closing?") rather than telling him to redo
it. If there's no worklog dir yet, that's fine — you'll create today's in Stage 6.

## Stage 1 — Pull open work (ClickUp)

The ClickUp tools are named `mcp__clickup__clickup_*`. **Connection guard
first:** if they aren't available this session, do NOT silently skip — tell
Charlie plainly the ClickUp MCP isn't connected (it's configured globally in
`~/.claude.json`, loads on session start, so restarting the session and
re-running lights it up), then continue from playbooks alone.

When the tools are available, filter by Charlie as assignee rather than dumping
lists: `clickup_resolve_assignees` on "me" → `clickup_filter_tasks` with that id
and `include_closed: false`. A bare list dump hits the 100-task page cap and
misses recently-assigned work. For anything you want to describe, pull the
description with `clickup_get_task` (`include: ["description"]`) — it often holds
the concrete next step.

## Stage 2 — Gather recent playbooks & briefs

Scan `~/knowledge/meetings/` by modified time. Take the most recent handful —
roughly the last 7 days, or the newest ~5 files if it's been quiet. These are
the `*-playbook.md` and brief files `/meeting-debrief` produces. Read each
enough to know what it covers and what state the work is in. Don't re-summarize
them in full — you want pointers, not re-teaching.

## Stage 3 — Cross-reference

Match playbooks to open tasks:

- Playbook whose matching task is **still open** → a live thread, ready to act on.
- Playbook whose task is **closed** → done; drop it or note it in one line.
- Open task with **no playbook** → a loose thread, flag it.
- If a match is ambiguous, say so rather than guessing.

## Stage 4 — Present the rundown (chat)

Three short sections, human and newcomer-calibrated (`explain-for-newcomer`
voice — no template or QA-textbook tone, Charlie will call it out):

- **On your plate** — open tasks, each with status + the playbook link if one
  exists (link the file so he can click it open).
- **Playbooks ready to act on** — the live ones, one line each on what they cover.
- **Loose threads** — tasks with no playbook, or anything ambiguous worth a look.

## Stage 5 — Suggested outline

A handful of **ordered work blocks**, each with a one-line *why*. No clock times
— sequence and rationale only. Frame it explicitly as a suggestion he adapts,
not a schedule.

**Always open with a short learning block.** Pick a concept worth shoring up from
the vault `*-map.md` index files (`~/knowledge/*-map.md`), biased toward what the
day's tasks actually touch — a verify task pairs with a QA concept from
`qa-map.md`, a coding task with something from `programming-map.md`. Link it as a
`[[wikilink]]`. Then order the task work after the warm-up, with deeper-focus
blocks later once he's warmed up.

Example shape:

> 1. **Warm up — skim [[what-is-qa]]** — light start, sets up the verify task.
> 2. **Verify release D1** — playbook's ready, freshest thing on your plate.
> 3. **Code on X** — deeper focus once you're warmed up.

## Stage 6 — Open (or continue) today's worklog

After presenting the rundown, make sure today's log exists at
`~/knowledge/worklog/YYYY-MM-DD.md` (create the `worklog/` dir if it's missing).
Seed it with the plan — the day's open threads and the suggested outline — so
there's a spine to fill in. If today's file already exists (a second run, or a
resumed session), append to it, don't clobber it.

Suggested shape — keep it plain, not a template:

```markdown
# Worklog — 2026-07-09

## Plan
- [ ] Verify release D1 (playbook ready)
- [ ] Code on X

## Done
_(fill in as the day goes)_

## Notes / carried over
```

**Then keep it as living memory for the rest of the session.** This is the part
that matters — the log is worthless if it's only written once at kickoff. As
real work gets done in this session, update the file *on your own initiative*
when a meaningful unit finishes — no need to ask each time:

- Check a task off `Plan` and add a one-line entry under `Done` (what changed,
  any file/PR/task ref) when something is actually completed or verified.
- Log a decision, a blocker, or a thread you're carrying to tomorrow under
  `Notes / carried over`.
- Don't narrate every tool call or trivial step — capture the units Charlie
  would want to see next morning, at roughly the granularity of the Plan items.

This closes the loop with Stage 0: what you write today is what keeps tomorrow's
run from re-suggesting finished work.

## Notes

- One rundown per run, for today.
- Degrade gracefully: no ClickUp → work from playbooks; no recent playbooks →
  work from open tasks and still suggest a learning-first outline.
- Keep it tight. This is a launchpad, not a report.
