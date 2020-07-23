#!/bin/bash

source /lgsm_functions.sh

fn_check_user
fn_check_lgsm_installed

if [ "${LGSM_GAMESERVER_START}" != "true" ]
then
    exit 0
fi

# Wait for file creation
while [ ! -f /server-data/server-console.txt ]
do
    sleep 1
done

# Display logs
tail -f /server-data/server-console.txt
