# Contracts

Shared OpenAPI specification for the Ductifact platform. This repository acts as the **single source of truth** for the API contract consumed by backend, frontend, and QA.

## Prerequisites

| Dependency | Purpose |
|---|---|
| [Docker](https://docs.docker.com/get-docker/) | Runs all tooling without local installs |

The following Docker images are pulled automatically on first use:

- `redocly/cli` — OpenAPI linting & bundling
- `swaggerapi/swagger-ui` — Interactive API documentation

## Quick Start

```bash
make validate   # Lint and validate the OpenAPI spec
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
