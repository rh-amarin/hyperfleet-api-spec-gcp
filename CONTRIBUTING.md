# Contributing to HyperFleet Template API Spec

Thank you for your interest in contributing! This document covers the development workflow for the Template-specific API specification.

## Development Setup

### Prerequisites

- Node.js 20.x or later
- npm 11.6.2 or later
- Git

### Initial Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/openshift-hyperfleet/hyperfleet-api-spec-template.git
   cd hyperfleet-api-spec-template
   ```

2. Install dependencies (includes the TypeSpec compiler and the `hyperfleet` shared package):

   ```bash
   npm install
   ```

3. Verify your setup:

   ```bash
   npm run build
   ```

## Repository Structure

```
hyperfleet-api-spec-template/
├── main.tsp                  # Main TypeSpec entry point
├── tspconfig.yaml            # TypeSpec compiler configuration
├── build-schema.sh           # Build script
├── models/                   # Template-specific models
│   ├── cluster/             # TemplateClusterSpec
│   ├── nodepool/            # Template nodepool models
│   ├── channel/             # Channel model
│   └── version/             # Version model
├── services/                 # Template-specific service endpoints
│   ├── channels.tsp
│   └── versions.tsp
└── schemas/template/              # Generated OpenAPI output (committed)
    ├── openapi.yaml          # OpenAPI 3.0
    └── swagger.yaml          # OpenAPI 2.0 (Swagger)
```

Shared models and services are imported via the `hyperfleet` npm package from [hyperfleet-api-spec](https://github.com/openshift-hyperfleet/hyperfleet-api-spec).

## Testing

### Building Schema

```bash
npm run build           # OpenAPI 3.0
npm run build:swagger   # OpenAPI 3.0 + Swagger 2.0
```

### Linting

```bash
npx spectral lint schemas/template/openapi.yaml
```

### Validating Output

```bash
ls -l schemas/template/openapi.yaml schemas/template/swagger.yaml
```

## Common Tasks

### Adding a Template-specific model field

Edit the relevant file in `models/` (e.g., `models/cluster/model.tsp`) and rebuild:

```bash
npm run build
```

### Adding a new Template-specific service

1. Create the service file in `services/`:

   ```typescript
   // services/newservice.tsp
   import "@typespec/http";
   import "@typespec/openapi";
   import "../models/common/model.tsp";

   namespace HyperFleet;

   @route("/new-resource")
   interface NewService {
     @get list(): NewResource[] | Error;
   }
   ```

2. Import in `main.tsp`:

   ```typescript
   import "./services/newservice.tsp";
   ```

3. Build and verify: `npm run build`

### Updating the shared core dependency

When a new version of the core repo is released, update `package.json`:

```json
"hyperfleet": "github:openshift-hyperfleet/hyperfleet-api-spec#v1.0.19"
```

Then run `npm install` and rebuild.

## Commit Standards

Please refer to the architecture repo [commit standard](https://github.com/openshift-hyperfleet/architecture/blob/main/hyperfleet/standards/commit-standard.md).

**Examples:**

```
feat: add channelGroup to ReleaseSpec (Template-696)
fix: correct required fields in ChannelSpec
docs: update README with new endpoint examples
```

## Release Process

Releases are **fully automated**. See [RELEASING.md](RELEASING.md) for details.

## Pull Request Process

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Build: `npm run build` (and `npm run build:swagger` if needed)
4. Commit with a conventional commit message
5. Open a Pull Request
6. Address review feedback

### PR Guidelines

- Include schema outputs in commits when they change
- Update `CHANGELOG.md` with your changes under `[Unreleased]`
- Reference related issues or JIRA tickets in the PR description
