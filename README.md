# HyperFleet Template API Spec

This repository generates the HyperFleet Template OpenAPI specification from TypeSpec definitions. It extends the [hyperfleet-api-spec](https://github.com/openshift-hyperfleet/hyperfleet-api-spec) core contract with Template-specific models (cluster spec, channels, versions) and imports the shared models and services from core as the `hyperfleet` npm package.

## Consuming the API Specifications

### Latest Release (Recommended for development)

Download the latest stable OpenAPI specification directly from GitHub Releases:

```bash
curl -L -O https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/latest/download/template-openapi.yaml
```

**Use in code generation:**

```bash
openapi-generator generate -i https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/latest/download/template-openapi.yaml -g go -o ./client
```

### Version-Specific Downloads

```bash
curl -L -O https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases/download/v1.0.17/template-openapi.yaml
```

**See all releases:** <https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template/releases>

## Repository Structure

```
hyperfleet-api-spec-template/
├── main.tsp                  # Main TypeSpec entry point
├── tspconfig.yaml            # TypeSpec compiler configuration
├── build-schema.sh           # Build script for OpenAPI generation
├── models/                   # Template-specific model definitions
│   ├── cluster/             # TemplateClusterSpec with Template-specific fields
│   ├── nodepool/            # Template nodepool models
│   ├── channel/             # ChannelSpec (is_default, enabled_regex)
│   └── version/             # VersionSpec (raw_version, release_image, etc.)
├── services/                 # Template-specific service endpoints
│   ├── channels.tsp         # /channels CRUD routes
│   └── versions.tsp         # /channels/{id}/versions CRUD routes
└── schemas/                  # Generated OpenAPI output
    └── template/
        └── openapi.yaml
```

Shared models and services (clusters, nodepools, statuses, resources) are imported from the `hyperfleet` npm package, which is sourced from the [hyperfleet-api-spec](https://github.com/openshift-hyperfleet/hyperfleet-api-spec) core repository.

## Prerequisites

After cloning the repository, install all dependencies:

```bash
npm install
```

This installs the TypeSpec compiler, all required libraries, and the `hyperfleet` shared package from GitHub into `node_modules/`.

## Building OpenAPI Specification

### Using npm Scripts (Recommended)

```bash
# Build OpenAPI 3.0
npm run build

# Build OpenAPI 3.0 + OpenAPI 2.0 (Swagger)
npm run build:swagger
```

### Using the Build Script Directly

```bash
./build-schema.sh            # OpenAPI 3.0 only
./build-schema.sh --swagger  # OpenAPI 3.0 + Swagger 2.0
```

The script compiles `main.tsp` and outputs `schemas/template/openapi.yaml` (and optionally `schemas/template/swagger.yaml`).

## Architecture

- **Simple CRUD only**: No business logic, no event creation
- **Separation of concerns**: API layer focuses on data persistence; orchestration is handled by external components
- **Shared contract**: Cluster, nodepool, status, and resource endpoints are defined in the core repo and imported here; only Template-specific models and services live in this repo

## Updating the Specification

### Making an API change

1. **Edit the TypeSpec sources** in `models/` or `services/`.

2. **Bump the version** in `main.tsp`:

   ```typescript
   @info(#{ version: "1.0.18", ... })
   ```

3. **Rebuild the schema**:

   ```bash
   ./build-schema.sh
   ```

4. **Update [CHANGELOG.md](CHANGELOG.md)** — move your changes from `[Unreleased]` into a new versioned entry.

5. **Open a PR.** CI enforces:
   - Committed schema matches freshly generated output.
   - OpenAPI 3.0 schema passes `spectral:oas` linting.
   - Version in `main.tsp` is higher than the latest GitHub release tag.

6. **Merge to main.** The release workflow runs automatically: it creates an annotated tag (`vX.Y.Z`), builds the schema, and publishes a GitHub release with `template-openapi.yaml` and `template-swagger.yaml` attached.

### Updating the shared core dependency

When the core repo releases a new version, update the `hyperfleet` dependency in `package.json` to pin the new tag:

```json
"hyperfleet": "github:openshift-hyperfleet/hyperfleet-api-spec#v1.0.19"
```

Then run `npm install` and rebuild.

## Dependencies

- `hyperfleet` — shared models and services from [hyperfleet-api-spec](https://github.com/openshift-hyperfleet/hyperfleet-api-spec)
- `@typespec/compiler` — TypeSpec compiler
- `@typespec/http` — HTTP protocol support
- `@typespec/openapi` — OpenAPI decorators
- `@typespec/openapi3` — OpenAPI 3.0 emitter
- `api-spec-converter` — Converts OpenAPI 3.0 to OpenAPI 2.0 (Swagger)

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, workflow, and PR guidelines.

## Architecture Context

This repository is part of the HyperFleet project. For broader context:
- Core API spec: <https://github.com/openshift-hyperfleet/hyperfleet-api-spec>
- Architecture repo: <https://github.com/openshift-hyperfleet/architecture>
- Main API implementation: <https://github.com/openshift-hyperfleet/hyperfleet-api>
