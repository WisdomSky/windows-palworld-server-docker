FROM --platform=linux/amd64 cm2network/steamcmd:root

LABEL Author="NewittAll - https://github.com/NewittAll"
LABEL Version="1.0"
LABEL Description="A modded PalWorld server using Proton based on peeopturtle's upload https://github.com/peepoturtle/palworld-docker-proton-server"

# Install required programs
RUN apt-get update && apt-get install -y procps xdg-user-dirs wget unzip sed python3 libfreetype6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install supercronic 
RUN wget https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 \
    && echo "71b0d58cc53f6bd72cf2f293e09e294b79c666d8  supercronic-linux-amd64" | sha1sum -c - \
    && chmod +x supercronic-linux-amd64 \
    && mv supercronic-linux-amd64 "/usr/local/bin/supercronic-linux-amd64" \
    && ln -s "/usr/local/bin/supercronic-linux-amd64" /usr/local/bin/supercronic

# Install RCON
RUN wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz \
    && echo "8601c70dcab2f90cd842c127f700e398 rcon-0.10.3-amd64_linux.tar.gz" | md5sum -c - \
    && tar xfz rcon-0.10.3-amd64_linux.tar.gz \
    && chmod +x "rcon-0.10.3-amd64_linux/rcon" \
    && mv "rcon-0.10.3-amd64_linux/rcon" "/usr/local/bin/rcon" \
    && ln -s "/usr/local/bin/rcon" /usr/local/bin/rconcli \
    && rm -Rf rcon-0.10.3-amd64_linux rcon-0.10.3-amd64_linux.tar.gz

WORKDIR /home/steam/.steam/steam
# Install Proton
RUN mkdir -p compatibilitytools.d/
RUN wget -O - https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-23/GE-Proton9-23.tar.gz \
    | tar -xz -C compatibilitytools.d/
RUN mkdir -p steamapps/compatdata/2394010 
RUN cp -r compatibilitytools.d/GE-Proton9-23/files/share/default_pfx steamapps/compatdata/2394010
RUN chown -R steam:steam /home/steam


# Setup directories
RUN mkdir -p /scripts /mods /palworld/backups \
    && chown -R steam:steam /palworld

ENV STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/${USER}/.steam/steam" \
    STEAM_COMPAT_DATA_PATH=/home/steam/.steam/steam/steamapps/compatdata/2394010 \
    PROTON=/home/steam/.steam/steam/compatibilitytools.d/GE-Proton9-23/proton \
    STEAMCMD=/home/steam/steamcmd/steamcmd.sh \
    PUID=1000 \
    PGID=1000
VOLUME ["/palworld"]
USER steam
EXPOSE 8211/udp 25575/tcp

# Copy files over
COPY --chown=steam:steam --chmod=755 ./scripts/*.sh /scripts
COPY --chown=steam:steam --chmod=755 /init.sh /
ADD --chown=steam:steam --chmod=440 rcon.yaml /home/steam/steamcmd/rcon.yaml
ADD --chown=steam:steam mods /mods

ENTRYPOINT ["/scripts/start.sh"]
