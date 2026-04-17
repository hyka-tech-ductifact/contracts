# Ductifact Contracts Makefile

.PHONY: help validate bundle breaking start stop clean

SPEC         := openapi/openapi.yaml
BUNDLED      := openapi/bundled.yaml
BASE_REF     ?= main
SWAGGER_PORT ?= 8081

# ─── Help ────────────────────────────────────────────────────
help:
	@echo "Available commands:"
	@echo ""
	@echo "  Spec:"
	@echo "    validate         - Lint and validate the OpenAPI spec"
	@echo "    bundle           - Resolve \$$ref and generate bundled.yaml"
	@echo "    breaking         - Detect breaking changes vs a base (default: main)"
	@echo "                       make breaking BASE_REF=v0.1.0"
	@echo ""
	@echo "  Swagger UI:"
	@echo "    start            - Bundle + launch Swagger UI (port $(SWAGGER_PORT))"
	@echo "                       make start SWAGGER_PORT=9090"
	@echo "    stop             - Stop Swagger UI"
	@echo ""
	@echo "  Maintenance:"
	@echo "    clean            - Remove all untracked/ignored files (git clean)"

# ─── Spec ────────────────────────────────────────────────────

# Lint and validate the OpenAPI spec
validate:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli lint /spec/openapi.yaml

# Resolve all $ref and generate bundled.yaml
bundle:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli bundle /spec/openapi.yaml -o /spec/bundled.yaml

# Detect breaking changes against a base branch or tag
breaking: bundle
	@rm -rf /tmp/oasdiff-base && mkdir -p /tmp/oasdiff-base
	cd /tmp/oasdiff-base && git -C $(CURDIR) archive $(BASE_REF) -- openapi/ | tar xf -
	docker run --rm -v /tmp/oasdiff-base/openapi:/spec redocly/cli bundle /spec/openapi.yaml -o /spec/base-bundled.yaml
	docker run --rm \
		-v /tmp/oasdiff-base/openapi:/base:ro \
		-v $(PWD)/openapi:/spec:ro \
		tufin/oasdiff breaking /base/base-bundled.yaml /spec/bundled.yaml
	@rm -rf /tmp/oasdiff-base

# ─── Swagger UI ──────────────────────────────────────────────

# Bundle + launch Swagger UI
start: bundle
	@docker rm -f swagger-ui 2>/dev/null || true
	docker run --rm -d --name swagger-ui \
		-p $(SWAGGER_PORT):8080 \
		-e SWAGGER_JSON=/spec/bundled.yaml \
		-v $(PWD)/openapi:/spec \
		swaggerapi/swagger-ui
	@echo "Swagger UI → http://localhost:$(SWAGGER_PORT)"

# Stop Swagger UI
stop:
	@docker stop swagger-ui 2>/dev/null || echo "Swagger UI is not running"

# ─── Maintenance ─────────────────────────────────────────────

# Clean all untracked and ignored files.
clean:
	@echo "Cleaning all generated files..."
	@git clean -fdx
	@echo "✅ Cleanup completed!"


