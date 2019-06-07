build:
	docker build -t easyglobalmarket/mqtt-probe .
push:
	docker push easyglobalmarket/mqtt-probe	
run:
	docker run  -e "IP=192.168.99.100" -e "PORT=1883" --name docker-mqtt-probe --net=egm easyglobalmarket/mqtt-probe 
stop:
	docker stop docker-mqtt-probe
	docker rm docker-mqtt-probe