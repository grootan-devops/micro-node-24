#!/usr/bin/env bash

set -euo pipefail

: "${CONTAINER_MOUNT:?CONTAINER_MOUNT must be set by the Buildah workflow}"
# renovate: datasource=github-tags depName=nodejs/node extractVersion=^v?(?<version>.+)$
NODE_VERSION="24.18.0"
# renovate: datasource=npm depName=npm
NPM_VERSION="12.0.1"
# renovate: datasource=npm depName=yarn
YARN_VERSION="1.22.22"
NODE_BASE="/usr/local"
NODE_HOME="/usr/local/node"
NODE_PACKAGE_FILE_NAME="node_src.tar.gz"
for variable in NODE_VERSION NPM_VERSION YARN_VERSION NODE_BASE NODE_HOME; do
  buildah config --env "${variable}=${!variable}" "${BASE_CONTAINER}"
done
buildah config --env "NPM_VERSION=${NPM_VERSION}" "${BASE_CONTAINER}"
buildah config --env "YARN_VERSION=${YARN_VERSION}" "${BASE_CONTAINER}"

mkdir -p "${CONTAINER_MOUNT}${NODE_BASE}"
curl --fail --show-error --location --proto '=https' --tlsv1.2 --retry 3 \
  --output "${NODE_PACKAGE_FILE_NAME}" \
  "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz"
tar -xzf "${NODE_PACKAGE_FILE_NAME}"
rm -f "${NODE_PACKAGE_FILE_NAME}"
mv "node-v${NODE_VERSION}-linux-x64" "${CONTAINER_MOUNT}${NODE_HOME}"

run_in_container_mount "
  ln -sf '${NODE_HOME}/bin/npm' '/usr/bin/npm'
  ln -sf '${NODE_HOME}/bin/node' '/usr/bin/node'
  ln -sf '${NODE_HOME}/bin/npx' '/usr/bin/npx'
  mkdir -p /.npm /.config /.npm-global /.npmrc /.yarn
  chgrp -R 0 '${NODE_HOME}' /.npm /.config /.npm-global /.npmrc /.yarn
  chmod -R g=u '${NODE_HOME}' /.npm /.config /.npm-global /.npmrc /.yarn
  npm install -g npm@\${NPM_VERSION} yarn@\${YARN_VERSION} tar@latest minimatch@latest picomatch@latest
  ln -sf '${NODE_HOME}/bin/yarn' '/usr/bin/yarn'
  ln -sf '${NODE_HOME}/bin/yarnpkg' '/usr/bin/yarnpkg'
  npm cache clean --force
"
