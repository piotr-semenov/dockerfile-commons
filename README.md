[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repo holds the collections of "ready-to-use" code snippets helping to develop tiny Docker images.

| Collection | Description |
|:----------:|:------------|
| [Make Recipes](./recipes) | Certain "ready to use" Makefile recipes to cover the most of Docker image development:<BR> <UL><LI>**Lint** all the files matching Dockerfile* pattern via [Hadolint](https://github.com/hadolint/hadolint) (run by `make lint-dockerfiles`, see [lint-dockerfiles.mk](./recipes/lint-dockerfiles.mk)).</LI> <LI>**List** all the files sending to docker build context (run by `make test-dockerignore`, see [test-dockerignore.mk](./recipes/test-dockerignore.mk)).</LI> <LI>**Scan** the docker image for the vulnerabilities via [Anchore](https://github.com/anchore/anchore-engine)/[Clair](https://github.com/arminc/clair-scanner) (run by `make scan-docker`, see [scan-docker.mk](./recipes/scan-docker.mk))</LI> <LI>**Clean out** the dangling docker images, intermediate (i.e. providing the label stage=intermediate) ones, and already exited containers (run by `make clean-docker`, see [clean-docker.mk](./recipes/clean-docker.mk)).</LI></UL> |
| [Make Functions](./docker-funcs.mk) | Makefile functions for common Docker development tasks: build, test via [Dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss), and uuid generation. |
| Bash Scripts | POSIX-compliant shell scripts for Alpine Linux to short-cut the commonly used Dockerfile RUN directives:<BR> <UL><LI>**Download** file and verify its GPG signature (see [curl_and_gpgverify.sh](./curl_and_gpgverify.sh)).</LI> <LI>**Reduce** the Alpine system to specified batch of executables/files/folders (see [reduce_alpine.sh](./reduce_alpine.sh)).</LI></UL> |
| Configs | Config for [Hadolint](https://github.com/hadolint/hadolint) tool (see [.hadolint.yaml](.hadolint.yaml)). |


## Installation

Just copy the sources to your project root. Or you can add it as submodule to your repository via command below:

```bash
git submodule add https://github.com/piotr-semenov/dockerfile-commons dockerfile-commons
```

## Requirements

  * [Docker](https://docs.docker.com/engine/install/) and [Docker-Compose](https://docs.docker.com/compose/install/)
  * CLI tools: GNU make, [curl](https://curl.se)
  * [Goss](https://github.com/aelsabbahy/goss) and [Dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss)

## Usage

You can setup the following environment variables in your .env file.

| Variable | Description | Used by recipes |
|:--------:|:------------|:---------------:|
| HADOLINT_CONFIG | Path to your Hadolint config (if not set, `make lint-dockerfiles` will use "./dockerfile-commons/.hadolint.yaml"). | lint-dockerfiles |
| IMAGE_NAMES | Whitespace-separated list of Docker image tags existing in your local Docker registry. E.g. "postgres:9 ubuntu:latest". | scan-docker |

Please, find the example .env file below:

```text
HADOLINT_CONFIG=$$PWD/.hadolint.yaml
IMAGE_NAMES="postgres:9 busybox"
```

Now you do the job via `make lint-dockerfiles test-dockerignore scan-docker clean-docker`.

Also you can include these recipes in your own Makefile with lines below:

```text
include /path/to/dockerfile-commons/Makefile
```

## Projects using [dockerfile-commons](https://github.com/piotr-semenov/dockerfile-commons)

| Project | Description |
|:-------:|:------------|
| [tiny-elm](https://github.com/piotr-semenov/elm-docker) | The smallest docker image for recent Elm compiler + tools. |
| [tiny-yuicompressor](https://github.com/piotr-semenov/yuicompressor-docker) | The smallest docker image for yuicompressor tool. |
| [tiny-uglify](https://github.com/piotr-semenov/uglify-docker) | The smallest docker image for uglifyJS and uglifyCSS tools. |
| [tiny-parigp](https://github.com/piotr-semenov/parigp-docker) | The smallest docker image for PARI/GP and GP2C scientific software. |
