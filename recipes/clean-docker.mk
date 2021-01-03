.PHONY: clean-docker
clean-docker:  ## Removes the intermediate & dangling docker images + already exited containers.
	-@docker rm -v $(shell docker ps -q --filter status=exited) 2> /dev/null
	-@docker rmi $(shell docker images -q --filter "label=stage=intermediate") 2> /dev/null
	-@docker rmi $(shell docker images -q --filter "dangling=true") 2> /dev/null
