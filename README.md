# Project Zomboid server - Docker image

Docker version of the Project Zomboid steam server.

## How to use this image
`docker run -d -e SERVER_NAME="pz-server" -e ADMIN_PASSWORD="pz-server-password" -v /My/path/to/My/Config/and/data:/server-data -p 8766:8766/udp -p 16261:16261/udp -p 16262-16272:16262-16272 -p 27015:27015 --name project-zomboid cyrale/project-zomboid`

Once you have run the docker for the first time, you can edit your config file in your mapped directory /server-data/Server/$SERVER_NAME.ini.

## Variables
- __SERVER_NAME__ Name of your server (for db & ini file)
- __ADMIN_PASSWORD__ Admin password on your server
- __PLAYER_PORTS__ Game ports to allow player to contact the server (by default : 10 players)

## Volumes
- __/server-data__ Data directory of the server. Contains db, config files...
- __/server-files__ Application dir of the server. Contains the mods directory.

## Expose
- __8766__ Steam
- __27015__ RCON
- __16261__ Game server (udp)
- __16262-16XXX__ Clients slots

You need to bind X ports for client connection. (Example : If you have 10 slots, you need to put -p 16262-16272:16262-16272, if you have 100 slots, you need to put -p 16262-16362:16262-16362).
