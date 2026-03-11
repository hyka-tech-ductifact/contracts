.PHONY: validate bundle start stop

SPEC       := openapi/openapi.yaml
BUNDLED    := openapi/bundled.yaml
SWAGGER_PORT := 8081

## validate: Lint and validate the OpenAPI spec
validate:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli lint /spec/openapi.yaml

## bundle: Resolve all $ref and generate bundled.yaml
bundle:
	docker run --rm -v $(PWD)/openapi:/spec redocly/cli bundle /spec/openapi.yaml -o /spec/bundled.yaml

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
