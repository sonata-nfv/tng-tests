build-no-cache:
	docker build --no-cache -t easyglobalmarket/mqtt-pub:latest .
build:
	docker build -t easyglobalmarket/mqtt-pub:latest .	
push:
	docker push easyglobalmarket/mqtt-pub:latest	
run:
	docker run --rm -e "IP=192.168.99.100" -e "PORT=1883" -e "TOPIC=WIMMS1/EM63/DATE" -e "ROUNDS=10" -e "INTERVAL=5" -e "CLIENTS=100" -e "COUNT=1"  --name mqtt-pub -d easyglobalmarket/mqtt-pub
stop:
	docker stop mqtt-pub
	docker rm mqtt-pub
