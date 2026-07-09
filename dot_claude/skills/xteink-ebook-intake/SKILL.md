---
name: xteink-ebook-intake
description: Use when Charlie has downloaded new books (loose epubs, a zip/folder of them, or Calibre-exported book folders) and wants them cleaned up and filed into his xteink X4 library. Triggers include "process my new books", "add these ebooks", "organize my downloads for the reader", "file these into the X4 folder".
---

# xteink X4 Ebook Intake

## Overview
Charlie's X4 e-reader library lives at `~/xteink-x4/`. New books arrive messy — loose files, zips, or Calibre folder trees with junk sidecars — and need to land as cleanly-named epubs in the right category. This skill is the repeatable intake routine.

**Core rules:**
- **epub only.** The X4 does not read PDF. Never copy `.pdf` into the library.
- **Copy, never move.** Leave the originals in `~/Downloads` untouched.
- **Covers are embedded in the epub** — ignore loose `.jpg`/`.opf` sidecars; the reader pulls the cover from inside the file.

## Library layout
```
~/xteink-x4/
├── Books/
│   ├── Fiction/
│   ├── Nonfiction/
│   └── Programming-Tech/
└── Wallpapers/
```
Books go in one of the three category folders. If a book fits none, ask Charlie rather than inventing a new category.

## Steps

1. **Locate the source.** Check `~/Downloads` for new epubs and for a recent `.zip`. If it's a zip, extract to a temp dir first: `unzip -qq "<file>" -d /tmp/ebook-intake`.

2. **Find every epub, ignore everything else.**
   ```bash
   find /tmp/ebook-intake ~/Downloads -maxdepth 4 -iname '*.epub'
   ```
   Skip `.pdf`, `.opf`, `.jpg` — those are junk for the X4.

3. **Decide the clean name** for each: `Title - Author.epub`
   - Move leading articles to the front: `Giver, The` → `The Giver`.
   - Strip subtitles after a colon/underscore: `Nexus_ A Brief History…` → `Nexus`.
   - Strip symbols, z-library tags, `(z-lib.sk …)`, edition cruft you don't want.
   - **Fix junk authors** — Calibre exports often carry the uploader's handle or `Unknown`. Correct to the real author (e.g. `Ben` → `Neal Stephenson`, `Yanrubin` → `Brian Ward`, `Unknown` → `Al Sweigart`). If unsure who the real author is, look it up rather than guessing.
   - Drop translators from the author field (keep just the author).

4. **Pick the category** — Fiction / Nonfiction / Programming-Tech. Use judgment; when genuinely ambiguous, ask.

5. **Skip if already filed.** The originals stay in `~/Downloads`, so a plain search re-finds books already in the library. Before copying, check whether that `Title - Author.epub` already exists anywhere under `~/xteink-x4/Books/`; if it does, skip it and note it as already-present. Match on the cleaned name, not the messy source filename.

6. **Copy in** with the clean name:
   ```bash
   cp "<source>.epub" ~/xteink-x4/Books/<Category>/"<Title - Author>.epub"
   ```

7. **Tidy up:** remove any empty category folders, delete the temp dir, and report to Charlie what landed where — plus anything skipped (PDF-only books, duplicates) and any author/title you had to correct or guess.

## Common mistakes
- **Copying the PDF twin.** Zips often ship epub + pdf of the same book. Take only the epub.
- **Treating loose `.jpg` as the cover to move.** It isn't — the cover is already inside the epub. Leave sidecars behind.
- **Trusting the Calibre author field.** It's frequently an uploader handle or `Unknown`. Verify.
- **Moving instead of copying.** Originals stay in Downloads.
- **Inventing categories.** Only three exist; ask before adding a fourth.
