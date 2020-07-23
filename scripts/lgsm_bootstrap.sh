#!/bin/bash

source /lgsm_functions.sh

fn_check_user

export LGSM_GAMESERVER_RENAME="$(fn_sanitize_string "${SERVER_NAME}")"
export LGSM_GAMESERVER_START="${SERVER_START:-true}"

ls -alh /home/linuxgsm
[ ! -L /server-data ] && echo "true" || echo "false"
echo $(readlink -fn /server-data)
[ ! -w $(readlink -fn /server-data) ] && echo "true" || echo "false"
[ ! -w /home/linuxgsm/Zomboid ] && echo "true" || echo "false"

# Check if both directory are writable
if [ ! -L /server-data ] || [ ! -w $(readlink -fn /server-data) ]
then
    echo "[Error] Can't access your data directory. Check permissions on your mapped directory with /server-data."
    exit 1
fi

if [ ! -L /server-files ] || [ ! -w $(readlink -fn /server-files) ]
then
    echo "[Error] Can't access your server files directory. Check permissions on your mapped directory with /server-files."
    exit 1
fi
