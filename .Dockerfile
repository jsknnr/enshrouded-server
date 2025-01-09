# Start with a Debian-based base image
FROM ubuntu:latest
#FROM debian:bullseye-slim

# Set container-specific build arguments
ARG CONTAINER_GID=10000
ARG CONTAINER_UID=10000

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV STEAM_APP_ID=2278520
ENV HOME=/home/steam
ENV ENSHROUDED_PATH=/home/steam/enshrouded
ENV ENSHROUDED_CONFIG=/home/steam/enshrouded/enshrouded_server.json
ENV EXTERNAL_CONFIG=0
ENV GE_PROTON_VERSION=9-18
ENV GE_PROTON_URL=https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-18/GE-Proton9-18.tar.gz
ENV STEAMCMD_PATH=/home/steam/steamcmd
ENV STEAM_SDK64_PATH=/home/steam/.steam/sdk64
ENV STEAM_SDK32_PATH=/home/steam/.steam/sdk32
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/steam/steamcmd
ENV STEAM_COMPAT_DATA_PATH=/home/steam/steamcmd/steamapps/compatdata/2278520
ENV UMU_ID=0

# Perform initial setup with the container UID and GID
RUN CONTAINER_GID=10000 CONTAINER_UID=10000 /bin/sh -c groupadd -g $CONTAINER_GID steam     && useradd -g $CONTAINER_GID -u $CONTAINER_UID -m steam     && dpkg --add-architecture i386     && apt-get update     && apt-get install --no-install-recommends -y         procps         ca-certificates         winbind         dbus         libfreetype6         curl         jq         locales         lib32gcc-s1     && echo 'LANG="en_US.UTF-8"' > /etc/default/locale     && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen     && locale-gen     && rm -f /etc/machine-id     && dbus-uuidgen --ensure=/etc/machine-id     && rm -rf /var/lib/apt/lists/*     && apt-get clean     && apt-get autoremove -y # buildkit

# Switch to the `steam` user
USER steam

# Perform additional setup as the `steam` user
RUN CONTAINER_GID=10000 CONTAINER_UID=10000 /bin/sh -c mkdir "$ENSHROUDED_PATH"     && mkdir -p "${ENSHROUDED_PATH}/savegame"     && mkdir -p "${STEAMCMD_PATH}/compatibilitytools.d"     && mkdir -p "${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID}"     && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C ${STEAMCMD_PATH}     && chmod +x ${STEAMCMD_PATH}/steamcmd.sh     && ${STEAMCMD_PATH}/steamcmd.sh +quit     && mkdir -p /home/steam/.steam     && ln -s ${STEAMCMD_PATH}/linux64 ${STEAM_SDK64_PATH}     && ln -s ${STEAM_SDK64_PATH}/steamclient.so ${STEAM_SDK64_PATH}/steamservice.so     && ln -s ${STEAMCMD_PATH}/linux32 ${STEAM_SDK32_PATH}     && ln -s ${STEAM_SDK32_PATH}/steamclient.so ${STEAM_SDK32_PATH}/steamservice.so     && curl -sqL "$GE_PROTON_URL" | tar zxvf - -C "${STEAMCMD_PATH}/compatibilitytools.d/" # buildkit

# Copy necessary files to the container
COPY .entrypoint.sh /home/steam/entrypoint.sh
COPY .enshrouded_server_example.json /home/steam/enshrouded_server_example.json

# Set the working directory
WORKDIR /home/steam

# Set the default entrypoint command
CMD ["/home/steam/entrypoint.sh"]
