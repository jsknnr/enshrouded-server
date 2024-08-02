FROM debian:12-slim

ARG CONTAINER_GID=10000
ARG CONTAINER_UID=10000

ENV DEBIAN_FRONTEND "noninteractive"
ENV ENSHROUDED_PATH "/home/steam/enshrouded"
ENV ENSHROUDED_CONFIG "${ENSHROUDED_PATH}/enshrouded_server.json"
ENV WINEPREFIX "/home/steam/.enshrouded_prefix"
ENV WINEARCH "win64"

RUN groupadd -g $CONTAINER_GID steam \
    && useradd -g $CONTAINER_GID -u $CONTAINER_UID -m steam \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        procps \
        ca-certificates \
        curl \
        wget \
        jq \
        lib32gcc-s1 \
        cabextract \
        winbind \
        xvfb \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/local/bin/winetricks \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y 


USER steam

COPY entrypoint.sh /home/steam/entrypoint.sh
COPY winetricks.sh /home/steam/winetricks.sh
COPY enshrouded_server_example.json /home/steam/enshrouded_server_example.json

RUN mkdir "$ENSHROUDED_PATH" \
    && mkdir "$ENSHROUDED_PATH"/savegame \
    && mkdir "$WINEPREFIX" \
    && mkdir /home/steam/steamcmd \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C /home/steam/steamcmd \
    && chmod +x /home/steam/steamcmd/steamcmd.sh \
    && /home/steam/winetricks.sh

WORKDIR /home/steam

CMD ["/home/steam/entrypoint.sh"]
