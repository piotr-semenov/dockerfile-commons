.PHONY: clean-docker
clean-docker:  ## Removes the intermediate & dangling docker images + already exited containers.
	$(eval _CONTAINERS_LIST := $(shell docker ps -q --filter status=exited))
	@$(if $(strip $(_CONTAINERS_LIST)), \
	 docker rm -v $(_CONTAINERS_LIST) 2> /dev/null, \
	)
	@for p in "label=stage=intermediate" "dangling=true"; do \
	 _IMAGES_LIST=$$(docker images -q --filter "$$p"); \
	 if [[ -n "$${_IMAGES_LIST}" ]]; then docker rmi $${_IMAGES_LIST}; fi; \
	done
