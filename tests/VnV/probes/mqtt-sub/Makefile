build-no-cache:
	docker build --no-cache -t easyglobalmarket/mqtt-sub:latest .
build:
	docker build -t easyglobalmarket/mqtt-sub:latest .	
push:
	docker push easyglobalmarket/mqtt-sub:latest	
run:
	docker run --rm -e "IP=192.168.99.100" -e "PORT=1883" -e "TOPIC=WIMMS1/#" -e "QOS=2"  --name mqtt-sub -d  easyglobalmarket/mqtt-sub
stop:
	docker stop mqtt-sub
	docker rm mqtt-sub
