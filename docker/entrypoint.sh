#!/bin/bash

# Validate arguments
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME="Enshrouded by jsknnr"
    echo "WARN: SERVER_NAME not set, using default: Enshrouded by jsknnr"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "ERROR: SERVER_PASSWORD not set, exitting"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT="15636"
    echo "WARN: GAME_PORT not set, using default: 15636"
fi

if [ -z "$QUERY_PORT" ]; then
    QUERY_PORT="15637"
    echo "WARN: QUERY_PORT not set, using default: 15637"
fi

if [ -z "$SERVER_SLOTS" ]; then
    SERVER_SLOTS="16"
    echo "WARN: SERVER_SLOTS not set, using default: 16"
fi

# Install/Update Enshrouded
echo "INFO: Updating Enshrouded Dedicated Server"
/home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$ENSHROUDED_PATH" +login anonymous +app_update 2278520 validate +quit

# Copy example server config if not already present
if ! [ -f "${ENSHROUDED_PATH}/enshrouded_server.json" ]; then
    echo "INFO: Enshrouded server config not present, copying example"
    cp /home/steam/enshrouded_server_example.json ${ENSHROUDED_PATH}/enshrouded_server.json
fi

# Modify server config to match our arguments
jq -i '.name = "${SERVER_NAME}"' ${ENSHROUDED_PATH}/enshrouded_server.json
jq -i '.password = "${SERVER_PASSWORD}"' ${ENSHROUDED_PATH}/enshrouded_server.json
jq -i '.gamePort = "${GAME_PORT}"' ${ENSHROUDED_PATH}/enshrouded_server.json
jq -i '.queryPort = "${QUERY_PORT}"' ${ENSHROUDED_PATH}/enshrouded_server.json
jq -i '.slotCount = "${SERVER_SLOTS}"' ${ENSHROUDED_PATH}/enshrouded_server.json

# Wine talks too much and it's annoying
export WINEDEBUG=-all

# Launch Enshrouded
wine ${ENSHROUDED_PATH}/enshrouded_server.exe
