FROM debian:13-slim

ARG CONTAINER_GID=10000
ARG CONTAINER_UID=10000

ENV DEBIAN_FRONTEND "noninteractive"
ENV STEAM_APP_ID "2278520"
ENV HOME "/home/steam"
ENV ENSHROUDED_PATH "/home/steam/enshrouded"
ENV ENSHROUDED_CONFIG "${ENSHROUDED_PATH}/enshrouded_server.json"
ENV EXTERNAL_CONFIG 0
ENV GE_PROTON_VERSION "10-17"
ENV GE_PROTON_URL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz"
ENV STEAMCMD_PATH="/home/steam/steamcmd"
ENV STEAM_SDK64_PATH="/home/steam/.steam/sdk64"
ENV STEAM_SDK32_PATH="/home/steam/.steam/sdk32"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH "$STEAMCMD_PATH"
ENV STEAM_COMPAT_DATA_PATH "${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID}"
ENV UMU_ID 0

RUN groupadd -g $CONTAINER_GID steam \
    && useradd -g $CONTAINER_GID -u $CONTAINER_UID -m steam \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        procps \
        ca-certificates \
        winbind \
        dbus \
        libfreetype6 \
        curl \
        jq \
        locales \
        lib32gcc-s1 \
        python3 \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y 

USER steam

RUN mkdir "$ENSHROUDED_PATH" \
    && mkdir -p "${ENSHROUDED_PATH}/savegame" \
    && mkdir -p "${STEAMCMD_PATH}/compatibilitytools.d" \
    && mkdir -p "${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID}" \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C ${STEAMCMD_PATH} \
    && chmod +x ${STEAMCMD_PATH}/steamcmd.sh \
    && ${STEAMCMD_PATH}/steamcmd.sh +quit \
    && mkdir -p /home/steam/.steam \
    && ln -s ${STEAMCMD_PATH}/linux64 ${STEAM_SDK64_PATH} \
    && ln -s ${STEAM_SDK64_PATH}/steamclient.so ${STEAM_SDK64_PATH}/steamservice.so \
    && ln -s ${STEAMCMD_PATH}/linux32 ${STEAM_SDK32_PATH} \
    && ln -s ${STEAM_SDK32_PATH}/steamclient.so ${STEAM_SDK32_PATH}/steamservice.so \
    && curl -sqL "$GE_PROTON_URL" | tar zxvf - -C "${STEAMCMD_PATH}/compatibilitytools.d/" 
    
COPY entrypoint.sh /home/steam/entrypoint.sh

WORKDIR /home/steam

CMD ["/home/steam/entrypoint.sh"]
