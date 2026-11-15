#!/usr/bin/env bash
# ZadLoop — install the dsh-market plugin (pinned working build) with one command.
# Verified on Linux. macOS paths follow the standard Electron layout and are
# auto-detected; if detection fails, pass the runtime directory explicitly:
#   ZL_RUNTIME=/Applications/ZadLoop.app/Contents/Resources/app.asar.unpacked/runtime ./install.sh
set -euo pipefail

REPO="github:ashrymahrm/zadloop-dsh-market"
PROFILE="${ZL_PROFILE:-web}"
PLATFORM="$(uname -s)"

# --- locate the ZadLoop runtime (app.asar.unpacked/runtime) -------------------
find_runtime() {
  if [ -n "${ZL_RUNTIME:-}" ]; then echo "$ZL_RUNTIME"; return; fi
  local candidates=(
    "/opt/ZadLoop/resources/app.asar.unpacked/runtime"                                   # Linux deb/rpm
    "$HOME/.local/share/ZadLoop/resources/app.asar.unpacked/runtime"                     # Linux AppImage/user install
    "/usr/lib/zadloop/resources/app.asar.unpacked/runtime"                               # Linux rpm alt
    "/Applications/ZadLoop.app/Contents/Resources/app.asar.unpacked/runtime"             # macOS
  )
  local c
  for c in "${candidates[@]}"; do
    if [ -d "$c" ]; then echo "$c"; return; fi
  done
  echo "ZadLoop runtime not found. Set ZL_RUNTIME=/path/to/ZadLoop/resources/app.asar.unpacked/runtime and re-run." >&2
  exit 1
}

RUNTIME="$(find_runtime)"
RES_DIR="$(dirname "$(dirname "$RUNTIME")")"   # .../ZadLoop/resources

# --- locate node --------------------------------------------------------------
NODE_BIN="${ZL_NODE:-}"
if [ -z "$NODE_BIN" ]; then
  for c in "$RES_DIR/primary-runtime/dependencies/node/bin/node" \
           "$(command -v node || true)"; do
    if [ -n "$c" ] && [ -x "$c" ]; then NODE_BIN="$c"; break; fi
  done
fi
if [ -z "$NODE_BIN" ]; then
  echo "node not found inside ZadLoop and no system node on PATH." >&2
  exit 1
fi

# --- locate DSH_HOME (the harness directory) ---------------------------------
if [ -n "${ZL_DSH_HOME:-}" ]; then DSH_HOME="$ZL_DSH_HOME"
else
  case "$PLATFORM" in
    Darwin) DSH_HOME="$HOME/Library/Application Support/ZadLoop/harness" ;;
    *)      DSH_HOME="$HOME/.config/ZadLoop/harness" ;;
  esac
fi
if [ ! -d "$DSH_HOME" ]; then
  echo "DSH_HOME not found at: $DSH_HOME" >&2
  echo "Pass it explicitly: ZL_DSH_HOME=/path/to/ZadLoop/harness $0" >&2
  exit 1
fi
export DSH_HOME

# --- align pnpm: the dsh CLI spawns `pnpm` from PATH; it must be the same
# major version the ZadLoop app itself uses, or the store path mismatches
# (ERR_PNPM_UNEXPECTED_STORE). Put ZadLoop's bundled pnpm first on PATH.
PNPM_CJS="$RES_DIR/primary-runtime/dependencies/pnpm/bin/pnpm.cjs"
if [ -f "$PNPM_CJS" ]; then
  TMPBIN="$(mktemp -d)"
  cat > "$TMPBIN/pnpm" <<EOF
#!/usr/bin/env bash
exec "$NODE_BIN" "$PNPM_CJS" "\$@"
EOF
  chmod +x "$TMPBIN/pnpm"
  export PATH="$TMPBIN:$PATH"
fi

echo "runtime : $RUNTIME"
echo "node    : $NODE_BIN ($($NODE_BIN --version 2>/dev/null || echo '?'))"
echo "DSH_HOME: $DSH_HOME"
echo "profile : $PROFILE"

# --- install ------------------------------------------------------------------
exec "$NODE_BIN" --expose-internals --use-system-ca \
  --import "file://$RUNTIME/lib/runtime.js" \
  "$RUNTIME/node_modules/@deepseek-ai/dsh/lib/bin.js" \
  plugin --profile "$PROFILE" add "$REPO"
