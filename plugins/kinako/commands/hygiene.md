---
description: Show which Claude Code session files Kinako's own bound sessions have left behind.
argument-hint: [--confirm <handle>]
allowed-tools: Bash
---

!`if [ -z "${KINAKO_CLI:-}" ] || [ -z "${KINAKO_APP_DATA:-}" ]; then printf '%s\n' "Kinako is not wired into this Claude Code session, so nothing was listed and nothing was touched. Your Claude Code store was not read." "" "Two environment variables have to be set before any Kinako command can run:" "" "  KINAKO_CLI       the full path to the kinako binary inside the installed Kinako app" "  KINAKO_APP_DATA  the full path to Kinako's application-support folder" "" "Set both in the env block of your Claude Code settings, start a new session, and run this again."; else "$KINAKO_CLI" "$KINAKO_APP_DATA" hygiene "$CLAUDE_CODE_SESSION_ID" "$ARGUMENTS"; fi || true`

**Show the leader exactly what that printed, verbatim.** Do not summarise it, reorder it, add to
it or leave anything out, and do not run any further command — whatever it says has already
happened or has already been refused.

If it said Kinako is not wired into this session, that is the whole answer: **nothing was listed,
nothing was deleted and the store was not read.** Name the two variables exactly as printed and
stop there — do not look for the binary, do not guess a path for either variable, and do not run
anything else.

If it listed session files, **nothing has been deleted**. The line beginning
`/kinako:hygiene --confirm` is the only thing that deletes anything, and running it is the
leader's own act — do not run it for them and do not offer to.

If it printed a refusal, name that one condition and no other, exactly as it was printed.

<!--
**One `!` block, and that is the whole design** — `bind.md`'s finding holds here identically.
Every `!` block in a Claude Code slash command runs at EXPANSION time: before the model runs,
before the leader has read anything, and unconditionally. A single interactive confirmation is
therefore not buildable on this transport, which is why the verb takes two invocations and a
confirmation handle rather than a prompt (`harness-store.md` § The command surface, `D-003`).

`$ARGUMENTS` rather than `$1`: positional arguments are ZERO-indexed on 2.1.258, contradicting the
documented `$1` form, so the CLI takes one quoted string and splits `--confirm <handle>` off it
itself — `bind`'s own `--acknowledge` precedent (`BD-025`, `cli.rs:473`).

`$CLAUDE_CODE_SESSION_ID` is the variable the harness exports; `$CLAUDE_SESSION_ID` is unset
(`BD-027`). It is passed FIRST and is load-bearing: the CLI excludes the invoking session from the
matched set, and refuses by name when it is empty, because a verb that cannot say which session it
runs from cannot spare that session's own file (`harness-store.md` § Refusal shapes, Ruling F/H1).

`|| true` is load-bearing: the harness aborts a command at the first `!` block that exits
non-zero, with no assistant turn at all, so a refusal exiting 2 would take the report down with
it. The block always succeeds; the CLI's own exit code stays meaningful for everything else.

**The unset-variable guard is the hooks' own, and the refusal beside it is this file's** (blind
gap-finding `GF-003`). Without it, `"$KINAKO_CLI"` expands to the empty string and the leader is
shown the shell's own diagnostic — `(eval):1: permission denied:` — which names no condition and
offers no remedy, and which GI-006 forbids reaching the user. This is the state of a **fresh
install**: `product/quickstart.md` says nothing sets these two for the leader.

**Composed here rather than by the CLI, and only because it has to be.** Every other sentence this
command prints is the CLI's (`plugin-bridge.md` ruling `R-3`), but the one condition the CLI cannot
compose for is the one where the CLI cannot be found. The hooks take the silent-exit-0 arm instead
(`quickstart.md`: *"silence, not an error; that is deliberate"*) because they fire unbidden on
every turn — a command the leader typed is owed an answer, which is why the two surfaces differ
here rather than by oversight. Plugin-side terminal prose, outside `prose.md` (`AX-027`).

The CLI composes every sentence this command prints and this file relays it verbatim — the same
division `bind.md` holds. This is plugin-side terminal prose, outside `prose.md`'s enforcement
(`AX-027`), so no lint reaches it; stated so the absence of coverage is not read as an oversight.
-->
