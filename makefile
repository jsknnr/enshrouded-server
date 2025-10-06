# I would prefer Podman but for some reason the Proton container just doesn't run right in Podman.
# Not sure if this is a me problem or a Podman problem. So Proton builds and runs with Docker instead.
#
# Image Values
REGISTRY := localhost
IMAGE := enshrouded-test
PROTON_IMAGE := enshrouded-proton-test
IMAGE_REF := $(REGISTRY)/$(IMAGE)
PROTON_IMAGE_REF := $(REGISTRY)/$(PROTON_IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman/Docker Options
CONTAINER_NAME := enshrouded-test
VOLUME_NAME := enshrouded-data
PROTON_CONTAINER_NAME := enshrouded-proton-test
PROTON_VOLUME_NAME := enshrouded-proton-data
PROTON_DOCKER_BUILD_OPTS := -f ./container/Dockerfile
PROTON_DOCKER_RUN_OPTS := --name $(PROTON_CONTAINER_NAME) -d --mount type=volume,source=$(PROTON_VOLUME_NAME),target=/home/steam/enshrouded/savegame -p 15636:15636/udp -p 15637:15637/udp --env=SERVER_NAME='Enshrouded Containerized Server' --env=SERVER_SLOTS=16 --env=SERVER_PASSWORD='ChangeThisPlease' --env=PORT=15637

# Makefile targets
.PHONY: build run cleanup

build:
	docker build $(PROTON_DOCKER_BUILD_OPTS) -t $(PROTON_IMAGE_REF):$(HASH) ./container

run:
	docker volume create $(PROTON_VOLUME_NAME)
	docker run $(PROTON_DOCKER_RUN_OPTS) $(PROTON_IMAGE_REF):$(HASH)

cleanup:
	docker rm -f $(PROTON_CONTAINER_NAME)
	docker rmi -f $(PROTON_IMAGE_REF):$(HASH)
	docker volume rm $(PROTON_VOLUME_NAME)
