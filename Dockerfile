FROM debian:trixie-slim

LABEL org.opencontainers.image.source=https://github.com/Luminaire1337/mtasa-docker \
      org.opencontainers.image.description="Unofficial MTA:SA Server Docker Image" \
      org.opencontainers.image.licenses=GPL-3.0-only

# Install dependencies and libssl1.1 from Debian Bullseye
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/bullseye.list \
	&& printf "Package: *\nPin: release n=bullseye\nPin-Priority: 100\n" > /etc/apt/preferences.d/bullseye \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates libncursesw6 wget netcat-openbsd \
	&& apt-get install -y --no-install-recommends -t bullseye libssl1.1 \
	&& rm /etc/apt/sources.list.d/bullseye.list /etc/apt/preferences.d/bullseye \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/log/apt/* /var/log/dpkg.log

# Create a non-root user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} mtasa && useradd -u ${UID} -g mtasa -s /usr/sbin/nologin -M mtasa

# Set the working directory
WORKDIR /src

# Create directories for volumes and set permissions
RUN mkdir -p /src/{shared-config,shared-modules,shared-resources,shared-http-cache,shared-databases} \
	&& chown -R mtasa:mtasa /src

# Copy over entrypoint and run scripts and change their permissions
COPY --chown=mtasa:mtasa --chmod=750 ./entrypoint.sh /src/entrypoint.sh
COPY --chown=mtasa:mtasa --chmod=750 ./run.sh /src/run.sh

# Change to the non-root user
USER mtasa

# Download latest MTA:SA server
RUN ARCH=$(dpkg --print-architecture) && \
	ARCH_TYPE=$(if [ "$ARCH" = "amd64" ]; then echo "x64"; else echo "arm64"; fi) && \
	wget -q https://linux.multitheftauto.com/dl/multitheftauto_linux_${ARCH_TYPE}.tar.gz -O /tmp/mtasa.tar.gz && \
	tar -xzf /tmp/mtasa.tar.gz -C /src && \
	mv /src/multitheftauto_linux* /src/server && \
	rm /tmp/mtasa.tar.gz

# Expose ports
EXPOSE 22003/udp 22005/tcp 22126/udp

# Expose volumes for shared data
VOLUME ["/src/shared-config", "/src/shared-modules", "/src/shared-resources", "/src/shared-http-cache", "/src/shared-databases"]

# Add healtcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
	CMD nc -z -u 127.0.0.1 22003 || exit 1

# Set the entrypoint
ENTRYPOINT ["/src/entrypoint.sh"]

# When that's done, run the server
CMD ["/src/run.sh"]