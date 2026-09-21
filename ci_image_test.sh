#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'image test failed: %s\n' "$1" >&2
  exit 1
}

[[ "$(id -u)" == "10001" ]] || fail "expected UID 10001, got $(id -u)"
[[ "$(id -g)" == "10001" ]] || fail "expected GID 10001, got $(id -g)"
[[ "${NODE_HOME}" == "/usr/local/node" ]] || fail "unexpected NODE_HOME"
test -x "${NODE_HOME}/bin/node" || fail "Node.js binary is missing"
node --version | grep -q '^v24\.18\.0$' || fail "unexpected Node.js version"
npm --version | grep -q '^12\.0\.1$' || fail "unexpected npm version"
npx --version >/dev/null
yarn --version | grep -q '^1\.22\.22$' || fail "unexpected Yarn version"
yarnpkg --version | grep -q '^1\.22\.22$' || fail "unexpected yarnpkg version"
node -e 'if (process.getuid() !== 10001) process.exit(1); if (process.cwd() !== "/") process.exit(1);'
