define _kv_extract
	$(shell echo $(1) |\
	        sed -nE 's/([^= ]+)=("[^"]+"|[^ ]+)[ \$$]/\1=\2;/gp' |\
	        tr ';' '\n')
endef


# Customize the build process of docker image.
# Args:
#     $(1) (str): The target image tag.
#     $(2) (str): The whitespace-separated list of build-arg=value pairs.
#     $(3) (str, optional): The additional flags and args for `docker build`. By default, it is "-f Dockerfile `pwd`".
# Examples:
#     $(call build_docker_image,"test","vcsref=$$(git rev-parse --short HEAD)","-f Dockerfile.test .")

define build_docker_image
	docker build \
	    $(echo '$(call _kv_extract,$(2))' | xargs -n1 -I@ echo "--build-arg '@'") \
	    --no-cache \
	    -t $(1) \
	    $(if $(3),$(subst $\",,$(3)),.)
endef


# Customize the goss-based testing of docker image.
# Args:
#     $(1) (str): The docker image tag under test.
#     $(2) (str, optional): The path to the target test yaml. By default, it is "`pwd`/tests/test.yaml".
#     $(3) (str, optional): The whitespace-separated list of var=value environment passed to goss.
# Examples:
#     $(call goss_docker_image,test,tests/main.yaml)
define goss_docker_image
	GOSS_FILES_PATH=$(if $(2),$(shell dirname $(2)),$(PWD)/tests)\
	GOSS_FILE=$(if $(2),$(shell basename $(2)),test.yaml)\
	GOSS_FILES_STRATEGY=cp\
	$(shell which dgoss) run --entrypoint=/bin/sh \
	                         $(echo '$(call _kv_extract,$(3))' | xargs -n1 -I@ echo "--env '@'") \
	                         -it $(1)
endef
