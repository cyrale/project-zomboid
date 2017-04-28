#!/bin/bash

SERVER_SCRIPT="/home/steam/linuxgsm/ProjectZomboid/pzserver"
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

/home/steam/update-linuxgsm.sh

# Customize server
if [ -f $SERVER_SCRIPT ]
then
    sed -ri "s/^servicename=\"(.*)\"$/servicename=\"${SERVER_NAME}\"/" $SERVER_SCRIPT
    sed -ri "s/^adminpassword=\"(.*)\"$/adminpassword=\"${ADMIN_PASSWORD}\"/" $SERVER_SCRIPT
fi

# Update the game with the last version
echo "Update the game to the last version after each start/restart"
$SERVER_SCRIPT auto-install

# Customize current server
if [ -f $SERVER_INI ]
then
    sed -ri "s/^SteamPort1=([0-9]+)$/SteamPort1=${STEAM_PORT_1}/" $SERVER_INI
    sed -ri "s/^SteamPort2=([0-9]+)$/SteamPort2=${STEAM_PORT_2}/" $SERVER_INI
    sed -ri "s/^RCONPort=([0-9]+)$/RCONPort=${RCON_PORT}/" $SERVER_INI
    sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${RCON_PASSWORD}/" $SERVER_INI
    sed -ri "s/^DefaultPort=([0-9]+)$/DefaultPort=${SERVER_PORT}/" $SERVER_INI
fi

# Start the server with a specific name and admin password
echo "Start the project-zomboid server named ${SERVER_NAME}"
$SERVER_SCRIPT start

tail -f /server-data/server-console.txt
