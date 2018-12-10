DOCKERHUB_USER = atbell013
IMAGE = $(DOCKERHUB_USER)/mylab


setup:
	mkdir -p ./workspace/.ssh
	mkdir -p ./workspace/develop
	mkdir -p ./workspace/resources
	ln -s ./settings/.env .env
	ln -s ./settings/.jovyan_passwd containers/common/.jovyan_passwd

bup:
	make build
	make up

build:
	docker build -t $(DOCKERHUB_USER)/mylab_env ./containers/common
	docker-compose build

push:
	docker push $(IMAGE)

up:
	docker-compose up jupyter ssh_server

down:
	docker-compose down
