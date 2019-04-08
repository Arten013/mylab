.PHONY: setup, build, rebuild_core
setup:
	make prep_setting
	make deploy
	make build_core

build:
	cp settings/passwords containers/env/passwords
	docker-compose build
	rm containers/env/passwords

rebuild:
	cp settings/passwords containers/env/passwords
	docker-compose build --no-cache
	rm containers/env/passwords

prep_setting:
	python ./scripts/unpack_template.py

deploy:
	mkdir -p ./workspace/.ssh
	mkdir -p ./workspace/develop
	mkdir -p ./workspace/resources
	ln -sf settings/.env .env
	cp ./settings/target_repos.yaml ./workspace/develop/target_repos.yaml
	cp ./scripts/auto_pull.py ./workspace/develop/auto_pull.py

build_core:
	docker build -t mylab_core ./containers/core

rebuild_core:
	docker build -t --no-cache mylab_core ./containers/core

bup:
	make build
	make up

up:
	docker-compose up -d jupyter

down:
	docker-compose down
