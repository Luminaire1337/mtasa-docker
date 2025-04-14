# Luminaire1337/mtasa-docker

### Unofficial MTA:SA Server Docker Image

This repository provides a Docker container for Multi Theft Auto: San Andreas (MTA:SA) with support for multiple platforms, including `amd64`, `i386`, and `arm64`.

## Getting Started

### Pulling the Image

You can pull the pre-built image directly from GitHub Container Registry:

```bash
docker pull ghcr.io/luminaire1337/mtasa-docker:latest
```

Alternatively, build it yourself from the repository:

```bash
docker build -t ghcr.io/luminaire1337/mtasa-docker:master https://github.com/Luminaire1337/mtasa-docker.git#master
```

### Running the Container

#### Basic Run Command

Run the container with default settings:

```bash
docker run -it \
  -p 22003:22003/udp \
  -p 22005:22005/tcp \
  -p 22126:22126/udp \
  -d ghcr.io/luminaire1337/mtasa-docker:latest
```

#### Docker Compose

You can also use Docker Compose to run the container. Here's an example `docker-compose.yml` file:

```yaml
services:
  mtasa:
    image: ghcr.io/luminaire1337/mtasa-docker:latest
    container_name: mtasa
    restart: unless-stopped
    volumes:
      - ./config:/src/shared-config
      - ./modules:/src/shared-modules
      - ./resources:/src/shared-resources
      - ./http-cache:/src/shared-http-cache
    ports:
      - "22003:22003/udp"
      - "22005:22005/tcp"
      - "22126:22126/udp"
    environment:
      - INSTALL_DEFAULT_RESOURCES=false

  # Optional: HTTP cache server
  # https://wiki.multitheftauto.com/wiki/Installing_and_Configuring_Nginx_as_an_External_Web_Server
  http-cache:
    image: nginx:alpine
    container_name: mtasa-http-cache
    restart: unless-stopped
    volumes:
      - ./http-cache:/usr/share/nginx/html
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "20080:20080/tcp"
```

## Environment Variables

Customize the container by setting these environment variables:

|           Variable            | Default Value |                    Comment                     |
| :---------------------------: | :-----------: | :--------------------------------------------: |
| **INSTALL_DEFAULT_RESOURCES** |     true      | Downloads default resources from MTA:SA mirror |

### Platform Support Notice

This image supports multiple platforms:

- `amd64` (64-bit x86 architecture)
- `i386` (32-bit x86 architecture)
- `arm64` (64-bit ARM architecture)

## License

The Docker image [ghcr.io/luminaire1337/mtasa-docker](https://github.com/Luminaire1337/mtasa-docker) is licensed under the [MIT License](https://github.com/Luminaire1337/mtasa-docker/blob/master/LICENSE).
