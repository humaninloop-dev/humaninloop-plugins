# The Kinako plugin

Runs inside **your own Claude Code**. It binds a session to exactly one brainstorm and hands each
completed turn of a bound session to the `kinako` CLI, which publishes it to a Kinako-owned spool.
The Kinako app sweeps that spool into your corpus.

**Kinako never writes your harness store** (`FR-008`). It reads three things — installed, enabled,
version — and writes nothing. The one consented write exception (`FR-069`'s hygiene verb) is
deferred in this release.

**Nothing on this path leaves your machine.** Capture is local: hook → CLI → spool → core.

**Kinako does not set your model or your effort level** (`FR-006`). A bound sparring session runs
on exactly the settings you gave it; where the stakes warrant a stronger one, `/kinako:bind` may
say so as advice and leaves the setting to you. Kinako's conduct — arguing back, pressing on weak
reasoning, naming gaps — is **requested of your harness in the instructions the session carries,
not guaranteed by it** (`FR-004`, `FR-005`), and nothing here measures whether it fired.

## What it needs

Two absolute paths, set as environment variables where the hook can see them:

| Variable | What it points at |
|---|---|
| `KINAKO_CLI` | the `kinako` binary — inside the app bundle at release (`IP-009`); the workspace build during dogfood |
| `KINAKO_APP_DATA` | the app-data root, whose `spool/` directory the CLI writes and the core sweeps |

## Installing it — two forms

### A · Project-scoped (**the verification form**)

Registers the hook in **one project only**, so it fires nowhere else. This is the form the
`**TEST:**` gate uses, and it is the safe one when the harness you are testing in is the same
Claude Code you work in: an unbound session must stay inert (`FR-003`), and a project-scoped
registration means unrelated sessions never invoke the hook at all.

In the test project's `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/kinako/plugin/hooks/capture-turn.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/kinako/plugin/hooks/record-prompt.sh"
          }
        ]
      }
    ]
  },
  "env": {
    "KINAKO_CLI": "/absolute/path/to/kinako/target/debug/kinako",
    "KINAKO_APP_DATA": "/absolute/path/to/an/app-data-root"
  }
}
```

Bind from inside that project with the CLI directly — the same five arguments the command's own
`!` block passes:

```
"$KINAKO_CLI" "$KINAKO_APP_DATA" bind "$CLAUDE_CODE_SESSION_ID" "<brainstorm name>" \
  "<session-start model>" "$(claude --version)" "/absolute/path/to/kinako/plugin/kinako-bridge.json"
