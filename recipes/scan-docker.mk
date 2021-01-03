IMAGE_NAMES ?=

define _check_service_are_unhealthy
	docker-compose -f $(1) ps -q $(2) |\
	xargs -I@ docker inspect -f '{{if .State.Running}}{{ .State.Health.Status }}{{end}}' @ |\
	grep -qvw healthy
endef

define _wait_healthy_containers
	until ! $(call _check_service_are_unhealthy,$(1),$(2)); \
	 do echo "Services $(2): waiting for status 'healthy'..." && sleep 10; \
	done;
endef


scan-anchore:
	@$(eval DOCKER_COMPOSE_FILE:=$(shell mktemp docker-compose.yaml.XXXXXX))
	@curl -q https://engine.anchore.io/docs/quickstart/docker-compose.yaml 2> /dev/null 1> $(DOCKER_COMPOSE_FILE)
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@$(call _wait_healthy_containers,$(DOCKER_COMPOSE_FILE),)
	@for IMAGE_NAME in $(IMAGE_NAMES); do \
	  docker run --net=host\
	              -e ANCHORE_CLI_URL=http://localhost:8228/v1/\
	              -i anchore/engine-cli\
	              /bin/bash -c "anchore-cli image add $$IMAGE_NAME 1> /dev/null &&\
	                            anchore-cli image wait $$IMAGE_NAME 1> /dev/null &&\
	                            anchore-cli image vuln $$IMAGE_NAME all &&\
	                            anchore-cli evaluate check $$IMAGE_NAME"; \
	done
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@rm -f $(DOCKER_COMPOSE_FILE)


define _CLAIR_DOCKERCOMPOSE_BODY
---
version: "3.7"

services:
  clair-db:
    container_name: postgres
    image: arminc/clair-db
    restart: unless-stopped
    ports:
      - "5432:5432"
    healthcheck:
      test: pg_isready
      interval: 1s
    networks:
      - clair

  clair:
    container_name: clair
    image: arminc/clair-local-scan
    restart: unless-stopped
    ports:
      - "6060:6060"
    healthcheck:
      test: wget --spider http://127.0.0.1:6061/health
      interval: 1s
    networks:
      - clair
    links:
      - clair-db

  clair-scanner:
    container_name: scanner
    image: ubuntu:latest
    environment:
      - "DEBIAN_FRONTEND=noninteractive"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    command:
      - "/bin/sh"
      - -c
      - |
        apt-get update &&\
        apt-get install wget -y &&\
        rm -rf /var/lib/apt/lists/* &&\
        \
        wget -qO /usr/local/bin/clair-scanner https://github.com/arminc/clair-scanner/releases/download/v12/clair-scanner_linux_amd64 &&\
        chmod +x /usr/local/bin/clair-scanner &&\
        \
        tail -f /dev/null
    ports:
      - "9279:9279"
    healthcheck:
      test: /usr/local/bin/clair-scanner --help
      interval: 1s
    networks:
      - clair
    links:
      - clair

networks:
  clair:
    external: false
endef

scan-clair: export DOCKER_COMPOSE_FILE_BODY=$(call _CLAIR_DOCKERCOMPOSE_BODY,)
scan-clair:
	@$(eval DOCKER_COMPOSE_FILE:=$(shell mktemp docker-compose.yaml.XXXXXX))
	@$(eval DOCKER_GATEWAY:=$(shell docker network inspect bridge --format "{{range .IPAM.Config}}{{.Gateway}}{{end}}"))
	@echo "$$DOCKER_COMPOSE_FILE_BODY" > $(DOCKER_COMPOSE_FILE)
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@$(call _wait_healthy_containers,$(DOCKER_COMPOSE_FILE),)
	@for IMAGE_NAME in $(IMAGE_NAMES); do \
	  docker exec -i scanner\
	                 /usr/local/bin/clair-scanner --ip "host.docker.internal"\
	                                              --clair="http://$(DOCKER_GATEWAY):6060"\
	                                              --exit-when-no-features=false\
	                                              --all\
	                                              $$IMAGE_NAME; \
	done
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@rm -f $(DOCKER_COMPOSE_FILE)


scan-docker: scan-anchore scan-clair;  ## Scans the docker images listed in $IMAGE_NAMES for vulnerabilities via Anchore and Clair.
