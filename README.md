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
docker run -d -e SERVER_NAME="pzserver" \
              -e ADMIN_PASSWORD="pzserver-password" \
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
      SERVER_NAME: "pzserver"
      ADMIN_PASSWORD: "pzserver-password"
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

- **LGSM_UPDATE** Enable automatic update of LinuxGSM\_ at restart (default: true)
- **STEAM_PORT_1** Steam port 1 (default: 8766)
- **STEAM_PORT_2** Steam port 2 (default: 8767)
- **RCON_PORT** RCON port (default: 27015)
- **RCON_PASSWORD** RCON password
- **SERVER_NAME** Name of your server (for db & ini file). **Warning:** don't use special characters or spaces.
- **SERVER_PASSWORD** Password of your server used to connect to it
- **SERVER_PUBLIC_NAME** Public name of your server
- **SERVER_PUBLIC_DESC** Public description of your server
- **SERVER_BRANCH** Name of the beta branch
- **SERVER_BETA_PASSWORD** Password for the beta branch
- **ADMIN_PASSWORD** Admin password on your server
- **SERVER_PORT** Game server port
- **PLAYER_PORTS** Game ports to allow player to contact the server (by default : 10 players)

## Volumes

- **/server-data** Data directory of the server. Contains db, config files...
- **/server-files** Application dir of the server. Contains the mods directory.

## Expose

- **8766** Steam port 1 (udp)
- **8767** Steam port 2 (udp)
- **27015** RCON
- **16261** Game server (udp)
- **16262-16XXX** Clients slots

You need to bind X ports for client connection. (Example : If you have 10 slots, you need to put `-p 16262-16272:16262-16272`, if you have 100 slots, you need to put `-p 16262-16362:16262-16362`).
