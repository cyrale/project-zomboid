#!/bin/bash

/home/steam/update-linuxgsm.sh

# Customize server
sed -ri 's/^servicename="pz-server"$/servicename="${SERVER_NAME}"/' /home/steam/linuxgsm/ProjectZomboid/pzserver
sed -ri 's/^adminpassword="CHANGE_ME"$/adminpassword="${ADMIN_PASSWORD}"/' /home/steam/linuxgsm/ProjectZomboid/pzserver

# Update the game with the last version
echo "Update the game to the last version after each start/restart"
/home/steam/linuxgsm/ProjectZomboid/pzserver auto-install

# Start the server with a specific name and admin password
echo "Start the project-zomboid server named ${SERVER_NAME}"
/home/steam/linuxgsm/ProjectZomboid/pzserver start

tail -f /home/steam/Zomboid/server-console.txt
