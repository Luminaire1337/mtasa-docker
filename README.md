# Luminaire1337/mtasa-docker
### Unofficial MTA:SA Server Docker Image

## Installation
#### Pulling image
```bash
# Pull image directly from Docker Hub
docker pull ghcr.io/luminaire1337/mtasa-docker:main

## OR

# Build it yourself
docker build -t ghcr.io/luminaire1337/mtasa-docker:main https://github.com/Luminaire1337/mtasa-docker.git#main
```
#### Running image
```bash
docker run -it \
	-p 22003:22003/udp \
	-p 22005:22005/tcp \
	-p 22126:22126/udp \
	-d ghcr.io/luminaire1337/mtasa-docker:main
```
#### Running image with docker-compose
```yml
version: "3"
   
services:
  mtasa:
    image: ghcr.io/luminaire1337/mtasa-docker:main
    container_name: mtasa
    restart: unless-stopped
    volumes:
        - "./config:/src/shared-config"
        - "./modules:/src/shared-modules"
        - "./resources:/src/shared-resources"
        - "./http-cache:/src/shared-http-cache"
    ports:
        - "22003:22003/udp"
        - "22005:22005/tcp"
        - "22126:22126/udp"
```

## License
Docker image [ghcr.io/luminaire1337/mtasa-docker](https://github.com/Luminaire1337/mtasa-docker) is released under [MIT License](https://github.com/Luminaire1337/mtasa-docker/blob/main/LICENSE).