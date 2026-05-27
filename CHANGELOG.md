# Changelog

All notable changes to the HyperFleet Template API specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.18] - 2026-05-26

### Added

- `GET /resources/{resource_id}/statuses` endpoint for listing adapter statuses per resource (HYPERFLEET-1103)

### Fixed

- `PATCH` HTTP method now correctly generated for cluster, nodepool, and resource patch endpoints (was `POST`)

## [1.0.17] - 2026-05-21

### Added

- `/channels` CRUD routes (`GET` list, `GET` by ID, `POST`, `PATCH`, `DELETE`)
- `/channels/{channel_id}/versions` CRUD routes
- `ChannelSpec` model (`is_default`, `enabled_regex`)
- `VersionSpec` model (`raw_version`, `enabled`, `is_default`, `release_image`, `end_of_life_time`)
- `KindChannel` and `KindVersion` kind aliases
- Generic `/resources` CRUD routes imported from shared core contract (HYPERFLEET-1083)

## [1.0.16] - 2026-05-20

### Added

- `channelGroup` optional field to `ReleaseSpec` in Template cluster model (Template-696)

## [1.0.15] - 2026-05-18

### Added

- Repository split from `hyperfleet-api-spec` core repository (HYPERFLEET-1103)
- Template-specific models (`TemplateClusterSpec`, nodepool models) moved to this repository
- CI workflow that rebuilds schemas, checks consistency, lints with `spectral:oas`, and enforces version bumps
- Release workflow that auto-creates annotated tags and publishes `template-openapi.yaml` and `template-swagger.yaml`
- `hyperfleet` npm dependency for importing shared models and services from the core repository

<!-- Links -->
[Unreleased]: https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/compare/v1.0.18...HEAD
[1.0.18]: https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/compare/v1.0.17...v1.0.18
[1.0.17]: https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/compare/v1.0.16...v1.0.17
[1.0.16]: https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/compare/v1.0.15...v1.0.16
[1.0.15]: https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/tag/v1.0.15
