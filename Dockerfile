FROM cyrale/linuxgsm

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

## Environment variables
# Steam ports
ENV STEAM_PORT_1 8766
ENV STEAM_PORT_2 8767
# RCON
ENV RCON_PORT 27015
ENV RCON_PASSWORD "rcon-password"
# Server Name
ENV SERVER_NAME "pz-server"
# Admin DB Password (required for the first launch)
ENV ADMIN_PASSWORD "pz-server-password"
# Server port
ENV SERVER_PORT 16261
# Game UDP port to allow player to contact the server (by default : 10 players)
ENV PLAYER_PORTS 16262-16272

# Switch to root to use apt-get
USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        default-jre && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Select the script as entry point
COPY ./start-server.sh /home/steam/
RUN mkdir -p /home/steam/Zomboid && \
    chown steam:steam /home/steam/Zomboid && \
    ln -s /home/steam/Zomboid /server-data && \
    chown steam:steam /server-data && \
    mkdir -p /home/steam/linuxgsm/ProjectZomboid/serverfiles && \
    chown steam:steam /home/steam/linuxgsm/ProjectZomboid/serverfiles && \
    ln -s /home/steam/linuxgsm/ProjectZomboid/serverfiles /server-files && \
    chown steam:steam /server-files && \
    chmod u+x /home/steam/start-server.sh && \
    chown steam:steam /home/steam/start-server.sh && \
    chmod u+x /home/steam/linuxgsm/ProjectZomboid/pzserver && \
    chown steam:steam /home/steam/linuxgsm/ProjectZomboid/pzserver

# Switch to the user steam
USER steam

# Make server port available to host : (10 slots)
EXPOSE ${STEAM_PORT_1}/udp ${STEAM_PORT_2}/udp ${SERVER_PORT}/udp ${PLAYER_PORTS} ${RCON_PORT}

# Persistant folder with server data : /server-data
VOLUME ["/server-data", "/server-files"]

ENTRYPOINT ["/home/steam/start-server.sh"]
