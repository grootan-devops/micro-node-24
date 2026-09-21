#!/usr/bin/env bash

set -euo pipefail

# renovate: datasource=github-tags depName=nodejs/node extractVersion=^v?(?<version>.+)$
NODE_VERSION="24.18.0"
# renovate: datasource=npm depName=npm
NPM_VERSION="12.0.2"
# renovate: datasource=npm depName=yarn
YARN_VERSION="1.22.22"
# renovate: datasource=npm depName=brace-expansion
BRACE_EXPANSION_VERSION="5.0.12"
# renovate: datasource=npm depName=ip-address
IP_ADDRESS_VERSION="10.7.2"
# renovate: datasource=npm depName=tar
TAR_VERSION="7.5.22"
# renovate: datasource=npm depName=undici
UNDICI_VERSION="6.28.0"
NODE_BASE="/usr/local"
NODE_HOME="/usr/local/node"
NODE_PACKAGE_FILE_NAME="node_src.tar.gz"

for variable in NODE_VERSION NPM_VERSION YARN_VERSION BRACE_EXPANSION_VERSION IP_ADDRESS_VERSION TAR_VERSION UNDICI_VERSION NODE_BASE NODE_HOME; do
  buildah config --env "${variable}=${!variable}" "${BASE_CONTAINER}"
done
buildah config --env "NPM_VERSION=${NPM_VERSION}" "${BASE_CONTAINER}"
buildah config --env "YARN_VERSION=${YARN_VERSION}" "${BASE_CONTAINER}"
buildah config --env "BRACE_EXPANSION_VERSION=${BRACE_EXPANSION_VERSION}" "${BASE_CONTAINER}"
buildah config --env "IP_ADDRESS_VERSION=${IP_ADDRESS_VERSION}" "${BASE_CONTAINER}"
buildah config --env "TAR_VERSION=${TAR_VERSION}" "${BASE_CONTAINER}"
buildah config --env "UNDICI_VERSION=${UNDICI_VERSION}" "${BASE_CONTAINER}"

mkdir -p "${CONTAINER_MOUNT}${NODE_BASE}"
curl --fail --show-error --location --proto '=https' --tlsv1.2 --retry 3 --output "${NODE_PACKAGE_FILE_NAME}" "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz"
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
  npm install -g npm@\${NPM_VERSION} yarn@\${YARN_VERSION} tar@\${TAR_VERSION} minimatch@latest picomatch@latest
  for package_spec in \
    brace-expansion@\${BRACE_EXPANSION_VERSION} \
    ip-address@\${IP_ADDRESS_VERSION} \
    tar@\${TAR_VERSION} \
    undici@\${UNDICI_VERSION}; do
    package_name=\${package_spec%@*}
    package_archive=\$(npm pack --silent --pack-destination /tmp \${package_spec})
    rm -rf '${NODE_HOME}/lib/node_modules/npm/node_modules/'\${package_name}
    mkdir -p '${NODE_HOME}/lib/node_modules/npm/node_modules/'\${package_name}
    node -e \"require('${NODE_HOME}/lib/node_modules/tar').x({file: '/tmp/' + process.argv[1], cwd: process.argv[2], strip: 1}).catch((error) => { console.error(error); process.exit(1); })\" \
      \"\${package_archive}\" '${NODE_HOME}/lib/node_modules/npm/node_modules/'\${package_name}
    rm -f '/tmp/'\${package_archive}
  done
  ln -sf '${NODE_HOME}/bin/yarn' '/usr/bin/yarn'
  ln -sf '${NODE_HOME}/bin/yarnpkg' '/usr/bin/yarnpkg'
  npm cache clean --force
"
