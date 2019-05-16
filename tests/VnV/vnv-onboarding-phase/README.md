# Build

make build run

# Execution

docker exec -i docker-robot sh -c "robot /docker-robot/tests/onboard_to_sonata.robot"

docker exec -i docker-robot sh -c "robot /docker-robot/tests/onboard_to_osm.robot"



