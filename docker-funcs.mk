define _kv_extract
	$(shell echo $(1) |\
	        sed -nE 's/([^= ]+)=("[^"]+"|[^ ]+)[ ]?/\1=\2:/gp')
endef

define _uuidgen_dockerfile_body
FROM alpine

RUN apk update &&\
    apk add --no-cache util-linux

ENTRYPOINT ["uuidgen"]
endef
export _uuidgen_dockerfile_body


# Customize the build process of docker image.
# Args:
#     $(1) (str): The target image tag.
#     $(2) (str): The whitespace-separated list of build-arg=value pairs.
#     $(3) (str, optional): The additional flags and args for `docker build`. By default, it is "-f Dockerfile `pwd`".
# Examples:
#     $(call build_docker_image,"test","vcsref=$$(git rev-parse --short HEAD)","-f Dockerfile.test .")

define build_docker_image
	docker build \
	    $(shell echo $(call _kv_extract,$(2)) | tr ':' '\n' | xargs -I@ echo "--build-arg '@'") \
	    --no-cache \
	    -t $(1) \
	    $(if $(3),$(subst $\",,$(3)),.)
endef


# Customize the goss-based testing of docker image.
# Args:
#     $(1) (str): The docker image tag under test.
#     $(2) (str, optional): The path to the target test yaml. By default, it is "`pwd`/tests/test.yaml".
#     $(3) (str, optional): The whitespace-separated list of var=value environment passed to goss.
#     $(4) (str, optional): The extra options to goss.
# Examples:
#     $(call goss_docker_image,test,tests/main.yaml)
define goss_docker_image
	if (! command dgoss > /dev/null 2>&1) || (! command goss > /dev/null 2>&1); \
	then \
	    dgoss() { docker run --rm \
	                         --entrypoint "dgoss" \
	                         -v /var/run/docker.sock:/var/run/docker.sock \
	                         -v `pwd`:/workdir:ro \
	                         -w /workdir \
	                         $$(env | grep ^GOSS_ | cut -f1 -d= | sed 's/^/-e /') \
	                         semenovp/tiny-dgoss "$$@"; }; \
	fi; \
	GOSS_FILES_PATH=$(if $(2),$(shell dirname $(2)),$(PWD)/tests) \
	GOSS_FILE=$(if $(2),$(shell basename $(2)),test.yaml) \
	GOSS_FILES_STRATEGY=cp \
	dgoss run $(shell echo $(4)) --entrypoint=/bin/sh \
	          $(shell echo $(call _kv_extract,$(3)) | tr ':' '\n' | xargs -I@ echo "--env '@'") \
	          -it $(1)
endef


# Generates the UUID out-of-the-box by build-run-removal of docker image.
# Args:
#    $(1): The uuidgen program options.
# Examples:
#    $(call generate_build,--md5 --namespace @dns --name "www.google.com")
# Returns:
#    Created UUID value.
define generate_uuid
	export IMAGE_SHA=$$(echo "$$_uuidgen_dockerfile_body" |\
	                    docker build -q --no-cache -f- .);\
	docker run --rm $$IMAGE_SHA $(1) &&\
	docker rmi $$IMAGE_SHA 1> /dev/null
endef


# Gets the latest version of any GitHub repo.
# Args:
#    $(1): The repo URL.
# Examples:
#    $(call get_latest_version,"https://github.com/leanprover/elan.git"))
# Returns:
#    Latest version.
define get_latest_version
	git ls-remote --tags --refs --sort="v:refname" $(1) | tail -n1 | sed 's/.*\/v*//'
endef
