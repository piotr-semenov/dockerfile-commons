define _UUIDGEN_DOCKERFILE_BODY
FROM alpine

RUN apk update &&\
    apk add --no-cache util-linux

ENTRYPOINT ["uuidgen"]
endef
export _UUIDGEN_DOCKERFILE_BODY


# Generates the UUID out-of-the-box by build-run-removal of docker image.
# Args:
#    $(1): The uuidgen program options.
# Examples:
#    $(call generate_build,--md5 --namespace @dns --name "www.google.com")
# Returns:
#    Created UUID value.
define generate_uuid
	export IMAGE_SHA=$$(echo "$$_UUIDGEN_DOCKERFILE_BODY" |\
	                    docker build -q --no-cache -f- .);\
	docker run --rm $$IMAGE_SHA $(1) &&\
	docker rmi $$IMAGE_SHA 1> /dev/null
endef
export generate_uuid 
