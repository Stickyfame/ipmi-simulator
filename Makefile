#
# IPMI Simulator
#

VERSION  := 0.1
IMG_NAME := canteuni/ipmi-simulator

TAGS := ${IMG_NAME}:latest ${IMG_NAME}:${VERSION}
CURR_DIR = $(shell pwd)
OPENIPMI_REPO := https://github.com/canteuni/openipmi.git

.PHONY: tags
tags:  ## Print the tags used for the Docker images
	@echo "${TAGS}"

.PHONY: build
build:  ## Build the Docker image for IPMI Simulator
	tags="" ; \
	for tag in $(TAGS); do tags="$${tags} -t $${tag}"; done ; \
	docker build -f Dockerfile $${tags} .

build-ipmisim:  ## Build the static ipmi_sim binary
	docker build -f ipmi_sim.Dockerfile -t local/ipmi_sim_build --build-arg openipmi_repo=$(OPENIPMI_REPO) .
	docker run --rm -v $(CURR_DIR)/output:/output local/ipmi_sim_build
	docker image rm --force local/ipmi_sim_build:latest

.PHONY: run
run: build  ## Build and run the IPMI Simulator locally (localhost:623/udp)
	docker run -d -p 623:623/udp --name ipmisim ${IMG_NAME}

.PHONY: version
version:  ## Print the version of IPMI Simulator
	@echo "${VERSION}"

.PHONY: help
help:  ## Print Make usage information
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help
