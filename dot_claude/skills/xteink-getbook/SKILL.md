---
name: xteink-getbook
description: Use when Charlie names a book he wants on his xteink X4 in chat — "get me Blindsight", "grab the Egan book", "put Recursion on my reader", or when recommending books and offering to fetch them. Also covers when fast-download credits are out ("no credits", quota errors) via a Playwright slow-download path. Wraps the getbook CLI.
---

# xteink getbook (chat wrapper)

Charlie has a `getbook` CLI that searches Anna's Archive, downloads an epub,
files it into `~/xteink-x4/<Category>/`, and pushes it to the X4 over WiFi.

When he names a book (or accepts a recommendation):
1. Run `getbook "<title>" --author "<author>" --list` to get the top 3
   candidates (non-interactive — prints numbered matches with their md5,
   no download). Show them to Charlie inline and let him pick a number.
2. Once he picks, run `getbook "<title>" --author "<author>" --pick <N>`
   (same title/author, `--pick` set to his choice) to download, file it,
   and push it to the reader.
3. Report where it filed and whether the push succeeded.
4. If the reader was offline, tell him to run `getbook --sync` once it's awake.

Never download `.pdf`. Respect the existing category folders (subfolders of
`Fiction/` and `Nonfiction/`); if classification looks wrong, offer to move
it with `--cat`.

## No fast credits — Playwright slow path

Use when `getbook` fails with a credits/quota error, or Charlie says the fast
downloads are used up. Same rules apply (epub only, he picks the candidate);
only the download step changes. Honor every wait the site imposes — waitlists
and countdowns are the deal for free downloads, never try to skip them.

1. Still run `getbook "<title>" --author "<author>" --list` first — search
   costs no credits, and it prints each candidate's year/size/format/md5;
   the md5 is the page address. If Charlie named the exact book and one
   candidate is clearly right (right title/author/language, epub, sane
   size), pick it and say which; otherwise show the list and let him pick.
2. Playwright: navigate to `https://annas-archive.gl/md5/<md5>`.
   `annas-archive.org` may not resolve; `.gl` works (fallbacks: `.pk`, `.gd`).
3. Click a **Slow Partner Server** link (ignore the Fast section — those
   burn credits). Servers #1–4 are faster with a waitlist, #5+ are
   no-waitlist but slow; start at #1, try the next on failure. A
   **DDoS-Guard 403 page is normal, not a failure**: wait ~10s (it resolves
   in place — re-snapshot to confirm; reload if still 403). If the partner
   page shows a countdown, wait it out with `browser_wait_for`.
4. On the "Download from partner website" page, click **"Download with short
   filename"**. In-browser clicks carry the UA/referer the partner servers
   require (curl on these links gets blocked). The file lands in
   `~/.playwright-mcp/` automatically, named `annas-arch-<md5-prefix>.epub`.
5. Before filing, verify it: `file` says "EPUB document", size roughly matches
   the listing, and dc:title/dc:creator in the OPF look right. HTML content or
   garbage metadata → retry with another slow server or another candidate.
6. File it: `getbook --file <path> --cat "<Top/Sub>"`. **Always pass `--cat`
   on this path** — the classifier misfiles manual downloads into
   `Nonfiction/_Unsorted`. The two book trees are `~/xteink-x4/Fiction/` and
   `~/xteink-x4/Nonfiction/` — `ls` them and pick an existing subfolder
   (`Knowledge/` is notepress territory, never file books there).
   `--file` copies the epub and pushes to the reader itself; the
   `~/.playwright-mcp/` original can be deleted after.
7. Report where it filed and whether the push succeeded, same as the fast
   path (reader offline → `getbook --sync` later, as above).

Gotcha: `getbook --delete` (e.g. to fix a misfile) auto-runs `--backup`,
committing and pushing the whole library to git — mention it if that matters.
For multiple books, do them one at a time, waiting whatever each download
page asks.
