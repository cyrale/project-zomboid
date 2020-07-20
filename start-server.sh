#!/bin/bash

ORIGINAL_SERVER_NAME="pzserver"
ORIGINAL_SERVER_SCRIPT="/home/linuxgsm/${ORIGINAL_SERVER_NAME}"
ORIGINAL_SERVER_CFG="/home/linuxgsm/lgsm/config-lgsm/pzserver/${ORIGINAL_SERVER_NAME}.cfg"
ORIGINAL_SERVER_INI="/home/linuxgsm/lgsm/config-default/config-game/server.ini"

SERVER_SCRIPT="/home/linuxgsm/${SERVER_NAME}"
SERVER_CFG="/home/linuxgsm/lgsm/config-lgsm/pzserver/${SERVER_NAME}.cfg"
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

# Install the server
if [ ! -f /home/linuxgsm/.server-installed ]
then
    echo "Install the server..."
    $ORIGINAL_SERVER_SCRIPT auto-install
    touch /home/linuxgsm/.server-installed
fi

# Update the server with the last version
echo "Update the server to the last version after each start/restart..."
if [ "${UPDATE_LGSM_AT_RESTART}" == "true" ]
then
    $ORIGINAL_SERVER_SCRIPT update-lgsm
fi
$ORIGINAL_SERVER_SCRIPT update

# Copy original config files
if [ "${ORIGINAL_SERVER_SCRIPT}" != "${SERVER_SCRIPT}" ]
then 
    cp "${ORIGINAL_SERVER_SCRIPT}" "${SERVER_SCRIPT}"

    if [ ! -f $SERVER_CFG ]
    then
        cp -f "${ORIGINAL_SERVER_CFG}" "${SERVER_CFG}"
    fi
fi

# Set admin password
if [ -f $SERVER_CFG ]
then
    if [ -z "$(grep "adminpassword" "${SERVER_CFG}")" ]
    then
        echo "" >> "${SERVER_CFG}"
        echo "adminpassword=\"${ADMIN_PASSWORD}\"" >> "${SERVER_CFG}"
    else
        sed -ri "s/^adminpassword=\"(.*)\"$/adminpassword=\"${ADMIN_PASSWORD}\"/" "${SERVER_CFG}"
    fi
fi

# Customize current server
if [ ! -f $SERVER_INI ]
then
    cp -f ${ORIGINAL_SERVER_INI} ${SERVER_INI}
fi

if [ -f $SERVER_INI ]
then
    sed -ri "s/^Password=(.*)$/Password=${SERVER_PASSWORD}/" "${SERVER_INI}"
    sed -ri "s/^PublicName=(.*)$/PublicName=${SERVER_PUBLIC_NAME}/" "${SERVER_INI}"
    sed -ri "s/^PublicDescription=(.*)$/PublicDescription=${SERVER_PUBLIC_DESC}/" "${SERVER_INI}"

    sed -ri "s/^DefaultPort=([0-9]+)$/DefaultPort=${SERVER_PORT}/" "${SERVER_INI}"
    sed -ri "s/^SteamPort1=([0-9]+)$/SteamPort1=${STEAM_PORT_1}/" "${SERVER_INI}"
    sed -ri "s/^SteamPort2=([0-9]+)$/SteamPort2=${STEAM_PORT_2}/" "${SERVER_INI}"
    sed -ri "s/^RCONPort=([0-9]+)$/RCONPort=${RCON_PORT}/" "${SERVER_INI}"
    sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${RCON_PASSWORD}/" "${SERVER_INI}"
fi

# Start the server with a specific name and admin password
echo "Start the project-zomboid server named ${SERVER_NAME}"
$SERVER_SCRIPT start

# Wait for file creation
while [ ! -f /server-data/server-console.txt ]
do
    sleep 1
done

# Display logs
tail -f /server-data/server-console.txt
