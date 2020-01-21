build:
	docker build -t easyglobalmarket/mqtt-probe:payload .
push:
	docker push easyglobalmarket/mqtt-probe:payload	
run:
	docker run  -rm -e "IP=$(ip)" -e "PORT=$(port)" -e "CLIENTS=$(clients)" -e "COUNT=$(count)" -e "SIZE=$(size)"  --name mqtt-probe --net=egm easyglobalmarket/mqtt-probe:payload
stop:
	docker stop mqtt-probe
	docker rm mqtt-probe
