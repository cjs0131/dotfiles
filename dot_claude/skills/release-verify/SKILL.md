---
name: release-verify
description: Pull a release's ClickUp task(s) and turn them into a QA verification checklist framed for a newcomer. Use when the user asks to verify a release, check what needs manual testing, or wants release notes explained.
user-invocable: true
---

# /release-verify — Release Verification Checklist

Arguments passed: `$ARGUMENTS` (a ClickUp task ID, list name, or release name — ask if empty)

## Steps

1. Look up the release in ClickUp:
   - Use `clickup_search` or `clickup_filter_tasks` to find the task(s) for
     the named release. If `$ARGUMENTS` is a task ID, use `clickup_get_task`
     directly.
   - Pull the description, status, and any linked/sub tasks — these usually
     contain the actual list of changes.
2. For each change/item in the release, work out:
   - **What changed** (plain description, no jargon).
   - **How it's verified** — does an automated test already cover this?
     Check the repo's test directories for related coverage before assuming
     there's a gap.
   - **What needs manual testing** — anything without automated coverage,
     or anything UI/visual that automated tests wouldn't catch.
3. Produce a checklist, ordered by risk (things most likely to break
   production first), with one line per item:
   `- [ ] <change> — <how to verify> (automated | manual)`
4. Call out anything ambiguous or where the ClickUp description doesn't say
   enough to verify confidently — ask the user or flag it as a gap, don't
   guess a verification method.

## Framing

Apply the `explain-for-newcomer` skill's style: give one or two sentences of
big-picture context (why this release/change matters, what area of the app
it touches) before the checklist, not just a bare list.
