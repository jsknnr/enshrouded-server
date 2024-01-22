# enshrouded-server

[![Static Badge](https://img.shields.io/badge/DockerHub-blue)]((https://hub.docker.com/r/sknnr/enshrouded-dedicated-server)) ![Docker Pulls](https://img.shields.io/docker/pulls/sknnr/enshrouded-dedicated-server) [![Static Badge](https://img.shields.io/badge/GitHub-green)](https://github.com/jsknnr/enshrouded-server) ![GitHub Repo stars](https://img.shields.io/github/stars/jsknnr/enshrouded-server)

**NOTICE**
This image will not be fully functional until the dedicated server binaries are released which I am anticipating to be 1/24/2024.

Run Enshrouded dedicated server in a container. Optionally includes helm chart for running in Kubernetes.

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.
## Usage

The processes within the container do **NOT** run as root. Everything runs as the user steam (gid:1000/uid:1000). If you exec into the container, you will drop into `/home/steam` as the steam user. Enshrouded will be installed to `/home/steam/enshrouded`. Any persistent volumes should be mounted to `/home/steam/enshrouded/savegame`.

### Ports

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 15636 |
| Query Port | UDP | 15637 |

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| SERVER_NAME | Name for the Server | Enshrouded Containerized | False |
| SERVER_PASSWORD | Password for the server | None | True |
| GAME_PORT | Port for server connections | 15636 | False |
| QUERY_PORT | Port for steam query of server | 15637 | False |
| SERVER_SLOTS | Number of slots for connections (Max 16) | 16 | False |

### Docker

To run the container in Docker, run the following command:

```bash
docker volume create enshrouded-persistent-data
docker run \
  --detach \
  --name enshrouded-server \
  --mount type=volume,source=enshrouded-persistent-data,target=/home/steam/enshrouded/savegame \
  --publish 15636:15636/udp \
  --publish 15637:15637/udp \
  --env=SERVER_NAME="Enshrouded Containerized Server" \
  --env=SERVER_SLOTS=16 \
  --env=SERVER_PASSWORD="ChangeThisPlease" \
  --env=GAME_PORT=15636 \
  --env=QUERY_PORT=15637 \
  sknnr/enshrouded-dedicated-server:latest
```

### Docker Compose

To use Docker Compose, either clone this repo or copy the `compose.yaml` and `default.env` files out of the `container` directory to your local machine. You can leave the `compose.yaml` file uncahnged. Edit the `default.env` file to change the environment variables to the values you desire and then save the changes. Once you have made your changes, from the same directory that contains both the env file and the compose file, simply run:

```bash
docker compose up -d -f compose.yaml
```

To bring the container down:

```bash
docker compose down -f compose.yaml
```

### Podman

To run the container in Podman, run the following command:

```bash
podman volume create enshrouded-persistent-data
podman run \
  --detach \
  --name enshrouded-server \
  --mount type=volume,source=enshrouded-persistent-data,target=/home/steam/enshrouded/savegame \
  --publish 15636:15636/udp \
  --publish 15637:15637/udp \
  --env=SERVER_NAME="Enshrouded Containerized Server" \
  --env=SERVER_SLOTS=16 \
  --env=SERVER_PASSWORD="ChangeThisPlease" \
  --env=GAME_PORT=15636 \
  --env=QUERY_PORT=15637 \
  docker.io/sknnr/enshrouded-dedicated-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.
