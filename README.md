# Luminaire1337/mtasa-docker
### Unofficial MTA:SA Server Docker Image
![Docker Pulls](https://img.shields.io/docker/pulls/luminaire/mtasa-docker)
![Docker Stars](https://img.shields.io/docker/stars/luminaire/mtasa-docker)

## Installation
#### Pulling image
```bash
# Pull image directly from Docker Hub
docker pull luminaire/mtasa-docker:latest

## OR

# Build it yourself
docker build -t luminaire/mtasa-docker:latest https://github.com/Luminaire1337/mtasa-docker.git#main
```
#### Running image
```bash
docker run -it \
	-p 22003:22003/udp \
	-p 22005:22005/tcp \
	-p 22126:22126/udp \
	-d luminaire/mtasa-docker:latest
```

## License
Docker image [luminaire/mtasa-docker](https://hub.docker.com/r/luminaire/mtasa-docker) is released under [MIT License](https://github.com/Luminaire1337/mtasa-docker/blob/main/LICENSE).