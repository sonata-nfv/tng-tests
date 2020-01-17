build:
	docker build -t easyglobalmarket/mqtt-constant .
push:
	docker push easyglobalmarket/mqtt-constant	
run:
	docker run  -e "IP=$(ip)" -e "PORT=$(port)" -e "CLIENTS=$(clients)" -e "COUNT=$(count)" -e "SIZE=$(size)" -e "USERNAME=$(username)" -e "PASSWORD=$(password)" --name mqtt-constant --net=egm easyglobalmarket/mqtt-constant
stop:
	docker stop mqtt-constant
	docker rm mqtt-constant
