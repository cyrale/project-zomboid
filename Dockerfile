FROM cyrale/linuxgsm:0.1

## Environment variables
ENV LGSM_UPDATE "true"
# Steam ports
ENV STEAM_PORT_1 8766
ENV STEAM_PORT_2 8767
# RCON
ENV RCON_PORT 27015
ENV RCON_PASSWORD "rcon-password"
# Server informations
ENV SERVER_NAME "pzserver"
ENV SERVER_PASSWORD ""
ENV SERVER_PUBLIC_NAME "Project Zomboid Server"
ENV SERVER_PUBLIC_DESC ""
ENV SERVER_BRANCH ""
ENV SERVER_BETA_PASSWORD ""
# Admin DB Password (required for the first launch)
ENV ADMIN_PASSWORD "pzserver-password"
# Server port
ENV SERVER_PORT 16261
# Game UDP port to allow player to contact the server (by default : 10 players)
ENV PLAYER_PORTS 16262-16272

# Switch to root to use apt-get
USER root

WORKDIR /

# Install dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        rng-tools && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Copy entrypoint
COPY start-server.sh /home/linuxgsm/start-server.sh
RUN chown linuxgsm:linuxgsm /home/linuxgsm/start-server.sh && \
    chmod +x /home/linuxgsm/start-server.sh   

# Create server directories and link to access them
RUN [ -d /home/linuxgsm/Zomboid ] || mkdir -p /home/linuxgsm/Zomboid && \
    chown linuxgsm:linuxgsm /home/linuxgsm/Zomboid && \
    ln -s /home/linuxgsm/Zomboid /server-data && \
    [ -d /home/linuxgsm/serverfiles ] || mkdir -p /home/linuxgsm/serverfiles && \
    chown linuxgsm:linuxgsm /home/linuxgsm/serverfiles && \
    ln -s /home/linuxgsm/serverfiles /server-files

# Switch to the user steam
USER linuxgsm

# Install PZ server
WORKDIR /home/linuxgsm
RUN ./linuxgsm.sh pzserver

# Make server port available to host : (10 slots)
EXPOSE ${STEAM_PORT_1}/udp ${STEAM_PORT_2}/udp ${SERVER_PORT}/udp ${PLAYER_PORTS} ${RCON_PORT}

# Persistant folder with server data : /server-data
VOLUME ["/server-data", "/server-files"]

entrypoint ["./start-server.sh"]
