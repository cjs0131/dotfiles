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

**Read-only against ClickUp — never create, edit, or comment on tasks.** What
this skill *does* write is local, in Charlie's vault: his daily worklog (Stage 0
and Stage 7) — the running memory of what's actually been done — and any missing
playbooks for tasks that need one (Stage 4). Neither touches ClickUp.

## Stage 0 — Read the recent worklog (before anything else)

Worklogs live at `~/knowledge/worklog/YYYY-MM-DD.md`, one file per working day.
Before pulling tasks, read the **last few** (most recent 3–5 by date, and always
today's if it already exists). This is your memory of what's already been done.

Use it to avoid the cardinal sin: **don't suggest or re-open work the log shows
is already finished.** If a task looks open in ClickUp but the log says it was
completed, trust the log and flag the mismatch ("log says D1 verified Tue, but
its ClickUp task is still open — worth closing?") rather than telling him to redo
it. If there's no worklog dir yet, that's fine — you'll create today's in Stage 7.

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
- Open task with **no playbook** but real work in it → you'll build the playbook
  in Stage 4. Note it now.
- If a match is ambiguous, say so rather than guessing.

## Stage 4 — Build playbooks for tasks that need one

Stage 3 turns up open tasks with **no playbook**. Some are just quick checkboxes
— but any task with *real work* in it (a release to verify, a staged onboarding,
any flow with setup + steps + things to record) deserves a playbook **before**
Charlie starts, the same shape as the ones already in `~/knowledge/meetings/`.
Don't leave that as a loose thread for him to decompose cold — build it now so
the day's work is ready to act on. This is the one place the skill does real
authoring; take the time to do it well.

**Vocab — keep these straight:** a **to-do** is work *Charlie* does ("Verify
2026-07-09-D1"); a **playbook** is the how-to guide *you* write to walk him
through that to-do. Building a playbook is the skill's job, done here in Stage 4 —
it is **never** itself a Plan checkbox on his dashboard. The dashboard to-do is
always the underlying work; the playbook you build just gets linked to it (per
Stage 7's wikilink rule).

**Which tasks get one:** any open task whose ClickUp description implies more
than a trivial check — a release with multiple sub-tickets/changes, a multi-step
onboarding, a flow with setup and expected results. **Skip** playbooks for
one-line admin items ("upgrade Claude, forward the invoice") — those just get a
line in the rundown.

**How to build one** (model it on the existing `*-playbook.md` files — match
their voice and structure exactly):

1. Pull the task's full description with `clickup_get_task`
   (`include: ["description"]`), then **follow its links** — a Verify task points
   at a release list of individual change tickets; open each so every change gets
   its own section with setup, steps, and what to record.
2. **Mine the repo's own docs before parking anything as "ask David."** The
   onboarding doc (`test-plans/qa-onboarding.md`), `test-plans/README.md`, and
   the manual-test docs answer most setup questions — dev URL, test accounts,
   Stripe test cards. Check the docs even for questions you'd default to asking
   David: sometimes the doc gives the answer outright, and sometimes it tells you
   *who* the answer comes from (e.g. the test API keys — the onboarding doc says
   to get `HP_TEST_SERVICE_KEY` / `HP_X_API_KEY` "from your supervisor," so David
   is genuinely the right source, not a guess). Either way you've saved a
   round-trip. Only questions the docs truly don't resolve go in an "open
   questions for David" list at the end.
3. Write it newcomer-first (`explain-for-newcomer` voice): what the task means,
   per-change setup + steps + expected result + what to record, edge cases, a
   close-out. Link vault concepts as `[[wikilinks]]`, **and link the repo docs you
   drew the setup from** — the onboarding doc, `README.md`, the relevant `TC-*` /
   `MO-*` doc — so the playbook is a hub back to its sources, not a dead end.
4. Save to `~/knowledge/meetings/YYYY-MM-DD-<slug>-playbook.md` (dated for the
   day you built it) and surface it in the rundown as a live thread.

If a task is too ambiguous to tell what verifying it even involves, **don't
invent a playbook** — flag it in the rundown as needing a word with David.

## Stage 5 — Present the rundown (chat)

Three short sections, human and newcomer-calibrated (`explain-for-newcomer`
voice — no template or QA-textbook tone, Charlie will call it out):

- **On your plate** — open tasks, each with status + the playbook link if one
  exists (link the file so he can click it open).
- **Playbooks ready to act on** — the live ones, one line each on what they
  cover. Call out any you just built in Stage 4 so he knows they're fresh.
- **Loose threads** — tasks too ambiguous to have decomposed, admin items with no
  ticket, or anything worth a second look.

**Link everything you name.** Every doc or note you mention becomes a clickable
link so Charlie opens it in one click, never hunts for it:
- **Repo process docs** — the QA onboarding doc (`test-plans/qa-onboarding.md`),
  `test-plans/README.md`, the specific `TC-*`/`MO-*` doc a task touches. Link the
  file so it opens locally.
- **Vault notes** — any `~/knowledge/` note you reference (a concept note, a
  `*-map.md` index): link the `.md`.
- **Playbooks** — always linked, as covered above.
If a task's concrete next step lives in a particular doc, link *straight to that
doc*, not just its name. When several docs are relevant to a task, list them all
under it — err toward more links, not fewer.

## Stage 6 — Suggested outline (granular, not a schedule)

Lay the day out as an **ordered list of concrete steps** — step 1, step 2, step
3 — each a specific action Charlie can start on, with a one-line *why*. This is
**not** a clock-time schedule and **not** a loose list of themes: the value is in
the granularity. Where a step has real sub-parts, break them out (step 2a, 2b) so
he can work straight down the list without stopping to figure out "okay, what
does that actually mean." The full detail lives in the playbook each step points
at — the outline is the ordered spine into it.

**Always open with a short learning block.** Pick a concept worth shoring up from
the vault `*-map.md` index files (`~/knowledge/*-map.md`), biased toward what the
day's tasks actually touch — a verify task pairs with a QA concept from
`qa-map.md`, a coding task with something from `programming-map.md`. Link it as a
`[[wikilink]]`. Then order the task work after the warm-up, with deeper-focus
blocks later once he's warmed up.

No clock times — sequence and rationale, just finer-grained than a bullet list of
themes. Frame it explicitly as a suggestion he adapts.

Example shape (note the granularity — sub-steps, not one line per block):

> 1. **Warm up — skim [[release-and-verification]]** — light start, primes both
>    verify tasks.
> 2. **Clear blockers in one Slack message to David** — bundle every open
>    question so nothing waits on a second round:
>    - a. the two Playwright API keys (or confirm the onboarding doc's location)
>    - b. verifying = update each feature ticket, or just the Verify task?
> 3. **Verify 2026-07-07-D1** — playbook's ready, high priority:
>    - a. Change 1 (stop taking new orders) — needs a chef + eater account, an
>      order placed first
>    - b. Changes 2–3 (AI image, address checkbox)
>    - c. Changes 4–5 (button outlines, Stripe styling) — capture screenshots
> 4. **Playwright onboarding, key-free parts** — build check, read the process
>    docs, install browsers, walk TC-0001 manually. Deeper focus, saved for last.

## Stage 7 — Open (or continue) today's worklog

After presenting the rundown, make sure today's log exists at
`~/knowledge/worklog/YYYY-MM-DD.md` (create the `worklog/` dir if it's missing).
Seed it with the plan — the day's open threads and the granular outline from
Stage 6, plus a note of any playbook you built in Stage 4 — so there's a spine to
fill in. If today's file already exists (a second run, or a resumed session),
append to it, don't clobber it.

**The Plan items are Charlie's personal work layer — write them so they surface
on his Obsidian dashboard.** He runs an Obsidian tasks module (the Work section of
[[dashboard]], driven by the Tasks plugin — see `obsidian-task-system-setup.md`).
It shows anything tagged `#work`. So write each Plan checkbox as a `#work` task
with today's date, e.g. `- [ ] #work Verify 2026-07-09-D1 — changes 1–3 📅 today`
(use the real `YYYY-MM-DD`), adding `⏫`/`🔼` for priority where it helps.

**If a task has a matching playbook, link it right in the task line** as a
`[[wikilink]]` to the playbook's note name — the Tasks plugin renders it clickable
on the dashboard, so Charlie jumps straight there instead of hunting. Put the link
in the description, before the date/priority emoji:
`- [ ] #work Finish Verify 2026-07-07-D1 — [[2026-07-07-verify-D1-playbook]] 📅 today ⏫`.
Applies to any task with a playbook (release verifies, the Playwright onboarding,
anything you built in Stage 4).

Two rules keep this clean:
- **ClickUp stays the source of truth for assigned work — don't mirror its
  status here.** The Plan is your *breakdown* of the day (granular sub-steps, the
  learning block) and the **untracked** items that have no ClickUp home (e.g.
  "upgrade Claude, forward invoice," "add TypeScript to the learning plan").
  Those especially belong here — the dashboard is the only place they'll surface.
- **Degrade gracefully.** If the Tasks plugin isn't enabled yet, `#work` tasks
  still render as ordinary checkboxes — nothing breaks, they just won't aggregate
  on the dashboard until Charlie installs it. Write them tagged regardless.

Suggested shape — keep it plain, not a template:

```markdown
# Worklog — 2026-07-09

## Plan
- [ ] #work Verify release D1 (playbook ready) 📅 2026-07-09 ⏫
- [ ] #work Upgrade Claude to Max 5X, forward invoice to David 📅 2026-07-09

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
