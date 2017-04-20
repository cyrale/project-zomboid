FROM cyrale/linuxgsm

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

## Environment variables
# Server Name
ENV SERVER_NAME "pz-server"
# Admin DB Password (required for the first launch)
ENV ADMIN_PASSWORD "pz-server-password"
# Game UDP port to allow player to contact the server (by default : 10 player)
ENV UDP_PLAYER_PORTS 16262-16272

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
COPY ./entrypoint-project-zomboid.sh /home/steam/
RUN mkdir -p /home/steam/Zomboid && \
    chown steam:steam /home/steam/Zomboid && \
    chmod u+x /home/steam/entrypoint-project-zomboid.sh && \
    chown steam:steam /home/steam/entrypoint-project-zomboid.sh && \
    chmod u+x /home/steam/linuxgsm/ProjectZomboid/pzserver && \
    chown steam:steam /home/steam/linuxgsm/ProjectZomboid/pzserver

# Switch to the user steam
USER steam

# Make server port available to host : (10 slots)
EXPOSE 16261/udp ${UDP_PLAYER_PORTS}/udp

# Persistant folder with server data : /home/steam/Zomboid
VOLUME ["/home/steam/Zomboid"]

ENTRYPOINT ["/home/steam/entrypoint-project-zomboid.sh"]
