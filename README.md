<p align="center">
  <img src="assets/logo.svg" width="96" alt="dsh-market logo">
</p>

# Plugins Market for ZadLoop

English | [العربية](README.ar.md)

This repository is a byte-identical redistribution of the dsh-market plugin, pinned to `dshmarket@1.73.19` and verified working on ZadLoop (`@deepseek-ai/dsh` 0.2.2-rc.2, 2026-11-15). Everything in this page is about ZadLoop only. Written with AI assistance; the error and the fix are real and tested on an actual machine.

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

The install fails when the pnpm first on your `PATH` is a different major than the one ZadLoop runs on. Each pnpm major writes its version into its store directory (`v10` vs `v11`), so two majors cannot share one `node_modules`, and rebuilds and the automatic rollback fail the same way. The install script above fixes this for you by putting ZadLoop's own pnpm first on the `PATH` before it installs anything.

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

## Provenance

Upstream project: [dsh-market/dsh-market](https://github.com/dsh-market/dsh-market) (MIT). Plugin catalog: [awesome-dsh-plugin.com](https://awesome-dsh-plugin.com). Installing from GitHub bypasses the npm catalog lookup, so the market keeps working when a mirror is unreachable.

## License

MIT · upstream [dshmarket.com](https://dshmarket.com)
