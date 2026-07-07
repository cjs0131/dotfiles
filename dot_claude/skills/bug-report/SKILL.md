---
name: bug-report
description: Use when Charlie needs to write up a bug found during QA — filing to ClickUp/Bugs, or drafting a bug report for the Homeplated app. Produces a report in Charlie's calibrated human voice, not AI-template QA-textbook prose.
---

# Writing a bug report (Charlie's style)

A bug report exists to let someone else **reproduce and fix** the problem with zero back-and-forth. Nothing more. Match the report's weight to the bug's weight — a small bug gets a few lines, not a form.

## Before writing: is this even a bug to file?

**File** if it's a clear violation of feature intent (validation gap, broken save, data inconsistency) and you're **70%+ confident** it's real.

**Don't file yet** (jot it down, ask David instead) if it's:
- "I think this could be better" → that's design feedback, not a bug
- "I'm confused how this works" → clarify first
- Under 70% confidence

## The four things every report needs

1. **What's broken** — one-line title
2. **How to reproduce** — numbered steps
3. **Expected vs Actual** — what should happen vs what does
4. **Where** — environment URL, browser/OS, and **which account** ("logged in as…" — David asks for this)

## Title format

Describe the **system misbehaviour, not the user's path**:

> `[Where] [what's wrong] [under what conditions, if relevant]`

Good (real examples Charlie has written):
- "Dish listing drafts don't retain spiciness rating"
- "Price/portions wheel pickers get stuck past the last value, end-of-list messages don't show"
- "'Other' option on meal origin has no follow-up input field"

Bad: "I tried to save a draft and it broke" (user path, vague).

## Voice — human, not template

This is the part that matters most to Charlie. **Do not** write QA-textbook prose.

- **First person, conversational.** "When I hit save, the spiciness rating resets." Not "Upon clicking the Save button, the spiciness rating field is not persisted."
- **"Hit save," not "Click the Save button."**
- **Terse.** Fragments over full sentences. No preamble, no throat-clearing. Read like clinical notes.
- **No padding** with QA jargon Charlie wouldn't naturally say.
- Match length to the bug. A validation gap is two lines; a subtle state bug earns more repro detail.

## Template (trim ruthlessly to fit the bug)

```
**Title:** [Where] [what's wrong]

Logged in as: qa-…@cjs-demo.com  ·  app.dev.homeplated.com  ·  Chrome/Firefox

Steps:
1.
2.
3.

Expected: …
Actual: …
```

For a tiny bug, collapse it — a title + one line of "when I do X, Y happens instead of Z" is a complete report.

## After drafting

If Charlie asks whether it reads too polished, offer to plain-en it — cut jargon, shorten, make it first-person. When in doubt, cut.

Related test accounts: `*@cjs-demo.com` catchall (see project memory). Bugs currently go to ClickUp — confirm with David whether there's a separate Bugs space vs a list in Product features.
