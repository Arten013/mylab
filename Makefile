deploy:
	mkdir -p ./workspace/.ssh
	mkdir -p ./workspace/develop
	mkdir -p ./workspace/resources
	ln -sf settings/.env .env

build_env:
	cp settings/passwords containers/common/passwords
	docker build -t mylab_env ./containers/common
	rm containers/common/passwords

setup:
	make deploy
	make setup

bup:
	make build
	make up

build:
	docker-compose build

push:
	docker push $(IMAGE)

up:
	docker-compose up -d jupyter ssh_server

down:
	docker-compose down
