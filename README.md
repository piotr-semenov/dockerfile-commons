## POSIX-Compliant Shell Scripts for Alpine Linux

| File | Description |
|:----:|:------------|
| [curl_and_gpgverify.sh](curl_and_gpgverify.sh) | Downloads file and its GPG signature from input URLs and then verifies.<hr />**Requirements**: [curl](https://curl.se)/[gnupg](https://gnupg.org) must be preliminarly installed. |
| [reduce_alpine.sh](reduce_alpine.sh) | Reduces the Alpine system to specified batch of executables/files/folders. |


## Frequently Used Makefile Targets

| Makefile inc. | Description |
|:-------------:|:------------|
| [generate-uuid.mk](generate-uuid.mk) | Provides function `generate_uuid` to generate the UUID out-of-the-box by build-run-removal of docker image. |
| [lint-dockerfiles.mk](lint-dockerfiles.mk) | Lints all the Dockerfiles.<hr />**Environment**: Customize \$HADOLINT_CONFIG variable to select your Hadolint config (by default it uses [.hadolint.yaml](.hadolint.yaml)]. |
| [test-dockerignore.mk](test-dockerignore.mk) | List all the files from `docker build` context. |
| [scan-docker.mk](scan-docker.mk) | Scans the docker image via Anchore/Clair engines locally. Specify the docker images to scan by \$IMAGE_NAMES variable. |
| [docker-funcs.mk](docker-funcs.mk) | Provides the customizable functions `build_docker_image` and `goss_docker_image`.<hr />**Requirements**: [goss](https://github.com/aelsabbahy/goss) must be preliminarly installed for `goss_docker_image`. |


## Misc. Files

| File | Description |
|:----:|:-----------:|
| [.hadolint.yaml](.hadolint.yaml) | Config for hadolint tool that lints Dockerfiles |
