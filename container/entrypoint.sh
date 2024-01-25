#!/bin/bash

# Validate arguments
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME='Enshrouded Containerized'
    echo "WARN: SERVER_NAME not set, using default: Enshrouded Containerized"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "ERROR: SERVER_PASSWORD not set, exitting"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT='15636'
    echo "WARN: GAME_PORT not set, using default: 15636"
fi

if [ -z "$QUERY_PORT" ]; then
    QUERY_PORT='15637'
    echo "WARN: QUERY_PORT not set, using default: 15637"
fi

if [ -z "$SERVER_SLOTS" ]; then
    SERVER_SLOTS='16'
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

# Check for proper save permissions
if [[ $(stat -c "%U %G" "${ENSHROUDED_PATH}/savegame") != "steam steam" ]]; then
    echo ""
    echo "ERROR: The ownership of /home/steam/enshrouded/savegame is not correct and the server will not be able to save..."
    echo "the directory that you are mounting into the container needs to be owned by 10000:10000"
    echo "from your container host attempt the following command 'chown -R 10000:10000 /your/enshrouded/folder'"
    echo ""
    exit 1
fi

# Modify server config to match our arguments
echo "INFO: Updating Enshrouded Server configuration"
tmpfile=$(mktemp)
jq --arg n "$SERVER_NAME" '.name = $n' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg p "$SERVER_PASSWORD" '.password = $p' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg g "$GAME_PORT" '.gamePort = $g' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg q "$QUERY_PORT" '.queryPort = $q' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg s "$SERVER_SLOTS" '.slotCount = $s' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG

# Wine talks too much and it's annoying
export WINEDEBUG=-all

# Launch Enshrouded
echo "INFO: Starting Enshrouded Dedicated Server"
wine ${ENSHROUDED_PATH}/enshrouded_server.exe
