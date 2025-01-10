#!/bin/bash
#Define Proton version for path. Look at unzipping and extracting to un-numbered directory in the future
GE_PROTON_VERSION=9-22

#Set enshrouded path, independent of Dockerfile
: "${ENSHROUDED_PATH:=/home/steam/enshrouded}"
echo "ENSHROUDED_PATH is set to: $ENSHROUDED_PATH"

# Quick function to generate a timestamp
timestamp() {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

shutdown() {
  echo ""
  echo "$(timestamp) INFO: Received SIGTERM, shutting down gracefully"
  kill -2 $enshrouded_pid
}

# Set trap for SIGTERM
trap 'shutdown' TERM

# Validate environment variables and provide defaults
if [ -z "$SERVER_NAME" ]; then
  SERVER_NAME='Enshrouded Containerized'
  echo "$(timestamp) WARN: SERVER_NAME not set, using default: Enshrouded Containerized"
fi

if [ -z "$SERVER_PASSWORD" ]; then
  echo "$(timestamp) WARN: SERVER_PASSWORD not set, server will be open to the public"
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

# Ensure necessary directories exist
if ! [ -d "$ENSHROUDED_PATH" ]; then
  mkdir -p "$ENSHROUDED_PATH"
  echo "$(timestamp) INFO: Created directory $ENSHROUDED_PATH"
fi

if ! [ -d "$ENSHROUDED_PATH/savegame" ]; then
  mkdir -p "$ENSHROUDED_PATH/savegame"
  echo "$(timestamp) INFO: Created savegame directory $ENSHROUDED_PATH/savegame"
fi

# Install/Update Enshrouded
echo "$(timestamp) INFO: Updating Enshrouded Dedicated Server"
retries=3
while [ $retries -gt 0 ]; do
  ${STEAMCMD_PATH}/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$ENSHROUDED_PATH" +login anonymous +app_update ${STEAM_APP_ID} validate +quit
  if [ $? -eq 0 ]; then
    break
  fi
  ((retries--))
  echo "$(timestamp) WARN: Retrying SteamCMD update... ($retries retries left)"
  sleep 5
done

if [ $retries -eq 0 ]; then
  echo "$(timestamp) ERROR: SteamCMD update failed after multiple attempts."
  exit 1
fi

# Copy example server config if not present
if [ $EXTERNAL_CONFIG -eq 0 ]; then
  if ! [ -f "${ENSHROUDED_PATH}/enshrouded_server.json" ]; then
    echo "$(timestamp) INFO: Enshrouded server config not present, copying example"
    if ! cp /home/steam/enshrouded_server_example.json "${ENSHROUDED_PATH}/enshrouded_server.json"; then
      echo "$(timestamp) ERROR: Failed to copy example server config."
      exit 1
    fi
  fi
fi

# Verify savegame directory permissions
#if ! touch "${ENSHROUDED_PATH}/savegame/test"; then
#  echo ""
#  echo "$(timestamp) ERROR: Incorrect ownership of $ENSHROUDED_PATH/savegame. Server will not save correctly."
#  echo "Run 'chown -R 10000:10000 /your/enshrouded/folder' on the host."
#  echo ""
#  exit 1
#fi
#rm "${ENSHROUDED_PATH}/savegame/test"

# Update server configuration if external config is not enabled
if [ $EXTERNAL_CONFIG -eq 0 ]; then
  echo "$(timestamp) INFO: Updating Enshrouded Server configuration"
  tmpfile=$(mktemp)
  jq --arg n "$SERVER_NAME" '.name = $n' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  if [ -n "$SERVER_PASSWORD" ]; then
    echo "jq --arg p "$SERVER_PASSWORD" '.userGroups[].password = $p' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG"
    jq --arg p "$SERVER_PASSWORD" '.userGroups[].password = $p' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  fi
  jq --arg g "$GAME_PORT" '.gamePort = ($g | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  jq --arg q "$QUERY_PORT" '.queryPort = ($q | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  jq --arg s "$SERVER_SLOTS" '.slotCount = ($s | tonumber)' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  jq --arg i "$SERVER_IP" '.ip = $i' ${ENSHROUDED_CONFIG} > "$tmpfile" && mv "$tmpfile" $ENSHROUDED_CONFIG
  ##Debugging
  echo "$ENSHROUDED_CONFIG"
else
  echo "$(timestamp) INFO: EXTERNAL_CONFIG set to true, skipping configuration update"
fi

# Suppress unnecessary Wine logs
export WINEDEBUG=-all

# Ensure logs directory exists
if ! [ -d "${ENSHROUDED_PATH}/logs" ]; then
  mkdir -p "${ENSHROUDED_PATH}/logs"
fi

# Ensure log file exists
if ! [ -f "${ENSHROUDED_PATH}/logs/enshrouded_server.log" ]; then
  touch "${ENSHROUDED_PATH}/logs/enshrouded_server.log"
fi

# Link logfile to container stdout
ln -sf /proc/1/fd/1 "${ENSHROUDED_PATH}/logs/enshrouded_server.log"

# Start the server
echo "$(timestamp) INFO: Starting Enshrouded Dedicated Server"
echo "${STEAMCMD_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/proton run ${ENSHROUDED_PATH}/enshrouded_server.exe &"
${STEAMCMD_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/proton run ${ENSHROUDED_PATH}/enshrouded_server.exe &

# Monitor the server process
timeout=0
while [ $timeout -lt 11 ]; do
  enshrouded_pid=$(pgrep -f "enshrouded_server.exe")
  if [ -n "$enshrouded_pid" ]; then
    break
  elif [ $timeout -eq 10 ]; then
    echo "$(timestamp) ERROR: Timed out waiting for enshrouded_server.exe to start"
    exit 1
  fi
  sleep 6
  ((timeout++))
  echo "$(timestamp) INFO: Waiting for enshrouded_server.exe to start"
done

# Wait for the server to stop
wait $enshrouded_pid

# Shutdown complete
echo "$(timestamp) INFO: Shutdown complete."
exit 0
