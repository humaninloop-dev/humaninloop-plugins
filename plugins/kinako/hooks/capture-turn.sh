#!/bin/sh
# Kinako — one completed turn of a BOUND session, handed to the `kinako` CLI.
#
# Registered on the harness's `Stop` event, which fires when the assistant has finished
# responding — the turn-completion boundary.
#
# `FR-012` / `TR-011`: every field comes from a DOCUMENTED hook input.
#   session_id             — on every hook event
#   last_assistant_message — added to `Stop` and `SubagentStop` by the harness expressly "so
#                            hooks can access it without parsing transcript files"
# The leader's prompt is the documented `prompt` field on `UserPromptSubmit`, recorded by
# `record-prompt.sh`. **No transcript file is opened and `transcript_path` is not read** — the
# transcript's on-disk format is not a documented surface and nothing here depends on it.
#
# **The event goes straight to the CLI, unread and unmapped.** This hook fires on every turn of
# every session in a project where the plugin is registered — bound or not — so what it costs is
# paid by ordinary coding, which `FR-003` forbids as squarely as it forbids capture. Spawning an
# interpreter here to rename two fields cost ~29ms of the hook's ~33ms, measured n=30 at C1-3
# attempt 1 (`F5`). The CLI reads the harness's own payload and its bound-session lookup is the
# first thing it does with it.
#
# A harness too old to send `last_assistant_message` sends no field, and capture stops rather than
# guessing from another source; that degradation is the `harness-below-minimum` capture-health
# condition (FR-018), whose readout is C1-5's.
#
# It never writes the corpus and never writes the leader's harness store. It exits 0 on every
# path: a capture failure must never break the leader's sparring session.

set -u

[ -n "${KINAKO_CLI:-}" ] || exit 0
[ -n "${KINAKO_APP_DATA:-}" ] || exit 0

"$KINAKO_CLI" "$KINAKO_APP_DATA" capture >/dev/null 2>&1

exit 0
