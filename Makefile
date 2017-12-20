DOCKER_ID_USER = $(whoami)
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H-%M-%SZ)
COMMIT_ID := $(shell git log --pretty=format:'%h' -n 1)
GO_FLAGS := -a -ldflags "-w -X main.buildDate=$(BUILD_DATE) -X main.commitId=$(COMMIT_ID)"

build:
	go build $(GO_FLAGS) .

assemble:
	glide up -v .
	go build -v -o main

buildstatic:
	go build $(GO_FLAGS) -tags netgo .

docker: buildstatic
	@echo "Updating the local Docker image"
	docker build -t instrumented_app:latest .

pushimage: docker
	@echo "Pushing image to $(DOCKER_ID_USER)/instrumented_app"
	docker tag instrumented_app:latest $(DOCKER_ID_USER)/instrumented_app
	docker push $(DOCKER_ID_USER)/instrumented_app
