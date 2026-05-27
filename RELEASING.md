# Release Process

This document describes the automated release process for the HyperFleet Template API specification.

## Overview

Releases are **fully automated** via GitHub Actions. When a PR is merged to `main`, the release workflow (`.github/workflows/release.yml`) automatically creates a versioned GitHub Release with the schema artifacts attached.

**Manual tagging or asset uploads are no longer required.**

## Versioning Strategy

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR** version: Incompatible API changes (breaking changes)
- **MINOR** version: Backward-compatible functionality additions
- **PATCH** version: Backward-compatible bug fixes

## How to Release

1. Bump the version in `main.tsp` (the `@info` decorator's `version` field)
2. Update `CHANGELOG.md` with the new version and changes
3. Build schemas: `npm run build` and `npm run build:swagger`
4. Commit the version bump, changelog, and regenerated schemas
5. Open a PR and merge to `main`

The CI workflow enforces that the version in `main.tsp` has been bumped from the latest release tag. If unchanged, CI will fail and block the merge.

## What the Automation Does

On every push to `main`, the release workflow:

1. **Extracts** the version from `main.tsp`
2. **Skips** if a Git tag for that version already exists (idempotent)
3. **Builds** both schema formats
4. **Creates** an annotated Git tag (`vX.Y.Z`)
5. **Publishes** a GitHub Release with auto-generated release notes and two artifacts:
   - `template-openapi.yaml` (OpenAPI 3.0)
   - `template-swagger.yaml` (OpenAPI 2.0)

## CI Validation

The CI workflow (`.github/workflows/ci.yml`) runs on every PR and push to `main`:

1. **Schema consistency** — Rebuilds schemas and verifies they match committed files
2. **OpenAPI linting** — Runs `spectral lint` against the `spectral:oas` ruleset
3. **Version bump check** — Compares the version in `main.tsp` against the latest release tag

## Download URLs

**Latest release (always points to newest):**
- Template OpenAPI 3.0: `https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/latest/download/template-openapi.yaml`
- Template Swagger 2.0: `https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/latest/download/template-swagger.yaml`

**Specific version:**
- `https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/download/vX.Y.Z/template-openapi.yaml`

## Troubleshooting

### CI fails with "Version matches latest release tag"

Bump the version in `main.tsp` before merging.

### Release not created after merge

Check that the version in `main.tsp` is new (no existing Git tag). Verify with:

```bash
git ls-remote --tags origin | grep vX.Y.Z
```
