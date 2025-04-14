FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/Luminaire1337/mtasa-docker
LABEL org.opencontainers.image.description="Unofficial MTA:SA Server Docker Image"
LABEL org.opencontainers.image.licenses=MIT

# Install dependencies
# Use noninteractive mode to avoid prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade \
	&& apt -y install libreadline8 libncursesw6 unzip wget \
	&& rm -rf /var/lib/apt/lists/*

# Set default permissions
ARG DEFAULT_PERMISSIONS=755

# Create a group and user with the specified IDs
ARG USER_NAME=mtasa
ARG USER_ID=1000
ARG GROUP_NAME=${USER_NAME}
ARG GROUP_ID=${USER_ID}
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} \
	&& useradd -u ${USER_ID} -g ${GROUP_NAME} -m -d /home/${USER_NAME} -s /usr/sbin/nologin ${USER_NAME}

# Set the working directory
WORKDIR /src

# Create directories for volumes and set permissions
RUN mkdir -p /src/shared-config \
	&& mkdir -p /src/shared-modules \
	&& mkdir -p /src/shared-resources \
	&& mkdir -p /src/shared-http-cache \
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
VOLUME ["/src/shared-config", "/src/shared-modules", "/src/shared-resources", "/src/shared-http-cache"]

# Set the entrypoint
ENTRYPOINT ["/src/entrypoint.sh"]

# When that's done, run the server
CMD ["/src/run.sh"]