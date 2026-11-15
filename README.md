<p align="center">
  <img src="assets/logo.svg" width="96" alt="dsh-market logo">
</p>

# Plugins Market for ZadLoop

English | [العربية](README.ar.md)

This repository is only a modification of [dsh-market](https://github.com/dsh-market/dsh-market) (the original plugin market for DeepSeek Harness) to make it work on ZadLoop: the plugin itself is redistributed byte-identical, pinned to `dshmarket@1.73.19`, verified against ZadLoop's runtime (`@deepseek-ai/dsh` 0.2.2-rc.2, 2026-11-15). Original site: [dshmarket.com](https://dshmarket.com). All credit to the original project and its authors. Written with AI assistance; the error and the fix are real and tested on an actual machine.

## Install first: one command

Type one line in your terminal. It finds ZadLoop's own Node runtime, puts ZadLoop's pnpm on the `PATH` first, and installs the market into the `web` profile. No app restart needed.

**Linux / macOS:**

```sh
curl -fsSL https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.ps1 | iex
```

When it finishes, open ZadLoop's Plugins page: the market is live.

Profile other than `web`? Export `ZL_PROFILE=<name>` first (`$env:ZL_PROFILE` on Windows). Custom locations: `ZL_RUNTIME`, `ZL_DSH_HOME`, `ZL_NODE`.

## If the install fails, the fix is here

The install fails when the pnpm first on your `PATH` is a different major than the one ZadLoop runs on. Each pnpm major writes its version into its store directory (`v10` vs `v11`), so two majors cannot share one `node_modules`, and rebuilds and the automatic rollback fail the same way. The fix that actually worked — and what the install script above does for you now — is putting ZadLoop's bundled pnpm, version **11.28.5**, first on the `PATH` before anything installs. Done by hand: upgrade your own pnpm to 11.28.5 and point `~/.local/bin/pnpm` at ZadLoop's bundled one with a symlink, and the install passes on the first retry.

## Waiting for agents to go idle

The market refuses profile changes while an agent session is mid-turn. The install queues and runs the moment sessions finish. Nothing to fix; close the session or press Run now when nothing is running.

## Manual install (Linux)

Equivalent to the script, if you prefer to run it by hand: put ZadLoop's bundled pnpm first on the `PATH` (the part the script does for you), then add the plugin.

```sh
RUNTIME=/opt/ZadLoop/resources/app.asar.unpacked/runtime
DSH_HOME=~/.config/ZadLoop/harness \
PATH="/opt/ZadLoop/resources/primary-runtime/dependencies/pnpm/bin:$PATH" \
/opt/ZadLoop/resources/primary-runtime/dependencies/node/bin/node \
  --expose-internals --use-system-ca \
  --import file://$RUNTIME/lib/runtime.js \
  $RUNTIME/node_modules/@deepseek-ai/dsh/lib/bin.js \
  plugin --profile web add github:ashrymahrm/zadloop-dsh-market
```

If `pnpm` is missing from `pnpm/bin` on your install, make an executable one-line shim that runs `exec "$NODE" /opt/ZadLoop/resources/primary-runtime/dependencies/pnpm/bin/pnpm.cjs "$@"` and put its directory first on the `PATH`.

## No restart needed (HMR)

ZadLoop runs the DeepSeek Harness HMR bundle by default: install and plugin switches hot-reload the running app in about a second, and the choice survives restarts.

## Troubleshooting

- `pnpm` refuses a git-hosted build: add the key pnpm prints to `allowBuilds` in the profile's `pnpm-workspace.yaml`, then rerun. Inside ZadLoop the market asks for this approval on its own.
- Stuck "Queued": one deferred change runs at a time. Dismiss finished notices in the Tasks panel and press Run now when no session is active.
- Windows/macOS scripts use the standard desktop layout and auto-detect the runtime; if a path differs on your machine, pass `ZL_RUNTIME` / `ZL_DSH_HOME`.

## What the plugin does (dsh-market features)

All of this comes from the original dsh-market plugin; nothing below was changed here.

- **Browse & search** the community catalog (4200+ plugins, growing daily): category filters, star counts, top/new sorting, bilingual descriptions
- **Host-aware discovery**: each card shows the DSH version the plugin requires, and the compatibility filter hides only confirmed mismatches with the running host
- **Screenshots**: AppStore-style screenshots on the card, with automatic README-extracted shots in the install dialog when the author added none
- **Comments**: every card opens its discussion thread in place, backed by GitHub Discussions through giscus
- **Favorites, groups, notes**: bookmark plugins, organise them into named groups with a per-group switch, and write your own one-line description on any installed plugin
- **Themes**: a dedicated tab for community themes: install, switch live with one click, uninstall to revert
- **One-click install & uninstall**: confirm the source, watch live progress; most plugins go live after a page refresh
- **Backup & restore**: export the plugin list and configuration as JSON, import elsewhere, sync through WebDAV or a private GitHub Gist; restores merge and validate
- **Updates**: per-plugin update checks and one-click updates, including the market itself; "What changed" links to release notes or commits
- **Resilient GitHub routes**: download routes fall back automatically in restricted networks, with one customizable proxy prefix
- **Hot disable / enable**: toggling a plugin writes an official patch row and the running app recomposes within a second, no restart
- **Recovery**: when a broken plugin stops a boot, an "Adjust plugins" page lets you choose what to enable and retries; a diagnostics page lists load order, duplicates, and conflicts, with a one-click AI fix prompt
- **Zero jargon setup**: if pnpm is missing, the market detects it and offers a one-click automatic setup; a one-click export produces a sanitized log for bug reports

## What the plugin changes in the running app

Everything above is unchanged upstream behavior. This repository only pins the version and verifies it inside ZadLoop; see the install command at the top.

## Provenance

Upstream project: [dsh-market/dsh-market](https://github.com/dsh-market/dsh-market) (MIT) · Upstream site: [dshmarket.com](https://dshmarket.com). Plugin catalog: [awesome-dsh-plugin.com](https://awesome-dsh-plugin.com). Installing from GitHub bypasses the npm catalog lookup, so the market keeps working when a mirror is unreachable.

## License

MIT · upstream [dshmarket.com](https://dshmarket.com)
