FROM ghcr.io/cyrale/linuxgsm:0.2.1

# Steam ports
ENV STEAM_PORT_1=8766  \
    STEAM_PORT_2=8767 \
    # RCON
    RCON_PORT=27015 \
    RCON_PASSWORD="rcon-password" \
    # Server informations
    SERVER_NAME="pzserver" \
    SERVER_PASSWORD="" \
    SERVER_PUBLIC_NAME="Project Zomboid Server" \
    SERVER_PUBLIC_DESC="" \
    SERVER_BRANCH="" \
    SERVER_BETA_PASSWORD="" \
    # Admin DB Password (required for the first launch)
    ADMIN_PASSWORD="pzserver-password" \
    # Server port
    SERVER_PORT=16261 \
    # Game UDP port to allow player to contact the server (by default : 10 players)
    PLAYER_PORTS=16262-16272

# Switch to root to use apt-get
USER root

# Install dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        rng-tools && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Create server directories and link to access them
RUN [ -d /home/linuxgsm/Zomboid ] || mkdir -p /home/linuxgsm/Zomboid && \
    chown linuxgsm:linuxgsm /home/linuxgsm/Zomboid && \
    ln -s /home/linuxgsm/Zomboid /server-data && \
    [ -d /home/linuxgsm/serverfiles ] || mkdir -p /home/linuxgsm/serverfiles && \
    chown linuxgsm:linuxgsm /home/linuxgsm/serverfiles && \
    ln -s /home/linuxgsm/serverfiles /server-files

# Copy scripts
COPY ./scripts/*.sh /
RUN chmod +x /*.sh

# Switch to the user steam
USER linuxgsm

# Make server port available to host : (10 slots)
EXPOSE ${STEAM_PORT_1}/udp ${STEAM_PORT_2}/udp ${SERVER_PORT}/udp ${PLAYER_PORTS} ${RCON_PORT}

# Persistant folder with server data : /server-data
VOLUME ["/server-data", "/server-files"]
