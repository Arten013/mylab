.PHONY: setup, build, rebuild_core
setup:
	make deploy
	make build_core

bup:
	make build
	make up

up:
	docker-compose up -d jupyter

down:
	docker-compose down

deploy:
	mkdir -p ./workspace/.ssh
	mkdir -p ./workspace/develop
	mkdir -p ./workspace/resources

build:
	docker-compose build

rebuild:
	docker-compose build --no-cache

build_core:
	docker build -t mylab_core ./containers/core

rebuild_core:
	docker build -t --no-cache mylab_core ./containers/core

exec:
	docker exec -it mylab_jupyter_1 /bin/bash
