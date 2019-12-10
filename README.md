# Project Zomboid server - Docker image

Docker version of the Project Zomboid steam server.

## How to use this image

### Before starting

Create two directories where you want to run your server :
- `server-data`: mandatory if you want to keep configuration between each restart
- `server-files`: optional, only necessary if you want to install mods
Adjust the permissions of this two directories. It could be done with this commands:

```bash
chown 1000:1000 server-data
chown 1000:1000 server-files
```

`1000:1000` represent the user and the group of the steam user that run server in the image.

### Docker command

```bash
docker run -d -e SERVER_NAME="pz-server" \
              -e ADMIN_PASSWORD="pz-server-password" \
              -v $(pwd)/server-data:/server-data \
              -p 8766:8766/udp \
              -p 8767:8767/udp \
              -p 16261:16261/udp \
              -p 16262-16272:16262-16272 \
              -p 27015:27015 \
              --name project-zomboid \
              cyrale/project-zomboid
```

### Docker Compose

Alternatively, you could use Docker Compose with this `docker-compose.yml` file:

```yaml
version: "3.0"

services:
  project-zomboid:
    image: cyrale/project-zomboid
    restart: unless-stopped
    environment:
      SERVER_NAME: "pz-server"
      ADMIN_PASSWORD: "pz-server-password"
    ports:
      - "8766:8766/udp"
      - "8767:8767/udp"
      - "16261:16261/udp"
      - "16262-16272:16262-16272"
      - "27015:27015"
    volumes:
      - ./server-data:/server-data
```

After creating this file, launch the server with `docker-compose up`.

### After starting

Once you have run the docker for the first time, you can edit your config file in your mapped directory `/server-data/Server/$SERVER_NAME.ini`. When it's done, restart your server.

Some of options are not used in these two examples. Look below if you want to adjust your settings.

## Variables

- __STEAM_PORT_1__ Steam port 1 (default: 8766)
- __STEAM_PORT_2__ Steam port 2 (default: 8767)
- __RCON_PORT__ RCON port (default: 27015)
- __RCON_PASSWORD__ RCON password
- __SERVER_NAME__ Name of your server (for db & ini file). __Warning:__ don't use special characters or spaces.
- __SERVER_PASSWORD__ Password of your server used to connect to it
- __SERVER_PUBLIC_NAME__ Public name of your server
- __SERVER_PUBLIC_DESC__ Public description of your server
- __ADMIN_PASSWORD__ Admin password on your server
- __SERVER_PORT__ Game server port
- __PLAYER_PORTS__ Game ports to allow player to contact the server (by default : 10 players)

## Volumes

- __/server-data__ Data directory of the server. Contains db, config files...
- __/server-files__ Application dir of the server. Contains the mods directory.

## Expose

- __8766__ Steam port 1 (udp)
- __8767__ Steam port 2 (udp)
- __27015__ RCON
- __16261__ Game server (udp)
- __16262-16XXX__ Clients slots

You need to bind X ports for client connection. (Example : If you have 10 slots, you need to put `-p 16262-16272:16262-16272`, if you have 100 slots, you need to put `-p 16262-16362:16262-16362`).
