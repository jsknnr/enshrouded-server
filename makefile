# Image values
REGISTRY := "localhost"
PROJECT := "sknnr"
IMAGE := "enshrouded-server-testing"
IMAGE_REF := $(REGISTRY)/$(PROJECT)/$(IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman Options
CONTAINER_NAME := "enshrouded-test"
VOLUME_NAME := "persistent-data-test"
BUILDAH_BUILD_OPTS := --format docker -f ./container/Containerfile
PODMAN_RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=$(VOLUME_NAME),target=/home/steam/enshrouded/savegame -p 15636:15636/udp -p 15637:15637/udp --env=SERVER_NAME='Enshrouded Containerized Server' --env=SERVER_SLOTS=16 --env=SERVER_PASSWORD='ChangeThisPlease' --env=GAME_PORT=15636 --env=QUERY_PORT=15637

# Makefile targets
.PHONY: build run cleanup

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	podman volume create $(VOLUME_NAME)
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f $(CONTAINER_NAME)
	podman rmi -f $(IMAGE_REF):$(HASH)
	podman volume rm $(VOLUME_NAME)
