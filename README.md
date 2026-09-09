# HumanInLoop plugins

A Claude Code plugin marketplace.

```
claude plugin marketplace add humaninloop-dev/humaninloop-plugins
```

## Plugins

| Plugin | Install | What it does |
|---|---|---|
| `kinako` | `claude plugin install kinako@humaninloop-plugins` | Spar with Kinako inside your own Claude Code; every completed turn of a bound session is captured for your corpus. Needs the Kinako app: `brew install humaninloop-dev/homebrew-tap/kinako`. See `plugins/kinako/README.md`. |

Each plugin's source of truth is its own repository; this repository carries the released copy,
tagged `<plugin>--v<version>` per release.
