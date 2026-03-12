.PHONY: validate bundle breaking start stop

SPEC       := openapi/openapi.yaml
BUNDLED    := openapi/bundled.yaml
BASE_REF   ?= main
SWAGGER_PORT := 8081

## validate: Lint and validate the OpenAPI spec
validate:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli lint /spec/openapi.yaml

## bundle: Resolve all $ref and generate bundled.yaml
bundle:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli bundle /spec/openapi.yaml -o /spec/bundled.yaml

## breaking: Detect breaking changes against a base branch or tag
##   Local usage:  make breaking              (compares against main)
##                 make breaking BASE_REF=v0.1.0
##   CI usage:     make breaking BASE_BUNDLED=openapi/base-bundled.yaml
breaking: bundle
ifndef BASE_BUNDLED
	@rm -rf /tmp/oasdiff-base && mkdir -p /tmp/oasdiff-base
	cd /tmp/oasdiff-base && git -C $(CURDIR) archive $(BASE_REF) -- openapi/ | tar xf -
	docker run --rm -v /tmp/oasdiff-base/openapi:/spec redocly/cli bundle /spec/openapi.yaml -o /spec/base-bundled.yaml
	cp /tmp/oasdiff-base/openapi/base-bundled.yaml openapi/base-bundled.yaml
	@rm -rf /tmp/oasdiff-base
endif
	docker run --rm -v $(PWD)/openapi:/spec:ro tufin/oasdiff breaking /spec/$(or $(notdir $(BASE_BUNDLED)),base-bundled.yaml) /spec/bundled.yaml
ifndef BASE_BUNDLED
	@rm -f openapi/base-bundled.yaml
endif

## start: Bundle + launch Swagger UI on port $(SWAGGER_PORT)
start: bundle
	@docker rm -f swagger-ui 2>/dev/null || true
	docker run --rm -d --name swagger-ui \
		-p $(SWAGGER_PORT):8080 \
		-e SWAGGER_JSON=/spec/bundled.yaml \
		-v $(PWD)/openapi:/spec \
		swaggerapi/swagger-ui
	@echo "Swagger UI → http://localhost:$(SWAGGER_PORT)"

## stop: Stop Swagger UI
stop:
	docker stop swagger-ui
