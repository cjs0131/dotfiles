---
name: xteink-getbook
description: Use when Charlie names a book he wants on his xteink X4 in chat — "get me Blindsight", "grab the Egan book", "put Recursion on my reader", or when recommending books and offering to fetch them. Wraps the getbook CLI.
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

Never download `.pdf`. Respect the three categories; if classification looks
wrong, offer to move it with `--cat`.
