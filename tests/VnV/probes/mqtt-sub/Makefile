build-no-cache:
	docker build --no-cache -t easyglobalmarket/mqtt-subscriber .
build:
	docker build -t easyglobalmarket/mqtt-subscriber .	
push:
	docker push easyglobalmarket/mqtt-subscriber	
run:
	docker run --rm -v /$(pwd)/../res.txt:/output/res.txt -e "IP=192.168.99.100" -e "PORT=1883" -e "TOPIC=test" -e "QOS=2" -e "INTERVAL=200" -e "RESULTS_FILE=/output/res.txt" --name mqtt-subscriber -d  easyglobalmarket/mqtt-subscriber
stop:
	docker stop mqtt-sub
	docker rm mqtt-sub
