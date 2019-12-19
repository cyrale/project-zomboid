FROM ubuntu:18.04

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
# Server informations
ENV SERVER_NAME "pz-server"
ENV SERVER_PASSWORD ""
ENV SERVER_PUBLIC_NAME "Project Zomboid Server"
ENV SERVER_PUBLIC_DESC ""
# Admin DB Password (required for the first launch)
ENV ADMIN_PASSWORD "pz-server-password"
# Server port
ENV SERVER_PORT 16261
# Game UDP port to allow player to contact the server (by default : 10 players)
ENV PLAYER_PORTS 16262-16272

# Switch to root to use apt-get
USER root

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        bc \
        binutils \
        bsdmainutils \
        bzip2 \
        ca-certificates \
        curl \
        default-jre \
        file \
        git \
        gzip \
        iproute2 \
        jq \
        lib32gcc1 \
        lib32ncurses5 \
        lib32z1 \
        libc6 \
        libstdc++6 \
        libstdc++6:i386 \
        locales \
        mailutils \
        postfix \
        python3 \
        tmux \
        util-linux \
        unzip \
        wget && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Set the locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --gecos "" \
    --shell /bin/bash \
    steam && \
    usermod -G tty steam

COPY ./start-server.sh /home/steam/

RUN [ -d /home/steam/ProjectZomboid ] || mkdir -p /home/steam/ProjectZomboid && \
    [ -d /home/steam/Zomboid ] || mkdir -p /home/steam/Zomboid && \
    [ -d /home/steam/ProjectZomboid/serverfiles ] || mkdir -p /home/steam/ProjectZomboid/serverfiles && \
    chown -R steam:steam /home/steam && \
    ln -s /home/steam/Zomboid /server-data && \
    chown steam:steam /server-data && \
    ln -s /home/steam/ProjectZomboid/serverfiles /server-files && \
    chown steam:steam /server-files && \
    chmod u+x /home/steam/start-server.sh && \
    chown steam:steam /home/steam/start-server.sh

# Switch to the user steam
USER steam

RUN cd /home/steam/ProjectZomboid/ && \
    wget -N --quiet --no-check-certificate https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/linuxgsm.sh && \
    chmod u+x /home/steam/ProjectZomboid/linuxgsm.sh && \
    bash linuxgsm.sh pzserver && \
    chmod u+x /home/steam/ProjectZomboid/pzserver && \
    /home/steam/ProjectZomboid/pzserver auto-install

# Make server port available to host : (10 slots)
EXPOSE ${STEAM_PORT_1}/udp ${STEAM_PORT_2}/udp ${SERVER_PORT}/udp ${PLAYER_PORTS} ${RCON_PORT}

# Persistant folder with server data : /server-data
VOLUME ["/server-data", "/server-files"]

ENTRYPOINT ["/home/steam/start-server.sh"]
