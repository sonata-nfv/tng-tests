# DOCKER TASKS

build: ## Build the image
		docker image build -t docker-robot .

build-nc: ## Build the image without caching
		docker image build --no-cache -t docker-robot .

run-dev: ## Run container (please replace the host absolute path)
		docker container run -d --rm -i  --net=host --name docker-robot-container --mount type=bind,src=//c/Users/asinatra/Desktop/ECLIPSE_WORKSPACE/tng-tests/tests/VnV/vnv-onboarding-phase/tests,dst=/docker-robot/tests docker-robot 

run-dev: ## Run container (please replace the host absolute path)
		docker container run -d --rm -i  --net=host --name docker-robot-container docker-robot 

up: build run


stop: ## Stop a running container
		docker container stop docker-robot-container

rm: ## Remove a stopped container
		docker container rm docker-robot-container

down: stop rm
