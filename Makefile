-include .env
include docker-funcs.mk recipes/*.mk


.PHONY: help
help:  ## Prints this usage.
	@echo 'Recipes:'
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
