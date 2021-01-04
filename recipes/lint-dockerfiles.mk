HADOLINT_CONFIG ?= `pwd`/dockerfile-commons/.hadolint.yaml


.PHONY: lint-dockerfiles
lint-dockerfiles: export FILES = $(shell find . -type f -name "Dockerfile*")
lint-dockerfiles:  ## Hadolints all the files matching the pattern Dockerfile.*.
	@for p in $$FILES; do \
	  docker run --rm \
	             -v $(HADOLINT_CONFIG):/tmp/.hadolint.yaml:ro \
	             -v `pwd`:/workdir \
	             -w /workdir \
	             -i hadolint/hadolint /bin/hadolint -f tty -c /tmp/.hadolint.yaml $$p; \
	done
