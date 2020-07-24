#!/bin/bash

source /lgsm_functions.sh
source /lgsm_variables.sh

fn_check_user
fn_check_lgsm_installed

log_dir="${HOME}/log"
log_file="${log_dir}/console/${LGSM_GAMESERVER}-console.log"

if [ ! -z "${LGSM_GAMESERVER_RENAME}" ]
then
    log_file="${log_dir}/console/${LGSM_GAMESERVER_RENAME}-console.log"
fi


if [ "${LGSM_GAMESERVER_START}" != "true" ]
then
    exit 0
fi

# Wait for file creation
while [ ! -f "${log_file}" ]
do
    sleep 1
done

# Display logs
tail -f "${log_file}"
