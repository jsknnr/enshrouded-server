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
BUILDAH_BUILD_OPTS := --format docker -f ./container/wine/Dockerfile
PODMAN_RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=$(VOLUME_NAME),target=/home/steam/enshrouded/savegame -p 15636:15636/udp -p 15637:15637/udp --env=SERVER_NAME='Enshrouded Containerized Server' --env=SERVER_SLOTS=16 --env=SERVER_PASSWORD='ChangeThisPlease' --env=GAME_PORT=15636 --env=QUERY_PORT=15637
PROTON_CONTAINER_NAME := enshrouded-proton-test
PROTON_VOLUME_NAME := enshrouded-proton-data
PROTON_DOCKER_BUILD_OPTS := -f ./container/proton/Dockerfile
PROTON_DOCKER_RUN_OPTS := --name $(PROTON_CONTAINER_NAME) -d --mount type=volume,source=$(PROTON_VOLUME_NAME),target=/home/steam/enshrouded/savegame -p 15636:15636/udp -p 15637:15637/udp --env=SERVER_NAME='Enshrouded Containerized Server' --env=SERVER_SLOTS=16 --env=SERVER_PASSWORD='ChangeThisPlease' --env=GAME_PORT=15636 --env=QUERY_PORT=15637

# Makefile targets
.PHONY: build run cleanup build-proton run-proton cleanup-proton

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container/wine

run:
	podman volume create $(VOLUME_NAME)
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f $(CONTAINER_NAME)
	podman rmi -f $(IMAGE_REF):$(HASH)
	podman volume rm $(VOLUME_NAME)

build-proton:
	docker build $(PROTON_DOCKER_BUILD_OPTS) -t $(PROTON_IMAGE_REF):$(HASH) ./container/proton

run-proton:
	docker volume create $(PROTON_VOLUME_NAME)
	docker run $(PROTON_DOCKER_RUN_OPTS) $(PROTON_IMAGE_REF):$(HASH)

cleanup-proton:
	docker rm -f $(PROTON_CONTAINER_NAME)
	docker rmi -f $(PROTON_IMAGE_REF):$(HASH)
	docker volume rm $(PROTON_VOLUME_NAME)
