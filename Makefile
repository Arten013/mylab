prep_setting:
	python ./scripts/unpack_template.py
deploy:
	mkdir -p ./workspace/.ssh
	mkdir -p ./workspace/develop
	mkdir -p ./workspace/resources
	ln -sf settings/.env .env

build_core:
	docker build -t mylab_core ./containers/core

setup:
	make deploy
	make build_core

bup:
	make build
	make up

build:
	cp settings/passwords containers/env/passwords
	docker-compose build
	rm containers/env/passwords

push:
	docker push $(IMAGE)

up:
	docker-compose up -d jupyter ssh_server

down:
	docker-compose down
