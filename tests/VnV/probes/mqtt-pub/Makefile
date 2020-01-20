build-no-cache:
	docker build --no-cache -t easyglobalmarket/mqtt-publisher .
build:
	docker build -t easyglobalmarket/mqtt-publisher .	
push:
	docker push easyglobalmarket/mqtt-publisher	
run:
	docker run --rm -e "IP=192.168.99.100" -e "PORT=1883" -e "TOPIC=test" -e "ROUNDS=20" -e "INTERVAL=10" -e "CLIENTS=100" -e "COUNT=1"  --name mqtt-publisher -d easyglobalmarket/mqtt-publisher
stop:
	docker stop mqtt-pub
	docker rm mqtt-pub
