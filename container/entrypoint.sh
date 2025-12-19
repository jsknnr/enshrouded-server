#!/bin/bash
set -euo pipefail

########################################
# Utility functions
########################################

timestamp() {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

shutdown() {
    echo "$(timestamp) INFO: Received SIGTERM, shutting down gracefully"
    pkill -2 -f '[e]nshrouded_server.exe' || true
}

trap shutdown TERM

########################################
# Defaults / validation
########################################

EXTERNAL_CONFIG="${EXTERNAL_CONFIG:-0}"

if [ "$EXTERNAL_CONFIG" -eq 0 ]; then
    : "${SERVER_NAME:=Enshrouded Containerized}"
    : "${PORT:=15637}"
    : "${SERVER_SLOTS:=16}"
    : "${SERVER_IP:=0.0.0.0}"

    [ -z "${SERVER_PASSWORD:-}" ] && \
        echo "$(timestamp) WARN: SERVER_PASSWORD not set, server will be public"
else
    echo "$(timestamp) INFO: EXTERNAL_CONFIG is set, checking for presence and permmission"
    if [ ! -f "$ENSHROUDED_CONFIG" ]; then
        echo "$(timestamp) ERROR: EXTERNAL_CONFIG set but config not found at $ENSHROUDED_CONFIG"
        exit 1
    fi
    if [ "$(stat -c '%u:%g' "$ENSHROUDED_CONFIG")" != "10000:10000" ]; then
        echo "$(timestamp) ERROR: External config ownership must be 10000:10000"
        echo "$(timestamp) INFO: Current ownership is $(stat -c '%u:%g' "$ENSHROUDED_CONFIG")"
        echo "$(timestamp) INFO: Adjust ownership and restart the container (e.g. sudo chown 10000:10000 /path/to/your/enshrouded_server.json)"
        exit 1
    fi
fi

########################################
# SteamCMD update
########################################

# Fix potential bad steam update state
rm -f "$ENSHROUDED_PATH"/steamapps/appmanifest_*.acf >/dev/null 2>&1 || true

echo "$(timestamp) INFO: Updating Enshrouded Dedicated Server"
if ! "${STEAMCMD_PATH}/steamcmd.sh" \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir "$ENSHROUDED_PATH" \
    +login anonymous \
    +app_update "$STEAM_APP_ID" validate \
    +quit; then
    echo "$(timestamp) ERROR: steamcmd update failed"
    exit 1
fi

########################################
# Config handling
########################################

if [ "$EXTERNAL_CONFIG" -eq 0 ]; then
    if [ ! -f "$ENSHROUDED_CONFIG" ]; then
        echo "$(timestamp) INFO: Server config not present, copying example"
        cp /home/steam/enshrouded_server_example.json "$ENSHROUDED_CONFIG"
    fi

    echo "$(timestamp) INFO: Updating Enshrouded Server configuration"

    tmpfile=$(mktemp)
    jq \
      --arg n "$SERVER_NAME" \
      --arg p "${SERVER_PASSWORD:-}" \
      --arg q "$PORT" \
      --arg s "$SERVER_SLOTS" \
      --arg i "$SERVER_IP" \
      '
      .name = $n
      | .queryPort = ($q|tonumber)
      | .slotCount = ($s|tonumber)
      | .ip = $i
      | (if $p != "" then .userGroups[]?.password = $p else . end)
      ' "$ENSHROUDED_CONFIG" > "$tmpfile" \
      && mv "$tmpfile" "$ENSHROUDED_CONFIG"
fi

########################################
# Savegame & logs
########################################

mkdir -p "$ENSHROUDED_PATH/savegame" "$ENSHROUDED_PATH/logs"

if ! touch "$ENSHROUDED_PATH/savegame/.permtest"; then
    echo "$(timestamp) ERROR: Savegame directory is not writable"
    exit 1
fi
rm -f "$ENSHROUDED_PATH/savegame/.permtest"

: > "$ENSHROUDED_PATH/logs/enshrouded_server.log"
ln -sf /proc/1/fd/1 "$ENSHROUDED_PATH/logs/enshrouded_server.log"

########################################
# Launch server
########################################

export WINEDEBUG=-all

echo "$(timestamp) INFO: Starting Enshrouded Dedicated Server"

"${STEAMCMD_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/proton" \
    run "$ENSHROUDED_PATH/enshrouded_server.exe" &

# Wait for process to start
for i in {1..10}; do
    if pgrep -f enshrouded_server.exe >/dev/null; then
        break
    fi
    sleep 6
    echo "$(timestamp) INFO: Waiting for enshrouded_server.exe"
    if [ "$i" -eq 10 ]; then
        echo "$(timestamp) ERROR: Timed out waiting for server to start"
        exit 1
    fi
done

# Hold us open until we recieve a SIGTERM
while pgrep -f '[e]nshrouded_server.exe' >/dev/null; do
    sleep 10
done

exit 0
