build:
	docker build -t easyglobalmarket/mqtt-probe2 .
push:
	docker push easyglobalmarket/mqtt-probe2	
run:
	docker run  -e "IP=$(ip)" -e "PORT=$(port)" -e "CLIENTS=$(clients)" -e "COUNT=$(count)" -e "USERNAME=$(username)" -e "PASSWORD=$(password)" --name docker-mqtt-probe --net=egm easyglobalmarket/mqtt-probe2
stop:
	docker stop docker-mqtt-probe
	docker rm docker-mqtt-probe
