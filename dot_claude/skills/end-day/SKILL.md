---
name: end-day
description: Use when Charlie is wrapping up for the day — "end day", "wrap up", "done for today", "eod", "close out". Reviews today's worklog, reports what got done vs. carried over, suggests which ClickUp tasks look ready to close, and seeds tomorrow. The evening bookend to /start-work.
user-invocable: true
---

# /end-day — close out the day

The evening half of `/start-work`. That skill opens the day from the worklog;
this one closes it: settle what today's log says, surface anything the session
did that the log missed, and leave a clean seed so tomorrow's `/start-work`
picks up accurately.

**Read-only against ClickUp — suggest status changes, never make them.** The
one thing this writes is today's worklog (same file `/start-work` maintains).

## Stage 1 — Read today's worklog

Open `~/knowledge/worklog/YYYY-MM-DD.md` for today. This is the spine.
- If it exists, it already has `Plan` / `Done` / `Notes` from the day.
- If it doesn't exist (Charlie worked without running `/start-work`), reconstruct
  what happened from this session's actual work and create the file now — don't
  end the day with no record.

## Stage 2 — Reconcile against what actually happened

Compare the log to what the session actually did. The log is only trustworthy if
it's complete, so **fill the gaps before summarizing**: anything finished in this
session that isn't yet under `Done`, add it now (one line, with any file/PR/task
ref). Anything on `Plan` that's still untouched stays open.

## Stage 3 — Report the day (chat)

Short and human (`explain-for-newcomer` voice — no template tone):
- **Done today** — what actually got completed, plainly.
- **Carried over** — Plan items not finished, and any blockers, so it's obvious
  what tomorrow inherits.
- **Worth capturing?** — if the day produced a lesson, a fix, or a concept worth
  keeping, flag it and offer `/recap`. If config/dotfiles changed, offer
  `/update-chezmoi`. Offer — don't silently do it.

## Stage 4 — Suggest ClickUp closes (read-only)

If the ClickUp tools (`mcp__clickup__clickup_*`) are connected, look at the tasks
that today's work touched and say which look **ready to close or advance** — with
the reason ("D1 verified in the log → its task looks done"). **Suggest only; make
no changes.** Same connection guard as `/start-work`: if the MCP isn't connected,
say so plainly rather than skipping silently, and continue from the log alone.

## Stage 5 — Seed tomorrow

Finish by writing the handoff into today's worklog so `/start-work` Stage 0 reads
it clean tomorrow:
- Move unfinished `Plan` items and blockers into `Notes / carried over`.
- Add a short **`## For tomorrow`** section — the first thread or two to pick up,
  with a one-line why. This is what stops tomorrow from re-deriving where things
  stood.

Then confirm what you wrote and where. Keep the whole thing tight — a bookend,
not a report.

## Notes

- One close-out per run, for today.
- Never edit ClickUp; never touch another day's log.
- Degrade gracefully: no ClickUp → work from the log; thin log → reconstruct from
  the session and still seed tomorrow.
