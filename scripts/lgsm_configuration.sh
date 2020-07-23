#!/bin/bash

source /lgsm_functions.sh
source /lgsm_variables.sh

fn_configure_variable () {
    if [ -z "$(grep "${1}" "${server_config_file}")" ]
    then
        echo "${1}=\"${2}\"" >> "${server_config_file}"
    else
        sed -ri "s/^${1}=\"(.*)\"$/${1}=\"${2}\"/" "${server_config_file}"
    fi
}

fn_check_user
fn_check_lgsm_installed

cd "${HOME}"

server_ini_file="/home/linuxgsm/Zomboid/Server/${LGSM_GAMESERVER}.ini"

if [ ! -z "${LGSM_GAMESERVER_RENAME}" ]
then
    server_ini_file="/home/linuxgsm/Zomboid/Server/${LGSM_GAMESERVER_RENAME}.ini"
fi

# Change LGSM configuration
if [ -f $server_config_file ]
then
    fn_configure_variable "adminpassword" $ADMIN_PASSWORD
    fn_configure_variable "branch" $SERVER_BRANCH
    fn_configure_variable "betapassword" $SERVER_BETA_PASSWORD
fi

# Change server configuration
if [ -f $server_ini_file ]
then
    sed -ri "s/^Password=(.*)$/Password=${SERVER_PASSWORD}/" "${server_ini_file}"
    sed -ri "s/^PublicName=(.*)$/PublicName=${SERVER_PUBLIC_NAME}/" "${server_ini_file}"
    sed -ri "s/^PublicDescription=(.*)$/PublicDescription=${SERVER_PUBLIC_DESC}/" "${server_ini_file}"

    sed -ri "s/^DefaultPort=([0-9]+)$/DefaultPort=${SERVER_PORT}/" "${server_ini_file}"
    sed -ri "s/^SteamPort1=([0-9]+)$/SteamPort1=${STEAM_PORT_1}/" "${server_ini_file}"
    sed -ri "s/^SteamPort2=([0-9]+)$/SteamPort2=${STEAM_PORT_2}/" "${server_ini_file}"
    sed -ri "s/^RCONPort=([0-9]+)$/RCONPort=${RCON_PORT}/" "${server_ini_file}"
    sed -ri "s/^RCONPassword=(.*)$/RCONPassword=${RCON_PASSWORD}/" "${server_ini_file}"
fi
