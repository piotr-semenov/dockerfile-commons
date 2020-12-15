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
	    $$suffix
endef
