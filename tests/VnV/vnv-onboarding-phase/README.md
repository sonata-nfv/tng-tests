# Build

make build run-dev

# Execution

docker exec -i docker-robot-container sh -c "robot /docker-robot/tests/onboard_to_sonata.robot"

docker exec -i docker-robot-container sh -c "robot /docker-robot/tests/onboard_to_osm.robot"

# Logs


```
docker cp docker-robot-container:/docker-robot/report.html /host/path/target
docker cp docker-robot-container:/docker-robot/log.html /host/path/target
```

