---
name: recap
description: Use when Charlie asks to "recap", "save this", "add this to my knowledge base", or wants to capture what a long explanation session taught into his ~/knowledge markdown vault (Obsidian). Turns an explanation into a linked concept note.
user-invocable: true
---

# recap — Capture an explanation into the knowledge vault

Charlie keeps a personal knowledge base at `~/knowledge/` — plain markdown, one
file per concept, cross-linked with `[[wikilinks]]`, browsable in Obsidian. Notes
carry area **tags** in YAML frontmatter and are indexed by **area map** hubs
(`linux-map.md`, `networking-map.md`, `programming-map.md`, `security-map.md`,
`ai-map.md`, `homelab-map.md`, `qa-map.md`, `hardware-map.md`, `tools-map.md`);
`home.md` links only the maps. This skill turns a just-finished explanation into a
note that lands in the right place.

## Core principle

**One concept = one file, and everything else links to it.** Never re-explain a
concept that already has a note; link to it with `[[note-name]]` instead. This is
what keeps overlap (Docker showing up under homelab *and* dev) from creating
duplicate, drifting copies.

## Steps

1. **Look at what's already there.** List `~/knowledge/*.md` and read the relevant
   `*-map.md` hub(s) so you know which concepts already exist and what to link to.
2. **Decide: new note or add to existing?**
   - If the session was about a concept that already has a file → extend that file.
   - If it's a genuinely new concept → new file, kebab-case name (`docker.md`,
     `dns-basics.md`). Name it by the concept, not the session.
   - If the session spanned several concepts, it's fine to write more than one
     note and link them.
3. **Write the note** (see format below) — including the frontmatter tags.
4. **Wire up links.** Add `[[new-note]]` references from related existing notes
   where it genuinely helps, and link *out* from the new note to concepts it
   depends on (even if those notes don't exist yet — a dangling `[[link]]` is a
   fine to-do marker).
5. **File it in the area map(s).** Add a `- [[new-note]] — one-liner` bullet to each
   `*-map.md` whose area the note belongs to (a note can appear on more than one —
   match the frontmatter tags). Only touch `home.md` if you're introducing a whole
   new area (new tag + new `*-map.md` hub, then link it from `home.md`).
6. **Report** the file path(s) written and the links/maps updated. Don't make Charlie
   approve a draft first — write it, then tell him. He edits after if needed.

## Note format

- **Filename:** kebab-case, `.md`, named after the concept.
- **Frontmatter tags first:** a YAML block with the note's area tag(s), e.g.
  ```
  ---
  tags:
    - linux
    - networking
  ---
  ```
  Use the existing area tags (`programming`, `linux`, `networking`, `security`,
  `ai`, `homelab`, `qa`, `hardware`, `tools`); multi-tag when it genuinely spans
  areas. These drive the graph color-groups and the maps.
- **Then `# note-name`** (matches the filename so wikilinks are obvious).
- **Then a one/two-sentence orient:** what this is and, if it came from a real
  problem, what problem. Big-picture before details — that's how Charlie learns.
- **Then the mechanics**, in the order you'd actually hit them.
- **Name unfamiliar terms** the first time they appear.
- **Keep a concrete section** for what actually happened this session (the real
  command, the real error, the real fix) — not just the abstract concept.
- **End with a `## Related` section** listing `[[links]]` to connected notes.

## Voice

Write like Charlie talks, not like a textbook or wiki. Plain, direct, first-person
where it fits ("what bit me was..."). No AI-flavored polish, no "In this article
we will explore." If it reads like a template, rewrite it. Match the style of the
existing notes in the vault.

## Don't

- Don't create folders — the vault is flat; links do the organizing.
- Don't duplicate an explanation that already has a note — link instead.
- Don't touch Obsidian's `.obsidian/` folder if it exists.
