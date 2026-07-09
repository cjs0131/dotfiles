---
name: medical-fill
description: Use when Charlie names a medical topic to write up or expand in his vault — "write up the pharmacology of X", "flesh out the [EKG rhythm] note", "research and draft [medical concept]", "fill in this stub", or points at a thin/skeleton medical note. Researches the topic and drafts a real, substantive note in his vault, not a skeleton.
user-invocable: true
---

# medical-fill — research and draft a medical vault note

Charlie is a paramedic building out the medical side of his `~/knowledge/` vault
(EKG, pharmacology, emergency & wilderness). He names a topic; you **research it
and write a genuinely fleshed-out note** in his vault's voice and format, filed
into the right area map.

## The core rule: draft real content, not a skeleton

**Charlie's explicit preference: do the research and write the actual note — do
not hand back a skeleton for him to fill in.** A note that's a table of headings
with everything marked "(verify)" has failed. Explain the real mechanism, the
real recognition logic, the real field relevance, grounded in sources.

`TODO(verify):` is for the **handful of specifics you genuinely can't pin down**
— an exact dose, a precise threshold, a protocol number that varies by service —
not a substitute for doing the work. If half the note is verify-markers, you
skipped the research. Reserve them; don't lean on them.

**Safety is why the research matters, not a reason to hedge everything:** this is
clinical content. Ground claims in real sources (research below), never invent
doses or numbers from memory, keep the draft-warning callout, and leave Charlie —
the actual clinician — as the final check. Thoroughness and the safety callout do
the safety work; empty skeletons don't.

## Steps

1. **Research first.** Use WebSearch/WebFetch against the references Charlie's
   vault already leans on: **DMEMSMD** (Denver Metro EMS Medical Directors
   prehospital protocols), **WMS** (wilderness), **AHA/ACLS**, **PHTLS**, plus
   LITFL and ECG workshops for rhythm notes. Pull the real mechanism, recognition
   criteria, and field management. Prefer 2+ sources for anything clinical.
   **Dosing is special:** Charlie's signed drug book is the real authority and you
   can't see it — put `TODO(verify):` on any protocol-specific dose rather than
   asserting one. Any other specific you can't confirm gets a `TODO(verify):` too;
   the rest of the note still gets written.
2. **Check the vault first** (like `/recap`): list `~/knowledge/*.md` and read the
   relevant medical map (`ekg-map.md`, `pharmacology-map.md`,
   `emergency-and-wilderness-map.md`). New note or extend an existing/stub one?
   One concept = one file; link to neighbors, don't duplicate them.
3. **Write the note** in the format below — fully drafted.
4. **Wire up links** — `[[wikilinks]]` out to concepts it depends on (dangling
   links are fine as to-do markers), and into it from clearly related notes.
5. **File it in the area map** — add a `- [[note]] — one-liner` bullet to the
   matching `*-map.md`. Multi-file if it genuinely spans areas (match tags).
6. **Report** what you wrote, the sources used, and any `TODO(verify)` lines you
   left so Charlie knows exactly what to check. Don't gate on approval — write it,
   then tell him; he corrects the clinical detail after.

## Note format (match the existing medical notes)

- **Filename:** kebab-case `.md`, named for the concept.
- **Frontmatter tags:** `medical` plus the sub-area (`ekg`, `pharmacology`,
  `emergency`, `wilderness` — match the target map's tag).
- **`# note-name`** matching the filename.
- **The draft-safety callout, always:**
  `> [!warning] Draft — verify before trusting. Structure/research from standard references ([name them]); Charlie corrects the clinical detail.`
- **Orient** — one or two sentences: what this is and why it matters, big-picture
  before mechanism (how Charlie learns).
- **Mechanism / recognition logic** — the real content, in the order you'd
  actually reason through it. Tables are good for comparisons (block types, drug
  classes) — but filled in, not blank.
- **Why it matters in the field** — the paramedic-relevant payoff: what changes
  management, what's dangerous, what the protocol hooks are.
- **`## Related`** — `[[links]]` to connected notes and the area `[[*-map]]` hub.
- **Sources line** at the end — name the references you actually used.

## Voice

Write like Charlie talks — plain, direct, a clinician's shorthand, not a textbook
or a wiki intro. No "In this article we will explore." Match the existing medical
notes (`av-blocks.md`, the map hubs). Name unfamiliar terms the first time, but
don't over-explain what a paramedic already owns.

## Don't

- Don't hand back a skeleton or a note that's mostly `(verify)` — that's the one
  failure this skill exists to prevent.
- Don't invent doses, thresholds, or numbers from memory — research or mark them.
- Don't drop the draft-safety callout, even on a well-sourced note.
- Don't create folders (flat vault); don't touch `.obsidian/`.
