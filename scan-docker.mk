IMAGE_NAME ?=

define _check_service_are_unhealthy
	docker-compose -f $(1) ps -q $(2) |\
	xargs -I@ docker inspect -f '{{if .State.Running}}{{ .State.Health.Status }}{{end}}' @ |\
	grep -qvw healthy
endef

define _wait_healthy_containers
	until ! $(call _check_service_are_unhealthy,$(1),$(2)); \
	 do echo "Services $(2): waiting for status 'healthy'..." && sleep 1; \
	done;
endef


scan-anchore:  ## Scans the \$IMAGE_NAME for vulnerabilities via Anchore.
	@$(eval DOCKER_COMPOSE_FILE:=$(shell mktemp docker-compose.yaml.XXXXXX))
	@curl -q https://engine.anchore.io/docs/quickstart/docker-compose.yaml 2> /dev/null 1> $(DOCKER_COMPOSE_FILE)
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@$(call _wait_healthy_containers,$(DOCKER_COMPOSE_FILE),)
	@docker run --net=host\
	            -e ANCHORE_CLI_URL=http://localhost:8228/v1/\
	            -i anchore/engine-cli\
	            /bin/bash -c "anchore-cli image add $(IMAGE_NAME) 1> /dev/null &&\
	                          anchore-cli image wait $(IMAGE_NAME) 1> /dev/null &&\
	                          anchore-cli image vuln $(IMAGE_NAME) all &&\
	                          anchore-cli evaluate check $(IMAGE_NAME)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@rm -f $(DOCKER_COMPOSE_FILE)
