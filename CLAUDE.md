# HyperFleet Template API Spec - AI Agent Context

This repository generates the HyperFleet Template OpenAPI specification from TypeSpec definitions. It imports shared models and services from the [hyperfleet-api-spec](https://github.com/openshift-hyperfleet/hyperfleet-api-spec) core repository as the `hyperfleet` npm package, and adds Template-specific models (cluster spec, channels, versions) and their service endpoints.

## Quick Reference

**Build commands:**
```bash
npm run build            # Generate Template OpenAPI 3.0
npm run build:swagger    # Generate Template OpenAPI 3.0 + Swagger 2.0
./build-schema.sh        # Same as npm run build
./build-schema.sh --swagger  # Same as npm run build:swagger
```

**Validation workflow:**
```bash
npm install                              # Install dependencies (includes hyperfleet package)
./build-schema.sh                        # Build Template OpenAPI 3.0
ls -l schemas/template/openapi.yaml           # Confirm output exists
```

## Key Concepts

### Dependency on Core Repo

Template-specific TypeSpec imports shared definitions via the `hyperfleet` npm package:

```typescript
// main.tsp
import "hyperfleet/shared/services/clusters.tsp";
import "hyperfleet/shared/services/statuses.tsp";
import "hyperfleet/shared/services/nodepools.tsp";
import "hyperfleet/shared/services/resources.tsp";
```

The `hyperfleet` package is sourced from the core repo branch/tag in `package.json`:

```json
"hyperfleet": "github:openshift-hyperfleet/hyperfleet-api-spec#v1.0.18"
```

To use a local core checkout during development, use `npm link` or a local path:

```json
"hyperfleet": "file:../hyperfleet-api-spec"
```

### What Lives Here vs Core

| Concern | Location |
|---------|----------|
| Cluster/nodepool/status/resource CRUD routes | Core repo (`hyperfleet` package) |
| `TemplateClusterSpec` fields | `models/cluster/model.tsp` |
| Template nodepool fields | `models/nodepool/model.tsp` |
| Channels and versions models | `models/channel/`, `models/version/` |
| Channels and versions service endpoints | `services/channels.tsp`, `services/versions.tsp` |
| Generated output | `schemas/template/openapi.yaml` (committed) |

### Public vs Internal APIs

The internal status and force-delete endpoints come from the core shared contract. This repo generates the public Template API contract only (no internal adapter endpoints).

## Code Style

### TypeSpec Conventions

**Imports first, namespace second:**
```typescript
import "@typespec/http";
import "hyperfleet/shared/models/common/model.tsp";
import "../models/cluster/model.tsp";

namespace HyperFleet;
```

**Model naming:**
- Template resources: `TemplateClusterSpec`, `ReleaseSpec`, `ChannelSpec`, `VersionSpec`
- Lists: `ChannelList`, `VersionList`
- Requests: `ChannelCreateRequest`, `ChannelPatchRequest`

### File Organization

```
models/{resource}/
  ├── model.tsp              # Model definitions
  ├── example_{resource}.tsp # GET example constant
  ├── example_post.tsp       # POST example constant
  └── example_patch.tsp      # PATCH example constant

services/
  └── {resource}.tsp         # Service endpoints
```

## Boundaries

**DO NOT:**
- Modify generated files in `schemas/` or `tsp-output-template/` directly
- Add shared/core models here — they belong in the core repo's `shared/` directory
- Commit `node_modules/` or build artifacts

**DO:**
- Run `./build-schema.sh` and commit `schemas/template/openapi.yaml` with your changes
- Run `./build-schema.sh --swagger` and commit `schemas/template/swagger.yaml` when releasing
- Keep TypeSpec files focused (one resource per service file)
- Update `package.json` to pin a new core version when consuming new shared models

## Common Tasks

### Add a field to Template cluster spec

```typescript
// models/cluster/model.tsp
model ReleaseSpec {
  // ... existing fields ...
  newField?: string;
}
```

Rebuild: `npm run build`

### Add a new Template-specific service endpoint

```typescript
// services/channels.tsp
namespace HyperFleet;

@route("/channels")
interface Channels {
  // ... existing endpoints ...

  @get
  @route("/{id}/summary")
  getSummary(@path id: string): ChannelSummary | Error;
}
```

Rebuild: `npm run build`

### Add a new Template-specific resource

1. Create model:
```typescript
// models/policy/model.tsp
import "@typespec/http";
import "hyperfleet/shared/models/common/model.tsp";

namespace HyperFleet;

model PolicySpec {
  rules: string[];
}
```

2. Create service:
```typescript
// services/policies.tsp
import "@typespec/http";
import "@typespec/openapi";
import "hyperfleet/shared/models/common/model.tsp";
import "../models/policy/model.tsp";

namespace HyperFleet;

@route("/policies")
interface Policies {
  @get list(): PolicySpec[] | Error;
}
```

3. Import both in `main.tsp`:
```typescript
import "./models/policy/model.tsp";
import "./services/policies.tsp";
```

4. Build: `npm run build`

### Update the hyperfleet core dependency

1. Edit `package.json`:
```json
"hyperfleet": "github:openshift-hyperfleet/hyperfleet-api-spec#v1.0.19"
```

2. Reinstall and rebuild:
```bash
npm install
npm run build
```

## Version Bump and Changelog

When bumping the version in `main.tsp`, always update `CHANGELOG.md`:

1. Keep `## [Unreleased]` at the top, then add a new version section as `## [X.Y.Z] - YYYY-MM-DD`
2. List changes under appropriate headings (`Added`, `Changed`, `Fixed`, `Removed`)
3. Update the comparison links at the bottom of the file
4. Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format

## Validation Checklist

Before submitting changes:

- [ ] Dependencies installed: `npm install`
- [ ] Template schema builds: `./build-schema.sh`
- [ ] Template Swagger builds: `./build-schema.sh --swagger`
- [ ] Schema files generated: `ls schemas/template/openapi.yaml schemas/template/swagger.yaml`
- [ ] No TypeSpec compilation errors (check output)
- [ ] Schema passes linting: `spectral lint schemas/template/openapi.yaml`
- [ ] Changes committed including schema updates
- [ ] PR description references related issue

## Build System Details

**The build-schema.sh script:**
1. Runs `node_modules/.bin/tsp compile main.tsp --output-dir tsp-output-template`
2. Moves output to `schemas/template/openapi.yaml`
3. (Optional with `--swagger`) Converts to OpenAPI 2.0 via `api-spec-converter` → `schemas/template/swagger.yaml`

**Output locations:**
- TypeSpec temp: `tsp-output-template/schema/openapi.yaml` (auto-deleted)
- Final: `schemas/template/openapi.yaml` and `schemas/template/swagger.yaml` (committed)

## Release Process

Releases are **fully automated** via GitHub Actions (`.github/workflows/release.yml`).

On every push to `main`, the release workflow:
1. Extracts the version from the `@info` decorator in `main.tsp`
2. Skips if a tag for that version already exists
3. Builds both schema formats (`openapi.yaml` and `swagger.yaml`)
4. Creates an annotated Git tag (`vX.Y.Z`)
5. Publishes a GitHub Release with `template-openapi.yaml` and `template-swagger.yaml` attached

The CI workflow enforces that the version in `main.tsp` is bumped from the latest release tag before a PR can be merged.

To release a new version, bump the version in `main.tsp` and merge to `main`.

## Architecture Context

- Core spec repo: <https://github.com/openshift-hyperfleet/hyperfleet-api-spec>
- Architecture repo: <https://github.com/openshift-hyperfleet/architecture>
- Main API implementation: <https://github.com/openshift-hyperfleet/hyperfleet-api>
