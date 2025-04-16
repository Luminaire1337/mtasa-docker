FROM ubuntu:24.04

LABEL org.opencontainers.image.source=https://github.com/Luminaire1337/mtasa-docker
LABEL org.opencontainers.image.description="Unofficial MTA:SA Server Docker Image"
LABEL org.opencontainers.image.licenses=MIT

# Install dependencies
# Use noninteractive mode to avoid prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade \
	&& apt -y install libreadline-dev libncurses-dev libmysqlclient-dev unzip wget \
	&& rm -rf /var/lib/apt/lists/*

# Check if host is running on amd64 arch, if it is - download libssl1.1 library
RUN if [ "$(uname -m)" = "x86_64" ]; then \
		wget -O /tmp/libssl1.1.deb https://launchpad.net/ubuntu/+archive/primary/+files/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb && \
		dpkg -i /tmp/libssl1.1.deb && \
		rm /tmp/libssl1.1.deb; \
	fi

# Set default permissions
ARG DEFAULT_PERMISSIONS=755

# Use built-in user to Ubuntu images
ARG USER_NAME=ubuntu
ARG GROUP_NAME=${USER_NAME}

# Set the working directory
WORKDIR /src

# Create directories for volumes and set permissions
RUN mkdir -p /src/shared-config \
	&& mkdir -p /src/shared-modules \
	&& mkdir -p /src/shared-resources \
	&& mkdir -p /src/shared-http-cache \
	&& mkdir -p /src/shared-databases \
	&& chown -R ${USER_NAME}:${GROUP_NAME} /src \
	&& chmod -R ${DEFAULT_PERMISSIONS} /src

# Copy over entrypoint and run scripts and change their permissions
COPY --chown=${USER_NAME}:${GROUP_NAME} --chmod=${DEFAULT_PERMISSIONS} ./entrypoint.sh /src/entrypoint.sh
COPY --chown=${USER_NAME}:${GROUP_NAME} --chmod=${DEFAULT_PERMISSIONS} ./run.sh /src/run.sh

# Change to the non-root user
USER ${USER_NAME}

# Expose ports
EXPOSE 22003/udp 22005/tcp 22126/udp

# Expose volumes for shared data
VOLUME ["/src/shared-config", "/src/shared-modules", "/src/shared-resources", "/src/shared-http-cache", "/src/shared-databases"]

# Set the entrypoint
ENTRYPOINT ["/src/entrypoint.sh"]

# When that's done, run the server
CMD ["/src/run.sh"]