#!/bin/bash

sanitize_string() {
    local sanitized="$1"

    # First, replace spaces with dashes
    sanitized=${sanitized// /-/}
    # Now, replace anything that's not alphanumeric, an underscore or a dash
    sanitized=${sanitized//[^a-zA-Z0-9_-]/-/}
    # Finally, lowercase with TR
    sanitized=`echo -n $sanitized | tr A-Z a-z`

    return sanitized
}

configure_variable () {
    if [ -z "$(grep "$1" "${SERVER_CFG}")" ]
    then
        echo "$1=\"$2\"" >> "${SERVER_CFG}"
    else
        sed -ri "s/^$1=\"(.*)\"$/$1=\"$2\"/" "${SERVER_CFG}"
    fi
}

ORIGINAL_SERVER_SCRIPT="/home/linuxgsm/pzserver"

SERVER_NAME=`sanitize_string ${SERVER_NAME}`
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

if [ "${ORIGINAL_SERVER_SCRIPT}" != "${SERVER_SCRIPT}" ] && [ ! -f ${SERVER_SCRIPT} ]
then 
    cp "${ORIGINAL_SERVER_SCRIPT}" "${SERVER_SCRIPT}"
fi

# Install the server
if [ ! -f /home/linuxgsm/.${SERVER_NAME}-installed ]
then
    echo "Install the server..."
    $SERVER_SCRIPT auto-install
    touch /home/linuxgsm/.${SERVER_NAME}-installed
fi

# Change LGSM configuration
if [ -f $SERVER_CFG ]
then
    configure_variable "adminpassword" $ADMIN_PASSWORD
    configure_variable "branch" $SERVER_BRANCH
    configure_variable "betapassword" $SERVER_BETA_PASSWORD
fi

# Change server configuration
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

# Update the server with the latest version
echo "Update the server to the lastest version after each start/restart..."
if [ "${LGSM_UPDATE}" == "true" ]
then
    $SERVER_SCRIPT update-lgsm
fi
$SERVER_SCRIPT update

# Start the server with a specific name and admin password
echo "Start the project-zomboid server named ${SERVER_NAME}..."
$SERVER_SCRIPT start

# Wait for file creation
while [ ! -f /server-data/server-console.txt ]
do
    sleep 1
done

# Display logs
tail -f /server-data/server-console.txt
