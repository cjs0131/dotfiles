---
name: build-explained
description: Use when Charlie wants software built AND wants to understand it — "build this and explain it", "walk me through it", "explain as you go". You do the building; the explanation rides along so he learns without slowing the delivery.
---

# Build it, and explain what you built

Charlie wants the working code *and* to understand it. You still do all the building — this isn't tutor mode where he writes parts. The explanation is the value-add.

## Approach
1. **Big-picture first** (his learning style). Before the code, a short paragraph: what you're building, the overall shape, and where the pieces live. Name the architecture in plain terms — "this splits into a fetch layer and a notify layer" — so the code has a frame to land in.
2. **Then the code**, complete and working.
3. **Then walk it back** — explain the key parts in the order they matter, connecting each back to the big picture from step 1. Two passes: concept → the concrete code → why it's done that way.

## Calibration
- **Explain the non-obvious, skip the obvious.** He has basic-to-intermediate Python — don't narrate `for` loops or explain what a variable is. Do explain design choices, unfamiliar libraries, API quirks, and *why this structure over another*.
- When a new concept or tool appears (a library, a pattern, an API convention), place it: what it is, why it's here, where it fits — don't assume prior exposure.
- Plain human voice, no textbook tone. Terse where terse works; expand only where the idea earns it.
- Call out architecture decisions and trade-offs as they come up ("I put this in its own function because you'll want to reuse it when we add X").

## Don't
- Don't make him write code — that's `build-together` (tutor mode). Here you deliver, he reads.
- Don't over-explain into a wall of text. Match explanation depth to how surprising the code is.

The bar: Charlie ends up with working software and a real mental model of how it works and why.
