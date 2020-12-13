LOCAL_PREFIX ?=


define DOCKERFILE_TO_BUILD_CONTEXT
FROM busybox

COPY . /contextdir
WORKDIR /contextdir

CMD [\"sh\", \"-c\", \"find . -mindepth 1 | xargs du -sh | sort -rnk1\"]
endef

.PHONY: test-dockerignore
test-dockerignore: export DOCKERFILE_BODY="$(DOCKERFILE_TO_BUILD_CONTEXT)"
test-dockerignore: export IMAGE_NAME="$(LOCAL_PREFIX)build-context"
test-dockerignore:  ## Lists all the files in the context directory accepted by .dockerignore.
	@eval "echo $$DOCKERFILE_BODY" |\
	 docker build -t $(IMAGE_NAME) --no-cache -f- . 1> /dev/null

	@docker run --rm -t $(IMAGE_NAME)

	@docker rmi $(IMAGE_NAME) 1> /dev/null
