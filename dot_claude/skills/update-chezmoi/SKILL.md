---
name: update-chezmoi
description: Use when Charlie wants to sync, save, back up, commit, or push his dotfiles — "update chezmoi", "sync my dotfiles", "commit my config", "push my dotfiles", "save my Hyprland/fish/etc changes". Runs git in the chezmoi source repo to keep the dotfiles remote up to date.
user-invocable: true
---

# /update-chezmoi — sync the dotfiles repo

Charlie manages his dotfiles with **chezmoi**. This skill captures any config
changes and pushes them to his dotfiles remote so nothing drifts or gets lost.

**Quick orientation (chezmoi has two locations):**
- The **live files** in his home dir — `~/.config/hypr/...`, `~/.config/fish/...`,
  etc. These are what actually run.
- The **source repo** at `~/.local/share/chezmoi` — a git repo (remote:
  `git@github.com:cjs0131/dotfiles.git`, branch `master`) holding chezmoi's
  managed copy of those files. This is what gets committed and pushed.

Edits made to the live files don't reach the source until you tell chezmoi to
pick them up. So syncing is two moves: **capture drift into the source, then git
push the source.** Missing the capture step pushes a stale copy.

Interactively Charlie would `chezmoi cd` into the source and run git there. From
here, run git against the source without changing shells:
`chezmoi git -- <args>` (runs the arg in the source repo).

## Steps

1. **Pull remote first** so a push can't be rejected and to avoid clobbering
   anything committed from another machine:
   `chezmoi git -- pull --rebase`
   If it can't fast-forward or hits a conflict, stop and show Charlie — don't
   force anything.

2. **Check for drift** between live files and the source:
   `chezmoi status`
   Each line has a two-letter code; the **second column** is what matters for
   syncing — it compares the live file in `~` against the source:
   - `M` in the second column = a managed file changed in `~` and the source is
     behind (needs re-add).
   - `A`/`D` = would be added/removed.
   A clean run (no output) means the source already matches the live files.
   If there's drift, show it and confirm before pulling it in with
   `chezmoi re-add` (updates the source from the live files — it does **not**
   touch `~`). If `chezmoi status` is clean, the source already matches; skip to
   step 3.

3. **Review what will be committed** in the source repo:
   `chezmoi git -- status` and `chezmoi git -- diff`
   Summarize the changes for Charlie in plain terms (which configs, what
   changed) — don't just dump the diff.

4. **Stage, commit, push:**
   `chezmoi git -- add -A`
   `chezmoi git -- commit -m "<message>"`
   `chezmoi git -- push`
   - Write a plain, specific message about what config changed
     (e.g. `hypr: bind super+c to screenshot region`), not "update dotfiles".
   - The message reads as Charlie's own — **no `Co-Authored-By` line, no Claude
     attribution.**
   - Nothing to commit? Say so and stop — don't invent an empty commit.

## Notes

- This is a separate repo from whatever project session you're in — commit here
  with plain `chezmoi git`, not the workspace commit tool.
- Never `push --force` or hard-reset the dotfiles repo without asking; another
  machine may have pushed since.
- If Charlie added a *brand-new* file that chezmoi doesn't manage yet, that's
  `chezmoi add <path>` (not `re-add`), then commit as above.
- Deeper reference lives in his vault: `~/knowledge/dotfiles-and-chezmoi.md`.
