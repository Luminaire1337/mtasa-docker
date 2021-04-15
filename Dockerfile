FROM debian:buster-slim
MAINTAINER github.com/Luminaire1337
ENV TERM xterm-256color
EXPOSE 22003/udp 22005/tcp 22126/udp

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    libreadline5 \
    libncursesw5 \
    unzip \
    wget

WORKDIR /src

RUN wget http://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz -O /tmp/mtasa.tar.gz \
    && tar -xzf /tmp/mtasa.tar.gz \
    && rm -rf /tmp/mtasa.tar.gz

VOLUME /src/shared-config /src/shared-modules /src/shared-resources /src/shared-http-cache

COPY entrypoint.sh /src/entrypoint.sh
ENTRYPOINT /src/entrypoint.sh