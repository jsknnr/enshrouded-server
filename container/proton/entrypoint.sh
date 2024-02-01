#!/bin/bash

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

# Validate arguments
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME='Enshrouded Containerized'
    echo "$(timestamp) WARN: SERVER_NAME not set, using default: Enshrouded Containerized"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "$(timestamp) ERROR: SERVER_PASSWORD not set, exitting"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT='15636'
    echo "$(timestamp) WARN: GAME_PORT not set, using default: 15636"
fi

if [ -z "$QUERY_PORT" ]; then
    QUERY_PORT='15637'
    echo "$(timestamp) WARN: QUERY_PORT not set, using default: 15637"
fi

if [ -z "$SERVER_SLOTS" ]; then
    SERVER_SLOTS='16'
    echo "$(timestamp) WARN: SERVER_SLOTS not set, using default: 16"
fi

if [ -z "$SERVER_IP" ]; then
    SERVER_IP='0.0.0.0'
    echo "$(timestamp) WARN: SERVER_IP not set, using default: 0.0.0.0"
fi

# Install/Update Enshrouded
echo "$(timestamp) INFO: Updating Enshrouded Dedicated Server"
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$ENSHROUDED_PATH" +login anonymous +app_update ${STEAM_APP_ID} validate +quit

# Check that steamcmd was successful
if [ $? != 0 ]; then
    echo "$(timestamp) ERROR: steamcmd was unable to successfully initialize and update Enshrouded"
    exit 1
fi

# Copy example server config if not already present
if ! [ -f "${ENSHROUDED_PATH}/enshrouded_server.json" ]; then
    echo "$(timestamp) INFO: Enshrouded server config not present, copying example"
    cp /home/steam/enshrouded_server_example.json ${ENSHROUDED_PATH}/enshrouded_server.json
fi

# Check for proper save permissions
if ! touch "${ENSHROUDED_PATH}/savegame/test"; then
    echo ""
    echo "$(timestamp) ERROR: The ownership of /home/steam/enshrouded/savegame is not correct and the server will not be able to save..."
    echo "the directory that you are mounting into the container needs to be owned by 10000:10000"
    echo "from your container host attempt the following command 'chown -R 10000:10000 /your/enshrouded/folder'"
    echo ""
    exit 1
fi

rm "${ENSHROUDED_PATH}/savegame/test"

# Modify server config to match our arguments
echo "$(timestamp) INFO: Updating Enshrouded Server configuration"
tmpfile=$(mktemp)
jq --arg n "$SERVER_NAME" '.name = $n' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg p "$SERVER_PASSWORD" '.password = $p' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg g "$GAME_PORT" '.gamePort = ($g | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg q "$QUERY_PORT" '.queryPort = ($q | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg s "$SERVER_SLOTS" '.slotCount = ($s | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
jq --arg i "$SERVER_IP" '.ip = $i' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG

# Wine talks too much and it's annoying
#export WINEDEBUG=-all

# Check that log directory exists, if not create
if ! [ -d "${ENSHROUDED_PATH}/logs" ]; then
    mkdir -p "${ENSHROUDED_PATH}/logs"
fi

# Check that log file exists, if not create
if ! [ -f "${ENSHROUDED_PATH}/logs/enshrouded_server.log" ]; then
    touch "${ENSHROUDED_PATH}/logs/enshrouded_server.log"
fi

# Link logfile to stdout of pid 1 so we can see logs
ln -sf /proc/1/fd/1 "${ENSHROUDED_PATH}/logs/enshrouded_server.log"

# Launch Enshrouded
echo "$(timestamp) INFO: Starting Enshrouded Dedicated Server"

${STEAM_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/proton run ${ENSHROUDED_PATH}/enshrouded_server.exe &

# Find pid for enshrouded_server.exe
timeout=0
while [ $timeout -lt 11 ]; do
    if ps -e | grep "enshrouded_serv"; then
        enshrouded_pid=$(ps -e | grep "enshrouded_serv" | awk '{print $1}')
        break
    elif [ $timeout -eq 10 ]; then
        echo "$(timestamp) ERROR: Timed out waiting for enshrouded_server.exe to be running"
        exit 1
    fi
    sleep 6
    ((timeout++))
    echo "$(timestamp) INFO: Waiting for enshrouded_server.exe to be running"
done

# I don't love this but I can't use `wait` because it's not a child of our shell
tail --pid=$enshrouded_pid -f /dev/null

# If we lose our pid, exit container
echo "$(timestamp) ERROR: He's dead, Jim"
exit 1
