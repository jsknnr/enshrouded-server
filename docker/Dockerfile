FROM debian:12

ENV DEBIAN_FRONTEND "noninteractive"
ENV ENSHROUDED_PATH "/home/steam/enshrouded"
ENV WINEPREFIX "/home/steam/.enshrouded_prefix"
ENV WINEARCH "win64"

RUN groupadd -g 1000 steam \
    && useradd -g 1000 -u 1000 -m steam \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        wget \
        vim \
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
    && chmod +x /usr/local/bin/winetricks

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
