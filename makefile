# Image values
REGISTRY := "localhost"
PROJECT := "sknnr"
IMAGE := "enshrouded-server-testing"
IMAGE_REF := $(REGISTRY)/$(PROJECT)/$(IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman Options
BUILDAH_BUILD_OPTS := --build-arg CONTAINER_GID=10000 --build-arg CONTAINER_UID=10000 --format docker -f ./container/Containerfile
PODMAN_RUN_OPTS := --name enshrouded-test -d -v ./persistent-data-test:/home/steam/enshrouded/savegame -p 15636:15636/udp -p 15637:15637/udp --env=SERVER_NAME='Enshrouded Containerized Server' --env=SERVER_SLOTS=16 --env=SERVER_PASSWORD='ChangeThisPlease' --env=GAME_PORT=15636 --env=QUERY_PORT=15637

# Makefile targets
.PHONY: build run cleanup

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	mkdir ./persistent-data-test
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f enshrouded-test
	podman rmi -f $(IMAGE_REF):$(HASH)
	rm -rf ./persistent-data-test
