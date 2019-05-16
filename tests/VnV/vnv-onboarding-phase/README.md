# Build

make build run

# Execution

docker exec -it docker-robot sh -c "robot /docker-robot/tests/onboard_to_sonata.robot"

docker exec -it docker-robot sh -c "robot /docker-robot/tests/onboard_to_osm.robot"



