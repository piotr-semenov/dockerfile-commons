define _BUILDCONTEXT_DOCKERFILE_BODY
FROM busybox

COPY . /contextdir
WORKDIR /contextdir

CMD ["sh", "-c", "find . -mindepth 1 | xargs du -sh | sort -rnk1"]
endef

.PHONY: test-dockerignore
test-dockerignore: export DOCKERFILE_BODY=$(_BUILDCONTEXT_DOCKERFILE_BODY)
test-dockerignore:  ## Lists all the files in the docker build context.
	@IMAGE_SHA=$$(printf "$$DOCKERFILE_BODY" |\
	              docker build -q --no-cache -f- .) &&\
	 docker run --rm $$IMAGE_SHA &&\
	 docker rmi $$IMAGE_SHA 1> /dev/null
