---
name: explain-for-newcomer
description: Style guide for explaining QA/release/testing concepts to a newcomer — big picture before details. Use whenever explaining how a process, test, or release works, not just what code does.
user-invocable: false
---

# explain-for-newcomer — Explanation Style

Applies whenever explaining a QA workflow, release process, test setup, or
similar process concept (not plain code-reading questions — those should
stay direct per the code-explanation norm).

## Structure

1. **Orient first.** One or two sentences on where this fits in the bigger
   picture — what problem the process solves, or what would go wrong
   without it — before any specifics.
2. **Then explain the mechanics**, in the order someone would actually
   encounter them (not necessarily the order they're implemented).
3. **Name the unfamiliar terms** the first time they appear (e.g. "a
   fixture — a reusable setup step pytest runs before the test") rather than
   assuming prior QA/testing vocabulary.
4. **Keep it concrete** — tie explanations to this repo's actual files,
   tests, or ClickUp tasks rather than generic textbook description.

## What NOT to do

- Don't front-load an exhaustive list of edge cases or options before the
  reader has the basic shape of the thing.
- Don't skip straight to implementation detail on a first explanation of a
  process — that's the second pass, not the first.
- Don't over-explain concepts the user has already demonstrated familiarity
  with in the conversation; recalibrate as they show more context.
