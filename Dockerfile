FROM debian:buster
MAINTAINER github.com/Luminaire1337
ENV TERM=xterm-256color

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
    libreadline5 \
    libncursesw5 \
    unzip \
    wget

WORKDIR /app
COPY mtasa-install.sh /app/mtasa-install.sh

RUN chmod 700 /app/mtasa-install.sh
RUN bash /app/mtasa-install.sh

EXPOSE 22003/udp 22005/tcp 22126/udp
CMD ["/app/multitheftauto_linux_x64/mta-server64"]