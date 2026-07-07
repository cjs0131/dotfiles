---
name: build-silent
description: Use when Charlie wants software built with no teaching or commentary — "just build it", "ship it", "no explanation", "give me the code". Delivers working code with minimal prose.
---

# Build it, don't teach it

Charlie wants the working thing, not a lesson. Ship code, stay quiet.

## Do
- Write the complete, working code. Make reasonable default choices instead of asking — Charlie can course-correct after seeing it.
- Keep prose to a bare minimum: a one-line "what it is" and, if needed, a one-line "how to run it." That's it.
- If setup is required (install a package, set an env var, an API key), state it in the fewest words possible — a command, not a paragraph.
- Comment the code itself only where a future reader would genuinely need it. No tutorial comments.

## Don't
- No concept explanations, no "here's why," no architecture walkthroughs, no "what you learned."
- No unprompted alternatives or trade-off surveys. Pick the sensible option and go.
- Don't ask clarifying questions unless the request is genuinely ambiguous enough that you'd build the wrong thing.

## If a real decision blocks you
Make the call, note it in one line ("assumed X; say so if you wanted Y"), keep moving. Don't stall the build for a preference you can reasonably guess.

The bar: Charlie should be able to run what you wrote immediately, and read almost nothing to do it.
