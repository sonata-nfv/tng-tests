[![Join the chat at https://gitter.im/sonata-nfv/Lobby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/sonata-nfv/Lobby)

<p align="center"><img src="https://github.com/sonata-nfv/tng-communications-pilot/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# 5GTANGO VnV Tests

# Head-less browser execution

The previous containers can be executed with the following commands:

danielvifal/docker-chromium-rec (docker_chromium-rec folder)

docker run -e WEB="https://rooms.quobis.com" -e CALLED="quobisqa1@quobis" -e PASSWORD="PNrdj3G948WP" -e USER="apps" docker-chromium-rec:latest

danielvifal/docker-chromium (docker_chromium folder)

docker run -e WEB="https://rooms.quobis.com" -e CALLER="quobisqa3@quobis" -e PASSWORD="oWc0n2M84xt2" -e CALLED="quobisqa1" -e DURATION=10000 -e USER="apps" docker-chromium:latest


## Head-less browser results in the VnV

The last one, danielvifal/docker-chromium, writes the ouput in a file avaliable in the following path, due to it is the folder where the VnV reads the outputs and shows them in the test section:

| Folder | Comment |
| --- | --- |
| `/output/${PROBE}/$HOSTNAME/results.log` | Output VnV |

Where:

| Env Variables | Comment |
| --- | --- |
| `${PROBE}` | headless by default |
| `$HOSTNAME` | container ID |

## Check the output file from localhost

If it is neccesary to check the content of the output file results.log, it is possible to copy this file from the container to the host with the following shell command:

docker cp <CONTAINER_ID>:/output/headless/$HOSTNAME /results.log results.log

The next picture, shows an example of the output of the container whose content are the Puppeteer logs, that descrive the evolution of the call, the enviroment variables and the output of the command used to get information asked for the test of the VnV.

## Docker Hub Repositories

danielvifal/docker-chromium-rec (docker_chromium-rec folder)

https://cloud.docker.com/repository/docker/danielvifal/docker-chromium-rec

danielvifal/docker-chromium (docker_chromium folder)

https://cloud.docker.com/repository/docker/danielvifal/docker-chromium

