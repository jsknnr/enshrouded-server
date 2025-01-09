# Start with a base image
FROM ubuntu:latest

# Set container-specific build arguments
ARG CONTAINER_GID=10000
ARG CONTAINER_UID=10000
ARG GE_PROTON_VERSION=9-22

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    STEAM_APP_ID=2278520 \
    HOME=/home/steam \
    ENSHROUDED_PATH=/home/steam/enshrouded \
    ENSHROUDED_CONFIG=${ENSHROUDED_PATH}/enshrouded_server.json \
    EXTERNAL_CONFIG=0 \
    GE_PROTON_URL=https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz \
    STEAMCMD_PATH=/home/steam/steamcmd \
    STEAM_SDK64_PATH=/home/steam/.steam/sdk64 \
    STEAM_SDK32_PATH=/home/steam/.steam/sdk32 \
    STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/steam/steamcmd \
    STEAM_COMPAT_DATA_PATH=${STEAMCMD_PATH}/steamapps/compatdata/2278520 \
    UMU_ID=0

# Install required dependencies and create the steam user
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install --no-install-recommends -y \
        ubuntu-server \
        procps \
        ca-certificates \
        winbind \
        dbus \
        libfreetype6 \
        curl \
        jq \
        locales \
        lib32gcc-s1 \
    && groupadd -g ${CONTAINER_GID} steam \
    && useradd -m -u ${CONTAINER_UID} -g ${CONTAINER_GID} steam \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y 

# Switch to the steam user
USER steam

# Download and configure SteamCMD and Proton
RUN mkdir -p ${ENSHROUDED_PATH}/savegame \
    && mkdir -p ${STEAMCMD_PATH}/compatibilitytools.d \
    && mkdir -p ${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID} \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C ${STEAMCMD_PATH} \
    && chmod +x ${STEAMCMD_PATH}/steamcmd.sh \
    && ${STEAMCMD_PATH}/steamcmd.sh +quit \
    && mkdir -p /home/steam/.steam \
    && ln -s ${STEAMCMD_PATH}/linux64 ${STEAM_SDK64_PATH} \
    && ln -s ${STEAM_SDK64_PATH}/steamclient.so ${STEAM_SDK64_PATH}/steamservice.so \
    && ln -s ${STEAMCMD_PATH}/linux32 ${STEAM_SDK32_PATH} \
    && ln -s ${STEAM_SDK32_PATH}/steamclient.so ${STEAM_SDK32_PATH}/steamservice.so \
    && curl -sqL ${GE_PROTON_URL} | tar zxvf - -C "${STEAMCMD_PATH}/compatibilitytools.d/"

# Copy necessary files
COPY container/proton/entrypoint.sh /home/steam/entrypoint.sh
COPY container/proton/enshrouded_server_example.json /home/steam/enshrouded_server_example.json

# Set working directory
WORKDIR /home/steam

USER root

# Ensure entrypoint script is executable
RUN chmod +x /home/steam/entrypoint.sh

USER steam

# Default command
CMD ["/home/steam/entrypoint.sh"]
