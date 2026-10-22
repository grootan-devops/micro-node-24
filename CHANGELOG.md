# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.1] - 2026-10-22

### Changed

- Switched the `micro-root` base image Renovate annotation from `gitlab-tags` to `github-tags`
  (`grootan-devops/micro-root`), so Renovate can track new base image releases again.

## [1.2.0] - 2026-10-22

### Changed

- Updated CI library to `1.6.0`
- Moved image test to ci library
- Accepted CVE-2026-19534, CVE-2026-85024, CVE-2026-18540 (undici) and CVE-2026-104844 (postcss-selector-parser) in `ignored-cves.yml`: all are in the npm CLI's vendored dependencies and are not reachable from application code; drop them once the bundled npm ships the patched versions.

## [1.1.1] - 2026-09-23

### Changed

- Use the fully qualified `docker.io/grootantech/micro-root` reference so Buildah does not require interactive short-name resolution.

## [1.1.0] - 2026-09-22

### Changed

- Pinned the GitHub Actions build, verification, and release workflows to `github-ci-library` 1.0.0.

## [1.0.0] - 2026-09-22

### Added

- Initial Node.js 24.18.0 Buildah image with npm 12.0.1 and Yarn 1.22.22,
  based on micro-root 1.5.1.
- GitHub Actions build, smoke-test, security-scan, and release workflows.
