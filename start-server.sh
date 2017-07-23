#!/bin/bash

ORIGINAL_SERVER_SCRIPT="/home/steam/ProjectZomboid/pzserver"
ORIGINAL_SERVER_CFG="/home/steam/ProjectZomboid/lgsm/config-lgsm/pzserver/pzserver.cfg"
ORIGINAL_SERVER_INI="/home/steam/ProjectZomboid/lgsm/config-default/config-game/server.ini"

SERVER_SCRIPT="/home/steam/ProjectZomboid/${SERVER_NAME}"
SERVER_CFG="/home/steam/ProjectZomboid/lgsm/config-lgsm/pzserver/${SERVER_NAME}.cfg"
SERVER_INI="/server-data/Server/${SERVER_NAME}.ini"

# Check if both directory are writable
if [ ! -w /server-data ]
then
	echo "[Error] Can't access your data directory. Check permissions on your mapped directory with /server-data."
	exit 1
fi

if [ ! -w /server-files ]
then
	echo "[Error] Can't access your server files directory. Check permissions on your mapped directory with /server-files."
	exit 1
fi

# Update the game with the last version
echo "Update the game to the last version after each start/restart"
$ORIGINAL_SERVER_SCRIPT update-lgsm
$ORIGINAL_SERVER_SCRIPT update

# Customize server
cp "${ORIGINAL_SERVER_SCRIPT}" "${SERVER_SCRIPT}"
if [ ! -f $SERVER_CFG ]
then
    cp "${ORIGINAL_SERVER_CFG}" "${SERVER_CFG}"

    if [ -z "$(grep "adminpassword" "${SERVER_CFG}")" ]
    then
        echo "ADD PASSWORD"
        echo "" >> "${SERVER_CFG}"
        echo "adminpassword=\"${ADMIN_PASSWORD}\"" >> "${SERVER_CFG}"
    else
        echo "CHANGE PASSWORD"
        sed -ri "s/^adminpassword=\"(.*)\"$/adminpassword=\"${ADMIN_PASSWORD}\"/" "${SERVER_CFG}"
    fi
fi

# Customize current server
if [ ! -f $SERVER_INI ]
then
    cp ${ORIGINAL_SERVER_INI} ${SERVER_INI}

    sed -ri "s/^SteamPort1=([0-9]+)$/SteamPort1=${STEAM_PORT_1}/" "${SERVER_INI}"
    sed -ri "s/^SteamPort2=([0-9]+)$/SteamPort2=${STEAM_PORT_2}/" "${SERVER_INI}"
    sed -ri "s/^RCONPort=([0-9]+)$/RCONPort=${RCON_PORT}/" "${SERVER_INI}"
    sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${RCON_PASSWORD}/" "${SERVER_INI}"
    sed -ri "s/^DefaultPort=([0-9]+)$/DefaultPort=${SERVER_PORT}/" "${SERVER_INI}"
fi

# Start the server with a specific name and admin password
echo "Start the project-zomboid server named ${SERVER_NAME}"
$SERVER_SCRIPT start

tail -f /server-data/server-console.txt
