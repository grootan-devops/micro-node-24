# micro-node-24

Minimal Node.js image built directly with Buildah on top of the Grootan
micro-root image. The project intentionally contains no Dockerfile.

## Image

- Registry: Docker Hub
- Repository: `grootantec/micro-node-24`
- Release: `1.0.0`
- Node.js: `24.18.0`
- npm: `12.0.1`
- Yarn: `1.22.22`
- Base: `grootantec/micro-root:1.5.1`

The image uses `/usr/bin/dumb-init --` as its entrypoint and starts `node` by
default. `NODE_HOME` is `/usr/local/node`, and the Node.js, npm, npx, Yarn, and
yarnpkg symlinks are exposed in `/usr/bin`.

## Build and test

The GitHub Actions workflows build the image with Buildah, execute
`ci_image_test.sh` as UID `10001:10001`, and run a blocking Trivy image scan.
The same checks run for pull requests and release candidates.

## License

This project is licensed under the GNU Affero General Public License v3.0.
See [LICENSE.md](LICENSE.md).
