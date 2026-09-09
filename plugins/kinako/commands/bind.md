---
description: Bind this session to exactly one brainstorm, so its completed turns are captured.
argument-hint: <brainstorm name>  [--acknowledge <revision>]
allowed-tools: Bash
---

!`"$KINAKO_CLI" "$KINAKO_APP_DATA" bind "$CLAUDE_CODE_SESSION_ID" "$ARGUMENTS" "${ANTHROPIC_MODEL:-unknown}" "$(claude --version 2>/dev/null)" "${CLAUDE_PLUGIN_ROOT}/kinako-bridge.json" || true`

**Show the leader exactly what that printed, verbatim.** Do not summarise it, reorder it, add to
it or leave anything out, and do not run any further command — whatever it says has already
happened or has already been refused.

If it printed a line beginning `refused=`, that is the harness handshake declining
(**`FLOW-034`**); the line names exactly one of `harness-below-minimum`, `plugin-disabled` and
`bridge-capability-mismatch`, and the `harnessVersion=` / `minimumHarnessVersion=` / `missing=`
lines beside it are what the leader acts on. Name that one condition and **no other**.

If it asked the leader to run `/kinako:bind … --acknowledge …`, that line is the whole answer:
**this session is not bound**, nothing has been captured and no transcript exists. Do not run it
for them, do not offer to, and do not paraphrase the disclosure — running it is their
acknowledgement and it is theirs to give.

If it confirmed a binding, then for the rest of this session keep the conduct it describes:
**argue back rather than agreeing**, press on weak reasoning, and name the gaps and unstated
assumptions in what the leader puts to you. Do not display beliefs, stance marks, provenance or
corpus tallies — the terminal confirms; the leader reads beliefs in the app.

<!--
**One `!` block, and that is the whole design.** Every `!` block in a Claude Code slash command
runs at EXPANSION time: before the model runs, before the leader has read anything, and
unconditionally. A file that placed `acknowledge` and `bind` under prose the model was meant to
evaluate therefore fired both on every invocation — measured against Claude Code 2.1.258 at C1-3
attempt 1 (F2). `TR-016`'s "a first bind on an unacknowledged profile presents the disclosure and
does not proceed until acknowledged" is not implementable in that shape at all, so the CLI does
the whole walk and this file relays it. `BD-026`.

`$ARGUMENTS` rather than `$1` or `$0`: positional arguments are ZERO-indexed on 2.1.258, which
contradicts the documented `$1` form, and a command that depends on which one a harness version
implements breaks on an upgrade. The bind takes one name, so the whole argument string is the
argument — and the CLI splits a trailing `--acknowledge <revision>` off it. `BD-025`.

`$CLAUDE_CODE_SESSION_ID` is the variable the harness exports; `$CLAUDE_SESSION_ID` is unset and
handed the CLI an empty session id. Probed from inside a `!` block. `BD-027`.

`|| true` is load-bearing: the harness aborts a command at the first `!` block that exits
non-zero, with no assistant turn at all, so a refusal exiting 2 would take the disclosure down
with it. The block always succeeds; the CLI's own exit code stays meaningful for everything else.

This frontmatter carries no `model:` key and nothing in this file passes a model or effort-level
flag, because `FR-006` forbids Kinako setting either for a sparring session. The read of
`${ANTHROPIC_MODEL:-unknown}` READS the leader's model to stamp the turn under `FR-015`; reading
is not setting. The prohibition is checked structurally by the C1-3 gate, which greps this file
and `hooks/hooks.json`.

`FR-015` wants the model the session STARTED on. No hook input carries it: probed against Claude
Code 2.1.258, `SessionStart` sends only `session_id`, `source`, `cwd` and `transcript_path`, and
neither `UserPromptSubmit` nor `Stop` carries a model either. `ANTHROPIC_MODEL` is the documented
environment variable that pins the model, so it is the true answer whenever the leader has set
it; where they have not, the stamp is the literal `unknown` and that is a known gap, raised at the
C1-1 checkpoint rather than papered over. Reading the transcript to recover it is not available —
its format is not a documented surface (`FR-012`, `TR-011`).
-->
