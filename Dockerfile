FROM debian:buster-slim
MAINTAINER github.com/Luminaire1337
ENV TERM xterm-256color

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    libreadline5 \
    libncursesw5 \
    unzip \
    wget

WORKDIR /src

RUN mkdir -p tmp \
    && cd tmp \
    && wget http://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz \
    && tar -xf multitheftauto_linux_x64.tar.gz \
    && rm -rf multitheftauto_linux_x64.tar.gz \ 
    && wget http://linux.mtasa.com/dl/baseconfig.tar.gz \
    && tar -xf baseconfig.tar.gz \
    && rm -rf baseconfig.tar.gz \
    && mv baseconfig/* multitheftauto_linux_x64/mods/deathmatch \
    && rm -rf baseconfig \
    && mkdir -p multitheftauto_linux_x64/mods/deathmatch/resources \
    && cd multitheftauto_linux_x64/mods/deathmatch/resources \
    && wget http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip \
    && unzip mtasa-resources-latest.zip \
    && rm -rf mtasa-resources-latest.zip \
    && cd /src \
    && mv -v tmp/multitheftauto_linux_x64/* . \
    && rm -rf tmp

VOLUME /src/mods
VOLUME /src/modules

EXPOSE 22003/udp 22005/tcp 22126/udp
CMD ./mta-server64