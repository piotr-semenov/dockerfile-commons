# Customize the build process of docker image.
# Args:
#     $(1): The target image tag.
#     $(2): The whitespace-separated list of build-arg=value pairs.
#     $(3), optional: The additional flags and args for `docker build`. By default, it is "-f Dockerfile `pwd`".
# Examples:
#     $(call build_docker_image,"test","vcsref=$$(git rev-parse --short HEAD)","-f Dockerfile.test .")
define build_docker_image
	export suffix=$(if $(3),$(3),.) && docker build \
	    $$(echo $(2) | xargs -n1 -I@ echo "--build-arg @") \
	    --no-cache \
	    -t $(1) \
	    $$(echo $$suffix)
endef


# Customize the goss-based testing of docker image.
# Args:
#     $(1): The docker image tag under test.
#     $(2), optional: The path to the target test yaml. By default, it is "`pwd`/tests/test.yaml".
#     $(3), optional: The whitespace-separated list of var=value environment passed to goss.
# Examples:
#     $(call goss_docker_image,test,tests/main.yaml)
define goss_docker_image
	GOSS_FILES_PATH=$(if $(2),$(shell dirname $(2)),$(PWD)/tests)\
	GOSS_FILE=$(if $(2),$(shell basename $(2)),test.yaml)\
	GOSS_FILES_STRATEGY=cp\
	$(shell which dgoss) run --entrypoint=/bin/sh \
	                         $$(echo $(3) | xargs -n1 -I@ echo "--env @") \
	                         -it $(1)
endef
