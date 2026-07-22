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

## Stage 5 — Purge Playwright artifacts (look before you nuke)

Manual walks and test runs leave disposable artifacts that pile up on disk — all
gitignored, so purely local cruft: `.playwright-mcp/` (page snapshots `.yml`,
console `.log`, screenshots), `test-results/`, `playwright-report/`. Clear them at
end of day, but **scan before deleting** — don't nuke blind.

1. **Sanity-scan `.playwright-mcp/` first.** List what's there and skim for
   anything that looks worth keeping before it's gone — a screenshot or snapshot
   tied to a bug not yet filed, an `error-context.md` from a failure not yet
   written up, evidence for an in-progress verify. If something looks helpful,
   surface it to Charlie (and offer to move it into `.playwright-mcp/evidence/`)
   **before** purging. This look-first step is the point of the stage.
2. **Spare `.playwright-mcp/evidence/`** — that's the intentional named-screenshot
   store; never delete it here.
3. **Then purge the rest**, from the repo root (`/home/charlie/work/hp-app-core-react`):
   ```bash
   find .playwright-mcp -mindepth 1 -maxdepth 1 ! -name evidence -exec rm -rf {} +
   rm -rf test-results playwright-report e2e/test-results e2e/playwright-report
   ```
   Gotcha: a Docker WebKit run leaves `test-results/` **root-owned** — if `rm`
   fails with permission denied, use `sudo rm -rf` (passwordless sudo is enabled).
4. Skip the stage cleanly if the dirs don't exist or Charlie isn't in the e2e repo.

## Stage 6 — Seed tomorrow

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
