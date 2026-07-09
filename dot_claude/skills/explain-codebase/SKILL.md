---
name: explain-codebase
description: Use when Charlie points at a codebase (a repo, a folder, "explain this project", "how does this code work", "walk me through this codebase", "I inherited this, help me understand it") and wants to understand how it works — starting from the high-level module map before any deep dive.
---

# Explain a codebase, top-down

Charlie hands you a codebase and wants a real mental model of it — not a file-by-file tour. Match his learning style: **big picture first, then detail on request.** The whole point is the two phases stay separate. Do not drill into function internals in Phase 1.

Target: point it at the working directory by default, or at a path/repo Charlie names as an argument.

## Phase 1 — The map (always do this first, then STOP)

Goal: a short orientation Charlie can hold in his head, plus a module map. Recon, don't read everything.

**Recon (cheap, strategic — not exhaustive):**
- Read the README, and manifests that name the stack and entry points (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.).
- Look at the top-level directory layout and the entry point(s) — where execution starts.
- For anything large, dispatch the **Explore** agent to map structure so you don't burn context reading every file. You need responsibilities and boundaries, not line-by-line detail.

Phase 1 is meant to be **in-depth, not a teaser** — a few solid paragraphs plus the map, enough that Charlie could explain the project's shape to someone else afterward. "High-level" means you stay above individual function bodies, *not* that you keep it short. Deliver, in this order:

1. **Orient — a real explanation, not one line.** What this project *is*, what problem it solves, and who/what uses it. Name the kind of thing it is (CLI, API service, library, scraper, batch job) and the core stack. Then a paragraph on the **overall architecture** — the big organizing idea, the shape it takes ("layered fetch → transform → output," "event loop with plugins," "MVC web app"), and any load-bearing design decisions that explain why the rest looks the way it does.
2. **The module map — a few sentences each, not a one-liner.** For every major module/directory: what it's responsible for, what it owns vs. delegates, and the key types/entry points inside it (named, so Phase 2 has hooks — but *not* their internals). Group by responsibility, not alphabetically.
3. **How they interact — trace it end to end.** Walk the main flow(s) concretely: where execution starts, where data enters, what calls what in what order, where it exits. Cover the primary path in depth, then note significant secondary flows (error handling, background jobs, auth) more briefly. Include a **Mermaid diagram** when there are 3+ modules with real relationships (flowchart for data/control flow) — the diagram supports the prose, doesn't replace it.
4. **The seams worth knowing** — where the important boundaries are (what's pluggable, what's coupled), any cross-cutting concerns (config, logging, state), and 2–3 things that would surprise someone new to *this* codebase specifically.
5. **Name the unfamiliar** the first time it appears — a framework, a pattern, a convention — what it is and why it's here. Don't assume prior exposure to a given stack, but don't narrate the obvious either.

**Then stop.** However thorough Phase 1 is, it stays above function bodies — the depth is in breadth of coverage and the *why*, not in line-by-line reading. End by offering the drill-down and letting Charlie steer:
> "That's the shape of it. Want me to go deeper on any of these — [module A], [module B], the [specific flow] — or a particular function/class?"

Do not pre-emptively dump function-level detail. The stop is the skill.

## Phase 2 — The drill-down (only what Charlie asks for)

When he picks a target, go as deep as it earns:
- **Concept → concrete code → why it's built that way** (his two-pass style). Read the actual file now; quote the real functions/classes with `file_path:line` so he can click through.
- Explain the non-obvious: design choices, control flow, trade-offs, quirks. Skip narrating basic syntax — he has basic-to-intermediate Python.
- Tie every explanation back to where it sits in the Phase 1 map, so detail lands in the frame you already built.
- After each drill-down, offer the next thread rather than assuming. Let him keep steering depth.

## Voice
Plain and human, not a code-review template or a textbook. Terse where terse works; expand only where the idea earns it. Recalibrate as he shows familiarity — don't re-explain what he's already grasped.

## Don't
- Don't skip Phase 1 and start deep — even if the codebase is small, give the map first.
- Don't go file-by-file in reading order. Organize by responsibility and flow.
- Don't dump all detail at once "to be thorough." Depth is his call, one thread at a time.
- Don't read the entire tree into context when Explore or a targeted read answers the question.
