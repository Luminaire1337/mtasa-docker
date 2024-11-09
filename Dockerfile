FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/Luminaire1337/mtasa-docker
LABEL org.opencontainers.image.description="Unofficial MTA:SA Server Docker Image"
LABEL org.opencontainers.image.licenses=MIT

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade \
	&& apt -y install libreadline8 libncursesw5 unzip wget \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /src
VOLUME /src/shared-config /src/shared-modules /src/shared-resources /src/shared-http-cache

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

COPY ./run.sh /run.sh
RUN chmod +x /run.sh
EXPOSE 22003/udp 22005/tcp 22126/udp
CMD ["/run.sh"]