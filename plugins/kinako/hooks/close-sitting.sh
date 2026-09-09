#!/bin/sh
# Kinako — a BOUND session ending, handed to the `kinako` CLI.
#
# Registered on the harness's `SessionEnd` event, which fires when a session finishes — the
# sitting-completion boundary.
#
# `FR-012` / `TR-011`: every field comes from a DOCUMENTED hook input.
#   session_id — on every hook event
# **No transcript file is opened and `transcript_path` is not read** — the transcript's on-disk
# format is not a documented surface and nothing here depends on it.
#
# **The event goes straight to the CLI, unread and unmapped** — `capture-turn.sh`'s own reasoning
# (`F5`): this hook fires for every session in a project where the plugin is registered, bound or
# not, so what it costs is paid by ordinary coding, which `FR-003` forbids as squarely as capture.
# The CLI's bound-session lookup is the first thing it does with the payload.
#
# **This is the fast path, not the guarantee** (`FR-021`, `NFR-001`, `D-022`). A session killed
# outright, or a machine put to sleep, emits no `SessionEnd` at all — so a sitting also ends on the
# settled quiet interval, and nothing the leader gets depends on this hook firing. It only makes
# their atoms arrive sooner.
#
# **The verb's frame is emitted, not discarded** (`SCR-037`, ruling `R-1`; C2-2 live-run finding
# `F16`). This hook used to end `>/dev/null 2>&1`, so the sitting-end frame the CLI composes had no
# way to reach the leader whatever it said — the contracted screen did not exist. The CLI composes
# it; this relays it and decides nothing, exactly as `bind`'s one `!` block does.
#
# **On both streams, because which one a `SessionEnd` hook surfaces is the harness's business.**
# Claude Code renders a hook's stdout and stderr differently per event and per mode, and this
# product cannot assert what it does; emitting on both is what keeps the frame reachable wherever
# it is rendered, and costs a duplicate line where both are shown.
#
# **Nothing at all for an unbound session** (`FR-003`). This hook fires for every session in a
# project where the plugin is registered. The verb answers `unbound` for a session nobody bound,
# and printing that on every ordinary coding session is noise the leader never asked for — so the
# inert token is filtered here rather than printed. The coupling to that one word is pinned by
# `tests/plugin_hook.rs`, which fails if the verb's inert answer ever changes.
#
# It never writes the corpus and never writes the leader's harness store. It exits 0 on every
# path: a sitting-end failure must never break the leader's sparring session.

set -u

[ -n "${KINAKO_CLI:-}" ] || exit 0
[ -n "${KINAKO_APP_DATA:-}" ] || exit 0

FRAME=$("$KINAKO_CLI" "$KINAKO_APP_DATA" close 2>/dev/null) || FRAME=""

case "$FRAME" in
  "" | unbound) ;;
  *)
    printf '%s\n' "$FRAME"
    printf '%s\n' "$FRAME" >&2
    ;;
esac

exit 0
