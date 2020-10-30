#!/bin/bash

source /lgsm_functions.sh
source /lgsm_variables.sh

fn_configuration_already_set() {
    local var_name="${1}="

    if [[ ( ! -z "${LGSM_COMMON_CONFIG}" && ! -z "$(echo "${LGSM_COMMON_CONFIG}" | grep "${var_name}")" ) \
        || (! -z "${LGSM_COMMON_CONFIG_FILE}" && ! -z "$(grep "${var_name}" "${LGSM_COMMON_CONFIG_FILE}")" ) \
        || ( ! -z "${LGSM_SERVER_CONFIG}" && ! -z "$(echo "${LGSM_SERVER_CONFIG}" | grep "${var_name}")" ) \
        || ( ! -z "${LGSM_SERVER_CONFIG_FILE}" && ! -z "$(grep "${var_name}" "${LGSM_SERVER_CONFIG_FILE}")" ) ]]
    then
        return 1
    fi

    return 0
}

fn_configure_variable () {
    fn_configuration_already_set "${1}"
    local already_set=$?

    if [[ $already_set -eq 0 ]]
    then
        if [ -z "$(grep "${1}" "${server_config_file}")" ]
        then
            echo "${1}=\"${2}\"" >> "${server_config_file}"
        else
            sed -ri "s/^${1}=\"(.*)\"$/${1}=\"${2}\"/" "${server_config_file}"
        fi
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
    ips=($(hostname -I))

    fn_configure_variable "ip" "${ips[0]}"
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