```

It runs the handshake, composes the disclosure and binds — the whole walk, in one call. On a first
bind it prints the disclosure and the exact line to run back, which is
`… bind "<session-id>" "<brainstorm name> --acknowledge <revision>" …`: the re-invocation carrying
the revision **is** the acknowledgement. No verb here reads standard input, so nothing hangs
waiting on a terminal.

### B · Marketplace (**the end-user form**)

Installs the plugin through Claude Code's own plugin mechanism, from the Kinako-owned marketplace
repository `humaninloop-dev/humaninloop-plugins` — the marketplace the engine-choice record's D9
rules, beside the Homebrew tap. This directory is the plugin's source of truth; the marketplace
repository carries a copy of it under `plugins/kinako/`, tagged per release.

```
claude plugin marketplace add humaninloop-dev/humaninloop-plugins
claude plugin install kinako@humaninloop-plugins
```

The default scope is `user`, which arms the hook in every session on the machine — the form an end
user wants. `--scope local` confines it to one project, in `.claude/settings.local.json`, which is
not committed. The bundled `hooks/hooks.json` registers all three events using
`${CLAUDE_PLUGIN_ROOT}`, so no absolute path to any script is needed in this form.

The two variables are still yours to set — under `env` in `~/.claude/settings.json`, or exported
in the shell that launches `claude`. The marketplace carries the hooks, not the paths.

**The install is a copy, not a link.** Claude Code copies the plugin into
`~/.claude/plugins/cache/humaninloop-plugins/kinako/<version>/` and records the commit it copied.
A newer release reaches an installed plugin only after `claude plugin update kinako@humaninloop-plugins`.
While iterating on this directory itself, `claude --plugin-dir plugin` loads the working tree
directly and needs no marketplace at all.

`/kinako:bind <brainstorm name>` is then available in any session the scope covers.

## What `/kinako:bind` does, and why it is one command

The command carries **one** `!` block and nothing the model decides. Every `!` block in a Claude
Code slash command runs at *expansion* time — before the model runs, before you have read
anything, and unconditionally — so a disclosure step placed under prose the model was meant to
evaluate fires anyway, and the bind after it fires whether or not you answered. The CLI therefore
does the whole walk and the command relays what it printed:

| You run | What happens |
|---|---|
| `/kinako:bind <name>` on an unacknowledged disclosure | the handshake, then the two-egress disclosure and the exact line to run back. **Nothing is bound**, nothing captured, no transcript created |
| `/kinako:bind <name> --acknowledge <revision>` | that re-invocation **is** the acknowledgement: it is recorded across the spool, and the bind follows if the revision is still the one Kinako is showing |
| `/kinako:bind <name>` once acknowledged | it binds, and prints what the session now carries |

The whole argument string is the brainstorm name, with a trailing `--acknowledge <revision>` split
off it. Positional placeholders are **not** used: they are zero-indexed on Claude Code 2.1.258
while the documentation describes `$1`, and a command that depends on which one a version
implements breaks on an upgrade.

## Where every captured field comes from — `FR-012`

Capture depends on **documented hook inputs only** (`FR-012`, `TR-011`). A turn is a pair, and its
halves arrive on two events:

| Field | Event | Documented input |
|---|---|---|
| the leader's prompt | `UserPromptSubmit` | `prompt` |
| the final assistant text | `Stop` | `last_assistant_message` |
| the session | both | `session_id` |
| the bound brainstorm · the session-start model | — | the binding, recorded at `/kinako:bind` |

`last_assistant_message` was added to `Stop` and `SubagentStop` by the harness expressly *"so hooks
can access it without parsing transcript files"*. **No transcript file is opened and
`transcript_path` is not read** — the transcript's on-disk format is not a documented surface, and
`crates/kinako-core/tests/plugin_hook.rs::no_hook_script_reads_a_transcript_file` holds the scripts
to that structurally.

**The hooks pipe the event straight to the CLI and parse nothing themselves.** They fire on every
turn of every session in a project where the plugin is registered, bound or not, so whatever they
cost is paid by your ordinary coding — and `FR-003` forbids added latency as squarely as it forbids
capture. An interpreter spawned there to rename two fields cost about 29ms of each hook's 33ms,
measured over 30 invocations. The CLI reads the harness's own field names, and for an unbound
session its bound-session lookup is the first and last thing it does.

A harness too old to send `last_assistant_message` sends no such field. Capture then stops rather
than reaching for another source, and the degradation is the **`harness-below-minimum`**
capture-health condition (`FR-018`) — an existing member of the closed four. The readout itself
ships with C1-5.

## The capability handshake — `kinako-bridge.json`

The plugin reaches your machine by a **different path** than the app — its own consented install
into your harness — so the two are independently versioned and can drift. `/kinako:bind` therefore
runs a handshake before it binds anything, and refuses by name when the pair does not fit.

`kinako-bridge.json` is the plugin's half of that: the bridge surfaces **this plugin requires**.

```json
{
  "bridgeSchemaVersion": 1,
  "pluginVersion": "0.0.0",
  "requiredCapabilities": ["acknowledge", "bind", "capture.prompt", "capture.stop",
                           "disclose", "handshake"]
}
```

The app's half is the set of bridge surfaces **it offers**, carried in the `kinako` CLI that ships
inside the app bundle (`IP-009`). The bind proceeds when required ⊆ offered.

`/kinako:bind` runs the comparison as its **first step**, which is why it takes the harness version
and the path to this file. The same comparison is reachable on its own — this is the one verb that
takes its payload on standard input, so the redirect is not optional:

```
"$KINAKO_CLI" "$KINAKO_APP_DATA" handshake "$(claude --version)" < kinako-bridge.json
```

**The gate is the capability set, not the version** (`D-026`). Both versions are printed so you can
act on a refusal, but a Claude Code newer than the one Kinako was built against passes cleanly —
refusing every unrecognised version is the behaviour that makes people turn version checks off.

Three conditions refuse, and a refusal names **exactly one** of them (`FR-007`):

| `refused=` | What it means | The fix |
|---|---|---|
| `harness-below-minimum` | your Claude Code is below **2.1.47**, the release that added `last_assistant_message` to `Stop` — below it there is no documented field to capture the reply half from | update Claude Code |
| `plugin-disabled` | the harness does not record this plugin as enabled. It does not run, so `/kinako:bind` is simply absent; the app names the condition rather than leaving you with an unknown command | enable the plugin |
| `bridge-capability-mismatch` | this plugin requires a surface this build of the app does not offer; the `missing=` line names which | update the app and the plugin together |

The handshake reads your harness and **writes nothing** — it needs no corpus access at all.

## Registering both events

Form A's project-scoped `.claude/settings.json` needs **both** hooks — `record-prompt.sh` on
`UserPromptSubmit` and `capture-turn.sh` on `Stop`. Registering only the second captures nothing,
because a turn is never completed without its prompt half. Form B's bundled `hooks/hooks.json`
registers both already.
