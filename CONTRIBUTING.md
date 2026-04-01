# Contributing Guide

## Workflow overview

- Topic branches → PR into `main` → CI validates + checks breaking changes
- Tag a version on `main` → CI bundles and publishes as GitHub Release
- No `release` branch — releases are driven by tags

---

## 1) Branches

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New endpoints, schemas, or fields | `feat/add-invoice-endpoints` |
| `fix/` | Fix spec errors, typos, wrong types | `fix/user-email-format` |
| `chore/` | Makefile, CI, docs, tooling | `chore/update-ci-workflow` |

All PRs target `main`.

---

## 2) Day-to-day workflow

```bash
git checkout main && git pull
git checkout -b feat/add-invoice-endpoints
```

Edit the source files under `openapi/` (never edit `bundled.yaml` directly).

Validate locally:

```bash
make validate
make breaking
```

Commit, push, and open a Pull Request against `main`. Use **squash merge** (1 PR = 1 commit).

---

## 3) Releases

Use **SemVer**: `vMAJOR.MINOR.PATCH`

| Change type | Example | Version bump |
|---|---|---|
| **PATCH** | Fix typo in description, update example | `v0.1.0` → `v0.1.1` |
| **MINOR** | Add new endpoint or optional field | `v0.1.0` → `v0.2.0` |
| **MAJOR** | Remove field, rename endpoint, change response structure | `v0.1.0` → `v1.0.0` |

```bash
git checkout main && git pull
git tag -a v0.2.0 -m "feat: add invoice endpoints"
git push origin v0.2.0
```

CI automatically creates the GitHub Release with `bundled.yaml` attached.

Consumers can download the bundled spec from any release:

```
https://github.com/<org>/contracts/releases/download/<tag>/bundled.yaml
```

---

## 4) CI/CD

A GitHub Actions workflow (`.github/workflows/contracts.yml`) automates validation and publishing:

| Trigger | Job | What it does |
|---|---|---|
| Pull request to `main` | **validate** | Runs `make validate` — blocks merge if spec is invalid |
| Pull request to `main` | **breaking** | Compares current spec against `main` and fails if there are breaking changes |
| Push tag `v*` | **release** | Validates, bundles, and publishes `bundled.yaml` as a GitHub Release asset |

---

## 5) Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

`feat:`, `fix:`, `chore:`

---

## 6) PR rules

- No direct pushes to `main`
- CI must pass (validate + breaking change detection)
- Keep PRs small and focused
