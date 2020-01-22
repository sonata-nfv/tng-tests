build-no-cache:
	docker build --no-cache -t easyglobalmarket/mqtt-publisher-rampup .
build:
	docker build -t easyglobalmarket/mqtt-publisher-rampup .	
push:
	docker push easyglobalmarket/mqtt-publisher-rampup	
run:
	docker run --rm -e "IP=192.168.99.100" -e "PORT=1883" -e "TOPIC=test" -e "ROUNDS=20" -e "INTERVAL=10" -e "CLIENTS=5" -e "COUNT=1"  --name mqtt-publisher-rampup -d easyglobalmarket/mqtt-publisher-rampup
stop:
	docker stop mqtt-publisher-rampup
