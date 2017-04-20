# Project Zomboid server - Docker image

Docker version of the Project Zomboid steam server.

## How to use this image
`docker run -d -e SERVER_NAME="pz-server" -e ADMIN_PASSWORD="pz-server-password" -v /My/path/to/My/Config/and/data:/home/steam/Zomboid -p 8766:8766/udp -p 16261:16261/udp -p 16262-16272:16262-16272 --name project-zomboid cyrale/project-zomboid`

## Variables
No variables.

## Volumes
No volumes mounted.

## Expose
No ports exposed.
