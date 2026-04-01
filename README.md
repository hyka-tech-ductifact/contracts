# Contracts

Shared OpenAPI specification for the Ductifact platform. This repository acts as the **single source of truth** for the API contract consumed by backend, frontend, and QA.

## Prerequisites

| Dependency | Purpose |
|---|---|
| [Docker](https://docs.docker.com/get-docker/) | Runs all tooling without local installs |

The following Docker images are pulled automatically on first use:

- `redocly/cli` — OpenAPI linting & bundling
- `tufin/oasdiff` — Breaking change detection between spec versions
- `swaggerapi/swagger-ui` — Interactive API documentation

## Quick Start

```bash
make validate   # Lint and validate the OpenAPI spec
make breaking   # Detect breaking changes vs main
make start      # Bundle + launch Swagger UI at http://localhost:8081
make stop       # Stop Swagger UI
```

The Swagger UI port can be overridden:

```bash
make start SWAGGER_PORT=9090
```

## Project Structure

```
openapi/
├── openapi.yaml        # Root spec (entry point)
├── paths/              # Path definitions split by resource
│   ├── auth.yaml
│   ├── clients.yaml
│   ├── health.yaml
│   └── users.yaml
└── schemas/            # Reusable schema definitions
    ├── auth.yaml
    ├── client.yaml
    ├── error.yaml
    ├── health.yaml
    └── user.yaml
```

> `bundled.yaml` is a generated artifact (git-ignored). It is created by `make start` to resolve all `$ref` entries into a single file for Swagger UI.

## CI/CD

A GitHub Actions workflow (`.github/workflows/contracts.yml`) automates validation and publishing:

| Trigger | Job | What it does |
|---|---|---|
| Pull request to `main` | **validate** | Runs `make validate` — blocks merge if spec is invalid |
| Pull request to `main` | **breaking** | Compares current spec against `main` and fails if there are breaking changes |
| Push tag `v*` | **release** | Validates, bundles, and publishes `bundled.yaml` as a GitHub Release asset |

Consumers can download the bundled spec from any release:

```
https://github.com/<org>/contracts/releases/download/<tag>/bundled.yaml
```

## Versioning

This repository follows [Semantic Versioning](https://semver.org/):

| Change type | Example | Version bump |
|---|---|---|
| **PATCH** | Fix typo in description, update example | `v0.1.0` → `v0.1.1` |
| **MINOR** | Add new endpoint or optional field | `v0.1.0` → `v0.2.0` |
| **MAJOR** | Remove field, rename endpoint, change response structure | `v0.1.0` → `v1.0.0` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, workflow, and release process.

## License
The contracts/specifications in this repository are licensed under CC BY-NC 4.0.

- Non-commercial use only.
- Commercial use (including use in products/services offered for sale) is not permitted without prior written permission.