#!/bin/sh
# Kinako — the prompt half of a turn, from the harness's `UserPromptSubmit` event.
#
# `UserPromptSubmit` carries the leader's prompt in its documented `prompt` field. A turn is a
# pair, and its other half arrives on `Stop`; this records the first half so `capture-turn.sh` can
# complete it. Nothing is published here and an unbound session records nothing at all.
#
# **The event goes straight to the CLI, unread and unmapped.** This hook fires on every turn of
# every session in a project where the plugin is registered — bound or not — so what it costs is
# paid by ordinary coding, which `FR-003` forbids as squarely as it forbids capture. Spawning an
# interpreter here to rename two fields cost ~29ms of the hook's ~33ms, measured n=30 at C1-3
# attempt 1 (`F5`). `serde_json` is already the CLI's wire type; it parses the harness's own
# payload and exits on the bound-session lookup when the session is unbound.
#
# Silent and successful when Kinako is not configured, and on every failure path: a capture
# problem must never break the leader's sparring session (FR-018). That is why the CLI's exit code
# is discarded rather than propagated.

set -u

[ -n "${KINAKO_CLI:-}" ] || exit 0
[ -n "${KINAKO_APP_DATA:-}" ] || exit 0

"$KINAKO_CLI" "$KINAKO_APP_DATA" prompt >/dev/null 2>&1

exit 0
