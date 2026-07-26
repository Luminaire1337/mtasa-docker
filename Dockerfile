# Need to use Ubuntu Noble because MTA:SA server requires libmysqlclient21 which is not available in Ubuntu Resolute or Debian Sid
FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/Luminaire1337/mtasa-docker \
      org.opencontainers.image.description="Unofficial MTA:SA Server Docker Image" \
      org.opencontainers.image.licenses=GPL-3.0-only

# Manual binary version injected by GitHub Actions workflow
ARG VERSION=1.7.0-untested-26734

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
	&& apt-get install -y --no-install-recommends libncursesw6 ca-certificates wget unzip netcat-openbsd libmysqlclient21 \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/log/apt/* /var/log/dpkg.log

# Set the working directory
WORKDIR /src

# Create directories for volumes and set permissions
RUN mkdir -p /src/shared-config \
	&& mkdir -p /src/shared-modules \
	&& mkdir -p /src/shared-resources \
	&& mkdir -p /src/shared-http-cache \
	&& mkdir -p /src/shared-databases \
	&& chown -R ubuntu:ubuntu /src

# Copy over entrypoint and run scripts and change their permissions
COPY --chown=ubuntu:ubuntu --chmod=750 ./entrypoint.sh /src/entrypoint.sh
COPY --chown=ubuntu:ubuntu --chmod=750 ./run.sh /src/run.sh

# Change to the non-root user
USER ubuntu

# Download latest MTA:SA server
RUN ARCH=$(dpkg --print-architecture) \
    && ARCH_TYPE=$(if [ "$ARCH" = "amd64" ]; then echo "x64"; else echo "arm64"; fi) \
	# Temporary nightly build download until the official release is available
	&& wget -q https://nightly.multitheftauto.com/multitheftauto_linux_${ARCH_TYPE}-${VERSION}.tar.gz -O /tmp/mtasa.tar.gz \
	&& tar -xzf /tmp/mtasa.tar.gz -C /src \
	&& mv /src/multitheftauto_linux* /src/server \
	&& rm /tmp/mtasa.tar.gz

# Expose ports
EXPOSE 22003/udp 22005/tcp 22126/udp

# Expose volumes for shared data
VOLUME ["/src/shared-config", "/src/shared-modules", "/src/shared-resources", "/src/shared-http-cache", "/src/shared-databases"]

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
	CMD nc -z -u 127.0.0.1 22003 || exit 1

# Set the entrypoint
ENTRYPOINT ["/src/entrypoint.sh"]

# When that's done, run the server
CMD ["/src/run.sh"]