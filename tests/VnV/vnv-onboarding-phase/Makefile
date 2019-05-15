# DOCKER TASKS

build: ## Build the image
		docker image build -t docker-robot .

build-nc: ## Build the image without caching
		docker image build --no-cache -t docker-robot .

run: ## Run container
		docker container run -i -t --rm --net=host --name docker-robot-container --mount type=bind,src=$(shell pwd)/tests,dst=/docker-robot/tests docker-robot


up: build run


stop: ## Stop a running container
		docker container stop docker-robot-container

rm: ## Remove a stopped container
		docker container rm docker-robot-container

down: stop rm
